from __future__ import annotations

import json
import unittest
from dataclasses import dataclass, field
from typing import Any

from audit_agent.client import (
    DEFAULT_NIM_MODEL,
    OpenAICompatibleChatClient,
    OpenAICompatibleConfig,
)
from audit_agent.errors import ConfigurationError
from audit_agent.loop import JsonlTrace


def _event(payload: object) -> list[bytes]:
    value = payload if isinstance(payload, str) else json.dumps(payload, ensure_ascii=False)
    return [f"data: {value}\n".encode(), b"\n"]


@dataclass
class _Response:
    status_code: int
    events: list[object]
    headers: dict[str, str] = field(default_factory=dict)
    closed: bool = False

    def iter_lines(self):
        for event in self.events:
            yield from _event(event)

    def close(self) -> None:
        self.closed = True


class _Transport:
    def __init__(self, responses: list[_Response]) -> None:
        self.responses = responses
        self.requests: list[tuple[Any, float, float]] = []

    def __call__(self, request, connect_timeout, read_timeout):
        self.requests.append((request, connect_timeout, read_timeout))
        return self.responses.pop(0)


class NimClientTests(unittest.TestCase):
    def test_trace_drops_reasoning_and_credential_shaped_text(self) -> None:
        import tempfile
        from pathlib import Path

        with tempfile.TemporaryDirectory() as directory:
            trace = JsonlTrace(Path(directory))
            trace.write(
                "model_response",
                {"reasoning_content": "private", "content": "nvapi-secret-value"},
            )
            trace.close()
            text = next(Path(directory).glob("*.jsonl")).read_text(encoding="utf-8")
        self.assertNotIn("private", text)
        self.assertNotIn("nvapi-secret-value", text)

    def test_environment_uses_nim_and_ignores_legacy_credential(self) -> None:
        with self.assertRaises(ConfigurationError):
            OpenAICompatibleConfig.from_environment({"AUDIT_API_KEY": "old"})
        config = OpenAICompatibleConfig.from_environment({"NVIDIA_API_KEY": "test"})
        self.assertEqual(config.model, DEFAULT_NIM_MODEL)
        self.assertEqual(config.max_tokens, 32768)
        self.assertEqual((config.connect_timeout_seconds, config.read_timeout_seconds), (15.0, 300.0))
        self.assertTrue(config.force_nonempty_content)

    def test_stream_keeps_reasoning_transient_and_reassembles_tool_call(self) -> None:
        response = _Response(
            200,
            [
                {"choices": [{"delta": {"reasoning_content": "private", "content": "ok"}}]},
                {
                    "choices": [
                        {
                            "delta": {
                                "tool_calls": [
                                    {
                                        "index": 0,
                                        "id": "c1",
                                        "function": {"name": "get_", "arguments": "{\"x\":"},
                                    }
                                ]
                            }
                        }
                    ]
                },
                {
                    "choices": [
                        {
                            "delta": {
                                "tool_calls": [
                                    {"index": 0, "function": {"name": "event", "arguments": "1}"}}
                                ]
                            }
                        }
                    ]
                },
                "[DONE]",
            ],
        )
        transport = _Transport([response])
        client = OpenAICompatibleChatClient(
            OpenAICompatibleConfig(api_key="test"), transport=transport, sleep=lambda _: None
        )
        result = client.complete([{"role": "user", "content": "x"}], [{"type": "function"}])
        self.assertEqual(result.content, "ok")
        self.assertEqual(result.reasoning_content, "private")
        self.assertEqual(result.tool_calls[0].name, "get_event")
        self.assertEqual(result.tool_calls[0].arguments, {"x": 1})
        payload = transport.requests[0][0].payload
        self.assertEqual(
            payload["chat_template_kwargs"],
            {"enable_thinking": True, "force_nonempty_content": True},
        )
        self.assertNotIn("response_format", payload)
        self.assertNotIn("nvext", payload)

    def test_embedded_503_retries_with_backoff(self) -> None:
        transport = _Transport(
            [
                _Response(200, [{"object": "error", "error": {"status": 503}}]),
                _Response(200, [{"choices": [{"delta": {"content": "ok"}}]}, "[DONE]"]),
            ]
        )
        waits: list[float] = []
        client = OpenAICompatibleChatClient(
            OpenAICompatibleConfig(api_key="test"), transport=transport, sleep=waits.append
        )
        result = client.complete([{"role": "user", "content": "x"}])
        self.assertEqual(result.content, "ok")
        self.assertEqual(result.attempts, 2)
        self.assertEqual(waits, [2.0])


if __name__ == "__main__":
    unittest.main()
