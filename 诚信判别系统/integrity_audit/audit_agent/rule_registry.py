"""Compatibility exports for the canonical machine rule registry.

The implementation lives in :mod:`audit_agent.rules`; this module remains as
an import boundary for callers of the earlier prototype path.
"""

from .rules import LABS, LabRule, RuleRegistry, default_rule_registry

__all__ = ["LABS", "LabRule", "RuleRegistry", "default_rule_registry"]
