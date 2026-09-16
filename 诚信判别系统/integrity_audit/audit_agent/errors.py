class AuditError(Exception):
    """Base error for expected audit failures."""


class ConfigurationError(AuditError):
    """A required runtime configuration value is missing or invalid."""


class DataAccessError(AuditError):
    """The requested student data or artifact cannot be safely accessed."""


class ToolError(AuditError):
    """A model tool call is invalid or exceeds the read-only contract."""


class ModelProtocolError(AuditError):
    """The chat-completions response cannot be interpreted safely."""


class ValidationError(AuditError):
    """A submitted assessment does not meet the evidence contract."""

