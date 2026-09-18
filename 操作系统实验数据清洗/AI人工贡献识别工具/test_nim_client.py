from __future__ import annotations

import json
import unittest
from dataclasses import dataclass, field

from contribution_recognition.nim_client import NimStreamingClient
from contribution_recognition.protocol import NimConfig, NimConfigurationError, NimResponseTruncatedError


@dataclass
class _Response:
    status_code: int
    lines: list[bytes]
    headers: dict[str, str] = field(default_factory=dict)
    closed: bool = False

    def iter_lines(self):
        return iter(self.lines)

    def close(self) -> None:
        self.closed = True


def _event(payload: object) -> list[bytes]:
    encoded = payload if isinstance(payload, str) else json.dumps(payload, ensure_ascii=False)
    return [f"data: {encoded}\n".encode(), b"\n"]


class _SequenceTransport:
    def __init__(self, responses: list[_Response]) -> None:
        self.responses = responses
        self.requests = []

    def __call__(self, request, connect_timeout_seconds, read_timeout_seconds):
        self.requests.append((request, connect_timeout_seconds, read_timeout_seconds))
        return self.responses.pop(0)


class NimStreamingClientTests(unittest.TestCase):
    def test_missing_credential_diagnostic_does_not_name_the_environment_variable(self) -> None:
        with self.assertRaises(NimConfigurationError) as context:
            NimConfig.from_environment({})

        self.assertIn("模型服务凭据", str(context.exception))
        self.assertNotIn("NVIDIA_API_KEY", str(context.exception))

    def test_visible_content_omits_reasoning_and_uses_required_payload(self) -> None:
        response = _Response(
            200,
            _event(
                {
                    "model": "test-model",
                    "choices": [
                        {"delta": {"reasoning_content": "private", "content": "{\"ok\":"}},
                    ],
                }
            )
            + _event({"choices": [{"delta": {"content": "true}"}}], "usage": {"total_tokens": 9}})
            + _event("[DONE]"),
            {"x-request-id": "request-1"},
        )
        transport = _SequenceTransport([response])
        client = NimStreamingClient(NimConfig(api_key="test-key"), transport=transport, sleep=lambda _: None)

        result = client.complete([{"role": "user", "content": "hello"}])

        request, connect_timeout, read_timeout = transport.requests[0]
        self.assertEqual(result.content, '{"ok":true}')
        self.assertEqual(result.request_id, "request-1")
        self.assertEqual(result.usage, {"total_tokens": 9})
        self.assertNotIn("private", result.content)
        self.assertEqual(request.payload["chat_template_kwargs"], {"enable_thinking": True})
        self.assertEqual(request.payload["max_tokens"], 32768)
        self.assertEqual((connect_timeout, read_timeout), (15.0, 300.0))
        self.assertTrue(response.closed)

    def test_retries_embedded_503_with_backoff(self) -> None:
        unavailable = _Response(
            200,
            _event({"object": "error", "error": {"status": 503}}),
        )
        success = _Response(
            200,
            _event({"choices": [{"delta": {"content": "ok"}}]}) + _event("[DONE]"),
        )
        transport = _SequenceTransport([unavailable, success])
        waits: list[float] = []
        client = NimStreamingClient(
            NimConfig(api_key="test-key"),
            transport=transport,
            sleep=waits.append,
        )

        result = client.complete([{"role": "user", "content": "hello"}])

        self.assertEqual(result.content, "ok")
        self.assertEqual(result.attempts, 2)
        self.assertEqual(waits, [2.0])
        self.assertTrue(unavailable.closed)
        self.assertTrue(success.closed)

    def test_token_limited_completion_is_rejected(self) -> None:
        response = _Response(
            200,
            _event({"choices": [{"delta": {"content": "partial"}, "finish_reason": "length"}]})
            + _event("[DONE]"),
        )
        client = NimStreamingClient(
            NimConfig(api_key="test-key"),
            transport=_SequenceTransport([response]),
            sleep=lambda _: None,
        )

        with self.assertRaises(NimResponseTruncatedError):
            client.complete([{"role": "user", "content": "hello"}])


if __name__ == "__main__":
    unittest.main()
