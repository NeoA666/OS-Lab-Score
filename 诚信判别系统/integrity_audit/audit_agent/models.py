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
    # NIM may return a private reasoning stream when thinking is enabled.  The
    # host loop may carry this value in memory into the next request, but it is
    # deliberately kept out of persisted trace/assessment objects.
    reasoning_content: str | None = None
    # Non-sensitive transport metadata is useful for diagnostics and tests;
    # callers must not persist provider response bodies.
    usage: dict[str, Any] | None = None
    request_id: str | None = None
    attempts: int = 1
    model: str | None = None
    elapsed_seconds: float | None = None


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
