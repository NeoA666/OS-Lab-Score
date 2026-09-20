"""Credential redaction for text that leaves the cleaned-data boundary."""

from __future__ import annotations

import re
from typing import Any


REDACTED = "[REDACTED]"

_SENSITIVE_NAME = (
    r"(?:[A-Za-z][A-Za-z0-9_-]*[_-])*"
    r"(?:api[_-]?key|access[_-]?token|auth(?:orization|entication)?[_-]?token|"
    r"refresh[_-]?token|id[_-]?token|client[_-]?secret|secret(?:[_-]?(?:key|token))?|"
    r"password|passwd|private[_-]?key)"
)
_ASSIGNMENT_RE = re.compile(
    rf"""(?ix)
    (?P<prefix>(?<![A-Za-z0-9])['\"]?{_SENSITIVE_NAME}['\"]?\s*(?:=|:)\s*)
    (?P<value>"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[^\s,;}}\]\)]+)
    """
)
_QUERY_RE = re.compile(
    rf"(?ix)(?P<prefix>[?&]{_SENSITIVE_NAME}=)(?P<value>[^&#\s]+)"
)
_BEARER_RE = re.compile(r"(?i)(?P<prefix>\bbearer\s+)(?P<value>[^\s,;]+)")
_PRIVATE_KEY_RE = re.compile(
    r"-----BEGIN(?: [A-Z0-9]+)* PRIVATE KEY-----.*?-----END(?: [A-Z0-9]+)* PRIVATE KEY-----",
    re.DOTALL,
)
_OPAQUE_TOKEN_RE = re.compile(
    r"(?ix)\b(?:"
    r"nvapi-[A-Za-z0-9_-]{8,}|"
    r"sk-(?:proj-)?[A-Za-z0-9_-]{12,}|"
    r"gh[pousr]_[A-Za-z0-9_]{12,}|"
    r"github_pat_[A-Za-z0-9_]{12,}|"
    r"AKIA[0-9A-Z]{16}"
    r")\b"
)


def _replace_assignment(match: re.Match[str]) -> str:
    value = match.group("value")
    if value.startswith('"'):
        return f'{match.group("prefix")}"{REDACTED}"'
    if value.startswith("'"):
        return f"{match.group('prefix')}'{REDACTED}'"
    return f"{match.group('prefix')}{REDACTED}"


def redact_sensitive_text(value: str) -> str:
    """Replace credential-shaped substrings while preserving surrounding evidence."""

    text = value

    def replace_private_key(match: re.Match[str]) -> str:
        # Source citations use original physical line numbers.  Preserve every
        # newline hidden inside a PEM block so a redacted excerpt remains
        # aligned with the immutable source line map.
        return REDACTED + "\n" * match.group(0).count("\n")

    text = _PRIVATE_KEY_RE.sub(replace_private_key, text)
    text = _ASSIGNMENT_RE.sub(_replace_assignment, text)
    text = _QUERY_RE.sub(lambda match: f"{match.group('prefix')}{REDACTED}", text)
    text = _BEARER_RE.sub(lambda match: f"{match.group('prefix')}{REDACTED}", text)
    return _OPAQUE_TOKEN_RE.sub(REDACTED, text)


def redact_sensitive_value(value: Any) -> Any:
    """Recursively redact strings without changing the surrounding JSON shape."""

    if isinstance(value, str):
        return redact_sensitive_text(value)
    if isinstance(value, dict):
        return {key: redact_sensitive_value(item) for key, item in value.items()}
    if isinstance(value, list):
        return [redact_sensitive_value(item) for item in value]
    if isinstance(value, tuple):
        return tuple(redact_sensitive_value(item) for item in value)
    return value
