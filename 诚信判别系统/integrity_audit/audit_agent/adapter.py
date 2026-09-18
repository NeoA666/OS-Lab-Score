"""Compatibility import path for the v3 contribution assessment adapter."""

from .v3_adapter import (
    ANALYSIS_STATUSES,
    CONFIDENCE_VALUES,
    ContributionAssessmentV3Adapter,
    DEFAULT_DATA_ROOT,
    EvidenceRef,
    SOURCE_KINDS,
    SUPPORTED_LABS,
    SourceRecord,
    StudentLabSnapshot,
    UNIT_LABELS,
    V3ContractError,
    V3_SCHEMA_VERSION,
    ValidatedContributionUnit,
)

__all__ = [
    "ANALYSIS_STATUSES",
    "CONFIDENCE_VALUES",
    "ContributionAssessmentV3Adapter",
    "DEFAULT_DATA_ROOT",
    "EvidenceRef",
    "SOURCE_KINDS",
    "SUPPORTED_LABS",
    "SourceRecord",
    "StudentLabSnapshot",
    "UNIT_LABELS",
    "V3ContractError",
    "V3_SCHEMA_VERSION",
    "ValidatedContributionUnit",
]
