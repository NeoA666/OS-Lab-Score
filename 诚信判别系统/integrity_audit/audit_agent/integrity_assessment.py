"""Host-owned integrity assessment contract and label gates.

The contribution-recognition assessment is an input to this module, never the
final integrity decision.  The host applies the evidence and rule gates here
after all model-authored candidate findings have been validated.
"""

from __future__ import annotations

import hashlib
import json
import re
from dataclasses import asdict, dataclass, field
from typing import Any, Iterable, Mapping


OVERALL_LABELS = (
    "完全诚信",
    "基本诚信",
    "存在疑点",
    "高风险待核实",
    "资料不足/无法判定",
)

OVERALL_DISPOSITIONS = {
    "完全诚信": "no_action",
    "基本诚信": "teaching_note",
    "存在疑点": "teacher_review",
    "高风险待核实": "formal_verification",
    "资料不足/无法判定": "insufficient_data",
}

_DISPOSITION_ORDER = {"N0": 0, "N1": 1, "R1": 2, "R2": 3}
_SENSITIVE_KEY_RE = re.compile(
    r"(api[_-]?key|authorization|reasoning|chain[_-]?of[_-]?thought|raw[_-]?(?:response|prompt)|request[_-]?(?:body|payload))",
    re.IGNORECASE,
)

# v3 contribution validation is deliberately finer grained than the legacy
# integrity evidence.  These issue prefixes describe the contribution layer
# (including its Lab-level conclusion and independent review); they must not
# make otherwise independent event evidence disappear from the host audit.
_CONTRIBUTION_LOCAL_ISSUE_RE = re.compile(
    r"^(?:contribution_units(?:\[|\s)|unit(?:\[|\s)|"
    r"lab_conclusion(?:[.\s]|$)|review(?:[.\s]|$)|"
    r"diff_hunks(?:\[|\s))",
    re.IGNORECASE,
)


def _safe_value(value: Any) -> Any:
    """Remove model-private fields before an assessment can be persisted."""

    if isinstance(value, Mapping):
        return {
            str(key): _safe_value(item)
            for key, item in value.items()
            if not _SENSITIVE_KEY_RE.search(str(key))
        }
    if isinstance(value, list):
        return [_safe_value(item) for item in value]
    if isinstance(value, tuple):
        return [_safe_value(item) for item in value]
    if isinstance(value, str):
        # Keep common credential-shaped strings out of reports and JSONL.
        return re.sub(r"\b(?:nvapi|sk)-[A-Za-z0-9_-]{8,}\b", "[REDACTED]", value)
    return value


def stable_fingerprint(value: Any) -> str:
    payload = json.dumps(_safe_value(value), ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return "sha256:" + hashlib.sha256(payload.encode("utf-8")).hexdigest()


@dataclass(frozen=True)
class IntegrityAssessment:
    """Stable, host-owned output for one student and one Lab."""

    student_directory: str
    student_id: str | None
    lab: str
    overall_label: str
    overall_disposition: str
    coverage: dict[str, Any] = field(default_factory=dict)
    contribution_access: dict[str, Any] = field(default_factory=dict)
    contribution_units: list[dict[str, Any]] = field(default_factory=list)
    # Persist the machine rule registration used by the host gate.  Keeping
    # this alongside the result makes a later review reproducible even when a
    # rule file or its routing switch changes.
    rule_registry: dict[str, Any] = field(default_factory=dict)
    evidence: list[dict[str, Any]] = field(default_factory=list)
    findings: list[dict[str, Any]] = field(default_factory=list)
    alternative_explanations: list[str] = field(default_factory=list)
    teacher_actions: list[str] = field(default_factory=list)
    limitations: list[str] = field(default_factory=list)
    run_fingerprint: str | None = None
    render_fingerprint: str | None = None
    schema_version: str = "integrity-assessment/v1"

    def __post_init__(self) -> None:
        if self.overall_label not in OVERALL_LABELS:
            raise ValueError(f"未知诚信标签：{self.overall_label}")
        expected = OVERALL_DISPOSITIONS[self.overall_label]
        if self.overall_disposition != expected:
            raise ValueError("overall_disposition 与 overall_label 不匹配")

    def to_dict(self) -> dict[str, Any]:
        return _safe_value(asdict(self))


def _snapshot_value(snapshot: Any, name: str, default: Any = None) -> Any:
    if snapshot is None:
        return default
    if isinstance(snapshot, Mapping):
        return snapshot.get(name, default)
    return getattr(snapshot, name, default)


def _coverage(snapshot: Any) -> dict[str, Any]:
    value = _snapshot_value(snapshot, "coverage", {})
    return dict(value) if isinstance(value, Mapping) else {}


def _review(snapshot: Any) -> dict[str, Any]:
    value = _snapshot_value(snapshot, "review", {})
    return dict(value) if isinstance(value, Mapping) else {}


def _lab_conclusion(snapshot: Any) -> dict[str, Any]:
    value = _snapshot_value(snapshot, "lab_conclusion", {})
    return dict(value) if isinstance(value, Mapping) else {}


def _units(snapshot: Any) -> list[dict[str, Any]]:
    value = _snapshot_value(snapshot, "valid_units", None)
    if value is None:
        value = _snapshot_value(snapshot, "contribution_units", [])
    if not isinstance(value, (list, tuple)):
        return []
    result: list[dict[str, Any]] = []
    for item in value:
        if isinstance(item, Mapping):
            result.append(dict(item))
        elif hasattr(item, "to_dict"):
            converted = item.to_dict()
            if isinstance(converted, Mapping):
                result.append(dict(converted))
    return result


def _source_manifest(snapshot: Any) -> list[dict[str, Any]]:
    value = _snapshot_value(snapshot, "source_manifest", None)
    if value is None:
        value = _snapshot_value(snapshot, "sources", ())
    if not isinstance(value, (list, tuple)):
        return []
    result: list[dict[str, Any]] = []
    for item in value:
        if isinstance(item, Mapping):
            result.append(dict(item))
        elif hasattr(item, "to_dict"):
            converted = item.to_dict()
            if isinstance(converted, Mapping):
                result.append(dict(converted))
    return result


def _unit_summary(unit: Mapping[str, Any]) -> dict[str, Any]:
    """Keep contribution details bounded and report-safe."""

    raw_summary = unit.get("summary", "")
    summary = str(raw_summary) if raw_summary is not None else ""
    # The summary is useful in the first-screen unit index, but it is still
    # model-authored text. Keep it bounded before it reaches reports/logs.
    if len(summary) > 600:
        summary = summary[:597] + "..."
    refs = unit.get("evidence_refs", [])
    safe_refs: list[dict[str, Any]] = []
    if isinstance(refs, (list, tuple)):
        for ref in refs:
            if isinstance(ref, Mapping):
                # Preserve exact locators and excerpts, but never arbitrary
                # model fields or source contents.
                safe_refs.append(
                    {
                        key: ref[key]
                        for key in (
                            "kind",
                            "evidence_level",
                            "valid",
                            "source_id",
                            "relative_path",
                            "sha256",
                            "line_start",
                            "line_end",
                            "excerpt",
                            "invalid_reason",
                        )
                        if key in ref
                    }
                )
    return {
        "unit_id": str(unit.get("unit_id", "")),
        "unit_type": str(unit.get("unit_type", "unknown")),
        "label": str(unit.get("label", unit.get("unit_label", "indeterminate"))),
        "confidence": str(unit.get("confidence", unit.get("unit_confidence", "weak"))),
        "summary": summary,
        "valid": bool(unit.get("valid", False)),
        "evidence_refs": safe_refs,
        "issues": list(unit.get("validation_issues", unit.get("issues", [])))
        if isinstance(unit.get("validation_issues", unit.get("issues", [])), (list, tuple))
        else [],
    }


def _has_e1(items: Iterable[Mapping[str, Any]]) -> bool:
    return any(str(item.get("evidence_level", "")).upper() == "E1" for item in items)


def _finding_level(finding: Mapping[str, Any]) -> str:
    evidence = finding.get("evidence")
    if isinstance(evidence, list) and _has_e1(item for item in evidence if isinstance(item, Mapping)):
        return "E1"
    evidence_refs = finding.get("evidence_refs")
    if isinstance(evidence_refs, list) and _has_e1(item for item in evidence_refs if isinstance(item, Mapping)):
        return "E1"
    return "E2"


def _rule_allows_contribution(rule_registry: Any, lab: str) -> bool:
    if rule_registry is None:
        return lab == "lab0"
    if hasattr(rule_registry, "contribution_routing_enabled"):
        value = rule_registry.contribution_routing_enabled(lab)
        return bool(value)
    if isinstance(rule_registry, Mapping):
        entry = rule_registry.get(lab, {})
        if isinstance(entry, Mapping):
            return bool(entry.get("contribution_routing_enabled", entry.get("contribution_routing", False)))
    return lab == "lab0"


def _coverage_complete(coverage: Mapping[str, Any]) -> bool:
    status = coverage.get("status")
    if status in {"complete", "available"}:
        return True
    materials = coverage.get("materials")
    if isinstance(materials, list) and materials:
        return all(
            isinstance(item, Mapping)
            and (item.get("status", item.get("availability")) in {"available", "not_applicable"})
            for item in materials
            if item.get("required", True)
        )
    return False


def _explicit_snapshot_failure(snapshot: Any) -> str | None:
    """Return a host-facing reason when a v3 snapshot cannot be consumed.

    The adapter exposes these properties on ``StudentLabSnapshot``.  The
    mapping fallbacks keep this gate usable in report-only callers and tests
    that provide a serialised snapshot instead of the dataclass.
    """

    if snapshot is None:
        return "贡献 assessment 未提供"
    available = _snapshot_value(snapshot, "assessment_available", None)
    if available is False:
        return "贡献 assessment 不可用"
    compatibility = _snapshot_value(snapshot, "compatibility", None)
    if compatibility is not None and compatibility != "compatible":
        return f"贡献 assessment schema 不兼容（{compatibility}）"
    # ``schema_compatible`` is the spelling used by bounded inventory
    # responses; honor it when a caller passes that representation.
    schema_compatible = _snapshot_value(snapshot, "schema_compatible", None)
    if schema_compatible is False:
        return "贡献 assessment schema 不兼容"
    issues = _snapshot_value(snapshot, "issues", None)
    issue_values = [str(item).strip() for item in issues] if isinstance(issues, (list, tuple)) else []
    # ``semantic_consumable`` includes contribution-unit and Lab-conclusion
    # checks.  A failure there disables the contribution route, but it does not
    # invalidate independently verified legacy event evidence.  Compatibility
    # and non-local structural/source errors remain a whole-assessment gate.
    semantic = _snapshot_value(snapshot, "semantic_consumable", None)
    if semantic is False:
        if compatibility != "compatible":
            return "贡献 assessment 未通过宿主语义校验"
        blocking = [item for item in issue_values if not _CONTRIBUTION_LOCAL_ISSUE_RE.match(item)]
        if blocking:
            return "贡献 assessment 存在宿主校验错误"
        return None
    if issue_values:
        blocking = [item for item in issue_values if not _CONTRIBUTION_LOCAL_ISSUE_RE.match(item)]
        if blocking:
            return "贡献 assessment 存在宿主校验错误"
    return None


def _unit_can_route_contribution(unit: Mapping[str, Any]) -> bool:
    """Check the narrow v3 unit gate used for the Lab0 E2 diversion path."""

    # ``valid`` is host-owned; a missing flag is not proof that the unit was
    # revalidated and therefore cannot open the contribution routing path.
    if unit.get("valid") is not True:
        return False
    refs = unit.get("evidence_refs")
    if isinstance(refs, (list, tuple)):
        if not refs:
            return False
        if any(
            not isinstance(ref, Mapping) or ref.get("valid") is not True
            for ref in refs
        ):
            return False
    else:
        return False
    label = str(unit.get("label", unit.get("unit_label", "indeterminate")))
    confidence = str(unit.get("confidence", unit.get("unit_confidence", "weak")))
    return label in {"ai_dominant", "mixed"} and confidence != "weak"


def _upstream_limitations(snapshot: Any) -> list[str]:
    """Return bounded, non-empty limitations carried by a v3 assessment.

    ``StudentLabSnapshot.assessment`` is already redacted by the adapter.  Do
    not treat an arbitrary non-list value as a limitation: malformed v3 data
    is handled by the interface-consumption gate instead of changing a label
    through an untyped field.
    """

    assessment = _snapshot_value(snapshot, "assessment", None)
    value = assessment.get("limitations") if isinstance(assessment, Mapping) else None
    if value is None:
        value = _snapshot_value(snapshot, "limitations", ())
    if not isinstance(value, (list, tuple)):
        return []
    result: list[str] = []
    for item in value:
        if not isinstance(item, str):
            continue
        text = item.strip()
        if text and text not in result:
            result.append(text)
    return result


def derive_overall_label(
    *,
    snapshot: Any = None,
    candidate_findings: Iterable[Mapping[str, Any]] = (),
    independent_e1: bool = False,
    r1_r2_passed: bool = False,
    rule_registry: Any = None,
) -> tuple[str, str, list[str]]:
    """Apply the deterministic host gates and return label, disposition, limits.

    ``candidate_findings`` is deliberately treated as a proposal.  Its highest
    requested disposition can only become a high-risk label when an independent
    E1 source and the R1/R2 checks are both present.
    """

    coverage = _coverage(snapshot)
    status = str(_snapshot_value(snapshot, "analysis_status", "unknown"))
    review = _review(snapshot)
    conclusion = _lab_conclusion(snapshot)
    lab = str(_snapshot_value(snapshot, "lab", "lab0"))
    limits: list[str] = []

    snapshot_failure = _explicit_snapshot_failure(snapshot)
    if snapshot_failure is not None:
        limits.append(snapshot_failure + "，不能用于提升诚信风险。")
        return "资料不足/无法判定", OVERALL_DISPOSITIONS["资料不足/无法判定"], limits

    if status in {"failed", "insufficient_data", "incompatible", "missing", "unknown"}:
        limits.append(f"贡献资料状态为 {status}，不能用于提升诚信风险。")
        return "资料不足/无法判定", OVERALL_DISPOSITIONS["资料不足/无法判定"], limits
    if not _coverage_complete(coverage):
        limits.append("当前 Lab 的规定材料覆盖不完整，不能据缺失作不利推断。")
        return "资料不足/无法判定", OVERALL_DISPOSITIONS["资料不足/无法判定"], limits

    # A complete v3 assessment can still explicitly declare scope limits.
    # They are not adverse evidence, but they prevent an unqualified
    # "完全诚信" label when no higher host conclusion applies.
    limits.extend(_upstream_limitations(snapshot))

    review_status = review.get("status")
    overall_decision = review.get("overall_decision")
    if review_status != "agreed" or overall_decision != "agree":
        if review_status in {"not_run", "disagreed"}:
            limits.append("独立贡献复核未形成 agreed/agree，一律不提升诚信风险。")

    valid_units = _units(snapshot)
    routable_units = [unit for unit in valid_units if _unit_can_route_contribution(unit)]
    contribution_enabled = _rule_allows_contribution(rule_registry, lab)
    contribution_candidate = (
        contribution_enabled
        and review_status == "agreed"
        and overall_decision == "agree"
        and bool(_snapshot_value(snapshot, "lab_conclusion_valid", True))
        and str(conclusion.get("label")) in {"ai_dominant", "mixed"}
        and str(conclusion.get("confidence")) != "weak"
        and bool(routable_units)
        and bool(_snapshot_value(snapshot, "contribution_refs_valid", True))
    )

    findings = [dict(item) for item in candidate_findings if isinstance(item, Mapping)]
    high_candidate = any(str(item.get("disposition")) in {"R1", "R2"} for item in findings)
    review_valid = _snapshot_value(snapshot, "review_valid", True)
    review_agreed = (
        review_status == "agreed"
        and overall_decision == "agree"
        and review_valid is not False
    )
    semantic_consumable = _snapshot_value(snapshot, "semantic_consumable", True)
    if semantic_consumable is False and _snapshot_value(snapshot, "compatibility", "compatible") == "compatible":
        limits.append("贡献层存在局部校验失败，已取消受影响单元的分流信号。")
    if high_candidate and review_agreed and independent_e1 and r1_r2_passed:
        return "高风险待核实", OVERALL_DISPOSITIONS["高风险待核实"], limits

    if contribution_candidate:
        # A contribution image is an E2 diversion signal only.  It cannot by
        # itself become a formal risk disposition.
        refs_ok = bool(getattr(snapshot, "contribution_refs_valid", True))
        if refs_ok:
            limits.append("贡献分流仅基于经重验的 E2 材料，仍需教师复核。")
            return "存在疑点", OVERALL_DISPOSITIONS["存在疑点"], limits
        limits.append("贡献引用存在失效单元，已取消贡献层升级信号。")

    n1 = any(str(item.get("disposition")) == "N1" for item in findings)
    if n1 or limits:
        return "基本诚信", OVERALL_DISPOSITIONS["基本诚信"], limits
    return "完全诚信", OVERALL_DISPOSITIONS["完全诚信"], limits


def make_integrity_assessment(
    *,
    student_directory: str,
    student_id: str | None,
    lab: str,
    snapshot: Any,
    candidate_findings: Iterable[Mapping[str, Any]] = (),
    evidence: Iterable[Mapping[str, Any]] = (),
    independent_e1: bool = False,
    r1_r2_passed: bool = False,
    rule_registry: Any = None,
    teacher_actions: Iterable[str] = (),
    alternative_explanations: Iterable[str] = (),
    limitations: Iterable[str] = (),
    run_metadata: Mapping[str, Any] | None = None,
) -> IntegrityAssessment:
    findings = [dict(item) for item in candidate_findings if isinstance(item, Mapping)]
    label, disposition, gate_limits = derive_overall_label(
        snapshot=snapshot,
        candidate_findings=findings,
        independent_e1=independent_e1,
        r1_r2_passed=r1_r2_passed,
        rule_registry=rule_registry,
    )
    coverage = _coverage(snapshot)
    access = {
        "analysis_status": _snapshot_value(snapshot, "analysis_status", "unknown"),
        "schema_compatibility": _snapshot_value(snapshot, "compatibility", "unknown"),
        "review_status": _review(snapshot).get("status", "not_run"),
        "overall_decision": _review(snapshot).get("overall_decision"),
        "valid_unit_count": len(_units(snapshot)),
        "invalid_unit_count": len(
            _snapshot_value(snapshot, "invalid_units", ())
            if isinstance(_snapshot_value(snapshot, "invalid_units", ()), (list, tuple))
            else ()
        ),
        "lab_conclusion_valid": bool(getattr(snapshot, "lab_conclusion_valid", True)),
        "contribution_refs_valid": bool(getattr(snapshot, "contribution_refs_valid", True)),
        "contribution_upgrade": label == "存在疑点",
        "lab_conclusion": _lab_conclusion(snapshot),
        "source_manifest": _source_manifest(snapshot),
        "units": [_unit_summary(item) for item in _units(snapshot)],
        "issues": list(_snapshot_value(snapshot, "issues", ()) or ()),
    }
    if hasattr(rule_registry, "to_dict"):
        registry_payload = rule_registry.to_dict()
    elif isinstance(rule_registry, Mapping):
        registry_payload = dict(rule_registry)
    else:
        registry_payload = {}
    if hasattr(rule_registry, "sha256"):
        registry_payload = dict(registry_payload)
        registry_payload["sha256"] = str(rule_registry.sha256)
    all_limits = [str(item) for item in [*limitations, *gate_limits] if str(item).strip()]
    payload = {
        "student_directory": student_directory,
        "student_id": student_id,
        "lab": lab,
        "overall_label": label,
        "overall_disposition": disposition,
        "coverage": coverage,
        "contribution_access": access,
        "contribution_units": [_unit_summary(item) for item in _units(snapshot)],
        "rule_registry": registry_payload,
        "evidence": list(evidence),
        "findings": findings,
        "alternative_explanations": list(alternative_explanations),
        "teacher_actions": list(teacher_actions),
        "limitations": all_limits,
        "run_metadata": dict(run_metadata or {}),
    }
    run_fingerprint = stable_fingerprint(payload)
    return IntegrityAssessment(
        student_directory=student_directory,
        student_id=student_id,
        lab=lab,
        overall_label=label,
        overall_disposition=disposition,
        coverage=coverage,
        contribution_access=access,
        contribution_units=[_unit_summary(item) for item in _units(snapshot)],
        rule_registry=registry_payload,
        evidence=[dict(item) for item in evidence if isinstance(item, Mapping)],
        findings=findings,
        alternative_explanations=[str(item) for item in alternative_explanations],
        teacher_actions=[str(item) for item in teacher_actions],
        limitations=all_limits,
        run_fingerprint=run_fingerprint,
    )


__all__ = [
    "IntegrityAssessment",
    "OVERALL_LABELS",
    "OVERALL_DISPOSITIONS",
    "derive_overall_label",
    "make_integrity_assessment",
    "stable_fingerprint",
]
