"""Exceptions raised by the contribution-recognition data layer."""

from __future__ import annotations


class ContributionRecognitionError(Exception):
    """Base class for errors the CLI can present as a task-level failure."""


class DataAccessError(ContributionRecognitionError):
    """Raised when a cleaned artifact is missing, unsafe, or malformed."""


class InvalidReferenceError(DataAccessError):
    """Raised when a student or lab selector is not a supported logical identifier."""


class SnapshotValidationError(ContributionRecognitionError):
    """Raised when a caller attempts to construct an internally inconsistent snapshot."""
