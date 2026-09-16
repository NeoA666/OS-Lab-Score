from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Protocol


@dataclass(frozen=True)
class ToolCall:
    """One function call requested by an OpenAI-compatible model."""

    call_id: str
    name: str
    arguments: dict[str, Any]


@dataclass(frozen=True)
class AssistantResponse:
    """Normalized assistant message returned by a model provider."""

    content: str | None
    tool_calls: tuple[ToolCall, ...]
    raw_message: dict[str, Any]


class ChatModel(Protocol):
    """Minimal interface used by the host-controlled agent loop."""

    def complete(
        self,
        messages: list[dict[str, Any]],
        tools: list[dict[str, Any]],
    ) -> AssistantResponse:
        ...


@dataclass(frozen=True)
class AuditRunResult:
    """Validated result returned by an agent loop before report rendering."""

    assessment: dict[str, Any]
    turns: int
    tool_calls: int
    trace_path: str | None

