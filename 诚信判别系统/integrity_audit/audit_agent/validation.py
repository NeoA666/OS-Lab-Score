from __future__ import annotations

import copy
import re
from typing import Any

from .errors import DataAccessError, ValidationError
from .policy import PolicyDocument
from .repository import StudentAuditRepository


DISPOSITION_ORDER = {"N0": 0, "N1": 1, "R1": 2, "R2": 3}
FINDING_ID_PATTERN = re.compile(r"^[A-Za-z][A-Za-z0-9_-]{0,47}$")


def _require_string(value: Any, field: str, maximum: int = 2000) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ValidationError(f"{field} 必须是非空字符串")
    if len(value) > maximum:
        raise ValidationError(f"{field} 过长")
    return value.strip()


def _require_strings(value: Any, field: str, minimum: int = 1, maximum: int = 12) -> list[str]:
    if not isinstance(value, list) or len(value) < minimum or len(value) > maximum:
        raise ValidationError(f"{field} 必须是包含 {minimum} 到 {maximum} 项的数组")
    return [_require_string(item, f"{field}[{index}]") for index, item in enumerate(value)]


class AssessmentValidator:
    """Host-side validation for all model-authored assessment content."""

    def __init__(
        self,
        repository: StudentAuditRepository,
        policy: PolicyDocument,
        contribution_snapshot: Any | None = None,
    ) -> None:
        self.repository = repository
        self.policy = policy
        if contribution_snapshot is None:
            # Loading is deliberately best-effort.  Legacy event-only runs do
            # not have a v3 assessment and must retain their old contract.
            try:
                from .v3_adapter import ContributionAssessmentV3Adapter

                contribution_snapshot = ContributionAssessmentV3Adapter(
                    repository.data_root
                ).load(repository.reference.directory_name, repository.lab)
            except (DataAccessError, OSError, ValueError):
                contribution_snapshot = None
        self.contribution_snapshot = contribution_snapshot

    def validate(self, raw: dict[str, Any]) -> dict[str, Any]:
        if not isinstance(raw, dict):
            raise ValidationError("assessment 必须是对象")
        required = {"overall_disposition", "summary", "data_limitations", "findings"}
        missing = required.difference(raw)
        if missing:
            raise ValidationError(f"assessment 缺少字段：{', '.join(sorted(missing))}")

        overall = raw["overall_disposition"]
        if overall not in DISPOSITION_ORDER:
            raise ValidationError("overall_disposition 不合法")
        summary = _require_string(raw["summary"], "summary")
        limitations = _require_strings(raw["data_limitations"], "data_limitations", minimum=1, maximum=20)
        findings_raw = raw["findings"]
        if not isinstance(findings_raw, list) or len(findings_raw) > 12:
            raise ValidationError("findings 必须是至多 12 项的数组")

        findings: list[dict[str, Any]] = []
        identifiers: set[str] = set()
        for index, finding_raw in enumerate(findings_raw):
            finding = self._validate_finding(finding_raw, index)
            if finding["id"] in identifiers:
                raise ValidationError(f"finding id 重复：{finding['id']}")
            identifiers.add(finding["id"])
            findings.append(finding)

        max_finding_disposition = max(
            (DISPOSITION_ORDER[finding["disposition"]] for finding in findings), default=0
        )
        if DISPOSITION_ORDER[overall] < max_finding_disposition:
            raise ValidationError("综合处理级别不能低于任一风险点的处理级别")
        if not findings and overall != "N0":
            raise ValidationError("没有风险点时综合处理级别只能是 N0")

        return {
            "overall_disposition": overall,
            "summary": summary,
            "data_limitations": limitations,
            "findings": findings,
            "policy_sha256": self.policy.sha256,
            "lab": self.repository.lab,
            "student_id": self.repository.reference.student_id,
        }

    def _validate_finding(self, raw: Any, index: int) -> dict[str, Any]:
        if not isinstance(raw, dict):
            raise ValidationError(f"findings[{index}] 必须是对象")
        required = {
            "id",
            "disposition",
            "rule_refs",
            "observations",
            "limitations",
            "alternative_explanations",
            "teacher_verification",
        }
        missing = required.difference(raw)
        if missing:
            raise ValidationError(f"findings[{index}] 缺少字段：{', '.join(sorted(missing))}")

        identifier = _require_string(raw["id"], f"findings[{index}].id", 50)
        if not FINDING_ID_PATTERN.fullmatch(identifier):
            raise ValidationError(f"findings[{index}].id 格式不合法")
        disposition = raw["disposition"]
        if disposition not in DISPOSITION_ORDER:
            raise ValidationError(f"findings[{index}].disposition 不合法")

        rule_refs = _require_strings(raw["rule_refs"], f"findings[{index}].rule_refs", 1, 6)
        for rule_ref in rule_refs:
            try:
                self.policy.get_section(rule_ref)
            except DataAccessError as error:
                raise ValidationError(f"finding {identifier} 引用了不存在的规则章节：{rule_ref}") from error

        observations = _require_strings(raw["observations"], f"findings[{index}].observations", 1, 8)
        finding_limitations = _require_strings(raw["limitations"], f"findings[{index}].limitations", 1, 8)
        alternatives = _require_strings(
            raw["alternative_explanations"],
            f"findings[{index}].alternative_explanations",
            1,
            8,
        )
        verification = _require_strings(
            raw["teacher_verification"], f"findings[{index}].teacher_verification", 1, 8
        )
        evidence_input: list[Any] = []
        if "evidence" in raw:
            if not isinstance(raw["evidence"], list):
                raise ValidationError(f"findings[{index}].evidence 必须是数组")
            evidence_input.extend(raw["evidence"])
        if "evidence_refs" in raw:
            if not isinstance(raw["evidence_refs"], list):
                raise ValidationError(f"findings[{index}].evidence_refs 必须是数组")
            evidence_input.extend(
                {"kind": "v3", "evidence_level": item.get("evidence_level", "E2"), **item}
                if isinstance(item, dict)
                else item
                for item in raw["evidence_refs"]
            )
        contribution_evidence = raw.get("contribution_evidence")
        if "contribution_evidence" in raw and not isinstance(contribution_evidence, list):
            raise ValidationError(f"findings[{index}].contribution_evidence 必须是数组")
        if isinstance(contribution_evidence, list):
            for item_index, item in enumerate(contribution_evidence):
                if not isinstance(item, dict):
                    raise ValidationError(
                        f"findings[{index}].contribution_evidence[{item_index}] 必须是对象"
                    )
                evidence_input.append(
                    {
                        "kind": "v3",
                        "evidence_level": item.get("evidence_level", "E2"),
                        **item,
                    }
                )
        if not evidence_input:
            raise ValidationError(
                f"findings[{index}] 必须包含至少一项 evidence、evidence_refs 或 contribution_evidence"
            )
        evidence = self._validate_evidence(evidence_input, identifier)

        if disposition in {"R1", "R2"} and not any(
            item["evidence_level"] == "E1" for item in evidence
        ):
            raise ValidationError(f"{identifier} 为 {disposition}，但没有可用的 E1 原始证据")

        return {
            "id": identifier,
            "disposition": disposition,
            "rule_refs": rule_refs,
            "observations": observations,
            "evidence": evidence,
            "evidence_refs": [
                ref
                for item in evidence
                for ref in item.get("evidence_refs", [])
                if isinstance(ref, dict)
            ],
            "limitations": finding_limitations,
            "alternative_explanations": alternatives,
            "teacher_verification": verification,
        }

    def _validate_evidence(self, raw: Any, finding_id: str) -> list[dict[str, Any]]:
        if not isinstance(raw, list) or not raw or len(raw) > 8:
            raise ValidationError(f"{finding_id}.evidence 必须是包含 1 到 8 项的数组")

        evidence: list[dict[str, Any]] = []
        for index, item in enumerate(raw):
            if not isinstance(item, dict):
                raise ValidationError(f"{finding_id}.evidence[{index}] 必须是对象")
            reported_level = item.get("evidence_level")
            is_v3 = (
                item.get("kind") == "v3"
                or "unit_id" in item
                or "evidence_refs" in item
                or "evidence_ref" in item
                or "source_id" in item
            )
            if reported_level is None and is_v3:
                reported_level = "E2"
            if reported_level not in {"E1", "E2"}:
                raise ValidationError(f"{finding_id}.evidence[{index}].evidence_level 不合法")
            # v3 contribution evidence is intentionally part of the same
            # evidence array as legacy timeline events.  The host decides the
            # actual level after re-opening the fixed, hashed source range.
            if is_v3:
                if "unit_id" not in item and "evidence_refs" not in item and "evidence_ref" not in item:
                    evidence.append(self._validate_direct_v3_evidence(item, finding_id, index, reported_level))
                    continue
                evidence.append(self._validate_v3_evidence(item, finding_id, index, reported_level))
                continue

            event_id = _require_string(item.get("event_id"), f"{finding_id}.evidence[{index}].event_id", 300)
            quote = _require_string(item.get("quote"), f"{finding_id}.evidence[{index}].quote", 1500)
            try:
                resolved = self.repository.get_event(event_id)
            except DataAccessError as error:
                raise ValidationError(f"{finding_id} 引用了不在当前 lab 的事件：{event_id}") from error
            if not self.repository.quote_matches_event(event_id, quote):
                raise ValidationError(f"{finding_id} 的引文不在事件 {event_id} 中")
            actual_level = resolved["evidence_level"]
            if reported_level != actual_level:
                raise ValidationError(
                    f"{finding_id} 将事件 {event_id} 标为 {reported_level}，但当前可用级别是 {actual_level}"
                )
            evidence.append(
                {
                    "kind": "event",
                    "event_id": event_id,
                    "quote": quote,
                    "evidence_level": actual_level,
                    "provenance": copy.deepcopy(resolved["provenance"]),
                }
            )
        return evidence

    def _validate_v3_evidence(
        self,
        item: dict[str, Any],
        finding_id: str,
        index: int,
        reported_level: str,
    ) -> dict[str, Any]:
        """Revalidate one model-cited contribution unit and its source refs."""

        field = f"{finding_id}.evidence[{index}]"
        if item.get("kind") not in {None, "v3"}:
            raise ValidationError(f"{field}.kind 不合法")
        unit_id = _require_string(item.get("unit_id"), f"{field}.unit_id", 200)
        snapshot = self.contribution_snapshot
        if snapshot is None or not bool(getattr(snapshot, "assessment_available", False)):
            raise ValidationError(f"{field} 引用了不可用的 v3 assessment")
        if str(getattr(snapshot, "assessment_status", "")) != "complete":
            raise ValidationError(f"{field} 的 v3 assessment 状态不是 complete")
        if getattr(snapshot, "compatibility", "incompatible") != "compatible":
            raise ValidationError(f"{field} 的 v3 assessment schema 不兼容")
        try:
            unit = snapshot.unit(unit_id)
        except (DataAccessError, KeyError) as error:
            raise ValidationError(f"{field} 引用了不存在的 contribution unit：{unit_id}") from error
        if not bool(getattr(unit, "valid", False)):
            raise ValidationError(f"{field} 引用了未通过宿主重验的 contribution unit：{unit_id}")
        if unit_id in getattr(snapshot, "disagreement_unit_ids", frozenset()):
            raise ValidationError(f"{field} 引用了独立复核有分歧的 contribution unit：{unit_id}")

        refs_raw = item.get("evidence_refs")
        if refs_raw is None and isinstance(item.get("evidence_ref"), dict):
            refs_raw = [item["evidence_ref"]]
        if not isinstance(refs_raw, list) or not refs_raw or len(refs_raw) > 8:
            raise ValidationError(f"{field}.evidence_refs 必须是包含 1 到 8 项的数组")

        canonical_refs = tuple(getattr(unit, "evidence_refs", ()))
        if not canonical_refs:
            raise ValidationError(f"{field} 的 contribution unit 没有可引用来源")
        normalized_refs: list[dict[str, Any]] = []
        for ref_index, ref_value in enumerate(refs_raw):
            if not isinstance(ref_value, dict):
                raise ValidationError(f"{field}.evidence_refs[{ref_index}] 必须是对象")
            source_id = ref_value.get("source_id")
            if not isinstance(source_id, str) or not source_id:
                raise ValidationError(f"{field}.evidence_refs[{ref_index}].source_id 无效")
            # A model may select a subset of the unit's refs, but it cannot
            # invent a new path, hash, range, or excerpt.
            match = next(
                (
                    ref
                    for ref in canonical_refs
                    if _same_v3_ref(ref_value, ref)
                ),
                None,
            )
            if match is None:
                raise ValidationError(
                    f"{field}.evidence_refs[{ref_index}] 未与 assessment 中的已验证引用一致"
                )
            actual_level = str(getattr(match, "evidence_level", "E2"))
            if reported_level != actual_level:
                raise ValidationError(
                    f"{field} 将 v3 引用标为 {reported_level}，但宿主重验级别是 {actual_level}"
                )
            # Re-open the bounded range so a file mutation between adapter
            # load and submission is detected before the report is written.
            try:
                snapshot.read_reference(ref_value)
            except (DataAccessError, OSError, ValueError) as error:
                raise ValidationError(f"{field}.evidence_refs[{ref_index}] 读取校验失败：{error}") from error
            normalized_refs.append(match.to_dict() if hasattr(match, "to_dict") else copy.deepcopy(ref_value))

        return {
            "kind": "v3",
            "unit_id": unit_id,
            "unit_type": str(getattr(unit, "unit_type", "unknown")),
            "unit_label": str(getattr(unit, "label", "indeterminate")),
            "unit_confidence": str(getattr(unit, "confidence", "weak")),
            "evidence_level": str(getattr(canonical_refs[0], "evidence_level", "E2")),
            "evidence_refs": normalized_refs,
        }

    def _validate_direct_v3_evidence(
        self,
        item: dict[str, Any],
        finding_id: str,
        index: int,
        reported_level: str,
    ) -> dict[str, Any]:
        """Validate a direct source-range reference without a unit wrapper."""

        field = f"{finding_id}.evidence[{index}]"
        snapshot = self.contribution_snapshot
        if snapshot is None or not bool(getattr(snapshot, "assessment_available", False)):
            raise ValidationError(f"{field} 引用了不可用的 v3 assessment")
        status = getattr(snapshot, "assessment_status", None)
        if status is None:
            status = getattr(snapshot, "analysis_status", None)
        if status != "complete":
            raise ValidationError(f"{field} 的 v3 assessment 状态不是 complete")
        if getattr(snapshot, "compatibility", "incompatible") != "compatible":
            raise ValidationError(f"{field} 的 v3 assessment schema 不兼容")
        source_id = item.get("source_id")
        if not isinstance(source_id, str) or not source_id:
            raise ValidationError(f"{field}.source_id 无效")
        source = getattr(snapshot, "source_by_id", {}).get(source_id)
        if source is None or not bool(getattr(source, "valid", False)):
            raise ValidationError(f"{field}.source_id 不属于当前且已验证的 source_manifest")
        ref_keys = ("source_id", "relative_path", "sha256", "line_start", "line_end", "excerpt")
        if any(key not in item for key in ref_keys):
            raise ValidationError(f"{field} 缺少 source_id、路径、哈希、范围或摘录")
        canonical = next(
            (ref for unit in getattr(snapshot, "contribution_units", ()) for ref in getattr(unit, "evidence_refs", ())
             if _same_v3_ref(item, ref)),
            None,
        )
        # Direct references need not belong to a contribution unit, but all
        # identity fields must still match the current source manifest.
        if item.get("relative_path") != source.relative_path or item.get("sha256") != source.sha256:
            raise ValidationError(f"{field} 的路径或哈希与 source_manifest 不一致")
        try:
            snapshot.read_reference(item)
        except (DataAccessError, OSError, ValueError) as error:
            raise ValidationError(f"{field} 读取校验失败：{error}") from error
        actual_level = "E2"
        if reported_level != actual_level:
            raise ValidationError(f"{field} 将 v3 引用标为 {reported_level}，但宿主重验级别是 E2")
        normalized = canonical.to_dict() if canonical is not None else dict(item)
        normalized["kind"] = "v3"
        normalized["evidence_level"] = actual_level
        normalized["valid"] = True
        return {
            "kind": "v3",
            "evidence_level": actual_level,
            "evidence_refs": [normalized],
            "source_id": source_id,
        }


def _same_v3_ref(value: dict[str, Any], canonical: Any) -> bool:
    """Compare all persisted identity fields without trusting model labels."""

    if hasattr(canonical, "to_dict"):
        expected = canonical.to_dict()
    elif isinstance(canonical, dict):
        expected = canonical
    else:
        return False
    keys = ("source_id", "relative_path", "sha256", "line_start", "line_end", "excerpt")
    return all(value.get(key) == expected.get(key) for key in keys)
