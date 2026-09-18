from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .client import OpenAICompatibleChatClient, OpenAICompatibleConfig
from .errors import AuditError
from .integrity_assessment import stable_fingerprint
from .loop import (
    AuditAgentLoop,
    PROMPT_VERSION,
    VALIDATION_VERSION,
    _host_owned_assessment,
    _trace_safe,
)
from .policy import PolicyDocument
from .report import (
    render_report,
    render_teacher_review_report,
    write_report,
    write_teacher_review_report,
)
from .repository import StudentAuditRepository
from .rules import default_rule_registry
from .tools import AuditTools
from .validation import AssessmentValidator


def _workspace_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _project_root() -> Path:
    """Return the repository root containing the cleaning pipeline."""

    return Path(__file__).resolve().parents[3]


def _defaults() -> dict[str, Path]:
    system_root = _workspace_root()
    project_root = _project_root()
    return {
        "data_root": project_root / "操作系统实验数据清洗" / "操作系统实验数据记录-已清洗",
        "policy": system_root / "lab0课程规则边界.md",
        "output_dir": system_root / "诚信审核报告草稿",
        "teacher_output_dir": system_root / "教师复核报告草稿",
        "trace_dir": system_root / "诚信审核运行日志",
    }


def _add_common_input_options(parser: argparse.ArgumentParser) -> None:
    defaults = _defaults()
    parser.add_argument("--data-root", type=Path, default=defaults["data_root"], help="清洗数据根目录")
    parser.add_argument("--policy", type=Path, default=defaults["policy"], help="Lab0 审核规则 Markdown")


def _add_report_output_options(parser: argparse.ArgumentParser) -> None:
    defaults = _defaults()
    parser.add_argument("--output-dir", type=Path, default=defaults["output_dir"])
    parser.add_argument("--teacher-output-dir", type=Path, default=defaults["teacher_output_dir"])


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Lab0 诚信审核 Agent Loop")
    subcommands = parser.add_subparsers(dest="command", required=True)

    students = subcommands.add_parser("students", help="列出可处理的学生目录")
    students.add_argument("--data-root", type=Path, default=_defaults()["data_root"])

    inspect = subcommands.add_parser("inspect", help="查看单个学生单个 lab 的清洗数据范围")
    _add_common_input_options(inspect)
    inspect.add_argument("--student", required=True, help="学生目录名或学号")
    inspect.add_argument("--lab", default="lab0", help="实验标签，默认 lab0")

    audit = subcommands.add_parser("audit", help="运行模型工具循环并生成审核草稿")
    _add_common_input_options(audit)
    audit.add_argument("--student", required=True, help="学生目录名或学号")
    audit.add_argument("--lab", default="lab0", help="实验标签，默认 lab0")
    audit.add_argument("--baseline-manifest", type=Path, help="可选的已发布基线哈希清单")
    _add_report_output_options(audit)
    audit.add_argument("--trace-dir", type=Path, default=_defaults()["trace_dir"])
    audit.add_argument("--max-turns", type=int, default=20)
    audit.add_argument(
        "--dry-run",
        action="store_true",
        help="只验证输入和规则，不调用模型或写入报告",
    )

    batch = subcommands.add_parser(
        "batch",
        aliases=["audit-batch"],
        help="批量运行多个学生和实验标签，并按任务隔离失败",
    )
    _add_common_input_options(batch)
    batch.add_argument(
        "--student",
        action="append",
        default=[],
        help="精确筛选学生目录名或学号；可重复使用，省略时处理全部学生",
    )
    batch.add_argument(
        "--lab",
        action="append",
        default=[],
        help="实验标签；可重复使用，省略时默认为 lab0",
    )
    batch.add_argument(
        "--all-labs",
        action="store_true",
        help="从所选学生的时间线文件中发现全部 labN（与 --lab 互斥）",
    )
    batch.add_argument("--baseline-manifest", type=Path, help="可选的已发布基线哈希清单")
    _add_report_output_options(batch)
    batch.add_argument("--trace-dir", type=Path, default=_defaults()["trace_dir"])
    batch.add_argument("--max-turns", type=int, default=20)
    batch.add_argument("--batch-id", help="批次目录名；省略时使用 UTC 时间生成")
    batch.add_argument(
        "--dry-run",
        action="store_true",
        help="只检查任务清单，不调用模型或写入报告/汇总",
    )
    batch.add_argument(
        "--resume",
        action="store_true",
        help="复用输入未变化的已完成任务，并保留失败任务等待重试",
    )
    batch.add_argument(
        "--retry-failed",
        action="store_true",
        help="配合 --resume 重新运行上次失败的任务",
    )
    batch.add_argument(
        "--force",
        action="store_true",
        help="忽略缓存，强制重新调用模型",
    )

    render_trace = subcommands.add_parser("render-trace", help="从已验证运行日志重新生成两份报告")
    _add_common_input_options(render_trace)
    render_trace.add_argument("--student", required=True, help="学生目录名或学号")
    render_trace.add_argument("--lab", default="lab0", help="实验标签，默认 lab0")
    render_trace.add_argument("--trace", type=Path, required=True, help="包含 validated_assessment 的 JSONL 日志")
    _add_report_output_options(render_trace)
    render_trace.add_argument("--trace-dir", type=Path, default=_defaults()["trace_dir"])
    return parser


def _make_repository(args: argparse.Namespace) -> StudentAuditRepository:
    return StudentAuditRepository(args.data_root, args.student, args.lab)


def _json_print(value: dict[str, Any]) -> None:
    print(json.dumps(value, ensure_ascii=False, indent=2))


AUDIT_MANIFEST_SCHEMA = "integrity-audit-manifest/v1"
BATCH_SUMMARY_SCHEMA = "integrity-audit-batch/v1"
REPORT_TEMPLATE_VERSION = "integrity-report-template/v3"
CACHE_SCHEMA = "integrity-audit-cache/v1"


def _safe_component(value: str | None, fallback: str) -> str:
    text = str(value or "").strip()
    cleaned = "".join(
        character if (character.isalnum() or character in "-_.") else "_"
        for character in text
    ).strip(".")
    return cleaned[:160] or fallback


def _task_log_root(trace_root: Path, repository: StudentAuditRepository) -> Path:
    """Return the stable per-student/per-lab log directory."""

    return (
        Path(trace_root)
        / _safe_component(repository.reference.directory_name, "student")
        / _safe_component(repository.lab, "lab")
    )


def _atomic_write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            newline="\n",
            dir=path.parent,
            prefix=".audit-",
            suffix=".tmp",
            delete=False,
        ) as stream:
            temporary = Path(stream.name)
            stream.write(text)
        os.replace(temporary, path)
    finally:
        if temporary is not None and temporary.exists():
            temporary.unlink()


def _atomic_write_json(path: Path, value: Any) -> None:
    _atomic_write_text(path, json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n")


def _sha256(path: Path) -> str | None:
    if not path.is_file():
        return None
    digest = hashlib.sha256()
    try:
        with path.open("rb") as stream:
            for block in iter(lambda: stream.read(1024 * 1024), b""):
                digest.update(block)
    except OSError:
        return None
    return digest.hexdigest()


def _input_snapshot(repository: StudentAuditRepository) -> list[dict[str, Any]]:
    """Capture file identities used by this task without copying materials."""

    file_snapshot: list[dict[str, Any]] = []
    try:
        inventory = repository.inventory()
    except AuditError:
        inventory = {"artifacts": []}
    relative_paths = {
        "实验过程时间线/" + f"timeline_{repository.lab}.json",
        "AI人工贡献识别/assessment/" + f"assessment_{repository.lab}.json",
        "代码差异报告/" + f"{repository.lab}.md",
    }
    for artifact in inventory.get("artifacts", []):
        if isinstance(artifact, dict) and isinstance(artifact.get("relative_path"), str):
            relative_paths.add(artifact["relative_path"])
    for relative in sorted(relative_paths):
        path = repository.student_dir / relative
        available = path.is_file()
        size: int | None = None
        if available:
            try:
                size = path.stat().st_size
            except OSError:
                available = False
        file_snapshot.append(
            {
                "relative_path": relative,
                "available": available,
                "sha256": _sha256(path) if available else None,
                "size": size,
            }
        )
    # The v3 manifest is itself an input, and may name source paths that are
    # not part of the legacy artifact layout.  Include those exact paths in
    # the fingerprint without parsing any upstream Markdown report.
    try:
        from .v3_adapter import ContributionAssessmentV3Adapter

        v3_snapshot = ContributionAssessmentV3Adapter(repository.data_root).load(
            repository.reference.directory_name, repository.lab
        )
        for source in v3_snapshot.source_manifest:
            relative = source.relative_path
            if not isinstance(relative, str) or not relative or relative in relative_paths:
                continue
            path = repository.student_dir / relative
            available = path.is_file()
            size: int | None = None
            if available:
                try:
                    size = path.stat().st_size
                except OSError:
                    available = False
            file_snapshot.append(
                {
                    "relative_path": relative,
                    "available": available,
                    "sha256": _sha256(path) if available else None,
                    "size": size,
                    "source_id": source.source_id,
                }
            )
    except Exception:
        # Missing/incompatible v3 data is represented by the assessment JSON
        # entry above; it must not make batch discovery abort.
        pass
    file_snapshot.sort(key=lambda item: (str(item.get("relative_path")), str(item.get("source_id", ""))))
    return file_snapshot


def _provider_fingerprint() -> dict[str, Any]:
    """Read non-secret model settings for cache identity."""

    return {
        "endpoint": os.environ.get("NVIDIA_API_BASE_URL", "https://integrate.api.nvidia.com/v1"),
        "model": os.environ.get("NVIDIA_MODEL", "nvidia/nemotron-3-super-120b-a12b"),
        "max_tokens": os.environ.get("NVIDIA_MAX_TOKENS", "32768"),
        "temperature": os.environ.get("NVIDIA_TEMPERATURE", "1.0"),
        "top_p": os.environ.get("NVIDIA_TOP_P", "0.95"),
        "enable_thinking": True,
        "force_nonempty_content": True,
    }


def _fingerprint_model(descriptor: dict[str, Any] | None = None) -> Any:
    """Create a no-network model-shaped object for host recomputation."""

    values = descriptor or _provider_fingerprint()

    class DescriptorModel:
        def __init__(self) -> None:
            self.config = type("Config", (), {})()
            self.config.base_url = values.get("endpoint")
            self.config.model = values.get("model")
            try:
                self.config.max_tokens = int(values.get("max_tokens", 32768))
            except (TypeError, ValueError):
                self.config.max_tokens = 32768
            try:
                self.config.temperature = float(values.get("temperature", 1.0))
            except (TypeError, ValueError):
                self.config.temperature = 1.0
            try:
                self.config.top_p = float(values.get("top_p", 0.95))
            except (TypeError, ValueError):
                self.config.top_p = 0.95
            self.config.enable_thinking = bool(values.get("enable_thinking", True))
            self.config.force_nonempty_content = bool(values.get("force_nonempty_content", True))

    return DescriptorModel()


def _task_fingerprint(
    repository: StudentAuditRepository,
    policy: PolicyDocument,
    *,
    model_descriptor: dict[str, Any] | None = None,
    baseline_manifest: Path | None = None,
) -> str:
    baseline_hash = _sha256(baseline_manifest) if baseline_manifest else None
    payload = {
        "cache_schema": CACHE_SCHEMA,
        "student_directory": repository.reference.directory_name,
        "student_id": repository.reference.student_id,
        "lab": repository.lab,
        "policy_sha256": policy.sha256,
        "rule_registry_sha256": default_rule_registry(policy.path).sha256,
        "input_snapshot": _input_snapshot(repository),
        "baseline_sha256": baseline_hash,
        "prompt_version": PROMPT_VERSION,
        "validation_version": VALIDATION_VERSION,
        "v3_schema": "ai-human-contribution-assessment/v3",
        "model": model_descriptor or _provider_fingerprint(),
    }
    return stable_fingerprint(payload)


def _render_fingerprint(assessment: dict[str, Any]) -> str:
    return stable_fingerprint(
        {
            "template_version": REPORT_TEMPLATE_VERSION,
            "assessment_run_fingerprint": assessment.get("run_fingerprint"),
            "integrity_run_fingerprint": (
                assessment.get("integrity_assessment", {}).get("run_fingerprint")
                if isinstance(assessment.get("integrity_assessment"), dict)
                else None
            ),
        }
    )


def _with_render_fingerprint(assessment: dict[str, Any]) -> dict[str, Any]:
    value = dict(assessment)
    fingerprint = _render_fingerprint(value)
    value["render_fingerprint"] = fingerprint
    nested = value.get("integrity_assessment")
    if isinstance(nested, dict):
        nested_copy = dict(nested)
        nested_copy["render_fingerprint"] = fingerprint
        value["integrity_assessment"] = nested_copy
    return value


def _write_audit_artifacts(
    *,
    repository: StudentAuditRepository,
    policy: PolicyDocument,
    assessment: dict[str, Any],
    run_metadata: dict[str, Any],
    trace_root: Path,
    report_path: Path,
    teacher_report_path: Path,
    task_fingerprint: str | None = None,
    render_fingerprint: str | None = None,
    status: str = "complete",
) -> tuple[Path, Path]:
    """Persist the current assessment and its non-secret run manifest."""

    assessment = _trace_safe(assessment)
    task_root = _task_log_root(trace_root, repository)
    assessment_path = task_root / "assessment.json"
    manifest_path = task_root / "audit_manifest.json"
    _atomic_write_json(assessment_path, assessment)
    manifest = {
        "schema_version": AUDIT_MANIFEST_SCHEMA,
        "cache_schema": CACHE_SCHEMA,
        "status": status,
        "student": {
            "directory_name": repository.reference.directory_name,
            "student_id": repository.reference.student_id,
        },
        "lab": repository.lab,
        "policy_sha256": policy.sha256,
        "rule_registry_sha256": default_rule_registry(policy.path).sha256,
        "input_snapshot": _input_snapshot(repository),
        "input_fingerprint": task_fingerprint,
        "run_fingerprint": (
            assessment.get("run_fingerprint")
            or (
                assessment.get("integrity_assessment", {}).get("run_fingerprint")
                if isinstance(assessment.get("integrity_assessment"), dict)
                else None
            )
        ),
        "render_fingerprint": render_fingerprint or assessment.get("render_fingerprint"),
        "assessment_path": str(assessment_path),
        "report_path": str(report_path),
        "teacher_report_path": str(teacher_report_path),
        "trace_path": run_metadata.get("trace_path"),
        "turns": run_metadata.get("turns"),
        "tool_calls": run_metadata.get("tool_calls"),
        "completed_at": datetime.now(timezone.utc).isoformat(),
    }
    _atomic_write_json(manifest_path, manifest)
    return assessment_path, manifest_path


def _load_trace_assessment(
    trace_path: Path,
    repository: StudentAuditRepository,
    policy: PolicyDocument,
) -> tuple[dict[str, Any], dict[str, Any]]:
    if not trace_path.is_file():
        raise AuditError(f"运行日志不存在：{trace_path}")

    assessment: dict[str, Any] | None = None
    turns = 0
    tool_calls = 0
    for line_number, line in enumerate(trace_path.read_text(encoding="utf-8").splitlines(), start=1):
        if not line.strip():
            continue
        try:
            record = json.loads(line)
        except json.JSONDecodeError as error:
            raise AuditError(f"运行日志第 {line_number} 行不是合法 JSON") from error
        if not isinstance(record, dict):
            continue
        if record.get("event") == "model_response":
            turns += 1
        elif record.get("event") == "tool_result":
            tool_calls += 1
        elif record.get("event") == "validated_assessment":
            payload = record.get("payload")
            if isinstance(payload, dict):
                assessment = payload

    if assessment is None:
        raise AuditError("运行日志中没有通过宿主校验的 assessment")
    if assessment.get("lab") != repository.lab:
        raise AuditError("运行日志的实验标签与当前 --lab 不一致")
    if assessment.get("student_id") != repository.reference.student_id:
        raise AuditError("运行日志的学生标识与当前 --student 不一致")
    if assessment.get("policy_sha256") != policy.sha256:
        raise AuditError("运行日志的规则版本与当前规则文件不一致")

    tools = AuditTools(repository, policy)
    validated = AssessmentValidator(
        repository, policy, contribution_snapshot=tools.contribution_snapshot
    ).validate(assessment)
    # Recompute the host-owned nested contract from the validated candidate;
    # trace records are inputs for rendering, never an authority for labels.
    recomputed = _host_owned_assessment(
        candidate=validated,
        repository=repository,
        policy=policy,
        tools=tools,
        model=_fingerprint_model(_provider_fingerprint()),
    )
    return recomputed, {"turns": turns, "tool_calls": tool_calls, "trace_path": str(trace_path)}


def _write_reports(
    assessment: dict[str, Any],
    repository: StudentAuditRepository,
    policy: PolicyDocument,
    run_metadata: dict[str, Any],
    output_dir: Path,
    teacher_output_dir: Path,
) -> tuple[Path, Path]:
    rendered = _with_render_fingerprint(assessment)
    assessment.clear()
    assessment.update(rendered)
    full_report = render_report(assessment, repository, policy, run_metadata)
    teacher_report = render_teacher_review_report(assessment, repository, policy, run_metadata)
    return (
        write_report(output_dir, repository, full_report),
        write_teacher_review_report(teacher_output_dir, repository, teacher_report),
    )


def _repository_has_material(repository: StudentAuditRepository) -> bool:
    """Return whether a student/lab has any currently readable input."""

    if repository.has_lab_data():
        return True
    try:
        inventory = repository.inventory()
    except AuditError:
        return False
    return any(
        isinstance(item, dict) and item.get("available") is True
        for item in inventory.get("artifacts", [])
    )


def _contribution_inventory(tools: AuditTools) -> dict[str, Any]:
    """Expose the bounded v3 inventory in inspect/dry-run output."""

    snapshot = tools.contribution_snapshot
    if snapshot is None:
        return {
            "assessment_available": False,
            "analysis_status": "unavailable",
            "schema_compatible": False,
            "unit_count": 0,
            "valid_unit_ids": [],
            "invalid_unit_ids": [],
            "issues": ["当前任务没有可读取的 v3 assessment"],
        }
    return snapshot.inventory()


def _read_json_file(path: Path) -> dict[str, Any] | None:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError):
        return None
    return value if isinstance(value, dict) else None


def _cached_task_row(
    *,
    repository: StudentAuditRepository,
    policy: PolicyDocument,
    expected_fingerprint: str,
    trace_root: Path,
    output_dir: Path,
    teacher_output_dir: Path,
    baseline_manifest: Path | None,
    model_descriptor: dict[str, Any],
) -> dict[str, Any] | None:
    """Reuse and re-render a completed or no-material task whose inputs match."""

    task_root = _task_log_root(trace_root, repository)
    manifest_path = task_root / "audit_manifest.json"
    manifest = _read_json_file(manifest_path)
    if not manifest or manifest.get("input_fingerprint") != expected_fingerprint:
        return None
    if manifest.get("status") not in {"complete", "missing"}:
        return None
    assessment_path = task_root / "assessment.json"
    cached = _read_json_file(assessment_path)
    if cached is None:
        return None
    try:
        tools = AuditTools(repository, policy, baseline_manifest)
        validated = AssessmentValidator(
            repository, policy, contribution_snapshot=tools.contribution_snapshot
        ).validate(cached)
        recomputed = _host_owned_assessment(
            candidate=validated,
            repository=repository,
            policy=policy,
            tools=tools,
            model=_fingerprint_model(model_descriptor),
        )
        report_path, teacher_report_path = _write_reports(
            assessment=recomputed,
            repository=repository,
            policy=policy,
            run_metadata={
                "turns": manifest.get("turns", "缓存命中"),
                "tool_calls": manifest.get("tool_calls", "缓存命中"),
                "trace_path": manifest.get("trace_path"),
            },
            output_dir=output_dir,
            teacher_output_dir=teacher_output_dir,
        )
        assessment_path, new_manifest_path = _write_audit_artifacts(
            repository=repository,
            policy=policy,
            assessment=recomputed,
            run_metadata={
                "turns": manifest.get("turns"),
                "tool_calls": manifest.get("tool_calls"),
                "trace_path": manifest.get("trace_path"),
            },
            trace_root=trace_root,
            report_path=report_path,
            teacher_report_path=teacher_report_path,
            task_fingerprint=expected_fingerprint,
            render_fingerprint=recomputed.get("render_fingerprint"),
            status=str(manifest.get("status", "complete")),
        )
    except Exception:
        return None
    return {
        "student_directory": repository.reference.directory_name,
        "student_id": repository.reference.student_id,
        "lab": repository.lab,
        "status": "cached",
        "overall_disposition": recomputed.get("overall_disposition"),
        "overall_label": recomputed.get("overall_label"),
        "integrity_disposition": recomputed.get("integrity_disposition"),
        "run_fingerprint": recomputed.get("run_fingerprint"),
        "input_fingerprint": expected_fingerprint,
        "report": str(report_path),
        "teacher_review_report": str(teacher_report_path),
        "assessment": str(assessment_path),
        "audit_manifest": str(new_manifest_path),
        "trace": manifest.get("trace_path"),
    }


def _cached_failure_manifest(trace_root: Path, repository: StudentAuditRepository) -> dict[str, Any] | None:
    return _read_json_file(_task_log_root(trace_root, repository) / "audit_manifest.json")


def _write_failure_artifact(
    *,
    repository: StudentAuditRepository,
    policy: PolicyDocument,
    trace_root: Path,
    task_fingerprint: str,
    message: str,
) -> Path:
    task_root = _task_log_root(trace_root, repository)
    path = task_root / "audit_manifest.json"
    _atomic_write_json(
        path,
        {
            "schema_version": AUDIT_MANIFEST_SCHEMA,
            "cache_schema": CACHE_SCHEMA,
            "status": "failed",
            "student": {
                "directory_name": repository.reference.directory_name,
                "student_id": repository.reference.student_id,
            },
            "lab": repository.lab,
            "policy_sha256": policy.sha256,
            "rule_registry_sha256": default_rule_registry(policy.path).sha256,
            "input_snapshot": _input_snapshot(repository),
            "input_fingerprint": task_fingerprint,
            "error": _trace_safe(str(message))[:2000],
            "completed_at": datetime.now(timezone.utc).isoformat(),
        },
    )
    return path


def _run_audit_task(
    *,
    repository: StudentAuditRepository,
    policy: PolicyDocument,
    model: OpenAICompatibleChatClient | None,
    baseline_manifest: Path | None,
    max_turns: int,
    trace_root: Path,
    output_dir: Path,
    teacher_output_dir: Path,
    task_fingerprint: str | None = None,
    dry_run: bool = False,
) -> dict[str, Any]:
    """Run one student/lab task and return a JSON-safe result row."""

    identity = {
        "student_directory": repository.reference.directory_name,
        "student_id": repository.reference.student_id,
        "lab": repository.lab,
    }
    if dry_run:
        tools = AuditTools(repository, policy, baseline_manifest)
        return {
            **identity,
            "status": "dry-run",
            "inventory": repository.inventory(),
            "data_quality": repository.data_quality(),
            "baseline": repository.baseline_status(baseline_manifest),
            "contribution": _contribution_inventory(tools),
            "input_fingerprint": task_fingerprint,
        }
    if model is None:
        raise AuditError("批处理任务缺少模型客户端")

    tools = AuditTools(repository, policy, baseline_manifest)
    task_trace_dir = _task_log_root(trace_root, repository) / "runs"
    result = AuditAgentLoop(
        model=model,
        repository=repository,
        policy=policy,
        tools=tools,
        max_turns=max_turns,
        trace_dir=task_trace_dir,
    ).run()
    run_metadata = {
        "turns": result.turns,
        "tool_calls": result.tool_calls,
        "trace_path": result.trace_path,
    }
    report_path, teacher_report_path = _write_reports(
        assessment=result.assessment,
        repository=repository,
        policy=policy,
        run_metadata=run_metadata,
        output_dir=output_dir,
        teacher_output_dir=teacher_output_dir,
    )
    assessment_path, manifest_path = _write_audit_artifacts(
        repository=repository,
        policy=policy,
        assessment=result.assessment,
        run_metadata=run_metadata,
        trace_root=trace_root,
        report_path=report_path,
        teacher_report_path=teacher_report_path,
        task_fingerprint=task_fingerprint,
        render_fingerprint=result.assessment.get("render_fingerprint"),
    )
    return {
        **identity,
        "status": "completed",
        "overall_disposition": result.assessment["overall_disposition"],
        "overall_label": result.assessment.get("overall_label"),
        "integrity_disposition": result.assessment.get("integrity_disposition"),
        "run_fingerprint": result.assessment.get("run_fingerprint"),
        "input_fingerprint": task_fingerprint,
        "turns": result.turns,
        "tool_calls": result.tool_calls,
        "report": str(report_path),
        "teacher_review_report": str(teacher_report_path),
        "assessment": str(assessment_path),
        "audit_manifest": str(manifest_path),
        "trace": result.trace_path,
    }


def _run_missing_task(
    *,
    repository: StudentAuditRepository,
    policy: PolicyDocument,
    baseline_manifest: Path | None,
    trace_root: Path,
    output_dir: Path,
    teacher_output_dir: Path,
    task_fingerprint: str,
    model_descriptor: dict[str, Any],
) -> dict[str, Any]:
    """Write a deterministic no-material report without calling the model."""

    tools = AuditTools(repository, policy, baseline_manifest)
    candidate = {
        "overall_disposition": "N0",
        "summary": "当前学生和 Lab 没有可读取的清洗材料、v3 assessment 或代码差异材料；宿主无法作出诚信判断。",
        "data_limitations": [
            "没有发现当前学生/Lab 的可读取输入；缺失材料不能解释为未操作、未使用 AI 或存在风险。",
        ],
        "findings": [],
    }
    validated = AssessmentValidator(
        repository, policy, contribution_snapshot=tools.contribution_snapshot
    ).validate(candidate)
    assessment = _host_owned_assessment(
        candidate=validated,
        repository=repository,
        policy=policy,
        tools=tools,
        model=_fingerprint_model(model_descriptor),
    )
    run_metadata = {"turns": 0, "tool_calls": 0, "trace_path": None}
    report_path, teacher_report_path = _write_reports(
        assessment=assessment,
        repository=repository,
        policy=policy,
        run_metadata=run_metadata,
        output_dir=output_dir,
        teacher_output_dir=teacher_output_dir,
    )
    assessment_path, manifest_path = _write_audit_artifacts(
        repository=repository,
        policy=policy,
        assessment=assessment,
        run_metadata=run_metadata,
        trace_root=trace_root,
        report_path=report_path,
        teacher_report_path=teacher_report_path,
        task_fingerprint=task_fingerprint,
        render_fingerprint=assessment.get("render_fingerprint"),
        status="missing",
    )
    return {
        "student_directory": repository.reference.directory_name,
        "student_id": repository.reference.student_id,
        "lab": repository.lab,
        "status": "missing",
        "message": "没有该 lab 的原始材料、v3 assessment 或差异材料；已生成资料不足占位报告。",
        "overall_label": assessment.get("overall_label"),
        "integrity_disposition": assessment.get("integrity_disposition"),
        "run_fingerprint": assessment.get("run_fingerprint"),
        "input_fingerprint": task_fingerprint,
        "report": str(report_path),
        "teacher_review_report": str(teacher_report_path),
        "assessment": str(assessment_path),
        "audit_manifest": str(manifest_path),
        "trace": None,
    }


def _discover_labs(data_root: Path, students: list[Any]) -> tuple[str, ...]:
    labs: set[str] = set()
    for reference in students:
        directory = data_root / reference.directory_name
        # Discover the union of all task-producing inputs.  A missing timeline
        # must not hide a valid v3 assessment or a diff-only task.
        patterns = (
            (directory / "实验过程时间线", "timeline_lab*.json", r"timeline_(lab[0-8])\.json"),
            (
                directory / "AI人工贡献识别" / "assessment",
                "assessment_lab*.json",
                r"assessment_(lab[0-8])\.json",
            ),
            (directory / "代码差异报告", "lab*.md", r"(lab[0-8])\.md"),
            (directory / "终端对话记录", "terminal_qa_report_lab*.md", r"terminal_qa_report_(lab[0-8])\.md"),
            (directory / "终端命令统计", "command_statistics_lab*.md", r"command_statistics_(lab[0-8])\.md"),
        )
        for folder, glob_pattern, name_pattern in patterns:
            if not folder.is_dir():
                continue
            for path in folder.glob(glob_pattern):
                match = re.fullmatch(name_pattern, path.name)
                if match:
                    labs.add(match.group(1))
    return tuple(sorted(labs, key=lambda value: (int(value[3:]), value)))


def _select_batch_students(data_root: Path, filters: list[str]) -> list[Any]:
    students = StudentAuditRepository.list_students(data_root)
    if not filters:
        return students
    selected = [
        student
        for student in students
        if student.directory_name in filters or student.student_id in filters
    ]
    if not selected:
        raise AuditError(f"未找到匹配 --student 的学生：{', '.join(filters)}")
    return selected


def _batch_id(value: str | None) -> str:
    if value:
        safe = _safe_component(value, "batch")
        if safe != value:
            raise AuditError("--batch-id 只能包含字母、数字、点、下划线和连字符")
        return safe
    return "batch-" + datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def _run_batch(args: argparse.Namespace) -> tuple[dict[str, Any], int]:
    if args.lab and args.all_labs:
        raise AuditError("--lab 与 --all-labs 不能同时使用")
    students = _select_batch_students(args.data_root, args.student)
    if args.all_labs:
        labs = _discover_labs(args.data_root, students)
    else:
        labs = tuple(dict.fromkeys(args.lab or ["lab0"]))
    if not labs:
        raise AuditError("没有发现可处理的 labN")
    for lab in labs:
        if not re.fullmatch(r"lab[0-8]", lab):
            raise AuditError(f"实验标签必须是 lab0 到 lab8：{lab}")

    batch_id = _batch_id(args.batch_id)
    policy = PolicyDocument(args.policy)

    model: OpenAICompatibleChatClient | None = None
    model_descriptor = _provider_fingerprint()
    started_at = datetime.now(timezone.utc).isoformat()
    rows: list[dict[str, Any]] = []
    for student in students:
        for lab in labs:
            repository: StudentAuditRepository | None = None
            task_fingerprint: str | None = None
            try:
                repository = StudentAuditRepository(args.data_root, student.directory_name, lab)
                task_fingerprint = _task_fingerprint(
                    repository,
                    policy,
                    model_descriptor=model_descriptor,
                    baseline_manifest=args.baseline_manifest,
                )
                previous_manifest = _cached_failure_manifest(args.trace_dir, repository)

                # A completed task is reusable by default.  --force is the
                # explicit escape hatch; --resume additionally controls how
                # prior failures are treated.
                if not args.dry_run and not args.force:
                    cached = _cached_task_row(
                        repository=repository,
                        policy=policy,
                        expected_fingerprint=task_fingerprint,
                        trace_root=args.trace_dir,
                        output_dir=args.output_dir,
                        teacher_output_dir=args.teacher_output_dir,
                        baseline_manifest=args.baseline_manifest,
                        model_descriptor=model_descriptor,
                    )
                    if cached is not None:
                        rows.append(cached)
                        continue
                    if (
                        args.resume
                        and not args.retry_failed
                        and previous_manifest
                        and previous_manifest.get("status") == "failed"
                        and previous_manifest.get("input_fingerprint") == task_fingerprint
                    ):
                        rows.append(
                            {
                                "student_directory": student.directory_name,
                                "student_id": student.student_id,
                                "lab": lab,
                                "status": "deferred",
                                "message": "上次任务失败；使用 --retry-failed 才会重试。",
                                "input_fingerprint": task_fingerprint,
                            }
                        )
                        continue

                has_material = any(
                    isinstance(item, dict) and item.get("available") is True
                    for item in _input_snapshot(repository)
                )
                if not has_material:
                    if args.dry_run:
                        rows.append(
                            {
                                "student_directory": student.directory_name,
                                "student_id": student.student_id,
                                "lab": lab,
                                "status": "missing",
                                "message": "没有该 lab 的原始材料、v3 assessment 或差异材料；dry-run 未写报告。",
                                "input_fingerprint": task_fingerprint,
                            }
                        )
                    else:
                        rows.append(
                            _run_missing_task(
                                repository=repository,
                                policy=policy,
                                baseline_manifest=args.baseline_manifest,
                                trace_root=args.trace_dir,
                                output_dir=args.output_dir,
                                teacher_output_dir=args.teacher_output_dir,
                                task_fingerprint=task_fingerprint,
                                model_descriptor=model_descriptor,
                            )
                        )
                    continue

                if args.dry_run:
                    rows.append(
                        _run_audit_task(
                            repository=repository,
                            policy=policy,
                            model=None,
                            baseline_manifest=args.baseline_manifest,
                            max_turns=args.max_turns,
                            trace_root=args.trace_dir,
                            output_dir=args.output_dir,
                            teacher_output_dir=args.teacher_output_dir,
                            task_fingerprint=task_fingerprint,
                            dry_run=True,
                        )
                    )
                    continue

                if model is None:
                    model = OpenAICompatibleChatClient(OpenAICompatibleConfig.from_environment())
                rows.append(
                    _run_audit_task(
                        repository=repository,
                        policy=policy,
                        model=model,
                        baseline_manifest=args.baseline_manifest,
                        max_turns=args.max_turns,
                        trace_root=args.trace_dir,
                        output_dir=args.output_dir,
                        teacher_output_dir=args.teacher_output_dir,
                        task_fingerprint=task_fingerprint,
                    )
                )
            except Exception as error:  # Keep one malformed task from aborting the batch.
                safe_error = _trace_safe(str(error))
                try:
                    failure_path = _write_failure_artifact(
                        repository=repository,
                        policy=policy,
                        trace_root=args.trace_dir,
                        task_fingerprint=task_fingerprint or "",
                        message=safe_error,
                    )
                except Exception:
                    failure_path = None
                rows.append(
                    {
                        "student_directory": student.directory_name,
                        "student_id": student.student_id,
                        "lab": lab,
                        "status": "failed",
                        "message": safe_error,
                        "input_fingerprint": task_fingerprint,
                        "audit_manifest": str(failure_path) if failure_path else None,
                    }
                )

    counts: dict[str, int] = {}
    for row in rows:
        status = str(row.get("status", "unknown"))
        counts[status] = counts.get(status, 0) + 1
    completed_at = datetime.now(timezone.utc).isoformat()
    summary: dict[str, Any] = {
        "schema_version": BATCH_SUMMARY_SCHEMA,
        "batch_id": batch_id,
        "started_at": started_at,
        "completed_at": completed_at,
        "data_root": str(args.data_root),
        "policy": str(args.policy),
        "students": [student.directory_name for student in students],
        "labs": list(labs),
        "options": {
            "resume": bool(args.resume),
            "retry_failed": bool(args.retry_failed),
            "force": bool(args.force),
            "dry_run": bool(args.dry_run),
        },
        "counts": counts,
        "results": rows,
    }
    summary_path: Path | None = None
    if not args.dry_run:
        summary_path = args.trace_dir / "batches" / summary["batch_id"] / "summary.json"
        _atomic_write_json(summary_path, summary)
    response = {
        "batch": summary,
        "summary": str(summary_path) if summary_path is not None else None,
    }
    return response, 1 if counts.get("failed", 0) else 0


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        if args.command == "students":
            students = StudentAuditRepository.list_students(args.data_root)
            _json_print(
                {
                    "students": [
                        {"student_id": item.student_id, "directory": item.directory_name} for item in students
                    ]
                }
            )
            return 0

        if args.command in {"batch", "audit-batch"}:
            response, exit_code = _run_batch(args)
            _json_print(response)
            return exit_code

        repository = _make_repository(args)
        policy = PolicyDocument(args.policy)
        if args.command == "inspect":
            tools = AuditTools(repository, policy)
            _json_print(
                {
                    "inventory": repository.inventory(),
                    "data_quality": repository.data_quality(),
                    "contribution": _contribution_inventory(tools),
                    "policy": policy.inventory(),
                }
            )
            return 0

        if args.command == "render-trace":
            assessment, run_metadata = _load_trace_assessment(args.trace, repository, policy)
            report_path, teacher_report_path = _write_reports(
                assessment=assessment,
                repository=repository,
                policy=policy,
                run_metadata=run_metadata,
                output_dir=args.output_dir,
                teacher_output_dir=args.teacher_output_dir,
            )
            assessment_path, manifest_path = _write_audit_artifacts(
                repository=repository,
                policy=policy,
                assessment=assessment,
                run_metadata=run_metadata,
                trace_root=args.trace_dir,
                report_path=report_path,
                teacher_report_path=teacher_report_path,
                task_fingerprint=_task_fingerprint(
                    repository, policy, model_descriptor=_provider_fingerprint()
                ),
                render_fingerprint=assessment.get("render_fingerprint"),
            )
            _json_print(
                {
                    "report": str(report_path),
                    "teacher_review_report": str(teacher_report_path),
                    "assessment": str(assessment_path),
                    "audit_manifest": str(manifest_path),
                    "overall_disposition": assessment["overall_disposition"],
                    "overall_label": assessment.get("overall_label"),
                    "trace": str(args.trace),
                }
            )
            return 0

        if args.dry_run:
            tools = AuditTools(repository, policy, args.baseline_manifest)
            _json_print(
                {
                    "dry_run": True,
                    "inventory": repository.inventory(),
                    "data_quality": repository.data_quality(),
                    "contribution": _contribution_inventory(tools),
                    "baseline": repository.baseline_status(args.baseline_manifest),
                    "policy_sha256": policy.sha256,
                }
            )
            return 0

        model = OpenAICompatibleChatClient(OpenAICompatibleConfig.from_environment())
        task_result = _run_audit_task(
            repository=repository,
            policy=policy,
            model=model,
            baseline_manifest=args.baseline_manifest,
            max_turns=args.max_turns,
            trace_root=args.trace_dir,
            output_dir=args.output_dir,
            teacher_output_dir=args.teacher_output_dir,
            task_fingerprint=_task_fingerprint(
                repository, policy, model_descriptor=_provider_fingerprint()
            ),
        )
        _json_print(task_result)
        return 0
    except AuditError as error:
        print(f"审核 Agent 未完成：{error}", file=sys.stderr)
        return 2
    except OSError as error:
        print(f"本地文件操作失败：{error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
