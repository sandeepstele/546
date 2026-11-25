#!/usr/bin/env bash
# Runs INSIDE a Vertex AI custom job (started by scripts/vertex_job_launch.sh). Vertex mounts the bucket
# at /gcs/<bucket>, so code comes from there and outputs are copied back every few minutes and at exit.
# Each model: one test request, all conditions, a second pass that retries errored rows, then the judge
# (also twice: its rate limit drops a few labels on the first pass).
# Then a completeness check (src.check) and the analysis.
# The job ends FAILED if a model could not start, or if answers or labels are still missing after both
# passes, so SUCCEEDED means every document was answered and judged. The outputs are synced either way.
# Resumable: a rerun with the same RUN_ID starts from the outputs already in the bucket.
# Only this job's models are copied from and to the bucket, so jobs for different models never
# overwrite each other's files.
set -euo pipefail
RUN="${GCS_ROOT:-/gcs}/${BUCKET:?}/runs/${RUN_ID:?}"
CONDS="${CONDS:-C1 C2 T1 C3 C4 C5}"
CONC="${CONCURRENCY:-16}"
LIMIT="${LIMIT_PAIRS:+--limit-pairs $LIMIT_PAIRS}"   # smoke test: LIMIT_PAIRS=3 runs 3 pairs per group
cd "$(dirname "$0")/.."
now() { date -u +%H:%M:%S; }

echo "[$(now)] Installing packages"
pip install -q --no-cache-dir --root-user-action=ignore -r requirements.txt -c constraints.txt

mkdir -p outputs logs "$RUN"
for m in ${MODELS:?}; do
  for kind in raw judged; do
    [ -d "$RUN/outputs/$kind/$m" ] || continue
    echo "Resuming $m from $RUN/outputs/$kind/$m"
    mkdir -p "outputs/$kind/$m"; cp -r "$RUN/outputs/$kind/$m/." "outputs/$kind/$m/"
  done
done
sync_out() {
  local m kind
  mkdir -p "$RUN/logs"
  for m in $MODELS; do
    for kind in raw judged; do
      [ -d "outputs/$kind/$m" ] || continue
      mkdir -p "$RUN/outputs/$kind/$m"; cp -r "outputs/$kind/$m/." "$RUN/outputs/$kind/$m/"
    done
  done
  cp -r logs/. "$RUN/logs/"
  [ -d results ] && cp -r results "$RUN/" || true
}
progress() {   # always returns 0: with no log files yet, the failed test must not end the script (set -e)
  for f in logs/*.log; do [ -f "$f" ] && echo "  $(basename "$f" .log): $(tr '\r' '\n' < "$f" | grep -v '^\s*$' | tail -1 | cut -c1-150)"; done
  return 0
}
# set +e: one failed copy must not end the periodic sync for the rest of the job.
( set +e; while sleep "${SYNC_SECONDS:-300}"; do sync_out; echo "[$(now)] progress"; progress; done ) &
SYNC=$!
trap 'kill $SYNC 2>/dev/null; wait $SYNC 2>/dev/null || true; sync_out; echo "outputs synced to $RUN"' EXIT

FAIL=0
# One real request to the judge and to each model before the long run. A model that cannot start
# (missing package, no access, wrong region) is reported here, in the job's own log, within a minute.
python -m src.ping judge || { echo "[$(now)] The judge failed its test request; answers will be collected but not labeled."; FAIL=1; }
PIDS=()
for m in $MODELS; do
  if ! python -m src.ping "$m"; then
    echo "[$(now)] NOT STARTED: $m failed its test request (see the line above)"; FAIL=1; continue
  fi
  ( python -m src.run --model "$m" --conditions $CONDS --concurrency "$CONC" $LIMIT \
    && python -m src.run --model "$m" --conditions $CONDS --concurrency "$CONC" $LIMIT \
    && python -m src.judge --model "$m" --conditions $CONDS \
    && python -m src.judge --model "$m" --conditions $CONDS ) > "logs/$m.log" 2>&1 &   # 2nd pass: labels the judge's rate limit dropped
  PIDS+=($!)
  echo "[$(now)] started $m"
done
for p in ${PIDS[@]+"${PIDS[@]}"}; do wait "$p" || FAIL=1; done
progress

echo "[$(now)] Completeness (answers and labels per model and condition)"
python -m src.check --models $MODELS --conditions $CONDS $LIMIT 2>&1 | tee logs/check.log || FAIL=1

echo "[$(now)] Analyzing"
python -m src.analyze --models $MODELS > logs/analyze.log 2>&1 || { FAIL=1; tail -20 logs/analyze.log; }
echo "[$(now)] FINISHED (failures: $FAIL)"
exit $FAIL
