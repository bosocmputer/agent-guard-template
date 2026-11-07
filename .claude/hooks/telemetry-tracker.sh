#!/usr/bin/env bash
# Dual-Mode Real-Time Telemetry Tracker (Claude Code + Antigravity -> .claude/.telemetry.json)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT" || exit 0

TELEMETRY_FILE="$PROJECT_ROOT/.claude/.telemetry.json"
mkdir -p "$PROJECT_ROOT/.claude"

# โหมด 1: รับจาก Hook stdin โดยตรง (--hook-stdin <prompt|read|stop>)
if [ "${1:-}" = "--hook-stdin" ]; then
  HOOK_STAGE="${2:-unknown}"
  INPUT=$(cat)
  if echo "$INPUT" | grep -qE '"(conversationId|toolCall|invocationNum|executionNum)"'; then
    MODE="antigravity"
  else
    MODE="claude"
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$TELEMETRY_FILE" "$HOOK_STAGE" "$MODE" "$INPUT" <<'PYEOF' 2>/dev/null || true
import sys, os, json, time
from datetime import datetime, timezone

t_file, stage, mode, raw_in = sys.argv[1:5]
try:
    payload = json.loads(raw_in) if raw_in.strip() else {}
except Exception:
    payload = {}

state = {
    "updatedAt": "",
    "updatedEpochMs": 0,
    "activeEngine": mode,
    "activeModel": "sonnet" if mode == "claude" else "gemini-4-argon",
    "activeNode": "core",
    "systemStatus": "ready",
    "currentTask": "รอรับคำสั่ง (Waiting for command...)",
    "currentAction": "System Ready",
    "strikeCount": 0,
    "maxStrikes": 3,
    "touchedFiles": [],
    "stats": {"claudeCalls": 0, "antigravityCalls": 0, "blockedCount": 0, "filesEdited": 0},
    "events": []
}
if os.path.exists(t_file):
    try:
        loaded = json.load(open(t_file, encoding="utf-8"))
        if isinstance(loaded, dict):
            state.update(loaded)
    except Exception:
        pass

state["activeEngine"] = mode
if payload.get("modelName") and payload.get("modelName") != "auto":
    state["activeModel"] = str(payload["modelName"])

prompt_txt = payload.get("prompt") or payload.get("lastUserInput") or ""
if prompt_txt:
    clean_p = " ".join(str(prompt_txt).split())
    if len(clean_p) > 140:
        clean_p = clean_p[:137] + "..."
    state["currentTask"] = clean_p

if stage == "prompt":
    state["activeNode"] = "core"
    if mode == "claude" and not payload.get("modelName"):
        state["activeModel"] = "opus"
    state["systemStatus"] = "working"
    state["currentAction"] = f"👑 หัวหน้าสถาปนิก (Opus) กำลังวิเคราะห์โจทย์: {state['currentTask'][:70]}"
elif stage == "read":
    tool_name = (payload.get("toolCall") or {}).get("name") or payload.get("tool_name") or "Read/Search"
    tool_args = (payload.get("toolCall") or {}).get("args") or payload.get("tool_input") or {}
    target = tool_args.get("Path") or tool_args.get("file_path") or tool_args.get("pattern") or tool_args.get("Query") or ""
    if target:
        target = os.path.basename(str(target).rstrip("/")) or str(target)
    state["activeNode"] = "explorer"
    state["activeModel"] = "haiku" if mode == "claude" else state.get("activeModel", "auto")
    state["systemStatus"] = "working"
    state["currentAction"] = f"🔍 Explorer ({tool_name}): {target}" if target else f"🔍 Explorer ({tool_name})"
elif stage == "stop":
    term_reason = payload.get("terminationReason") or "COMPLETED"
    if term_reason == "MAX_TOKEN_BUDGET_EXCEEDED":
        state["activeNode"] = "core"
        state["systemStatus"] = "blocked"
        state["currentAction"] = "🔴 โควต้าเต็ม (MAX_TOKEN_BUDGET_EXCEEDED) — แนะนำสลับค่าย AI!"
    else:
        state["activeNode"] = "reviewer"
        state["systemStatus"] = "ready"
        state["currentAction"] = "✅ ทำงานรอบนี้เสร็จสิ้น (Ready for next prompt)"

stats = state.get("stats") or {"claudeCalls": 0, "antigravityCalls": 0, "blockedCount": 0, "filesEdited": 0}
if stage in ("prompt", "read"):
    if mode == "claude":
        stats["claudeCalls"] = int(stats.get("claudeCalls", 0)) + 1
    else:
        stats["antigravityCalls"] = int(stats.get("antigravityCalls", 0)) + 1
state["stats"] = stats

now_local = datetime.now().strftime("%H:%M:%S")
events = state.get("events") or []
events.insert(0, {
    "time": now_local,
    "engine": mode,
    "node": state["activeNode"],
    "status": state["systemStatus"],
    "detail": state["currentAction"]
})
state["events"] = events[:25]
state["updatedAt"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
state["updatedEpochMs"] = int(time.time() * 1000)

tmp = f"{t_file}.tmp.{os.getpid()}"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(state, f, ensure_ascii=False, indent=2)
os.replace(tmp, t_file)
PYEOF
  fi

  if [ "$MODE" = "antigravity" ]; then
    if [ "$HOOK_STAGE" = "read" ]; then
      printf '{"decision":"allow"}\n'
    elif [ "$HOOK_STAGE" = "stop" ]; then
      printf '{"decision":"allow"}\n'
    else
      printf '{}\n'
    fi
  fi
  exit 0
fi

# โหมด 2: เรียกจาก Hook อื่นๆ (--engine <mode> --node <node> --status <status> --detail <msg> [--file <path>] [--strike <n>] [--model <model>])
ENGINE="claude"
NODE="core"
STATUS="working"
DETAIL=""
FILE_TOUCHED=""
STRIKE=""
MODEL_ARG=""

while [ $# -gt 0 ]; do
  case "$1" in
    --engine) ENGINE="${2:-claude}"; shift 2 ;;
    --node)   NODE="${2:-core}"; shift 2 ;;
    --status) STATUS="${2:-working}"; shift 2 ;;
    --detail) DETAIL="${2:-}"; shift 2 ;;
    --file)   FILE_TOUCHED="${2:-}"; shift 2 ;;
    --strike) STRIKE="${2:-}"; shift 2 ;;
    --model)  MODEL_ARG="${2:-}"; shift 2 ;;
    *) shift ;;
  esac
done

if command -v python3 >/dev/null 2>&1; then
  python3 - "$TELEMETRY_FILE" "$ENGINE" "$NODE" "$STATUS" "$DETAIL" "$FILE_TOUCHED" "$STRIKE" "$MODEL_ARG" <<'PYEOF' 2>/dev/null || true
import sys, os, json, time
from datetime import datetime, timezone

t_file, engine, node, status, detail, file_touched, strike, model_arg = sys.argv[1:9]

state = {
    "updatedAt": "",
    "updatedEpochMs": 0,
    "activeEngine": engine,
    "activeModel": "opus" if (engine == "claude" and node == "core") else ("sonnet" if engine == "claude" else "gemini-4-argon"),
    "activeNode": node,
    "systemStatus": status,
    "currentTask": "กำลังดำเนินงานในโปรเจกต์...",
    "currentAction": detail or "กำลังประมวลผล...",
    "strikeCount": 0,
    "maxStrikes": 3,
    "touchedFiles": [],
    "stats": {"claudeCalls": 0, "antigravityCalls": 0, "blockedCount": 0, "filesEdited": 0},
    "events": []
}
if os.path.exists(t_file):
    try:
        loaded = json.load(open(t_file, encoding="utf-8"))
        if isinstance(loaded, dict):
            state.update(loaded)
    except Exception:
        pass

state["activeEngine"] = engine
state["activeNode"] = node
state["systemStatus"] = status
if model_arg:
    state["activeModel"] = model_arg
elif engine == "claude":
    if node == "core":
        state["activeModel"] = "opus"
    elif node == "explorer":
        state["activeModel"] = "haiku"
    elif node in ("implementer", "debugger", "reviewer"):
        state["activeModel"] = "sonnet"
else:
    state["activeModel"] = "gemini-4-argon"

if detail:
    state["currentAction"] = detail

if strike != "":
    try:
        state["strikeCount"] = int(strike)
    except Exception:
        pass

stats = state.get("stats") or {"claudeCalls": 0, "antigravityCalls": 0, "blockedCount": 0, "filesEdited": 0}
if engine == "claude":
    stats["claudeCalls"] = int(stats.get("claudeCalls", 0)) + 1
else:
    stats["antigravityCalls"] = int(stats.get("antigravityCalls", 0)) + 1

if status == "blocked":
    stats["blockedCount"] = int(stats.get("blockedCount", 0)) + 1

if file_touched:
    short_f = os.path.relpath(file_touched, os.getcwd()) if os.path.isabs(file_touched) else file_touched
    if short_f.startswith(".."):
        short_f = os.path.basename(file_touched)
    touched = state.get("touchedFiles") or []
    if short_f in touched:
        touched.remove(short_f)
    touched.insert(0, short_f)
    state["touchedFiles"] = touched[:6]
    stats["filesEdited"] = int(stats.get("filesEdited", 0)) + 1

state["stats"] = stats

now_local = datetime.now().strftime("%H:%M:%S")
events = state.get("events") or []
events.insert(0, {
    "time": now_local,
    "engine": engine,
    "node": node,
    "status": status,
    "detail": detail or status
})
state["events"] = events[:25]
state["updatedAt"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
state["updatedEpochMs"] = int(time.time() * 1000)

tmp = f"{t_file}.tmp.{os.getpid()}"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(state, f, ensure_ascii=False, indent=2)
os.replace(tmp, t_file)
PYEOF
fi
exit 0
