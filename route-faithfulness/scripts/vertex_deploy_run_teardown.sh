#!/usr/bin/env bash
# Deploy Llama 3.1 (8B or 70B) on Vertex AI Model Garden, run every condition, then DELETE the endpoint.
# The endpoint bills per hour while it exists, so teardown runs on normal exit, on any error, on Ctrl-C,
# and when the hard time limit (MAX_HOURS) is reached. Judging runs after teardown (it uses the MaaS judge).
#
#   bash scripts/vertex_deploy_run_teardown.sh llama8b            # deploy, 30-pair smoke, wait for the gate, full run
#   bash scripts/vertex_deploy_run_teardown.sh llama70b
#   bash scripts/vertex_deploy_run_teardown.sh teardown           # delete every route-llama31-* endpoint now
#
# Gate: after the smoke test the script waits for `touch logs/vertex_<which>.go` (continue to the full run)
# or `touch logs/vertex_<which>.stop` (tear down and quit). The hard time limit applies while waiting.
# Env: MAX_HOURS (default 4 for 8B, 5 for 70B), SMOKE_PAIRS (30), CONCURRENCY (32), NO_GATE=1 to skip the wait.
set -euo pipefail
cd "$(dirname "$0")/.."

PROJECT="${VERTEX_PROJECT:-thermal-loop-463117-r1}"
REGION="${VERTEX_REGION:-us-central1}"
G=(--project="$PROJECT" --billing-project="$PROJECT" --region="$REGION")
API="https://${REGION}-aiplatform.googleapis.com/v1/projects/${PROJECT}/locations/${REGION}"
# Same vLLM build for both sizes (Model Garden's image for Llama 3.1 70B on RTX PRO 6000).
IMAGE="us-docker.pkg.dev/vertex-ai/vertex-vision-model-garden-dockers/pytorch-vllm-serve:20251205_0916_RC01"
CONDS="C1 C2 T1 C3 C4 C5"
WHICH="${1:?usage: scripts/vertex_deploy_run_teardown.sh llama8b|llama70b|teardown}"

case "$WHICH" in
  llama8b)
    MG_MODEL="meta/llama3_1@llama-3.1-8b-instruct"; MACHINE="g2-standard-12"; ACC="NVIDIA_L4"; NACC=1
    WEIGHTS="gs://vertex-model-garden-restricted-us/llama3.1/Meta-Llama-3.1-8B-Instruct"
    HF_ID="meta-llama/Llama-3.1-8B-Instruct"; KEY="llama31_8b_vertex"; URLVAR="VERTEX_LLAMA31_8B_URL"
    MAX_HOURS="${MAX_HOURS:-4}"; DEPLOY_WAIT_MIN=60 ;;
  llama70b)
    MG_MODEL="meta/llama3_1@llama-3.1-70b-instruct"; MACHINE="g4-standard-96"; ACC="NVIDIA_RTX_PRO_6000"; NACC=2
    WEIGHTS="gs://vertex-model-garden-restricted-us/llama3.1/Meta-Llama-3.1-70B-Instruct"
    HF_ID="meta-llama/Llama-3.1-70B-Instruct"; KEY="llama31_70b_vertex"; URLVAR="VERTEX_LLAMA31_70B_URL"
    MAX_HOURS="${MAX_HOURS:-5}"; DEPLOY_WAIT_MIN=90 ;;
  teardown) ;;
  *) echo "unknown target '$WHICH' (llama8b, llama70b, teardown)"; exit 1 ;;
esac

log() { echo "[$(date '+%H:%M:%S')] $*"; }
token() { gcloud auth print-access-token; }
rest() { curl -s -H "Authorization: Bearer $(token)" -H "x-goog-user-project: $PROJECT" "$@"; }

# Endpoints whose display name starts with $1, one per line: "<endpoint id> <deployed id>:<model id> ..."
endpoints() {
  rest "$API/endpoints?pageSize=100" | python3 -c '
import json, sys
prefix = sys.argv[1]
d = json.load(sys.stdin)
if "error" in d:   # never report "no endpoints" when the listing itself failed
    sys.exit("endpoint listing failed: " + d["error"].get("message", ""))
for e in d.get("endpoints", []):
    if e.get("displayName", "").startswith(prefix):
        dms = " ".join(d["id"] + ":" + d.get("model", "").split("/")[-1] for d in e.get("deployedModels", []))
        print(e["name"].split("/")[-1], dms)' "$1"
}

teardown() {
  local prefix="$1" tries=0
  set +e
  [ -n "${WATCHDOG:-}" ] && kill "$WATCHDOG" 2>/dev/null
  [ -n "${OP:-}" ] && rest -X POST "$API/operations/$OP:cancel" > /dev/null   # no-op if the deploy finished
  while :; do
    local lines; lines="$(endpoints "$prefix")"
    if [ $? -ne 0 ]; then
      log "Could not list endpoints; retrying."
    elif [ -z "$lines" ]; then
      log "TEARDOWN OK: no endpoints named $prefix* remain."; break
    fi
    while read -r eid dms; do
      [ -z "$eid" ] && continue
      for dm in $dms; do
        log "Undeploying ${dm%%:*} from endpoint $eid"
        gcloud ai endpoints undeploy-model "$eid" --deployed-model-id="${dm%%:*}" --quiet "${G[@]}" 2>&1 | tail -1
        gcloud ai models delete "${dm##*:}" --quiet "${G[@]}" > /dev/null 2>&1
      done
      log "Deleting endpoint $eid"
      gcloud ai endpoints delete "$eid" --quiet "${G[@]}" 2>&1 | tail -1
    done <<< "$lines"
    tries=$((tries + 1))
    if [ "$tries" -ge 20 ]; then
      log "TEARDOWN FAILED after $tries tries. Endpoints still billing:"; endpoints "$prefix"
      log "Delete them in the console: https://console.cloud.google.com/vertex-ai/online-prediction/endpoints?project=$PROJECT"
      return 1
    fi
    sleep 30
  done
}

if [ "$WHICH" = teardown ]; then teardown "route-llama31-"; exit $?; fi

[ -d .venv ] && source .venv/bin/activate
EP_NAME="route-llama31-${WHICH#llama}"
GATE_GO="logs/vertex_${WHICH}.go"; GATE_STOP="logs/vertex_${WHICH}.stop"
CONCURRENCY="${CONCURRENCY:-32}"
mkdir -p logs; rm -f "$GATE_GO" "$GATE_STOP"
[ -n "$(endpoints "$EP_NAME")" ] && { log "An endpoint named $EP_NAME already exists; run teardown first."; exit 1; }

# Foreground children block bash's signal traps, so every long step runs in the background and is waited on.
CHILD=""
step() { "$@" & CHILD=$!; wait "$CHILD"; local rc=$?; CHILD=""; return $rc; }
on_signal() { log "Stopping (signal)."; [ -n "$CHILD" ] && kill "$CHILD" 2>/dev/null; exit 1; }
trap on_signal INT TERM
trap 'teardown "$EP_NAME"' EXIT

MAIN_PID=$$
( sleep $((MAX_HOURS * 3600)); echo "[watchdog] HARD STOP after $MAX_HOURS h"; kill -TERM "$MAIN_PID" ) &
WATCHDOG=$!
log "$WHICH on $MACHINE ($NACC x $ACC) in $REGION; hard stop in $MAX_HOURS h."

ARGS="python3,-m,vllm.entrypoints.api_server,--host=0.0.0.0,--port=7080,--model=$WEIGHTS"
ARGS+=",--served-model-name=$HF_ID,--tensor-parallel-size=$NACC,--max-model-len=16384,--max-num-seqs=32"
ARGS+=",--gpu-memory-utilization=0.95,--swap-space=16,--enable-chunked-prefill,--enable-prefix-caching"
ARGS+=",--enable-auto-tool-choice,--tool-call-parser=llama3_json,--disable-log-stats"
log "Deploying $MG_MODEL"
DEPLOY_OUT="$(gcloud ai model-garden models deploy --model="$MG_MODEL" --machine-type="$MACHINE" \
  --accelerator-type="$ACC" --accelerator-count="$NACC" --endpoint-display-name="$EP_NAME" \
  --container-image-uri="$IMAGE" --container-args="$ARGS" --container-ports=7080 \
  --container-predict-route=/generate --container-health-route=/ping \
  --container-env-vars="MODEL_ID=$HF_ID" --container-deployment-timeout-seconds=7200 \
  --accept-eula --asynchronous "${G[@]}" 2>&1)" || { echo "$DEPLOY_OUT"; exit 1; }
echo "$DEPLOY_OUT"
OP="$(echo "$DEPLOY_OUT" | grep -oE 'operations/[0-9]+' | head -1 | cut -d/ -f2 || true)"
log "Deploy operation: ${OP:-unknown}"

EID=""
for i in $(seq 1 $((DEPLOY_WAIT_MIN * 2))); do
  read -r EID DMS <<< "$(endpoints "$EP_NAME" | head -1)" || true
  [ -n "${DMS:-}" ] && break
  if [ -n "$OP" ]; then
    opstate="$(rest "$API/operations/$OP" | python3 -c 'import json,sys; o=json.load(sys.stdin); print(("ERROR " + o["error"].get("message","")) if o.get("done") and "error" in o else ("done" if o.get("done") else "running"))')"
    case "$opstate" in ERROR*) log "Deploy failed: $opstate"; exit 1 ;; esac
  fi
  [ $((i % 6)) -eq 0 ] && log "Still deploying ($((i / 2)) min)..."
  step sleep 30
done
[ -z "${DMS:-}" ] && { log "Not deployed after $DEPLOY_WAIT_MIN min."; exit 1; }

DNS="$(rest "$API/endpoints/$EID" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("dedicatedEndpointDns",""))')"
HOST="${DNS:-${REGION}-aiplatform.googleapis.com}"
export "$URLVAR=https://$HOST/v1beta1/projects/$PROJECT/locations/$REGION/endpoints/$EID"
log "Endpoint $EID is up: ${!URLVAR}"

log "One request to check the endpoint:"
step python3 - "$KEY" <<'EOF'
import asyncio, sys
from src.config import load_config   # also loads .env
from src.llm import LLM
cfg = load_config()
llm = LLM(cfg["models"][sys.argv[1]])
print(asyncio.run(llm.chat([{"role": "user", "content": "Reply with the single word: ready"}], max_tokens=5)))
EOF

log "Smoke test: ${SMOKE_PAIRS:-30} pairs"
step python -m src.run --model "$KEY" --conditions $CONDS --limit-pairs "${SMOKE_PAIRS:-30}" --concurrency "$CONCURRENCY"
if [ -z "${NO_GATE:-}" ]; then
  log "SMOKE DONE. Waiting: touch $GATE_GO to run everything, or touch $GATE_STOP to tear down."
  while [ ! -f "$GATE_GO" ] && [ ! -f "$GATE_STOP" ]; do step sleep 15; done
  [ -f "$GATE_STOP" ] && { log "Stop requested."; exit 0; }
fi

log "Full run"
step python -m src.run --model "$KEY" --conditions $CONDS --concurrency "$CONCURRENCY"
log "Second pass (retries errored rows)"
step python -m src.run --model "$KEY" --conditions $CONDS --concurrency "$CONCURRENCY"

trap - EXIT
teardown "$EP_NAME"
log "Judging (MaaS judge; endpoint already deleted)"
step python -m src.judge --model "$KEY" --conditions $CONDS
log "FINISHED $WHICH"
