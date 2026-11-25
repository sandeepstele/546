"""Is a run complete? Counts, per model and condition, the documents answered, errored, missing and judged.

    python -m src.check                                    # every model in outputs/raw, conditions from config
    python -m src.check --models gemma4_26b mistral_small31
    python -m src.check --models gpt4o --no-judge          # before judging
    python -m src.check --models gpt4o --limit-pairs 30    # after a smoke test: only the sampled pairs

Exits 1 while anything can still be filled in by rerunning (errored or missing answers, judge calls that
failed), so a script can tell "finished" from "complete". Not counted as gaps, because a rerun cannot
change them: empty answers (the model's own outcome, route event R5) and judge replies with no usable code.
"""
from __future__ import annotations

import argparse
import sys
from collections import Counter

from .config import load_config, read_jsonl, resolve
from .data import balanced_pair_sample, load_normalized

COLS = ("docs", "answered", "errors", "missing", "empty", "judged", "judge_failed", "unparseable")


def check_condition(cfg, model: str, cond: str, uids: set[str], judged: bool = True) -> tuple[dict, Counter]:
    out = resolve(cfg["run"]["output_dir"])
    raw = {r["doc_uid"]: r for r in read_jsonl(out / "raw" / model / f"{cond}.jsonl") if r.get("doc_uid") in uids}
    ok = {u: r for u, r in raw.items() if not r.get("error")}
    kinds = Counter(str(r["error"]).split(":")[0] for r in raw.values() if r.get("error"))
    answered = {u for u, r in ok.items() if r.get("answer")}
    row = {"docs": len(uids), "answered": len(ok), "errors": len(raw) - len(ok), "missing": len(uids - set(raw)),
           "empty": len(ok) - len(answered), "judged": 0, "judge_failed": 0, "unparseable": 0}
    if judged:
        codes = {r["doc_uid"]: r for r in read_jsonl(out / "judged" / model / f"{cond}.jsonl")}
        for u in answered:
            j = codes.get(u)
            if j and j.get("code"):
                row["judged"] += 1
            elif j and j.get("judge_error") == "unparseable":
                row["unparseable"] += 1
            else:
                row["judge_failed"] += 1   # never judged, or the judge call itself failed
    return row, kinds


def gaps(row: dict) -> int:
    return row["errors"] + row["missing"] + row["judge_failed"]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--models", nargs="+")
    ap.add_argument("--conditions", nargs="+")
    ap.add_argument("--no-judge", action="store_true", help="check answers only")
    ap.add_argument("--limit-pairs", type=int, help="check only the balanced sample that src.run --limit-pairs ran")
    ap.add_argument("--config")
    a = ap.parse_args()
    cfg = load_config(a.config)
    rows = load_normalized(cfg)
    if a.limit_pairs:  # the same sample src.run draws
        keep = balanced_pair_sample(rows, a.limit_pairs, cfg["run"].get("seed", 13))
        rows = [r for r in rows if r["pair_id"] in keep]
    uids = {r["doc_uid"] for r in rows}
    raw_dir = resolve(cfg["run"]["output_dir"]) / "raw"
    models = a.models or (sorted(p.name for p in raw_dir.iterdir() if p.is_dir()) if raw_dir.exists() else [])
    conds = a.conditions or cfg["run"]["conditions"]
    cols = COLS[:5] if a.no_judge else COLS
    print(f"{'model':20s} {'cond':4s} " + " ".join(f"{c:>12s}" for c in cols))
    total = 0
    for m in models:
        for c in conds:
            row, kinds = check_condition(cfg, m, c, uids, judged=not a.no_judge)
            total += gaps(row) if not a.no_judge else row["errors"] + row["missing"]
            note = ("   <- " + ", ".join(f"{k} x{n}" for k, n in kinds.most_common(3))) if kinds else ""
            print(f"{m:20s} {c:4s} " + " ".join(f"{row[k]:12d}" for k in cols) + note)
    if total:
        print(f"\nINCOMPLETE: {total} rows can still be filled in. Rerun src.run (answers) and src.judge (labels) "
              f"for the models above; both resume and retry only what is missing.")
        sys.exit(1)
    print("\nCOMPLETE: every document is answered" + ("" if a.no_judge else " and judged") + ".")


if __name__ == "__main__":
    main()
