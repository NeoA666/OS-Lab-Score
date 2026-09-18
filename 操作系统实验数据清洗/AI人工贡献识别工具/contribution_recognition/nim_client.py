"""Standard-library streaming client for NVIDIA's OpenAI-compatible NIM API."""

from __future__ import annotations

import http.client
import json
import socket
import ssl
import time
from collections.abc import Iterable, Mapping, Sequence
from dataclasses import dataclass
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

from .protocol import (
    Clock,
    NimConfig,
    NimError,
    NimProtocolError,
    NimRequest,
    NimResponse,
    NimResponseTruncatedError,
    NimStreamError,
    NimStreamResponse,
    NimStreamTruncatedError,
    NimTransport,
    NimTransportError,
    Sleep,
)


RETRY_DELAYS_SECONDS = (2.0, 4.0, 8.0, 16.0)
MAX_RETRIES = len(RETRY_DELAYS_SECONDS)


class NimStreamingClient:
    """Call NIM chat completions and retain only visible streamed content.

    ``transport``, ``clock``, and ``sleep`` are injectable for tests.  A custom
    transport receives a :class:`NimRequest` and separate connection/read
    timeout values, then returns an object satisfying ``NimStreamResponse``.
    """

    def __init__(
        self,
        config: NimConfig,
        *,
        transport: NimTransport | None = None,
        clock: Clock = time.monotonic,
        sleep: Sleep = time.sleep,
    ) -> None:
        self.config = config
        self._transport = transport or _urllib_streaming_transport
        self._clock = clock
        self._sleep = sleep

    def complete(self, messages: Sequence[Mapping[str, Any]]) -> NimResponse:
        """Return the visible completion for OpenAI-format ``messages``.

        Provider overloads and interrupted streams retry at 2, 4, 8, and 16
        seconds.  A retry starts a fresh completion and discards partial text
        from the failed stream.
        """

        normalized_messages = _normalize_messages(messages)
        request = NimRequest(
            endpoint=self.config.endpoint,
            api_key=self.config.api_key,
            payload={
                "model": self.config.model,
                "messages": normalized_messages,
                "stream": True,
                "chat_template_kwargs": {"enable_thinking": True},
                "max_tokens": self.config.max_tokens,
                "temperature": self.config.temperature,
                "top_p": self.config.top_p,
            },
        )
        started_at = self._clock()

        for attempt in range(1, MAX_RETRIES + 2):
            response: NimStreamResponse | None = None
            try:
                response = self._transport(
                    request,
                    self.config.connect_timeout_seconds,
                    self.config.read_timeout_seconds,
                )
                if response.status_code < 200 or response.status_code >= 300:
                    raise NimTransportError(
                        f"NVIDIA API 返回 HTTP {response.status_code}",
                        retryable=_is_retryable_status(response.status_code),
                        status_code=response.status_code,
                    )
                content, usage, response_model = _consume_sse(response.iter_lines())
                return NimResponse(
                    content=content,
                    model=response_model or self.config.model,
                    usage=usage,
                    request_id=_request_id(response.headers),
                    attempts=attempt,
                    elapsed_seconds=max(0.0, self._clock() - started_at),
                )
            except NimError as error:
                if not error.retryable or attempt > MAX_RETRIES:
                    raise
                self._sleep(RETRY_DELAYS_SECONDS[attempt - 1])
            except (URLError, TimeoutError, socket.timeout, OSError, ssl.SSLError, http.client.HTTPException) as error:
                transport_error = NimTransportError(
                    "无法完成 NVIDIA API 流式请求",
                    retryable=True,
                )
                if attempt > MAX_RETRIES:
                    raise transport_error from error
                self._sleep(RETRY_DELAYS_SECONDS[attempt - 1])
            finally:
                if response is not None:
                    _close_quietly(response)

        # The loop always returns or raises.  This protects type checkers and
        # keeps a future retry-policy edit from producing a silent None result.
        raise NimTransportError("NVIDIA API 重试状态异常", retryable=True)


def _normalize_messages(messages: Sequence[Mapping[str, Any]]) -> list[dict[str, Any]]:
    if isinstance(messages, (str, bytes)):
        raise NimProtocolError("messages 必须是 OpenAI message 对象数组")
    result: list[dict[str, Any]] = []
    for index, message in enumerate(messages):
        if not isinstance(message, Mapping):
            raise NimProtocolError(f"第 {index} 条 message 不是对象")
        role = message.get("role")
        if not isinstance(role, str) or not role:
            raise NimProtocolError(f"第 {index} 条 message 缺少 role")
        # Copy the mapping so caller mutation cannot alter a retry's request.
        result.append(dict(message))
    if not result:
        raise NimProtocolError("messages 不能为空")
    return result


def _is_retryable_status(status_code: int) -> bool:
    return status_code == 429 or 500 <= status_code <= 599


def _request_id(headers: Mapping[str, str]) -> str | None:
    for name in ("x-request-id", "x-nvidia-request-id", "request-id"):
        value = headers.get(name)
        if value:
            return str(value)
    # Some HTTP header mappings preserve source casing rather than normalizing.
    for name, value in headers.items():
        if name.lower() in {"x-request-id", "x-nvidia-request-id", "request-id"} and value:
            return str(value)
    return None


def _consume_sse(lines: Iterable[bytes | str]) -> tuple[str, dict[str, Any] | None, str | None]:
    """Parse an SSE stream and return visible content, usage, and model.

    The parser does not retain ``reasoning_content``.  It deliberately treats a
    missing ``[DONE]`` marker as a retryable interrupted stream, even when the
    HTTP status was 200.
    """

    data_lines: list[str] = []
    event_name: str | None = None
    visible_parts: list[str] = []
    usage: dict[str, Any] | None = None
    response_model: str | None = None
    saw_done = False
    saw_length_finish = False

    def flush_event() -> bool:
        nonlocal data_lines, event_name, usage, response_model, saw_length_finish
        if not data_lines:
            event_name = None
            return False
        raw_data = "\n".join(data_lines)
        data_lines = []
        current_event = event_name
        event_name = None
        if raw_data.strip() == "[DONE]":
            return True
        try:
            payload = json.loads(raw_data)
        except json.JSONDecodeError as error:
            raise NimProtocolError("NVIDIA API SSE 数据不是有效 JSON") from error
        if not isinstance(payload, dict):
            raise NimProtocolError("NVIDIA API SSE 数据必须是对象")
        stream_error = _embedded_stream_error(payload, current_event)
        if stream_error is not None:
            raise stream_error
        model = payload.get("model")
        if isinstance(model, str) and model:
            response_model = model
        raw_usage = payload.get("usage")
        if isinstance(raw_usage, dict):
            usage = dict(raw_usage)
        raw_choices = payload.get("choices")
        if raw_choices is None:
            return False
        if not isinstance(raw_choices, list):
            raise NimProtocolError("NVIDIA API SSE choices 必须是数组")
        for choice in raw_choices:
            if not isinstance(choice, dict):
                raise NimProtocolError("NVIDIA API SSE choice 必须是对象")
            delta = choice.get("delta")
            if delta is not None:
                if not isinstance(delta, dict):
                    raise NimProtocolError("NVIDIA API SSE delta 必须是对象")
                # Do not inspect or collect delta.reasoning_content.
                visible_parts.extend(_visible_content_parts(delta.get("content")))
            # Some compatible APIs emit a message object in a terminal chunk.
            message = choice.get("message")
            if message is not None:
                if not isinstance(message, dict):
                    raise NimProtocolError("NVIDIA API SSE message 必须是对象")
                # Do not inspect or collect message.reasoning_content.
                visible_parts.extend(_visible_content_parts(message.get("content")))
            finish_reason = choice.get("finish_reason")
            if finish_reason == "length":
                saw_length_finish = True
        return False

    try:
        for raw_line in lines:
            line = _decode_sse_line(raw_line)
            if line == "":
                if flush_event():
                    saw_done = True
                    break
                continue
            if line.startswith(":"):
                continue
            field, value = _split_sse_field(line)
            if field == "data":
                data_lines.append(value)
            elif field == "event":
                event_name = value
            # id and retry fields are metadata; unknown fields are ignored by SSE.
        if not saw_done and data_lines and flush_event():
            saw_done = True
    except NimError:
        raise
    except (TimeoutError, socket.timeout, OSError, ssl.SSLError, http.client.HTTPException) as error:
        raise NimTransportError("读取 NVIDIA API SSE 流时失败", retryable=True) from error

    if not saw_done:
        raise NimStreamTruncatedError(
            "NVIDIA API SSE 流在 [DONE] 前结束",
            retryable=True,
        )
    if saw_length_finish:
        raise NimResponseTruncatedError("NVIDIA API 响应因 token 上限被截断")
    return "".join(visible_parts), usage, response_model


def _decode_sse_line(raw_line: bytes | str) -> str:
    if isinstance(raw_line, bytes):
        try:
            line = raw_line.decode("utf-8")
        except UnicodeDecodeError as error:
            raise NimProtocolError("NVIDIA API SSE 包含非 UTF-8 数据") from error
    elif isinstance(raw_line, str):
        line = raw_line
    else:
        raise NimProtocolError("NVIDIA API SSE 行不是文本")
    return line.rstrip("\r\n")


def _split_sse_field(line: str) -> tuple[str, str]:
    field, separator, value = line.partition(":")
    if not separator:
        return field, ""
    if value.startswith(" "):
        value = value[1:]
    return field, value


def _visible_content_parts(content: Any) -> list[str]:
    if content is None:
        return []
    if isinstance(content, str):
        return [content]
    if isinstance(content, list):
        parts: list[str] = []
        for item in content:
            if isinstance(item, str):
                parts.append(item)
            elif isinstance(item, dict):
                text = item.get("text")
                if isinstance(text, str):
                    parts.append(text)
        return parts
    raise NimProtocolError("NVIDIA API SSE content 必须是字符串或文本数组")


def _embedded_stream_error(
    payload: Mapping[str, Any],
    event_name: str | None,
) -> NimStreamError | None:
    raw_error = payload.get("error")
    is_error_event = event_name == "error" or payload.get("object") == "error"
    if raw_error is None and not is_error_event:
        return None
    error_data: Mapping[str, Any]
    if isinstance(raw_error, Mapping):
        error_data = raw_error
    elif raw_error is None:
        error_data = payload
    else:
        error_data = {}
    status_code = _extract_status_code(error_data, payload)
    retryable = status_code is not None and _is_retryable_status(status_code)
    message = "NVIDIA API 在 HTTP 200 SSE 流中返回错误"
    if status_code is not None:
        message = f"{message}（状态 {status_code}）"
    return NimStreamError(message, retryable=retryable, status_code=status_code)


def _extract_status_code(*sources: Mapping[str, Any]) -> int | None:
    for source in sources:
        for key in ("status", "status_code", "code"):
            value = source.get(key)
            if isinstance(value, int):
                return value
            if isinstance(value, str) and value.isdigit():
                return int(value)
    return None


@dataclass
class _UrllibResponse:
    raw_response: Any

    @property
    def status_code(self) -> int:
        status = getattr(self.raw_response, "status", None)
        if status is None:
            status = getattr(self.raw_response, "code", None)
        if status is None:
            status = self.raw_response.getcode()
        return int(status)

    @property
    def headers(self) -> Mapping[str, str]:
        raw_headers = getattr(self.raw_response, "headers", None)
        if raw_headers is None:
            return {}
        return {str(name): str(value) for name, value in raw_headers.items()}

    def iter_lines(self) -> Iterable[bytes]:
        while True:
            line = self.raw_response.readline()
            if not line:
                return
            yield line

    def close(self) -> None:
        self.raw_response.close()


def _urllib_streaming_transport(
    request: NimRequest,
    connect_timeout_seconds: float,
    read_timeout_seconds: float,
) -> NimStreamResponse:
    """Open a real NIM SSE stream with stdlib urllib.

    ``urlopen`` uses the short timeout while establishing the request.  Once a
    response exists, its underlying socket is switched to the longer read
    timeout before SSE lines are consumed.
    """

    http_request = Request(
        request.endpoint,
        data=request.body,
        headers=request.headers,
        method="POST",
    )
    try:
        raw_response = urlopen(http_request, timeout=connect_timeout_seconds)
    except HTTPError as error:
        # HTTPError remains readable/closeable, allowing the caller to apply
        # ordinary status-based retry handling without retaining its body.
        raw_response = error
    except (URLError, TimeoutError, socket.timeout, OSError, ssl.SSLError) as error:
        raise NimTransportError("无法连接 NVIDIA API", retryable=True) from error
    _set_response_read_timeout(raw_response, read_timeout_seconds)
    return _UrllibResponse(raw_response)


def _set_response_read_timeout(raw_response: Any, timeout_seconds: float) -> None:
    """Best-effort urllib socket traversal; mocks and unusual handlers work too."""

    candidates = [
        raw_response,
        getattr(raw_response, "fp", None),
        getattr(getattr(raw_response, "fp", None), "raw", None),
        getattr(getattr(getattr(raw_response, "fp", None), "raw", None), "_sock", None),
    ]
    for candidate in candidates:
        settimeout = getattr(candidate, "settimeout", None)
        if callable(settimeout):
            try:
                settimeout(timeout_seconds)
            except OSError:
                # The request can still be consumed using urllib's existing
                # socket settings; this is not a provider protocol failure.
                pass
            return


def _close_quietly(response: NimStreamResponse) -> None:
    try:
        response.close()
    except Exception:
        # A completed or interrupted response must not obscure the useful NIM
        # error already being handled by the caller.
        pass
