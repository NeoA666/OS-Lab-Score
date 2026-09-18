"""Machine-readable Lab rule registry for integrity assessment routing.

Rules remain owned by the integrity system.  Contribution labels never enable
a risk path by themselves: the registry must explicitly enable a Lab and the
host must have verified the referenced evidence.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass, replace
from pathlib import Path
from typing import Any, Iterable, Mapping

from .errors import DataAccessError


LABS = tuple("lab" + str(index) for index in range(9))
DEFAULT_RULE_FILENAMES = {
    "lab0": "lab0课程规则边界.md",
}


def _sha256(path: Path) -> str | None:
    if not path.is_file():
        return None
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


@dataclass(frozen=True)
class LabRule:
    """One immutable machine rule registration."""

    lab: str
    enabled: bool = False
    rule_file: str | None = None
    rule_sha256: str | None = None
    evidence_level: str = "E2"
    contribution_routing_enabled: bool = False
    teacher_actions: tuple[str, ...] = ()
    notes: tuple[str, ...] = ()

    @property
    def configured(self) -> bool:
        return bool(self.rule_file and self.rule_sha256)

    @property
    def risk_routing_enabled(self) -> bool:
        return bool(self.enabled and self.contribution_routing_enabled)

    def to_dict(self) -> dict[str, Any]:
        return {
            "lab": self.lab,
            "enabled": self.enabled,
            "rule_file": self.rule_file,
            "rule_sha256": self.rule_sha256,
            "evidence_level": self.evidence_level,
            "contribution_routing_enabled": self.contribution_routing_enabled,
            "teacher_actions": list(self.teacher_actions),
            "notes": list(self.notes),
        }


class RuleRegistry:
    """Registry loaded from the integrity rules directory.

    The first release enables only Lab0.  Other Labs are represented
    explicitly as disabled and missing rules, so absence cannot silently
    become a permissive default.
    """

    def __init__(
        self,
        rules_root: Path | None = None,
        *,
        registrations: Mapping[str, LabRule | Mapping[str, Any]] | None = None,
    ) -> None:
        self.rules_root = Path(rules_root).expanduser().resolve() if rules_root else None
        if registrations is None:
            self._rules = self._default_rules()
        else:
            self._rules = self._coerce_registrations(registrations)

    def _default_rules(self) -> dict[str, LabRule]:
        result: dict[str, LabRule] = {}
        for lab in LABS:
            path = self._find_rule_file(lab)
            digest = _sha256(path) if path else None
            if lab == "lab0" and path and digest:
                result[lab] = LabRule(
                    lab=lab,
                    enabled=True,
                    rule_file=str(path),
                    rule_sha256=digest,
                    evidence_level="E1",
                    contribution_routing_enabled=True,
                    teacher_actions=(
                        "仅在独立 E1 与 R1/R2 校验成立时进入高风险待核实。",
                        "贡献层 E2 只作为已启用规则的存在疑点分流线索。",
                    ),
                )
            else:
                result[lab] = LabRule(
                    lab=lab,
                    enabled=False,
                    rule_file=str(path) if path else None,
                    rule_sha256=digest,
                    evidence_level="E2",
                    contribution_routing_enabled=False,
                    teacher_actions=("当前 Lab 尚未注册正式诚信规则。",),
                    notes=("缺规则或尚未启用；不得由贡献标签自动升级风险。",),
                )
        return result

    def _find_rule_file(self, lab: str) -> Path | None:
        if self.rules_root is None:
            # The package is normally launched from the repository checkout.
            candidate = Path(__file__).resolve().parents[2] / (
                DEFAULT_RULE_FILENAMES.get(lab, lab + "课程规则边界.md")
            )
            return candidate if candidate.is_file() else None
        # A PolicyDocument path is a convenient input for the single enabled
        # Lab0 rule.  Treat it as the rule file itself instead of appending a
        # second filename to it.
        if self.rules_root.is_file():
            return self.rules_root if lab == "lab0" else None
        candidates = [
            self.rules_root / DEFAULT_RULE_FILENAMES.get(lab, lab + "课程规则边界.md"),
            self.rules_root / (lab + ".md"),
            self.rules_root / (lab + "规则.md"),
        ]
        return next((item for item in candidates if item.is_file()), None)

    @staticmethod
    def _coerce_registrations(
        registrations: Mapping[str, LabRule | Mapping[str, Any]],
    ) -> dict[str, LabRule]:
        result: dict[str, LabRule] = {}
        for lab in LABS:
            value = registrations.get(lab)
            if isinstance(value, LabRule):
                rule = value
            elif isinstance(value, Mapping):
                rule = LabRule(
                    lab=lab,
                    enabled=bool(value.get("enabled", False)),
                    rule_file=value.get("rule_file") if isinstance(value.get("rule_file"), str) else None,
                    rule_sha256=value.get("rule_sha256") if isinstance(value.get("rule_sha256"), str) else None,
                    evidence_level=str(value.get("evidence_level", "E2")),
                    contribution_routing_enabled=bool(value.get("contribution_routing_enabled", False)),
                    teacher_actions=tuple(item for item in value.get("teacher_actions", ()) if isinstance(item, str)),
                    notes=tuple(item for item in value.get("notes", ()) if isinstance(item, str)),
                )
            else:
                rule = LabRule(lab=lab)
            if rule.lab != lab:
                raise DataAccessError("规则注册表中的 Lab 键与 rule.lab 不一致：" + lab)
            result[lab] = rule
        unknown = set(registrations) - set(LABS)
        if unknown:
            raise DataAccessError("规则注册表包含未知 Lab：" + ", ".join(sorted(unknown)))
        return result

    @classmethod
    def from_json(cls, path: Path) -> "RuleRegistry":
        try:
            value = json.loads(Path(path).read_text(encoding="utf-8"))
        except (OSError, UnicodeError, json.JSONDecodeError) as error:
            raise DataAccessError("规则注册表无法读取：" + str(path)) from error
        if not isinstance(value, dict):
            raise DataAccessError("规则注册表根节点必须是对象")
        registrations = value.get("labs", value)
        if not isinstance(registrations, Mapping):
            raise DataAccessError("规则注册表 labs 必须是对象")
        return cls(Path(path).parent, registrations=registrations)

    def get(self, lab: str) -> LabRule:
        if lab not in self._rules:
            raise DataAccessError("未知 Lab：" + str(lab))
        return self._rules[lab]

    def for_lab(self, lab: str) -> LabRule:
        return self.get(lab)

    def register(self, rule: LabRule) -> None:
        if rule.lab not in LABS:
            raise DataAccessError("未知 Lab：" + rule.lab)
        self._rules[rule.lab] = rule

    def with_rule(self, rule: LabRule) -> "RuleRegistry":
        values = dict(self._rules)
        values[rule.lab] = rule
        return RuleRegistry(self.rules_root, registrations=values)

    def all(self) -> tuple[LabRule, ...]:
        return tuple(self._rules[lab] for lab in LABS)

    def to_dict(self) -> dict[str, Any]:
        return {
            "schema_version": "integrity-rule-registry/v1",
            "labs": {lab: self._rules[lab].to_dict() for lab in LABS},
        }

    @property
    def sha256(self) -> str:
        encoded = json.dumps(
            self.to_dict(), ensure_ascii=False, sort_keys=True, separators=(",", ":")
        ).encode("utf-8")
        return hashlib.sha256(encoded).hexdigest()

    def contribution_routing_enabled(self, lab: str) -> bool:
        rule = self.get(lab)
        return rule.risk_routing_enabled

    def can_route_contribution(
        self,
        lab: str,
        *,
        evidence_levels: Iterable[str] = (),
        review_agreed: bool = False,
    ) -> bool:
        rule = self.get(lab)
        if not rule.risk_routing_enabled or not review_agreed:
            return False
        levels = tuple(evidence_levels)
        # The initial Lab0 contribution route is intentionally E2. Higher-risk
        # labels must still be gated by the host's independent E1 policy.
        return all(level in {"E1", "E2"} for level in levels)

    def teacher_actions(self, lab: str) -> tuple[str, ...]:
        return self.get(lab).teacher_actions


def default_rule_registry(rules_root: Path | None = None) -> RuleRegistry:
    return RuleRegistry(rules_root)


__all__ = ["LABS", "LabRule", "RuleRegistry", "default_rule_registry"]
