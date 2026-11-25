#!/usr/bin/env bash
# Run models entirely in Google Cloud as a Vertex AI custom job (your laptop can be off).
# Packages the code and data (never .env), uploads it to a bucket, and starts the job on a small CPU
# machine. The models it calls are pay-per-token Vertex endpoints, so nothing needs tearing down.
#
#   bash scripts/vertex_job_launch.sh "gemma4_26b deepseek_v41_flash mistral_small31"
#   LIMIT_PAIRS=3 MAX_HOURS=1 bash scripts/vertex_job_launch.sh "..."  # smoke test in the cloud first
#   RUN_ID=<existing id> bash scripts/vertex_job_launch.sh "..."       # resume a run from its outputs
#
# The job installs only requirements.txt, so code that works locally thanks to some other installed
# package fails there. The job sends one test request per model before the long run and prints the result.
#
# Watch:   gcloud ai custom-jobs stream-logs <job id> --region=us-central1 --project=<project>
# Fetch:   bash scripts/vertex_job_fetch.sh <RUN_ID>
#          (adds the run's models to outputs/, nothing local is deleted, then reports what is missing)
# Then:    python -m src.analyze
set -euo pipefail
cd "$(dirname "$0")/.."
MODELS="${1:?usage: scripts/vertex_job_launch.sh \"<model key> [<model key> ...]\"}"
PROJECT="${VERTEX_PROJECT:-thermal-loop-463117-r1}"
REGION="${VERTEX_REGION:-us-central1}"
BUCKET="${BUCKET:-${PROJECT}-route}"
RUN_ID="${RUN_ID:-$(date -u +%Y%m%d-%H%M%S)}"
CONDS="${CONDS:-C1 C2 T1 C3 C4 C5}"
CONCURRENCY="${CONCURRENCY:-16}"
MAX_HOURS="${MAX_HOURS:-8}"
IMAGE="${JOB_IMAGE:-docker.io/library/python:3.12-slim}"
G=(--project="$PROJECT" --billing-project="$PROJECT")

# Two jobs on one RUN_ID write to the same folder. Refuse while one is still active.
ACTIVE="$(gcloud ai custom-jobs list --region="$REGION" "${G[@]}" \
  --filter="displayName=route-$RUN_ID AND state:(JOB_STATE_QUEUED JOB_STATE_PENDING JOB_STATE_RUNNING)" \
  --format="value(name.basename())" 2>/dev/null || true)"
if [ -n "$ACTIVE" ]; then
  echo "RUN_ID=$RUN_ID already has an active job ($ACTIVE). Use a new RUN_ID, or wait for it to end."
  exit 1
fi

if ! gcloud storage buckets describe "gs://$BUCKET" "${G[@]}" > /dev/null 2>&1; then
  echo "Creating gs://$BUCKET in $REGION"
  gcloud storage buckets create "gs://$BUCKET" --location="$REGION" --uniform-bucket-level-access "${G[@]}"
fi

STAGE="$(mktemp -d)"; trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/data"
cp -r src scripts config.yaml requirements.txt "$STAGE/"
cp data/faithconflict.jsonl "$STAGE/data/"
# Pin to the versions in the local venv. This fixes versions only: the job still installs just the
# packages requirements.txt asks for, not everything the local venv has.
uv pip freeze --python .venv/bin/python > "$STAGE/constraints.txt"
find "$STAGE" -name __pycache__ -prune -exec rm -rf {} +
# --no-xattrs: macOS file attributes otherwise travel in the archive and Linux tar warns about each one.
COPYFILE_DISABLE=1 tar --no-xattrs -czf "$STAGE/code.tgz" -C "$STAGE" src scripts config.yaml requirements.txt constraints.txt data
gcloud storage cp "$STAGE/code.tgz" "gs://$BUCKET/code/$RUN_ID.tgz" "${G[@]}"

EXTRA_ENV=""
if [ -n "${LIMIT_PAIRS:-}" ]; then EXTRA_ENV="- {name: LIMIT_PAIRS, value: \"$LIMIT_PAIRS\"}"; fi
cat > "$STAGE/job.yaml" <<EOF
workerPoolSpecs:
  - machineSpec: {machineType: e2-standard-4}
    replicaCount: 1
    containerSpec:
      imageUri: $IMAGE
      command: [bash, -c]
      args: ["mkdir -p /work && tar xzf /gcs/$BUCKET/code/$RUN_ID.tgz -C /work && bash /work/scripts/vertex_job_entry.sh"]
      env:
        - {name: BUCKET, value: "$BUCKET"}
        - {name: RUN_ID, value: "$RUN_ID"}
        - {name: MODELS, value: "$MODELS"}
        - {name: CONDS, value: "$CONDS"}
        - {name: CONCURRENCY, value: "$CONCURRENCY"}
        - {name: GOOGLE_CLOUD_PROJECT, value: "$PROJECT"}
        - {name: PYTHONUNBUFFERED, value: "1"}
        $EXTRA_ENV
scheduling: {timeout: $((MAX_HOURS * 3600))s}
EOF
gcloud ai custom-jobs create --region="$REGION" --display-name="route-$RUN_ID" --config="$STAGE/job.yaml" "${G[@]}"
echo "RUN_ID=$RUN_ID  outputs: gs://$BUCKET/runs/$RUN_ID/"
