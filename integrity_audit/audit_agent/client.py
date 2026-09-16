from __future__ import annotations

import json
import os
from dataclasses import dataclass
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

from .errors import ConfigurationError, ModelProtocolError
from .models import AssistantResponse, ToolCall


@dataclass(frozen=True)
class OpenAICompatibleConfig:
    base_url: str
    api_key: str
    model: str
    timeout_seconds: float = 90.0
    max_tokens: int | None = None

    @classmethod
    def from_environment(cls) -> "OpenAICompatibleConfig":
        base_url = os.getenv("AUDIT_API_BASE_URL", "").strip().rstrip("/")
        api_key = os.getenv("AUDIT_API_KEY", "").strip()
        model = os.getenv("AUDIT_MODEL", "").strip()
        timeout_text = os.getenv("AUDIT_API_TIMEOUT_SECONDS", "90").strip()
        max_tokens_text = os.getenv("AUDIT_API_MAX_TOKENS", "").strip()
        missing = [
            name
            for name, value in {
                "AUDIT_API_BASE_URL": base_url,
                "AUDIT_API_KEY": api_key,
                "AUDIT_MODEL": model,
            }.items()
            if not value
        ]
        if missing:
            raise ConfigurationError(f"缺少模型配置环境变量：{', '.join(missing)}")
        try:
            timeout = float(timeout_text)
        except ValueError as error:
            raise ConfigurationError("AUDIT_API_TIMEOUT_SECONDS 必须是数字") from error
        if timeout <= 0 or timeout > 900:
            raise ConfigurationError("AUDIT_API_TIMEOUT_SECONDS 必须在 0 到 900 之间")
        max_tokens: int | None = None
        if max_tokens_text:
            try:
                max_tokens = int(max_tokens_text)
            except ValueError as error:
                raise ConfigurationError("AUDIT_API_MAX_TOKENS 必须是整数") from error
            if max_tokens <= 0:
                raise ConfigurationError("AUDIT_API_MAX_TOKENS 必须大于 0")
        return cls(
            base_url=base_url,
            api_key=api_key,
            model=model,
            timeout_seconds=timeout,
            max_tokens=max_tokens,
        )

    @property
    def endpoint(self) -> str:
        if self.base_url.endswith("/chat/completions"):
            return self.base_url
        return f"{self.base_url}/chat/completions"


class OpenAICompatibleChatClient:
    """Small standard-library client for OpenAI-compatible chat completions."""

    def __init__(self, config: OpenAICompatibleConfig) -> None:
        self.config = config

    def complete(
        self,
        messages: list[dict[str, Any]],
        tools: list[dict[str, Any]],
    ) -> AssistantResponse:
        payload = {
            "model": self.config.model,
            "messages": messages,
            "tools": tools,
            "tool_choice": "auto",
            "temperature": 0,
        }
        if self.config.max_tokens is not None:
            payload["max_tokens"] = self.config.max_tokens
        request = Request(
            self.config.endpoint,
            data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
            headers={
                "Authorization": f"Bearer {self.config.api_key}",
                "Content-Type": "application/json",
                "User-Agent": "lab0-integrity-audit-agent/0.1",
            },
            method="POST",
        )
        try:
            with urlopen(request, timeout=self.config.timeout_seconds) as response:
                raw = response.read().decode("utf-8")
        except HTTPError as error:
            detail = error.read().decode("utf-8", errors="replace")[:800]
            raise ModelProtocolError(f"模型接口返回 HTTP {error.code}：{detail}") from error
        except URLError as error:
            raise ModelProtocolError(f"无法连接模型接口：{error.reason}") from error
        except TimeoutError as error:
            raise ModelProtocolError("模型接口超时") from error

        try:
            body = json.loads(raw)
            message = body["choices"][0]["message"]
        except (KeyError, IndexError, TypeError, json.JSONDecodeError) as error:
            raise ModelProtocolError("模型接口没有返回兼容的 chat-completions message") from error
        if not isinstance(message, dict):
            raise ModelProtocolError("模型接口返回的 message 不是对象")

        calls: list[ToolCall] = []
        raw_calls = message.get("tool_calls") or []
        if not isinstance(raw_calls, list):
            raise ModelProtocolError("tool_calls 必须是数组")
        for index, raw_call in enumerate(raw_calls):
            try:
                call_id = raw_call["id"]
                function = raw_call["function"]
                name = function["name"]
                raw_arguments = function.get("arguments", "{}")
            except (KeyError, TypeError) as error:
                raise ModelProtocolError(f"第 {index} 个工具调用格式不完整") from error
            if not isinstance(call_id, str) or not isinstance(name, str):
                raise ModelProtocolError(f"第 {index} 个工具调用缺少字符串 id 或 name")
            try:
                arguments = raw_arguments if isinstance(raw_arguments, dict) else json.loads(raw_arguments)
            except json.JSONDecodeError:
                arguments = {"__audit_invalid_tool_arguments__": True}
            if not isinstance(arguments, dict):
                arguments = {"__audit_invalid_tool_arguments__": True}
            calls.append(ToolCall(call_id=call_id, name=name, arguments=arguments))

        content = message.get("content")
        if content is not None and not isinstance(content, str):
            content = str(content)
        return AssistantResponse(content=content, tool_calls=tuple(calls), raw_message=message)
