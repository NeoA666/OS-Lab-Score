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

    def __init__(self, repository: StudentAuditRepository, policy: PolicyDocument) -> None:
        self.repository = repository
        self.policy = policy

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
            "evidence",
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
        evidence = self._validate_evidence(raw["evidence"], identifier)

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
            event_id = _require_string(item.get("event_id"), f"{finding_id}.evidence[{index}].event_id", 300)
            quote = _require_string(item.get("quote"), f"{finding_id}.evidence[{index}].quote", 1500)
            reported_level = item.get("evidence_level")
            if reported_level not in {"E1", "E2"}:
                raise ValidationError(f"{finding_id}.evidence[{index}].evidence_level 不合法")
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
                    "event_id": event_id,
                    "quote": quote,
                    "evidence_level": actual_level,
                    "provenance": copy.deepcopy(resolved["provenance"]),
                }
            )
        return evidence

