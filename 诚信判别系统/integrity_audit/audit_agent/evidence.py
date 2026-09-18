"""Evidence references shared by the integrity auditor.

The contribution-recognition service emits references into cleaned Markdown
files.  The integrity auditor must re-open and verify those references before
using them.  This module deliberately contains no model or report logic: it
only describes a bounded, serialisable reference and the evidence level that
the host has actually established.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, replace
from typing import Any, Literal, Mapping


EvidenceLevel = Literal["E1", "E2"]
EvidenceKind = Literal["event", "v3"]

_SHA256_RE = re.compile(r"^[0-9a-fA-F]{64}$")
_REDACTION_MARKERS = (
    "[REDACTED]",
    "[已脱敏]",
    "<REDACTED>",
    "<已脱敏>",
    "***",
    "…",
    "...",
)
_SECRET_RE = re.compile(
    r"(?i)(?:nvapi-[A-Za-z0-9_-]+|bearer\s+[A-Za-z0-9._~+/=-]+|"
    r"(?:api[_ -]?key|token|password)\s*[:=]\s*[^\s,;]+)"
)


def _clean(value: Any) -> str | None:
    if not isinstance(value, str):
        return None
    value = value.strip()
    return value or None


def _line(value: Any) -> int | None:
    # bool is an int subclass but is never a valid line number.
    if isinstance(value, bool) or not isinstance(value, int):
        return None
    return value


def _redact(value: Any) -> Any:
    if isinstance(value, str):
        return _SECRET_RE.sub("[REDACTED]", value)
    if isinstance(value, dict):
        return {str(key): _redact(item) for key, item in value.items()}
    if isinstance(value, list):
        return [_redact(item) for item in value]
    if isinstance(value, tuple):
        return tuple(_redact(item) for item in value)
    return value


@dataclass(frozen=True)
class EvidenceRef:
    """A verified or pending evidence reference.

    ``event_id`` is retained for the original integrity timeline evidence.
    v3 references use ``source_id`` plus a path, hash, inclusive line range,
    and short excerpt.  The two forms intentionally share one type so host
    validation and reporting can handle them uniformly.

    The constructor is permissive enough to represent an invalid reference
    returned by a validator.  Callers should inspect :attr:`valid` before
    treating a reference as evidence.  ``evidence_level`` is always the
    *host-established* level; a model's claimed E1 cannot raise it.
    """

    kind: EvidenceKind = "v3"
    evidence_level: EvidenceLevel = "E2"
    event_id: str | None = None
    quote: str | None = None
    source_id: str | None = None
    relative_path: str | None = None
    sha256: str | None = None
    line_start: int | None = None
    line_end: int | None = None
    excerpt: str | None = None
    valid: bool = True
    invalid_reason: str | None = None
    provenance: Mapping[str, Any] | None = None

    def __post_init__(self) -> None:
        # Keep direct construction ergonomic for legacy event callers while
        # retaining explicit kind in all adapter-generated objects.
        if (
            self.kind == "v3"
            and self.event_id
            and self.source_id is None
            and self.relative_path is None
        ):
            object.__setattr__(self, "kind", "event")
        if self.kind not in {"event", "v3"}:
            raise ValueError("EvidenceRef.kind 必须是 event 或 v3")
        if self.evidence_level not in {"E1", "E2"}:
            raise ValueError("EvidenceRef.evidence_level 必须是 E1 或 E2")
        if self.kind == "event":
            if not _clean(self.event_id):
                raise ValueError("事件证据必须包含 event_id")
            if not _clean(self.quote):
                raise ValueError("事件证据必须包含 quote")
        else:
            required = {
                "source_id": self.source_id,
                "relative_path": self.relative_path,
                "sha256": self.sha256,
                "line_start": self.line_start,
                "line_end": self.line_end,
                "excerpt": self.excerpt,
            }
            if any(value is None for value in required.values()):
                raise ValueError("v3 证据必须包含 source_id、路径、哈希、范围和摘录")
            if not _SHA256_RE.fullmatch(str(self.sha256)):
                raise ValueError("v3 证据 sha256 必须是 64 位十六进制字符串")
            if (
                isinstance(self.line_start, bool)
                or isinstance(self.line_end, bool)
                or not isinstance(self.line_start, int)
                or not isinstance(self.line_end, int)
                or self.line_start < 1
                or self.line_end < self.line_start
            ):
                raise ValueError("v3 证据行范围无效")
            if not isinstance(self.excerpt, str) or len(self.excerpt) > 600:
                raise ValueError("v3 证据摘录必须是至多 600 字符的字符串")
        if self.valid and self.invalid_reason:
            # A reason on a valid object is almost always a caller bug and
            # makes persisted diagnostics ambiguous.
            raise ValueError("有效 EvidenceRef 不能带 invalid_reason")

    @classmethod
    def from_event(
        cls,
        event_id: str,
        quote: str,
        *,
        evidence_level: EvidenceLevel = "E2",
        provenance: Mapping[str, Any] | None = None,
        independent_archive: bool = False,
        archive_sha256: str | None = None,
        collection_chain: bool = False,
        precise_location: bool = False,
    ) -> "EvidenceRef":
        """Create a reference for a legacy ``event_id`` timeline item."""

        level: EvidenceLevel = (
            "E1"
            if evidence_level == "E1"
            and can_upgrade_to_e1(
                independent_archive=independent_archive,
                archive_sha256=archive_sha256,
                collection_chain=collection_chain,
                precise_location=precise_location,
            )
            else "E2"
        )
        return cls(
            kind="event",
            evidence_level=level,
            event_id=event_id,
            quote=quote,
            provenance=provenance,
        )

    @classmethod
    def from_v3(
        cls,
        value: Mapping[str, Any],
        *,
        evidence_level: EvidenceLevel = "E2",
        valid: bool = True,
        invalid_reason: str | None = None,
        independent_archive: bool = False,
        archive_sha256: str | None = None,
        collection_chain: bool = False,
        precise_location: bool = False,
    ) -> "EvidenceRef":
        """Build a reference from one v3 ``evidence_refs`` object.

        The v3 contract uses ``line_start``/``line_end``.  ``start_line`` and
        ``end_line`` are accepted only as an in-memory compatibility aid when
        callers explicitly pass a mapping; the adapter itself rejects those
        aliases while validating persisted assessments.
        """

        start = value.get("line_start", value.get("start_line"))
        end = value.get("line_end", value.get("end_line"))
        # Invalid references still need to be representable for unit-level
        # isolation.  Use a safe placeholder only after recording the reason.
        if not valid and (
            not isinstance(value.get("source_id"), str)
            or not isinstance(value.get("relative_path"), str)
            or not isinstance(value.get("sha256"), str)
            or not isinstance(start, int)
            or not isinstance(end, int)
            or not isinstance(value.get("excerpt"), str)
        ):
            return cls.invalid(
                kind="v3",
                reason=invalid_reason or "v3 证据字段不完整",
                source_id=value.get("source_id") if isinstance(value.get("source_id"), str) else None,
                relative_path=value.get("relative_path") if isinstance(value.get("relative_path"), str) else None,
                sha256=value.get("sha256") if isinstance(value.get("sha256"), str) else None,
                line_start=start if isinstance(start, int) else None,
                line_end=end if isinstance(end, int) else None,
                excerpt=value.get("excerpt") if isinstance(value.get("excerpt"), str) else None,
            )
        level: EvidenceLevel = (
            "E1"
            if evidence_level == "E1"
            and can_upgrade_to_e1(
                independent_archive=independent_archive,
                archive_sha256=archive_sha256,
                collection_chain=collection_chain,
                precise_location=precise_location,
            )
            else "E2"
        )
        try:
            return cls(
                kind="v3",
                evidence_level=level,
                source_id=value.get("source_id"),
                relative_path=value.get("relative_path"),
                sha256=value.get("sha256"),
                line_start=start,
                line_end=end,
                excerpt=value.get("excerpt"),
                valid=valid,
                invalid_reason=invalid_reason,
            )
        except ValueError:
            if valid:
                raise
            return cls.invalid(
                kind="v3",
                reason=invalid_reason or "v3 证据字段无效",
                source_id=value.get("source_id") if isinstance(value.get("source_id"), str) else None,
                relative_path=value.get("relative_path") if isinstance(value.get("relative_path"), str) else None,
                sha256=value.get("sha256") if isinstance(value.get("sha256"), str) else None,
                line_start=start if isinstance(start, int) else None,
                line_end=end if isinstance(end, int) else None,
                excerpt=value.get("excerpt") if isinstance(value.get("excerpt"), str) else None,
            )

    @classmethod
    def invalid(
        cls,
        *,
        kind: EvidenceKind,
        reason: str,
        evidence_level: EvidenceLevel = "E2",
        **kwargs: Any,
    ) -> "EvidenceRef":
        """Represent a rejected reference without allowing it into evidence."""

        if kind == "event":
            # Event references have no structural requirements beyond the
            # identifiers; placeholders keep diagnostics serialisable.
            return cls(
                kind="event",
                evidence_level=evidence_level,
                event_id=kwargs.get("event_id") or "<invalid-event>",
                quote=kwargs.get("quote") or "<invalid>",
                valid=False,
                invalid_reason=reason,
                provenance=kwargs.get("provenance"),
            )
        start_line = kwargs.get("line_start")
        end_line = kwargs.get("line_end")
        if not isinstance(start_line, int) or isinstance(start_line, bool) or start_line < 1:
            start_line = 1
        if not isinstance(end_line, int) or isinstance(end_line, bool) or end_line < start_line:
            end_line = start_line
        return cls(
            kind="v3",
            evidence_level=evidence_level,
            source_id=kwargs.get("source_id") or "<invalid-source>",
            relative_path=kwargs.get("relative_path") or "<invalid-path>",
            sha256=kwargs.get("sha256") if _SHA256_RE.fullmatch(str(kwargs.get("sha256") or "")) else "0" * 64,
            line_start=start_line,
            line_end=end_line,
            excerpt=kwargs.get("excerpt") if isinstance(kwargs.get("excerpt"), str) else "<invalid>",
            valid=False,
            invalid_reason=reason,
        )

    @property
    def start_line(self) -> int | None:
        """Compatibility alias used by older readers."""

        return self.line_start

    @property
    def end_line(self) -> int | None:
        """Compatibility alias used by older readers."""

        return self.line_end

    @property
    def source_sha256(self) -> str | None:
        return self.sha256

    @property
    def line_range(self) -> tuple[int | None, int | None]:
        return self.line_start, self.line_end

    @property
    def usable(self) -> bool:
        return self.valid

    @property
    def is_e1(self) -> bool:
        return self.valid and self.evidence_level == "E1"

    def downgraded(self, reason: str | None = None) -> "EvidenceRef":
        """Return an otherwise identical E2 reference.

        This is used when a model claims E1 but the host cannot establish an
        independent raw archive and collection chain.
        """

        return replace(self, evidence_level="E2", invalid_reason=reason if not self.valid else None)

    def to_dict(self) -> dict[str, Any]:
        """Return a safe, concise representation suitable for reports/logs."""

        result: dict[str, Any] = {
            "kind": self.kind,
            "evidence_level": self.evidence_level,
            "valid": self.valid,
        }
        if self.event_id is not None:
            result["event_id"] = _redact(self.event_id)
        if self.quote is not None:
            result["quote"] = _redact(self.quote)
        if self.source_id is not None:
            result["source_id"] = self.source_id
        if self.relative_path is not None:
            result["relative_path"] = self.relative_path
        if self.sha256 is not None:
            result["sha256"] = self.sha256
        if self.line_start is not None:
            result["line_start"] = self.line_start
        if self.line_end is not None:
            result["line_end"] = self.line_end
        if self.excerpt is not None:
            result["excerpt"] = _redact(self.excerpt)
        if self.invalid_reason:
            result["invalid_reason"] = self.invalid_reason
        if self.provenance:
            result["provenance"] = _redact(dict(self.provenance))
        return result

    def __str__(self) -> str:
        if self.kind == "event":
            return f"event:{self.event_id}"
        return f"{self.source_id}:{self.line_start}-{self.line_end}"


def claimed_evidence_level(value: Mapping[str, Any]) -> EvidenceLevel:
    """Read a model claim without trusting it.

    Unknown or absent claims intentionally become E2.  The adapter performs
    the independent-archive check required for E1 separately.
    """

    return "E1" if value.get("evidence_level") == "E1" else "E2"


def can_upgrade_to_e1(
    *,
    independent_archive: bool,
    archive_sha256: str | None,
    collection_chain: bool,
    precise_location: bool,
) -> bool:
    """Return whether an E2 cleaned reference has enough provenance for E1."""

    return bool(
        independent_archive
        and isinstance(archive_sha256, str)
        and _SHA256_RE.fullmatch(archive_sha256)
        and collection_chain
        and precise_location
    )


def effective_evidence_level(
    value: Mapping[str, Any],
    *,
    independent_archive: bool = False,
    archive_sha256: str | None = None,
    collection_chain: bool = False,
    precise_location: bool = False,
) -> EvidenceLevel:
    """Compute the host-authoritative level for a raw v3 reference."""

    if claimed_evidence_level(value) != "E1":
        return "E2"
    return (
        "E1"
        if can_upgrade_to_e1(
            independent_archive=independent_archive,
            archive_sha256=archive_sha256,
            collection_chain=collection_chain,
            precise_location=precise_location,
        )
        else "E2"
    )


__all__ = [
    "EvidenceKind",
    "EvidenceLevel",
    "EvidenceRef",
    "can_upgrade_to_e1",
    "claimed_evidence_level",
    "effective_evidence_level",
]
