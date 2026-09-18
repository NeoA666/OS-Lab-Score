"""Dependency-free streaming NVIDIA NIM client for the audit agent."""

from __future__ import annotations

import http.client
import json
import os
import socket
import ssl
import time
from collections.abc import Iterable, Mapping, Sequence
from dataclasses import dataclass, field
from typing import Any, Callable
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

from .errors import ConfigurationError, ModelProtocolError
from .models import AssistantResponse, ToolCall

DEFAULT_NIM_BASE_URL = "https://integrate.api.nvidia.com/v1"
DEFAULT_NIM_MODEL = "nvidia/nemotron-3-super-120b-a12b"
DEFAULT_CONNECT_TIMEOUT_SECONDS = 15.0
DEFAULT_READ_TIMEOUT_SECONDS = 300.0
DEFAULT_MAX_TOKENS = 32768
DEFAULT_TEMPERATURE = 1.0
DEFAULT_TOP_P = 0.95
RETRY_DELAYS_SECONDS = (2.0, 4.0, 8.0, 16.0)
MAX_RETRIES = 4


class NimError(ModelProtocolError):
    """Provider failure with a retry decision; body text is never retained."""

    def __init__(self, message: str, *, retryable: bool = False, status_code: int | None = None):
        super().__init__(message)
        self.retryable = retryable
        self.status_code = status_code


class NimTransportError(NimError):
    pass


class NimStreamError(NimError):
    pass


class NimStreamTruncatedError(NimError):
    pass


class NimResponseTruncatedError(NimError):
    pass


# Compatibility names used by the contribution-recognition NIM tests and by
# callers that want to distinguish configuration failures from protocol ones.
NimConfigurationError = ConfigurationError
NimProtocolError = ModelProtocolError


@dataclass(frozen=True)
class OpenAICompatibleConfig:
    """NIM settings, retaining the historical class name for compatibility."""

    base_url: str = DEFAULT_NIM_BASE_URL
    api_key: str = field(default="", repr=False)
    model: str = DEFAULT_NIM_MODEL
    timeout_seconds: float | None = None
    max_tokens: int = DEFAULT_MAX_TOKENS
    connect_timeout_seconds: float = DEFAULT_CONNECT_TIMEOUT_SECONDS
    read_timeout_seconds: float = DEFAULT_READ_TIMEOUT_SECONDS
    temperature: float = DEFAULT_TEMPERATURE
    top_p: float = DEFAULT_TOP_P
    enable_thinking: bool = True
    force_nonempty_content: bool = True

    def __post_init__(self) -> None:
        if not isinstance(self.api_key, str) or not self.api_key.strip():
            raise ConfigurationError("未配置模型服务凭据")
        if not isinstance(self.model, str) or not self.model.strip():
            raise ConfigurationError("NVIDIA 模型名称不能为空")
        if not self.base_url.startswith(("http://", "https://")):
            raise ConfigurationError("NVIDIA API 地址必须是 HTTP(S) 地址")
        if self.timeout_seconds is not None and self.timeout_seconds <= 0:
            raise ConfigurationError("timeout_seconds 必须大于 0")
        if self.connect_timeout_seconds <= 0 or self.read_timeout_seconds <= 0:
            raise ConfigurationError("连接和读取超时必须大于 0")
        if self.max_tokens <= 0:
            raise ConfigurationError("max_tokens 必须大于 0")
        if not 0 <= self.temperature <= 2:
            raise ConfigurationError("temperature 必须在 0 到 2 之间")
        if not 0 < self.top_p <= 1:
            raise ConfigurationError("top_p 必须在 0 到 1 之间")

    @classmethod
    def from_environment(cls, environ: Mapping[str, str] | None = None) -> "OpenAICompatibleConfig":
        source = os.environ if environ is None else environ
        key = source.get("NVIDIA_API_KEY", "").strip()
        if not key:
            raise ConfigurationError("未配置模型服务凭据")
        return cls(
            base_url=source.get("NVIDIA_API_BASE_URL", DEFAULT_NIM_BASE_URL).strip(),
            api_key=key,
            model=source.get("NVIDIA_MODEL", DEFAULT_NIM_MODEL).strip(),
            max_tokens=_positive_int(source, "NVIDIA_MAX_TOKENS", DEFAULT_MAX_TOKENS),
            connect_timeout_seconds=_positive_float(source, "NVIDIA_CONNECT_TIMEOUT_SECONDS", DEFAULT_CONNECT_TIMEOUT_SECONDS),
            read_timeout_seconds=_positive_float(source, "NVIDIA_READ_TIMEOUT_SECONDS", DEFAULT_READ_TIMEOUT_SECONDS),
            temperature=_float_value(source, "NVIDIA_TEMPERATURE", DEFAULT_TEMPERATURE),
            top_p=_float_value(source, "NVIDIA_TOP_P", DEFAULT_TOP_P),
        )

    @property
    def endpoint(self) -> str:
        base = self.base_url.rstrip("/")
        return base if base.endswith("/chat/completions") else f"{base}/chat/completions"

    @property
    def effective_connect_timeout(self) -> float:
        return self.timeout_seconds if self.timeout_seconds is not None else self.connect_timeout_seconds

    @property
    def effective_read_timeout(self) -> float:
        return self.timeout_seconds if self.timeout_seconds is not None else self.read_timeout_seconds


NimConfig = OpenAICompatibleConfig
NvidiaNimConfig = OpenAICompatibleConfig


@dataclass(frozen=True)
class NimRequest:
    endpoint: str
    payload: dict[str, Any]
    api_key: str = field(repr=False)

    @property
    def body(self) -> bytes:
        return json.dumps(self.payload, ensure_ascii=False, separators=(",", ":")).encode("utf-8")

    @property
    def headers(self) -> dict[str, str]:
        return {
            "Authorization": f"Bearer {self.api_key}",
            "Accept": "text/event-stream",
            "Content-Type": "application/json",
            "User-Agent": "os-lab-integrity-audit/0.2",
        }


@dataclass(frozen=True)
class _ParsedResponse:
    content: str | None
    tool_calls: tuple[ToolCall, ...]
    reasoning_content: str | None
    raw_message: dict[str, Any]
    usage: dict[str, Any] | None = None
    model: str | None = None


class OpenAICompatibleChatClient:
    """Open an SSE completion and expose only visible text/tool calls."""

    def __init__(
        self,
        config: OpenAICompatibleConfig,
        *,
        transport: Callable[[NimRequest, float, float], Any] | None = None,
        clock: Callable[[], float] = time.monotonic,
        sleep: Callable[[float], None] = time.sleep,
    ) -> None:
        self.config = config
        self._transport = transport or _urllib_streaming_transport
        self._clock = clock
        self._sleep = sleep

    def complete(
        self,
        messages: Sequence[Mapping[str, Any]],
        tools: Sequence[Mapping[str, Any]] | None = None,
    ) -> AssistantResponse:
        normalized_messages = _normalize_messages(messages)
        normalized_tools = _normalize_tools(tools)
        payload: dict[str, Any] = {
            "model": self.config.model,
            "messages": normalized_messages,
            "stream": True,
            # Nemotron's reasoning parser can emit only a thinking/tool block
            # for agent turns.  NVIDIA documents this flag for coding agents
            # so every tool call also has a valid non-empty content field.
            "chat_template_kwargs": {
                "enable_thinking": bool(self.config.enable_thinking),
                "force_nonempty_content": bool(self.config.force_nonempty_content),
            },
            "max_tokens": self.config.max_tokens,
            "temperature": self.config.temperature,
            "top_p": self.config.top_p,
        }
        # NIM forbids response_format/guided_json with tools; neither is sent.
        if normalized_tools:
            payload["tools"] = normalized_tools
            payload["tool_choice"] = "auto"
        request = NimRequest(self.config.endpoint, payload, self.config.api_key)
        started = self._clock()
        for attempt in range(1, MAX_RETRIES + 2):
            response = None
            try:
                response = self._transport(request, self.config.effective_connect_timeout, self.config.effective_read_timeout)
                status = int(response.status_code)
                if status < 200 or status >= 300:
                    raise NimTransportError(
                        f"NVIDIA API 返回 HTTP {status}",
                        retryable=_is_retryable_status(status),
                        status_code=status,
                    )
                parsed = _consume_response(response.iter_lines())
                return AssistantResponse(
                    content=parsed.content,
                    tool_calls=parsed.tool_calls,
                    raw_message=parsed.raw_message,
                    reasoning_content=parsed.reasoning_content,
                    usage=parsed.usage,
                    request_id=_request_id(getattr(response, "headers", {})),
                    attempts=attempt,
                    model=parsed.model or self.config.model,
                    elapsed_seconds=max(0.0, self._clock() - started),
                )
            except NimError as error:
                if not error.retryable or attempt > MAX_RETRIES:
                    raise
                self._sleep(RETRY_DELAYS_SECONDS[attempt - 1])
            except (URLError, TimeoutError, socket.timeout, OSError, ssl.SSLError, http.client.HTTPException) as error:
                if attempt > MAX_RETRIES:
                    raise NimTransportError("无法完成 NVIDIA API 请求", retryable=True) from error
                self._sleep(RETRY_DELAYS_SECONDS[attempt - 1])
            finally:
                if response is not None:
                    _close_quietly(response)
        raise NimTransportError("NVIDIA API 重试状态异常", retryable=True)


NimStreamingClient = OpenAICompatibleChatClient


def _normalize_messages(messages: Sequence[Mapping[str, Any]]) -> list[dict[str, Any]]:
    if isinstance(messages, (str, bytes)):
        raise ModelProtocolError("messages 必须是对象数组")
    result: list[dict[str, Any]] = []
    for index, message in enumerate(messages):
        if not isinstance(message, Mapping) or not isinstance(message.get("role"), str):
            raise ModelProtocolError(f"第 {index} 条 message 格式不合法")
        result.append(dict(message))
    if not result:
        raise ModelProtocolError("messages 不能为空")
    return result


def _normalize_tools(tools: Sequence[Mapping[str, Any]] | None) -> list[dict[str, Any]]:
    if tools is None:
        return []
    if isinstance(tools, (str, bytes)):
        raise ModelProtocolError("tools 必须是对象数组")
    result: list[dict[str, Any]] = []
    for index, tool in enumerate(tools):
        if not isinstance(tool, Mapping):
            raise ModelProtocolError(f"第 {index} 个 tool 不是对象")
        result.append(dict(tool))
    return result


def _consume_response(lines: Iterable[bytes | str]) -> _ParsedResponse:
    data_lines: list[str] = []
    event_name: str | None = None
    visible: list[str] = []
    reasoning: list[str] = []
    tool_states: dict[int, dict[str, Any]] = {}
    usage: dict[str, Any] | None = None
    response_model: str | None = None
    saw_done = False
    saw_sse = False
    saw_length = False
    first_nonempty = False

    def mark_length() -> None:
        nonlocal saw_length
        saw_length = True

    def flush() -> bool:
        nonlocal data_lines, event_name, saw_sse, usage, response_model
        if not data_lines:
            event_name = None
            return False
        raw = "\n".join(data_lines)
        data_lines = []
        name = event_name
        event_name = None
        if raw.strip() == "[DONE]":
            return True
        try:
            payload = json.loads(raw)
        except json.JSONDecodeError as error:
            raise ModelProtocolError("NVIDIA API 返回的数据不是有效 JSON") from error
        if not isinstance(payload, dict):
            raise ModelProtocolError("NVIDIA API 返回的数据必须是对象")
        saw_sse = True
        _embedded_error(payload, name)
        raw_usage = payload.get("usage")
        if isinstance(raw_usage, dict):
            usage = dict(raw_usage)
        if isinstance(payload.get("model"), str) and payload["model"]:
            response_model = payload["model"]
        _merge_payload(payload, visible, reasoning, tool_states, mark_length)
        return False

    try:
        for raw_line in lines:
            line = _decode_line(raw_line)
            if line == "":
                if flush():
                    saw_done = True
                    break
                continue
            if line.startswith(":"):
                continue
            field_name, separator, value = line.partition(":")
            if not separator:
                # Accept a complete JSON response from a compatible proxy.
                if not first_nonempty and line.lstrip().startswith("{"):
                    first_nonempty = True
                    try:
                        payload = json.loads(line)
                    except json.JSONDecodeError as error:
                        raise ModelProtocolError("NVIDIA API 返回的数据不是有效 JSON") from error
                    if not isinstance(payload, dict):
                        raise ModelProtocolError("NVIDIA API 返回的数据必须是对象")
                    _embedded_error(payload, None)
                    raw_usage = payload.get("usage")
                    if isinstance(raw_usage, dict):
                        usage = dict(raw_usage)
                    if isinstance(payload.get("model"), str) and payload["model"]:
                        response_model = payload["model"]
                    _merge_payload(payload, visible, reasoning, tool_states, mark_length)
                    saw_done = True
                    break
                continue
            first_nonempty = True
            saw_sse = True
            value = value[1:] if value.startswith(" ") else value
            if field_name == "data":
                data_lines.append(value)
            elif field_name == "event":
                event_name = value
        if not saw_done and data_lines and flush():
            saw_done = True
    except NimError:
        raise
    except (TimeoutError, socket.timeout, OSError, ssl.SSLError, http.client.HTTPException) as error:
        raise NimTransportError("读取 NVIDIA API 流时失败", retryable=True) from error

    if saw_sse and not saw_done:
        raise NimStreamTruncatedError("NVIDIA API SSE 流在 [DONE] 前结束", retryable=True)
    if not saw_done:
        raise ModelProtocolError("NVIDIA API 没有返回完整响应")
    if saw_length:
        raise NimResponseTruncatedError("NVIDIA API 响应因 token 上限被截断")

    calls: list[ToolCall] = []
    for index in sorted(tool_states):
        state = tool_states[index]
        call_id = state.get("id")
        name = state.get("name", "")
        if not isinstance(call_id, str) or not isinstance(name, str) or not name:
            raise ModelProtocolError("NVIDIA API 工具调用格式不完整")
        raw_arguments = state.get("arguments", "")
        if isinstance(raw_arguments, dict):
            arguments = raw_arguments
        elif not isinstance(raw_arguments, str) or not raw_arguments.strip():
            arguments = {}
        else:
            try:
                decoded = json.loads(raw_arguments)
            except json.JSONDecodeError:
                arguments = {"__audit_invalid_tool_arguments__": True}
            else:
                arguments = decoded if isinstance(decoded, dict) else {"__audit_invalid_tool_arguments__": True}
        calls.append(ToolCall(call_id=call_id, name=name, arguments=arguments))

    content = "".join(visible) or None
    raw_message: dict[str, Any] = {"role": "assistant", "content": content}
    if calls:
        raw_message["tool_calls"] = [
            {
                "id": call.call_id,
                "type": "function",
                "function": {
                    "name": call.name,
                    "arguments": json.dumps(call.arguments, ensure_ascii=False),
                },
            }
            for call in calls
        ]
    return _ParsedResponse(
        content,
        tuple(calls),
        "".join(reasoning) or None,
        raw_message,
        usage,
        response_model,
    )


def _merge_payload(
    payload: Mapping[str, Any],
    visible: list[str],
    reasoning: list[str],
    tool_states: dict[int, dict[str, Any]],
    mark_length: Callable[[], None],
) -> None:
    choices = payload.get("choices")
    if choices is None:
        return
    if not isinstance(choices, list):
        raise ModelProtocolError("NVIDIA API choices 必须是数组")
    for choice in choices:
        if not isinstance(choice, dict):
            raise ModelProtocolError("NVIDIA API choice 必须是对象")
        delta = choice.get("delta")
        if delta is not None:
            if not isinstance(delta, dict):
                raise ModelProtocolError("NVIDIA API delta 必须是对象")
            _merge_fragment(delta, visible, reasoning, tool_states)
        message = choice.get("message")
        if message is not None:
            if not isinstance(message, dict):
                raise ModelProtocolError("NVIDIA API message 必须是对象")
            _merge_fragment(message, visible, reasoning, tool_states)
        function_call = choice.get("function_call")
        if isinstance(function_call, dict):
            _merge_tool(0, {"function": function_call}, tool_states)
        if choice.get("finish_reason") == "length":
            mark_length()


def _merge_fragment(
    fragment: Mapping[str, Any],
    visible: list[str],
    reasoning: list[str],
    tool_states: dict[int, dict[str, Any]],
) -> None:
    visible.extend(_text_parts(fragment.get("content")))
    reasoning.extend(_text_parts(fragment.get("reasoning_content")))
    raw_calls = fragment.get("tool_calls")
    if raw_calls is None:
        return
    if not isinstance(raw_calls, list):
        raise ModelProtocolError("NVIDIA API tool_calls 必须是数组")
    for fallback, call in enumerate(raw_calls):
        if not isinstance(call, dict):
            raise ModelProtocolError("NVIDIA API tool_call 必须是对象")
        try:
            index = int(call.get("index", fallback))
        except (TypeError, ValueError) as error:
            raise ModelProtocolError("NVIDIA API tool_call index 不合法") from error
        _merge_tool(index, call, tool_states)


def _merge_tool(index: int, fragment: Mapping[str, Any], states: dict[int, dict[str, Any]]) -> None:
    state = states.setdefault(index, {"id": "", "name": "", "arguments": ""})
    if isinstance(fragment.get("id"), str) and fragment["id"]:
        state["id"] = fragment["id"]
    function = fragment.get("function")
    if isinstance(function, Mapping):
        if isinstance(function.get("name"), str):
            state["name"] += function["name"]
        arguments = function.get("arguments")
        if isinstance(arguments, str):
            if isinstance(state.get("arguments"), str):
                state["arguments"] += arguments
            else:
                state["arguments"] = arguments
        elif isinstance(arguments, dict):
            state["arguments"] = arguments
    # Also accept flattened gateway fields.
    if isinstance(fragment.get("name"), str):
        state["name"] += fragment["name"]
    if isinstance(fragment.get("arguments"), str):
        if isinstance(state.get("arguments"), str):
            state["arguments"] += fragment["arguments"]
        else:
            state["arguments"] = fragment["arguments"]


def _text_parts(value: Any) -> list[str]:
    if value is None:
        return []
    if isinstance(value, str):
        return [value]
    if isinstance(value, list):
        result: list[str] = []
        for item in value:
            if isinstance(item, str):
                result.append(item)
            elif isinstance(item, Mapping) and isinstance(item.get("text"), str):
                result.append(item["text"])
        return result
    raise ModelProtocolError("NVIDIA API 文本字段必须是字符串或文本数组")


def _embedded_error(payload: Mapping[str, Any], event_name: str | None) -> None:
    raw_error = payload.get("error")
    if raw_error is None and event_name != "error" and payload.get("object") != "error":
        return
    status: int | None = None
    sources: list[Mapping[str, Any]] = [payload]
    if isinstance(raw_error, Mapping):
        sources.insert(0, raw_error)
    for source in sources:
        for key in ("status", "status_code", "code"):
            value = source.get(key)
            if isinstance(value, int):
                status = value
                break
            if isinstance(value, str) and value.isdigit():
                status = int(value)
                break
        if status is not None:
            break
    suffix = f"（状态 {status}）" if status is not None else ""
    raise NimStreamError(
        f"NVIDIA API 在 HTTP 200 响应中返回错误{suffix}",
        retryable=status is not None and _is_retryable_status(status),
        status_code=status,
    )


def _decode_line(raw_line: bytes | str) -> str:
    if isinstance(raw_line, bytes):
        try:
            return raw_line.decode("utf-8").rstrip("\r\n")
        except UnicodeDecodeError as error:
            raise ModelProtocolError("NVIDIA API 响应包含非 UTF-8 数据") from error
    if isinstance(raw_line, str):
        return raw_line.rstrip("\r\n")
    raise ModelProtocolError("NVIDIA API 响应行不是文本")


def _is_retryable_status(status_code: int) -> bool:
    return status_code == 429 or 500 <= status_code <= 599


def _request_id(headers: Mapping[str, Any]) -> str | None:
    if not isinstance(headers, Mapping):
        return None
    for key in ("x-request-id", "x-nvidia-request-id", "request-id"):
        value = headers.get(key)
        if value:
            return str(value)
    for key, value in headers.items():
        if str(key).lower() in {"x-request-id", "x-nvidia-request-id", "request-id"} and value:
            return str(value)
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
        headers = getattr(self.raw_response, "headers", None)
        if headers is None:
            return {}
        return {str(key): str(value) for key, value in headers.items()}

    def iter_lines(self) -> Iterable[bytes]:
        while True:
            line = self.raw_response.readline()
            if not line:
                return
            yield line

    def close(self) -> None:
        self.raw_response.close()


def _urllib_streaming_transport(request: NimRequest, connect_timeout_seconds: float, read_timeout_seconds: float) -> _UrllibResponse:
    http_request = Request(request.endpoint, data=request.body, headers=request.headers, method="POST")
    try:
        raw_response = urlopen(http_request, timeout=connect_timeout_seconds)
    except HTTPError as error:
        raw_response = error
    except (URLError, TimeoutError, socket.timeout, OSError, ssl.SSLError) as error:
        raise NimTransportError("无法连接 NVIDIA API", retryable=True) from error
    _set_response_read_timeout(raw_response, read_timeout_seconds)
    return _UrllibResponse(raw_response)


def _set_response_read_timeout(raw_response: Any, timeout_seconds: float) -> None:
    candidates = [raw_response, getattr(raw_response, "fp", None), getattr(getattr(raw_response, "fp", None), "raw", None), getattr(getattr(getattr(raw_response, "fp", None), "raw", None), "_sock", None)]
    for candidate in candidates:
        setter = getattr(candidate, "settimeout", None)
        if callable(setter):
            try:
                setter(timeout_seconds)
            except OSError:
                pass
            return


def _close_quietly(response: Any) -> None:
    try:
        response.close()
    except Exception:
        pass


def _positive_float(environ: Mapping[str, str], name: str, default: float) -> float:
    raw = environ.get(name, "").strip()
    if not raw:
        return default
    try:
        value = float(raw)
    except ValueError as error:
        raise ConfigurationError(f"{name} 必须是数字") from error
    if value <= 0:
        raise ConfigurationError(f"{name} 必须大于 0")
    return value


def _positive_int(environ: Mapping[str, str], name: str, default: int) -> int:
    raw = environ.get(name, "").strip()
    if not raw:
        return default
    try:
        value = int(raw)
    except ValueError as error:
        raise ConfigurationError(f"{name} 必须是整数") from error
    if value <= 0:
        raise ConfigurationError(f"{name} 必须大于 0")
    return value


def _float_value(environ: Mapping[str, str], name: str, default: float) -> float:
    raw = environ.get(name, "").strip()
    if not raw:
        return default
    try:
        return float(raw)
    except ValueError as error:
        raise ConfigurationError(f"{name} 必须是数字") from error
