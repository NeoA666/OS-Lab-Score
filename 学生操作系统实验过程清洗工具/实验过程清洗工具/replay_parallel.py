"""Recording-level scheduling and durable cache helpers for terminal replay.

The report process owns aggregation and every formal output. A worker owns
exactly one recording cache file and returns a compact status record; the
parent then loads successful analysis data from that cache. Keeping the
boundary this small makes the module safe for Windows' ``spawn`` start method
and avoids copying rendered terminal frames through process pipes.
"""
from __future__ import annotations

import hashlib
import importlib
import json
import multiprocessing as mp
import os
import stat
import tempfile
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path
from typing import Any, Callable, Iterable, Mapping


CACHE_OWNER = "os-lab-terminal-replay"
CACHE_FORMAT_VERSION = 3
CACHE_FILE_SUFFIX = ".recording.json"
DEFAULT_WORKER_CAP = 12
_FAILURE_STATUSES = {"error", "failed", "failure", "失败"}
_MAX_ERROR_LENGTH = 1000


def default_worker_count() -> int:
    """Return the bounded default process count used by the CLI."""
    return max(1, min(DEFAULT_WORKER_CAP, int(os.cpu_count() or 1)))


def normalize_workers(value: Any) -> int:
    """Validate a worker count and return a positive integer."""
    try:
        workers = int(value)
    except (TypeError, ValueError):
        raise ValueError("workers must be a positive integer") from None
    if workers < 1:
        raise ValueError("workers must be a positive integer")
    return workers


def _json_bytes(value: Any) -> bytes:
    return json.dumps(
        value, ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")


def _normalise_relative(value: Any) -> str:
    """Normalize a source-relative identifier without resolving it on disk."""
    text = str(value or "").replace("\\", "/")
    while text.startswith("./"):
        text = text[2:]
    return text.strip("/")


def source_relative_identity(task: Mapping[str, Any]) -> str:
    """Return the source-relative identity retained in cache audit metadata.

    Production callers provide ``source_relative`` as an input-root-relative
    path. The fallbacks retain compatibility with small direct callers while
    avoiding absolute paths in cache metadata whenever a source root is known.
    """
    supplied = _normalise_relative(task.get("source_relative"))
    if supplied:
        return supplied

    out_path = task.get("out_path")
    source_root = task.get("source_root")
    if out_path and source_root:
        try:
            return Path(out_path).resolve().relative_to(Path(source_root).resolve()).as_posix()
        except (OSError, ValueError):
            pass

    recording_id = _normalise_relative(task.get("recording_id"))
    if recording_id:
        return recording_id
    return _normalise_relative(Path(str(out_path or "")).name)


def _source_root_identity(task: Mapping[str, Any]) -> str:
    return _normalise_relative(task.get("source_root_relative"))


def input_digest(path: str | os.PathLike[str] | None) -> str | None:
    """Hash a regular input file; missing files are represented by ``None``."""
    if not path:
        return None
    candidate = Path(path)
    try:
        if _has_link_component(candidate) or not candidate.is_file():
            return None
        digest = hashlib.sha256()
        with candidate.open("rb") as stream:
            for chunk in iter(lambda: stream.read(1024 * 1024), b""):
                digest.update(chunk)
        return digest.hexdigest()
    except OSError:
        return None


def input_file_state(path: str | os.PathLike[str] | None) -> dict[str, Any]:
    """Return a cheap identity token for a task input without opening its data."""
    if not path:
        return {"state": "missing"}
    candidate = Path(path)
    try:
        if _has_link_component(candidate):
            return {"state": "unsafe_link"}
        details = candidate.stat()
    except FileNotFoundError:
        return {"state": "missing"}
    except OSError:
        return {"state": "unreadable"}
    if not stat.S_ISREG(details.st_mode):
        return {"state": "not_regular"}
    return {
        "state": "file",
        "size": int(details.st_size),
        "mtime_ns": int(details.st_mtime_ns),
        "ctime_ns": int(details.st_ctime_ns),
        "device": int(details.st_dev),
        "inode": int(details.st_ino),
    }


def input_file_snapshot(path: str | os.PathLike[str] | None) -> dict[str, Any]:
    """Capture a content hash and reject files that change while it is read."""
    before = input_file_state(path)
    digest = input_digest(path) if before.get("state") == "file" else None
    after = input_file_state(path)
    stable = before == after and (after.get("state") != "file" or digest is not None)
    return {"sha256": digest, "state": after, "stable": stable}


def current_task_input_hashes(task: Mapping[str, Any]) -> dict[str, str | None]:
    """Hash the files currently addressed by a recording task."""
    return {
        "out": input_digest(task.get("out_path")),
        "tim": input_digest(task.get("tim_path")),
    }


def task_input_states_match(task: Mapping[str, Any]) -> bool:
    """Check whether a task still points at the file versions it was hashed from."""
    states = task.get("input_states")
    if not isinstance(states, Mapping):
        return True
    if not bool(task.get("input_stable", True)):
        return False
    return (
        states.get("out") == input_file_state(task.get("out_path"))
        and states.get("tim") == input_file_state(task.get("tim_path"))
    )


def _has_input_state_snapshot(task: Mapping[str, Any]) -> bool:
    """Return whether a task carries the stable state captured with its hash."""
    states = task.get("input_states")
    return isinstance(states, Mapping) and "out" in states and "tim" in states


def task_input_hashes(task: Mapping[str, Any]) -> dict[str, str | None]:
    """Return the immutable input snapshot expected by a recording cache.

    A task may carry precomputed hashes so workers do not hash the same gzip
    pair repeatedly. Otherwise this function computes them from the supplied
    paths. Task creators must replace a precomputed snapshot after changing
    an input file.
    """
    hashes = task.get("input_hashes")
    if isinstance(hashes, Mapping):
        return {
            "out": str(hashes.get("out")) if hashes.get("out") else None,
            "tim": str(hashes.get("tim")) if hashes.get("tim") else None,
        }
    return current_task_input_hashes(task)


def cache_identity(task: Mapping[str, Any]) -> str:
    """Return the durable identity used to reuse a recording across submissions.

    Batch callers set this to a stable student-and-recording identifier. When
    it is absent, the historical source-relative identity remains the cache
    key, preserving compatibility for direct callers.
    """
    return _normalise_relative(task.get("cache_identity"))


def recording_cache_key(task: Mapping[str, Any]) -> str:
    """Build a cache-file key from identity and the immutable input pair.

    The durable identity lets a later full submission reuse an unchanged
    recording.  The input hashes keep two retained submissions for the same
    student from racing over one file when they contain the same recording ID
    with different content.
    """
    stable_identity = cache_identity(task)
    payload = (
        {
            "cache_identity": stable_identity,
            "input_hashes": task_input_hashes(task),
            "timing_state": str(task.get("timing_state") or ""),
        }
        if stable_identity
        else {
            "source_root": _source_root_identity(task),
            "source_relative": source_relative_identity(task),
            "input_hashes": task_input_hashes(task),
            "timing_state": str(task.get("timing_state") or ""),
        }
    )
    return hashlib.sha256(_json_bytes(payload)).hexdigest()


def recording_cache_path(
    cache_root: str | os.PathLike[str], task: Mapping[str, Any]
) -> Path:
    """Return the one cache path owned by a recording task."""
    return Path(cache_root) / (recording_cache_key(task) + CACHE_FILE_SUFFIX)


def _requested_exact(task: Mapping[str, Any]) -> bool:
    mode = str(task.get("replay_mode") or task.get("mode") or "hybrid").lower()
    return mode == "exact" or bool(task.get("need_exact") or task.get("exact"))


def _effective_signature(
    task: Mapping[str, Any], analyzer_signature: str | None
) -> str | None:
    if analyzer_signature is not None:
        return str(analyzer_signature)
    task_signature = task.get("analyzer_signature")
    return str(task_signature) if task_signature is not None else None


def _entry_capabilities(
    result: Mapping[str, Any], task: Mapping[str, Any]
) -> dict[str, bool]:
    raw = result.get("capabilities")
    raw = raw if isinstance(raw, Mapping) else {}
    exact = raw.get("exact_frames")
    if exact is None:
        exact = raw.get("exact")
    if exact is None:
        exact = result.get("exact_frames")
    if exact is None:
        # An exact task is only written after its exact analysis has returned.
        # This default also keeps simple analyzers from creating an unusable
        # exact cache entry when they have no separate capabilities field.
        exact = _requested_exact(task)
    terminal_final = raw.get("terminal_final")
    if terminal_final is None:
        terminal_final = True
    return {
        "terminal_final": bool(terminal_final),
        "exact_frames": bool(exact),
    }


def _cache_capability_satisfies(entry: Mapping[str, Any], task: Mapping[str, Any]) -> bool:
    if not _requested_exact(task):
        return True
    capabilities = entry.get("capabilities")
    if not isinstance(capabilities, Mapping):
        return False
    return bool(capabilities.get("exact_frames") or capabilities.get("exact"))


def _is_failure_result(value: Mapping[str, Any]) -> bool:
    status = value.get("status")
    return isinstance(status, str) and status.strip().lower() in _FAILURE_STATUSES


def cache_entry_valid(
    entry: Any,
    task: Mapping[str, Any],
    analyzer_signature: str | None = None,
) -> bool:
    """Check ownership, identity, hashes, signature, and requested capability."""
    if not isinstance(entry, Mapping):
        return False
    if entry.get("cache_owner") != CACHE_OWNER:
        return False
    if entry.get("cache_format_version") != CACHE_FORMAT_VERSION:
        return False
    if _is_failure_result(entry):
        return False
    if entry.get("cache_key") != recording_cache_key(task):
        return False
    stable_identity = cache_identity(task)
    if entry.get("cache_identity", "") != stable_identity:
        return False
    # A durable identity intentionally permits the same recording to appear
    # below a new submission directory. Its original relative path remains in
    # the entry for audit; hashes and analyzer signature still prove reuse is
    # safe. Legacy callers without a durable identity retain path validation.
    if not stable_identity and entry.get("source_relative") != source_relative_identity(task):
        return False
    if not stable_identity and entry.get("source_root_relative", "") != _source_root_identity(task):
        return False
    signature = _effective_signature(task, analyzer_signature)
    if signature is not None and entry.get("analyzer_signature") != signature:
        return False
    if entry.get("input_hashes") != task_input_hashes(task):
        return False
    return _cache_capability_satisfies(entry, task)


def load_cache_entry(
    cache_root: str | os.PathLike[str],
    task: Mapping[str, Any],
    analyzer_signature: str | None = None,
) -> dict[str, Any] | None:
    """Load one validated analysis cache entry for the parent process."""
    if not task_input_states_match(task):
        return None
    try:
        root = _validated_cache_root(cache_root)
        path = recording_cache_path(root, task)
        if _is_link_like(path) or not path.is_file():
            return None
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, ValueError, TypeError):
        return None
    return dict(value) if cache_entry_valid(value, task, analyzer_signature) else None


def _owned_entry(value: Any, cache_key: str) -> bool:
    """Recognize current entries plus v1 entries written by this module.

    A malformed file, or a JSON file without this schema, is treated as a user
    file even when its name happens to share our suffix. That prevents cache
    cleanup from deleting unrelated material placed in ``.replay-cache``.
    """
    if not isinstance(value, Mapping):
        return False
    if value.get("cache_owner") == CACHE_OWNER:
        return True
    return (
        value.get("cache_format_version") == 1
        and value.get("cache_key") == cache_key
        and isinstance(value.get("source_relative"), str)
        and isinstance(value.get("input_hashes"), Mapping)
    )


def _read_json_object(path: Path) -> dict[str, Any] | None:
    if _is_link_like(path):
        return None
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, ValueError, TypeError):
        return None
    return dict(value) if isinstance(value, Mapping) else None


def _is_link_like(path: Path) -> bool:
    try:
        if path.is_symlink() or (hasattr(path, "is_junction") and path.is_junction()):
            return True
        attributes = getattr(path.lstat(), "st_file_attributes", 0)
        return bool(attributes & getattr(stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0))
    except FileNotFoundError:
        return False
    except OSError:
        return True


def _has_link_component(path: Path) -> bool:
    current = Path(path)
    while True:
        if _is_link_like(current):
            return True
        parent = current.parent
        if parent == current:
            return False
        current = parent


def _validated_cache_root(cache_root: str | os.PathLike[str]) -> Path:
    root = Path(cache_root)
    if _has_link_component(root):
        raise ValueError(f"recording cache root contains a symbolic link or junction: {root}")
    return root


def write_cache_entry(
    cache_root: str | os.PathLike[str],
    task: Mapping[str, Any],
    result: Mapping[str, Any],
    analyzer_signature: str | None = None,
) -> Path:
    """Atomically write a successful analysis result to its unique cache file."""
    if not isinstance(result, Mapping):
        raise TypeError("recording analyzer must return a mapping")
    if _is_failure_result(result):
        raise ValueError("failed recording analysis must not be cached")

    root = _validated_cache_root(cache_root)
    root.mkdir(parents=True, exist_ok=True)
    path = recording_cache_path(root, task)
    signature = _effective_signature(task, analyzer_signature)
    capabilities = _entry_capabilities(result, task)
    if _requested_exact(task) and not capabilities["exact_frames"]:
        raise ValueError("exact recording analysis did not provide exact frames")

    # Do not accidentally replace a valid exact result with a weaker hybrid
    # result if duplicate work was submitted concurrently.
    existing = _read_json_object(path)
    existing_capabilities = existing.get("capabilities") if existing is not None else None
    if (
        existing is not None
        and cache_entry_valid(existing, task, signature)
        and isinstance(existing_capabilities, Mapping)
        and bool(existing_capabilities.get("exact_frames"))
        and not capabilities["exact_frames"]
    ):
        return path

    payload = dict(result)
    payload.update({
        "cache_owner": CACHE_OWNER,
        "cache_format_version": CACHE_FORMAT_VERSION,
        "cache_key": recording_cache_key(task),
        "cache_identity": cache_identity(task),
        "source_relative": source_relative_identity(task),
        "source_root_relative": _source_root_identity(task),
        "input_hashes": task_input_hashes(task),
        "capabilities": capabilities,
    })
    if signature is not None:
        payload["analyzer_signature"] = signature
    else:
        payload.pop("analyzer_signature", None)

    # The temporary lives beside its destination, so os.replace is atomic on
    # Windows and POSIX filesystems. fsync makes completed writes durable
    # before a worker reports success.
    temporary: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", encoding="utf-8", newline="\n", dir=root,
            prefix=".replay-recording-", suffix=".tmp", delete=False,
        ) as stream:
            temporary = Path(stream.name)
            json.dump(payload, stream, ensure_ascii=False, sort_keys=True, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if temporary is not None and temporary.exists():
            try:
                temporary.unlink()
            except OSError:
                pass
    return path


def cleanup_cache(
    cache_root: str | os.PathLike[str],
    active_tasks: Iterable[Mapping[str, Any]],
    *,
    analyzer_signature: str | None = None,
) -> list[str]:
    """Remove obsolete owned entries while preserving foreign cache files."""
    root = _validated_cache_root(cache_root)
    if not root.is_dir():
        return []
    active = {recording_cache_key(task): task for task in active_tasks}
    removed: list[str] = []
    for path in sorted(root.glob("*" + CACHE_FILE_SUFFIX), key=lambda item: item.name):
        if _is_link_like(path):
            continue
        cache_key = path.name[:-len(CACHE_FILE_SUFFIX)]
        entry = _read_json_object(path)
        if not _owned_entry(entry, cache_key):
            continue
        task = active.get(cache_key)
        stale = task is None
        if not stale:
            stale = not cache_entry_valid(entry, task, analyzer_signature)
        if stale:
            try:
                path.unlink()
                removed.append(path.name)
            except OSError:
                pass
    return removed


def _stat_size(path: Any) -> int:
    try:
        return int(Path(path).stat().st_size) if path else 0
    except OSError:
        return 0


def _cost(value: Any, fallback_path: Any) -> int:
    try:
        if value is not None:
            return max(0, int(value))
    except (TypeError, ValueError):
        pass
    return _stat_size(fallback_path)


def task_sort_key(task: Mapping[str, Any]) -> tuple[int, int, str, str]:
    """Schedule expensive recordings first, with deterministic tie breaking."""
    timing_cost = _cost(
        task.get("timing_cost", task.get("timing_bytes")), task.get("tim_path")
    )
    file_cost = _cost(
        task.get("file_size", task.get("out_size")), task.get("out_path")
    )
    return (
        -timing_cost,
        -file_cost,
        str(task.get("student_key") or ""),
        source_relative_identity(task),
    )


def _resolve_analyzer(spec: str | None) -> Callable[[dict[str, Any]], Mapping[str, Any]]:
    if not spec:
        spec = "replay_engine:analyze_recording"
    module_name, separator, attribute_path = spec.partition(":")
    if not separator:
        attribute_path = "analyze_recording"
    target: Any = importlib.import_module(module_name)
    for attribute in attribute_path.split("."):
        target = getattr(target, attribute)
    if not callable(target):
        raise TypeError(f"analyzer is not callable: {spec}")
    return target


def _analyzer_spec(analyzer: Any) -> str | None:
    """Turn a top-level callable into an importable spawn-safe reference."""
    if analyzer is None:
        return "replay_engine:analyze_recording"
    if isinstance(analyzer, str):
        return analyzer
    if not callable(analyzer):
        return None
    module_name = getattr(analyzer, "__module__", None)
    qualname = getattr(analyzer, "__qualname__", None)
    if not module_name or not qualname or "<locals>" in qualname:
        return None
    try:
        resolved: Any = importlib.import_module(module_name)
        for attribute in qualname.split("."):
            resolved = getattr(resolved, attribute)
    except (AttributeError, ImportError):
        return None
    return f"{module_name}:{qualname}" if resolved is analyzer else None


def _short_error(exc: BaseException) -> str:
    text = f"{type(exc).__name__}: {exc}".strip()
    return text[:_MAX_ERROR_LENGTH]


def _status(
    task: Mapping[str, Any],
    status: str,
    *,
    cache_hit: bool,
    error: str | None = None,
) -> dict[str, Any]:
    """Return the small, JSON-compatible record that crosses process bounds."""
    value: dict[str, Any] = {
        "cache_key": recording_cache_key(task),
        "recording_id": task.get("recording_id"),
        "source_relative": source_relative_identity(task),
        "status": status,
        "cache_hit": cache_hit,
    }
    if error:
        value["error"] = error[:_MAX_ERROR_LENGTH]
    return value


def _worker_entry(payload: tuple[dict[str, Any], str | None, str | None]) -> dict[str, Any]:
    """Top-level entry point used under the Windows ``spawn`` context."""
    task, analyzer_spec, analyzer_signature = payload
    try:
        cache_root = task.get("cache_root")
        if not cache_root:
            raise ValueError("recording task is missing cache_root")
        signature = _effective_signature(task, analyzer_signature)
        if not task_input_states_match(task):
            return _status(
                task, "error", cache_hit=False,
                error="input_changed_before_analysis",
            )
        before_hashes: dict[str, str | None] | None = None
        # New task producers pass the state captured while hashing.  Comparing
        # that cheap token before and after analysis avoids reading each gzip
        # pair two more times in every cold-cache worker.  Direct legacy
        # callers without a state snapshot retain full-hash verification.
        if not _has_input_state_snapshot(task):
            expected_hashes = task_input_hashes(task)
            before_hashes = current_task_input_hashes(task)
            if before_hashes != expected_hashes:
                return _status(
                    task, "error", cache_hit=False,
                    error="input_changed_before_analysis",
                )
        if not task.get("_force_cache_refresh"):
            cached = load_cache_entry(cache_root, task, signature)
            if cached is not None:
                return _status(task, "cache_hit", cache_hit=True)
        analyzer = _resolve_analyzer(analyzer_spec)
        result = analyzer(task)
        if not isinstance(result, Mapping):
            raise TypeError("recording analyzer must return a mapping")
        if _is_failure_result(result):
            message = str(result.get("error") or result.get("message") or "analyzer reported failure")
            return _status(task, "error", cache_hit=False, error=message)
        if not task_input_states_match(task):
            return _status(
                task, "error", cache_hit=False,
                error="input_changed_during_analysis",
            )
        if before_hashes is not None and current_task_input_hashes(task) != before_hashes:
            return _status(
                task, "error", cache_hit=False,
                error="input_changed_during_analysis",
            )
        write_cache_entry(cache_root, task, result, signature)
        return _status(task, "completed", cache_hit=False)
    except Exception as exc:  # A broken recording must not terminate its batch.
        return _status(task, "error", cache_hit=False, error=_short_error(exc))


def _cache_root_for_task(
    task: Mapping[str, Any], cache_root: str | os.PathLike[str] | None
) -> str | None:
    root = cache_root if cache_root is not None else task.get("cache_root")
    return str(Path(root)) if root else None


def run_recording_tasks(
    tasks: Iterable[Mapping[str, Any]],
    *,
    workers: int | None = None,
    analyzer: Any = None,
    analyzer_signature: str | None = None,
    cache_root: str | os.PathLike[str] | None = None,
    force: bool = False,
) -> list[dict[str, Any]]:
    """Run recording tasks with a Windows-spawn process pool.

    Successful entries are written to ``cache_root`` and represented only by a
    compact status. Call :func:`load_cache_entry` in the parent after this
    function returns to obtain the full analysis object. Return order always
    matches the caller's input order, even though work is scheduled by cost.
    """
    normalized = [dict(task) for task in tasks]
    if not normalized:
        return []
    count = default_worker_count() if workers is None else normalize_workers(workers)

    for task in normalized:
        root = _cache_root_for_task(task, cache_root)
        if root is None:
            raise ValueError("recording tasks require cache_root")
        task["cache_root"] = str(_validated_cache_root(root))
        if force or task.get("force"):
            task["_force_cache_refresh"] = True

    analyzer_spec = _analyzer_spec(analyzer)
    indexed = list(enumerate(normalized))
    ordered = sorted(indexed, key=lambda item: task_sort_key(item[1]))
    results: dict[int, dict[str, Any]] = {}
    grouped: dict[tuple[str, str], tuple[dict[str, Any], list[int]]] = {}

    # Several retained full submissions can carry byte-identical recordings.
    # They intentionally share one cache key.  Submit one representative so a
    # hybrid task cannot race an exact task and overwrite the stronger result.
    # The deterministic scheduling order also makes cache audit metadata
    # stable when more than one source path refers to the same recording.
    for index, task in ordered:
        if not task_input_states_match(task):
            results[index] = _status(
                task, "error", cache_hit=False,
                error="input_changed_before_cache_lookup",
            )
            continue
        group_key = (task["cache_root"], recording_cache_key(task))
        group = grouped.get(group_key)
        if group is None:
            grouped[group_key] = (task, [index])
            continue
        representative, indices = group
        indices.append(index)
        if _requested_exact(task):
            representative["need_exact"] = True
        if task.get("_force_cache_refresh"):
            representative["_force_cache_refresh"] = True

    pending: list[tuple[list[int], dict[str, Any]]] = []

    # Loading is intentionally parent-side as well as worker-side. It avoids
    # spawning Python processes for a warm batch, and it gives the parent the
    # exact cache object it will later use to render reports.
    for task, indices in grouped.values():
        signature = _effective_signature(task, analyzer_signature)
        if not task.get("_force_cache_refresh"):
            cached = load_cache_entry(task["cache_root"], task, signature)
            if cached is not None:
                for index in indices:
                    original = normalized[index]
                    results[index] = _status(original, "cache_hit", cache_hit=True)
                continue
        pending.append((indices, task))

    if analyzer is not None and analyzer_spec is None:
        for indices, task in pending:
            for index in indices:
                results[index] = _status(
                    normalized[index],
                    "error",
                    cache_hit=False,
                    error="analyzer must be a top-level importable callable under spawn",
                )
        return [results[index] for index in range(len(normalized))]

    if not pending:
        return [results[index] for index in range(len(normalized))]

    context = mp.get_context("spawn")
    try:
        with ProcessPoolExecutor(max_workers=count, mp_context=context) as pool:
            futures = {
                pool.submit(
                    _worker_entry,
                    (task, analyzer_spec, _effective_signature(task, analyzer_signature)),
                ): (indices, task)
                for indices, task in pending
            }
            for future in as_completed(futures):
                indices, task = futures[future]
                try:
                    group_status = dict(future.result())
                except Exception as exc:  # Executor failures remain per-task diagnostics.
                    group_status = _status(
                        task, "error", cache_hit=False, error=_short_error(exc)
                    )
                for index in indices:
                    original = normalized[index]
                    results[index] = _status(
                        original,
                        str(group_status.get("status") or "error"),
                        cache_hit=bool(group_status.get("cache_hit")),
                        error=str(group_status["error"]) if group_status.get("error") else None,
                    )
    except Exception as exc:
        message = _short_error(exc)
        for indices, task in pending:
            for index in indices:
                results.setdefault(
                    index,
                    _status(normalized[index], "error", cache_hit=False, error=message),
                )

    return [results[index] for index in range(len(normalized))]


__all__ = [
    "CACHE_OWNER", "CACHE_FORMAT_VERSION", "CACHE_FILE_SUFFIX",
    "DEFAULT_WORKER_CAP", "default_worker_count", "normalize_workers",
    "source_relative_identity", "cache_identity", "input_digest", "task_input_hashes",
    "input_file_state", "input_file_snapshot", "current_task_input_hashes",
    "task_input_states_match",
    "recording_cache_key", "recording_cache_path", "cache_entry_valid",
    "load_cache_entry", "write_cache_entry", "cleanup_cache", "task_sort_key",
    "run_recording_tasks",
]
