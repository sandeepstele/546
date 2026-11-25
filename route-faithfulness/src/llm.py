"""Thin async wrapper over the chat APIs used in the study. Set `provider` per model in config.yaml:

    openai          (default) any OpenAI-compatible API: OpenAI, OpenRouter, Groq, Gemini API, vLLM
    vertex_openai   Vertex AI's OpenAI-compatible endpoint (Gemini, MaaS open models), gcloud ADC auth
    anthropic       Claude API, through the Anthropic SDK (src/llm_anthropic.py)
    anthropic_vertex Claude on Vertex AI, through the Anthropic SDK, gcloud ADC auth

Returns a plain dict so the rest of the code never touches SDK objects:
    {content, tool_calls: [{id, name, arguments}], assistant_message, reasoning_present, usage, finish_reason}
"""
from __future__ import annotations

import asyncio
import json
import os
import random
import re
import time

THINK_RE = re.compile(r"<think>.*?</think>", re.S)


class EmptyResponseError(Exception):
    """The API returned a choice without a message (seen occasionally on Gemini). Retried."""


class _VertexToken:
    """Google ADC access token for the Vertex OpenAI-compatible endpoint. Tokens last about an
    hour, so it is refreshed a few minutes before expiry; the OpenAI client asks for it per request."""

    def __init__(self):
        import google.auth

        self.creds, self.project = google.auth.default(scopes=["https://www.googleapis.com/auth/cloud-platform"])
        self.lock = asyncio.Lock()
        self.refreshes = 0

    async def __call__(self) -> str:
        async with self.lock:
            # `valid` turns False a few minutes before expiry (google-auth's refresh threshold).
            if not self.creds.valid:
                import google.auth.transport.requests

                await asyncio.to_thread(self.creds.refresh, google.auth.transport.requests.Request())
                self.refreshes += 1
            return self.creds.token


class _Pacer:
    """Spaces out request starts for a model with a requests-per-minute quota (`max_rpm` in config.yaml).
    Without it every worker hits the quota at once, most calls come back 429, and a row that uses up
    its retries is logged as an error. Retries are paced too, so the total never exceeds max_rpm."""

    def __init__(self, rpm: float):
        self.interval = 60.0 / float(rpm)
        self.next_at = 0.0
        self.lock = asyncio.Lock()

    async def wait(self) -> None:
        async with self.lock:
            now = time.monotonic()
            at = max(now, self.next_at)
            self.next_at = at + self.interval
        if at > now:
            await asyncio.sleep(at - now)


def vertex_openai_base_url(project: str, location: str) -> str:
    host = "aiplatform.googleapis.com" if location == "global" else f"{location}-aiplatform.googleapis.com"
    return f"https://{host}/v1/projects/{project}/locations/{location}/endpoints/openapi"


class LLM:
    def __init__(self, model_cfg: dict, mock: bool = False, mock_role: str = "model"):
        self.cfg = model_cfg
        self.model = model_cfg["model"]
        self.extra_body = model_cfg.get("extra_body") or None
        self.mock = mock
        self.provider = model_cfg.get("provider", "openai")
        self.backend = None  # set for providers that do not use the OpenAI SDK
        self.pacer = _Pacer(model_cfg["max_rpm"]) if model_cfg.get("max_rpm") and not mock else None
        # A paced model retries only in _retry, where every attempt waits its turn; the SDK's own
        # immediate retries would go around the pacer.
        sdk_retries = {"max_retries": 0} if self.pacer else {}
        if mock:
            from .mock import MockClient

            self.client = MockClient(role=mock_role)
        elif self.provider in ("anthropic", "anthropic_vertex"):
            from .llm_anthropic import AnthropicChat

            self.backend = AnthropicChat(model_cfg)
        elif self.provider == "vertex_openai":
            from openai import AsyncOpenAI

            token = _VertexToken()
            project = model_cfg.get("project") or os.environ.get(model_cfg.get("project_env", "GOOGLE_CLOUD_PROJECT")) \
                or token.project
            if not project:
                raise SystemExit("Vertex AI needs a project: set GOOGLE_CLOUD_PROJECT in .env")
            # A self-deployed Model Garden endpoint (e.g. Llama 3.1 on vLLM) has its own URL, which
            # scripts/vertex_deploy_run_teardown.sh exports in `base_url_env`; otherwise use MaaS.
            base = os.environ.get(model_cfg["base_url_env"]) if model_cfg.get("base_url_env") else None
            if model_cfg.get("base_url_env") and not base:
                raise SystemExit(f"Missing endpoint URL: set {model_cfg['base_url_env']} (deploy the endpoint first)")
            timeout = 300 if base else 120   # one self-hosted replica queues requests under load
            http_client = None
            if model_cfg.get("raw_predict"):
                # Partner models (e.g. Mistral) are not on the openapi endpoint; they take the same
                # OpenAI-style body at publishers/<publisher>/models/<model>:rawPredict.
                # The client class comes from the OpenAI SDK, not from `import httpx`: the SDK is built
                # on httpx2, and plain httpx is not one of this project's requirements (it is only
                # present where Jupyter happens to be installed, so the import fails in a clean install).
                from openai import DefaultAsyncHttpxClient

                loc = model_cfg["location"]
                base = (f"https://{loc}-aiplatform.googleapis.com/v1/projects/{project}/locations/{loc}"
                        f"/publishers/{model_cfg['raw_predict']}/models/{self.model}")

                async def _to_raw_predict(request):
                    if request.url.path.endswith("/chat/completions"):
                        request.url = request.url.copy_with(
                            path=request.url.path[: -len("/chat/completions")] + ":rawPredict")

                http_client = DefaultAsyncHttpxClient(event_hooks={"request": [_to_raw_predict]}, timeout=timeout)
            base = base or vertex_openai_base_url(project, model_cfg.get("location", "global"))
            self.client = AsyncOpenAI(api_key=token, base_url=base, timeout=timeout, http_client=http_client,
                                      **sdk_retries)
        elif self.provider == "openai":
            from openai import AsyncOpenAI

            key_env = model_cfg.get("api_key_env", "OPENAI_API_KEY")
            key = os.environ.get(key_env)
            if not key:
                raise SystemExit(f"Missing API key: set {key_env} in .env")
            self.client = AsyncOpenAI(api_key=key, base_url=model_cfg.get("base_url") or None, timeout=120,
                                      **sdk_retries)
        else:
            raise SystemExit(f"Unknown provider '{self.provider}' for model {self.model}")

    async def chat(self, messages, tools=None, tool_choice=None, temperature=0.0, max_tokens=400,
                   response_format=None) -> dict:
        if self.backend is not None:
            async def backend_call():
                if self.pacer:
                    await self.pacer.wait()
                return await self.backend.create(
                    messages, tools=tools, tool_choice=tool_choice, temperature=temperature,
                    max_tokens=max_tokens, response_format=response_format)

            return await self._retry(backend_call)
        kwargs = dict(model=self.model, messages=messages, temperature=temperature, max_tokens=max_tokens)
        if tools:
            kwargs["tools"] = tools
            if tool_choice is not None:
                kwargs["tool_choice"] = tool_choice
        if response_format:
            kwargs["response_format"] = response_format
        if self.extra_body:
            kwargs["extra_body"] = self.extra_body

        async def call():
            if self.pacer:
                await self.pacer.wait()
            return _normalize(await self.client.chat.completions.create(**kwargs))

        return await self._retry(call)

    @staticmethod
    async def _retry(call):
        delay = 2.0
        last_err = None
        for attempt in range(7):
            try:
                return await call()
            except Exception as e:  # noqa: BLE001 - retry anything transient, surface the rest
                last_err = e
                name = type(e).__name__
                status = getattr(e, "status_code", None)
                transient = name in ("RateLimitError", "APITimeoutError", "APIConnectionError",
                                     "InternalServerError", "EmptyResponseError") \
                    or (status is not None and status >= 500) \
                    or status == 429
                if not transient or attempt == 6:
                    raise
                await asyncio.sleep(delay + random.random())
                delay = min(delay * 2, 60)
        raise last_err  # pragma: no cover


def _normalize(resp) -> dict:
    choice = resp.choices[0]
    msg = choice.message
    usage = getattr(resp, "usage", None)
    if msg is None:
        finish = getattr(choice, "finish_reason", None)
        if finish in ("malformed_response", "malformed_function_call"):
            # Gemini: the model itself produced an unparseable tool call. Repeats on retry, so it is
            # logged as the model's outcome (empty answer -> route event R5), not as an API error.
            return {"content": "", "tool_calls": [], "assistant_message": {"role": "assistant", "content": None},
                    "reasoning_present": False, "finish_reason": finish,
                    "usage": {"prompt_tokens": getattr(usage, "prompt_tokens", None),
                              "completion_tokens": getattr(usage, "completion_tokens", None)} if usage else None}
        raise EmptyResponseError(f"no message in response (finish_reason={finish})")
    content = msg.content or ""
    details = getattr(usage, "completion_tokens_details", None)
    reasoning = bool(getattr(msg, "reasoning_content", None) or getattr(msg, "reasoning", None)
                     or "<think>" in content or (getattr(details, "reasoning_tokens", None) or 0) > 0)
    content = THINK_RE.sub("", content).strip()
    calls = []
    for tc in (getattr(msg, "tool_calls", None) or []):
        raw = tc.function.arguments or "{}"
        try:
            args = json.loads(raw)
        except json.JSONDecodeError:
            args = {"_raw": raw}
        # Provider-specific fields on the call, e.g. Gemini 3's extra_content.google.thought_signature.
        # They must be echoed back in the next request (Gemini 3 returns 400 without the signature).
        extra = {k: v for k, v in (getattr(tc, "model_extra", None) or {}).items() if v is not None}
        calls.append({"id": tc.id, "name": tc.function.name, "arguments": args, "raw_arguments": raw,
                      "extra": extra})
    assistant_message = {"role": "assistant", "content": content or None}
    if calls:
        assistant_message["tool_calls"] = [
            {"id": c["id"], "type": "function", "function": {"name": c["name"], "arguments": c["raw_arguments"]}}
            | c["extra"] for c in calls]
    return {
        "content": content,
        "tool_calls": calls,
        "assistant_message": assistant_message,
        "reasoning_present": reasoning,
        "finish_reason": getattr(choice, "finish_reason", None),
        "usage": {"prompt_tokens": getattr(usage, "prompt_tokens", None),
                  "completion_tokens": getattr(usage, "completion_tokens", None)} if usage else None,
    }
