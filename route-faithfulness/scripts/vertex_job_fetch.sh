#!/usr/bin/env bash
# Copy the answers and labels of one or more cloud runs into outputs/, then check they are complete.
#
#   bash scripts/vertex_job_fetch.sh <RUN_ID> [<RUN_ID> ...]
#
# Adds or updates only the files of the models those runs produced; nothing local is deleted.
# Safe while a job is still running (you get what it has synced so far) and safe to repeat.
# Afterwards:  python -m src.analyze     (rewrites results/ for every model in outputs/judged)
set -euo pipefail
cd "$(dirname "$0")/.."
[ $# -ge 1 ] || { echo "usage: scripts/vertex_job_fetch.sh <RUN_ID> [<RUN_ID> ...]"; exit 1; }
PROJECT="${VERTEX_PROJECT:-thermal-loop-463117-r1}"
BUCKET="${BUCKET:-${PROJECT}-route}"
G=(--project="$PROJECT" --billing-project="$PROJECT")
# gcloud downloads larger files in slices and verifies them with its gcloud-crc32c helper. Some
# installs (Homebrew) do not ship that helper, and then every file over about 8 MB fails and gcloud
# crashes. Whole-file downloads need no helper.
export CLOUDSDK_STORAGE_SLICED_OBJECT_DOWNLOAD_THRESHOLD=0

MODELS=""
for id in "$@"; do
  src="gs://$BUCKET/runs/$id/outputs"
  echo "Fetching $src"
  # -u: keep a local file that is newer than the bucket's copy. After a local `src.judge` pass has
  # filled in labels, fetching again must not put the bucket's less complete file back.
  gcloud storage rsync -r -u "$src" outputs "${G[@]}"
  for d in $(gcloud storage ls "$src/raw/" "${G[@]}" | grep '/$'); do
    m="$(basename "$d")"
    [ "$m" = raw ] || MODELS="$MODELS $m"
  done
done

PY=.venv/bin/python; [ -x "$PY" ] || PY=python3
echo
echo "Completeness of:$MODELS"
"$PY" -m src.check --models $MODELS
