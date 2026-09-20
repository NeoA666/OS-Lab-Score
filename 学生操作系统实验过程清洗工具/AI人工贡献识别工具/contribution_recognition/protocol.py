"""Protocol types shared by the contribution-recognition NIM client.

The client deliberately keeps provider details here rather than leaking them into
the analysis pipeline.  In particular, the API key is marked non-representable
so diagnostic output cannot accidentally include it.
"""

from __future__ import annotations

import json
import os
from collections.abc import Callable, Iterable, Mapping
from dataclasses import dataclass, field
from typing import Any, Protocol
from urllib.parse import urlsplit

from .errors import ContributionRecognitionError


DEFAULT_NIM_BASE_URL = "https://integrate.api.nvidia.com/v1"
DEFAULT_NIM_MODEL = "nvidia/nemotron-3-super-120b-a12b"
DEFAULT_CONNECT_TIMEOUT_SECONDS = 15.0
DEFAULT_READ_TIMEOUT_SECONDS = 300.0
DEFAULT_MAX_TOKENS = 32768
DEFAULT_TEMPERATURE = 1.0
DEFAULT_TOP_P = 0.95


class NimError(ContributionRecognitionError):
    """Base class for expected NVIDIA NIM client failures.

    ``retryable`` is intentionally exposed so callers that own larger batch
    policies can distinguish a bad request from an unavailable provider.
    """

    def __init__(
        self,
        message: str,
        *,
        retryable: bool = False,
        status_code: int | None = None,
    ) -> None:
        super().__init__(message)
        self.retryable = retryable
        self.status_code = status_code


class NimConfigurationError(NimError):
    """The environment-derived NIM configuration is incomplete or invalid."""


class NimTransportError(NimError):
    """A connection, timeout, or HTTP transport failure occurred."""


class NimProtocolError(NimError):
    """The response was not a valid OpenAI-compatible SSE completion."""


class NimStreamError(NimProtocolError):
    """NIM returned an error event inside an otherwise HTTP 200 stream."""


class NimStreamTruncatedError(NimProtocolError):
    """The stream ended before its required ``[DONE]`` marker."""


class NimResponseTruncatedError(NimProtocolError):
    """NIM completed the SSE stream but stopped generation at its token limit."""


@dataclass(frozen=True)
class NimAnalysisSettings:
    """Non-sensitive NIM settings that influence semantic-analysis output.

    These settings are deliberately separate from :class:`NimConfig` so an
    unchanged cached assessment can be reused without reading a credential.
    """

    base_url: str = DEFAULT_NIM_BASE_URL
    model: str = DEFAULT_NIM_MODEL
    connect_timeout_seconds: float = DEFAULT_CONNECT_TIMEOUT_SECONDS
    read_timeout_seconds: float = DEFAULT_READ_TIMEOUT_SECONDS
    max_tokens: int = DEFAULT_MAX_TOKENS
    temperature: float = DEFAULT_TEMPERATURE
    top_p: float = DEFAULT_TOP_P

    def __post_init__(self) -> None:
        if not self.model.strip():
            raise NimConfigurationError("NVIDIA_MODEL 不能为空")
        parsed = urlsplit(self.base_url)
        if parsed.scheme not in {"http", "https"} or not parsed.netloc:
            raise NimConfigurationError("NVIDIA_API_BASE_URL 必须是完整的 HTTP(S) 地址")
        if self.connect_timeout_seconds <= 0:
            raise NimConfigurationError("连接超时必须大于 0")
        if self.read_timeout_seconds <= 0:
            raise NimConfigurationError("读取超时必须大于 0")
        if self.max_tokens <= 0:
            raise NimConfigurationError("max_tokens 必须大于 0")
        if not 0 <= self.temperature <= 2:
            raise NimConfigurationError("temperature 必须在 0 到 2 之间")
        if not 0 < self.top_p <= 1:
            raise NimConfigurationError("top_p 必须在 0 到 1 之间")

    @classmethod
    def from_environment(
        cls,
        environ: Mapping[str, str] | None = None,
    ) -> "NimAnalysisSettings":
        """Read only non-sensitive NIM settings from an environment mapping."""

        source = os.environ if environ is None else environ
        return cls(
            base_url=source.get("NVIDIA_API_BASE_URL", DEFAULT_NIM_BASE_URL).strip(),
            model=source.get("NVIDIA_MODEL", DEFAULT_NIM_MODEL).strip(),
            connect_timeout_seconds=_positive_float(
                source,
                "NVIDIA_CONNECT_TIMEOUT_SECONDS",
                DEFAULT_CONNECT_TIMEOUT_SECONDS,
            ),
            read_timeout_seconds=_positive_float(
                source,
                "NVIDIA_READ_TIMEOUT_SECONDS",
                DEFAULT_READ_TIMEOUT_SECONDS,
            ),
            max_tokens=_positive_int(source, "NVIDIA_MAX_TOKENS", DEFAULT_MAX_TOKENS),
            temperature=_float_value(source, "NVIDIA_TEMPERATURE", DEFAULT_TEMPERATURE),
            top_p=_float_value(source, "NVIDIA_TOP_P", DEFAULT_TOP_P),
        )


@dataclass(frozen=True)
class NimConfig:
    """NVIDIA OpenAI-compatible chat-completions configuration.

    The default values are the production contribution-recognition settings.
    ``from_environment`` reads only environment variables and never persists
    their contents.
    """

    api_key: str = field(repr=False)
    base_url: str = DEFAULT_NIM_BASE_URL
    model: str = DEFAULT_NIM_MODEL
    connect_timeout_seconds: float = DEFAULT_CONNECT_TIMEOUT_SECONDS
    read_timeout_seconds: float = DEFAULT_READ_TIMEOUT_SECONDS
    max_tokens: int = DEFAULT_MAX_TOKENS
    temperature: float = DEFAULT_TEMPERATURE
    top_p: float = DEFAULT_TOP_P

    def __post_init__(self) -> None:
        if not self.api_key.strip():
            # This text can reach a failed assessment and batch summary. Keep
            # the credential source out of every persisted diagnostic.
            raise NimConfigurationError("未配置模型服务凭据")
        NimAnalysisSettings(
            base_url=self.base_url,
            model=self.model,
            connect_timeout_seconds=self.connect_timeout_seconds,
            read_timeout_seconds=self.read_timeout_seconds,
            max_tokens=self.max_tokens,
            temperature=self.temperature,
            top_p=self.top_p,
        )

    @property
    def endpoint(self) -> str:
        base = self.base_url.rstrip("/")
        if base.endswith("/chat/completions"):
            return base
        return f"{base}/chat/completions"

    @classmethod
    def from_environment(
        cls,
        environ: Mapping[str, str] | None = None,
    ) -> "NimConfig":
        """Build configuration from the process environment.

        Optional ``environ`` exists solely for deterministic tests; normal
        production callers should not pass it.  ``NVIDIA_API_KEY`` is required.
        """

        source = os.environ if environ is None else environ
        settings = NimAnalysisSettings.from_environment(source)
        api_key = source.get("NVIDIA_API_KEY", "").strip()
        return cls(
            api_key=api_key,
            base_url=settings.base_url,
            model=settings.model,
            connect_timeout_seconds=settings.connect_timeout_seconds,
            read_timeout_seconds=settings.read_timeout_seconds,
            max_tokens=settings.max_tokens,
            temperature=settings.temperature,
            top_p=settings.top_p,
        )


def _positive_float(
    environ: Mapping[str, str],
    name: str,
    default: float,
) -> float:
    raw = environ.get(name, "").strip()
    if not raw:
        return default
    try:
        value = float(raw)
    except ValueError as error:
        raise NimConfigurationError(f"{name} 必须是数字") from error
    if value <= 0:
        raise NimConfigurationError(f"{name} 必须大于 0")
    return value


def _positive_int(
    environ: Mapping[str, str],
    name: str,
    default: int,
) -> int:
    raw = environ.get(name, "").strip()
    if not raw:
        return default
    try:
        value = int(raw)
    except ValueError as error:
        raise NimConfigurationError(f"{name} 必须是整数") from error
    if value <= 0:
        raise NimConfigurationError(f"{name} 必须大于 0")
    return value


def _float_value(
    environ: Mapping[str, str],
    name: str,
    default: float,
) -> float:
    raw = environ.get(name, "").strip()
    if not raw:
        return default
    try:
        return float(raw)
    except ValueError as error:
        raise NimConfigurationError(f"{name} 必须是数字") from error


@dataclass(frozen=True)
class NimRequest:
    """One outbound completion request passed to an injectable transport."""

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
            "User-Agent": "os-lab-contribution-recognition/0.1",
        }


class NimStreamResponse(Protocol):
    """Minimal response contract used by a streaming transport."""

    @property
    def status_code(self) -> int:
        """HTTP status code returned by the provider."""

    @property
    def headers(self) -> Mapping[str, str]:
        """Response headers, used for the optional request ID."""

    def iter_lines(self) -> Iterable[bytes | str]:
        """Yield raw SSE lines without requiring a particular HTTP library."""

    def close(self) -> None:
        """Release the underlying network response."""


class NimTransport(Protocol):
    """Open an SSE response using distinct connection and read timeouts."""

    def __call__(
        self,
        request: NimRequest,
        connect_timeout_seconds: float,
        read_timeout_seconds: float,
    ) -> NimStreamResponse:
        ...


Clock = Callable[[], float]
Sleep = Callable[[float], None]


@dataclass(frozen=True)
class NimResponse:
    """Visible model output after a complete, validated SSE stream.

    ``content`` never contains NIM's ``reasoning_content`` field.  ``usage``
    is copied only when NIM sends it in a completion chunk.
    """

    content: str
    model: str
    usage: dict[str, Any] | None
    request_id: str | None
    attempts: int
    elapsed_seconds: float
