"""One real request per model, to find out in seconds whether it can start at all.

    python -m src.ping mistral_small31 gemma4_26b     # model keys from config.yaml
    python -m src.ping judge                          # the judge model

Exits 1 if any of them fails. Run it before a long job: a missing package, no access to the model or a
wrong region shows up here, not as thousands of errored rows (or a crash) a few minutes into the run.
"""
from __future__ import annotations

import asyncio
import sys

from .config import load_config
from .llm import LLM


async def ping(cfg: dict, key: str) -> str:
    model_cfg = cfg["judge"] if key == "judge" else cfg["models"][key]
    llm = LLM(model_cfg)
    try:
        r = await llm.chat([{"role": "user", "content": "Reply with the single word: ready"}], max_tokens=16)
    finally:
        client = getattr(llm, "client", None) or getattr(llm.backend, "client", None)
        if client is not None:
            await client.close()
    return f"{model_cfg['model']} answered {r['content']!r} (finish_reason={r['finish_reason']})"


async def ping_all(keys: list[str]) -> int:
    cfg = load_config()
    failed = 0
    for key in keys:
        try:
            print(f"OK      {key}: {await ping(cfg, key)}", flush=True)
        except (Exception, SystemExit) as e:  # noqa: BLE001 - LLM() exits on a missing key or endpoint URL
            failed += 1
            print(f"FAILED  {key}: {type(e).__name__}: {str(e)[:400]}", flush=True)
    return failed


def main() -> None:
    keys = sys.argv[1:]
    if not keys:
        sys.exit("usage: python -m src.ping <model key | judge> [...]")
    sys.exit(1 if asyncio.run(ping_all(keys)) else 0)


if __name__ == "__main__":
    main()
