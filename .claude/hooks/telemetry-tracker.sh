#!/usr/bin/env bash
# Slim Dual-Mode Guard State & Read-Secret Hook (Claude Code + Antigravity IDE)
# Keeps: Read secret blocker, Zero-Python Read fast-path, compact <1KB .telemetry.json
# state (strikeCount / stats / session turns), and 100t/120t Auto-Handoff & Survival Mode.
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT" || exit 0

TELEMETRY_FILE="$PROJECT_ROOT/.claude/.telemetry.json"
mkdir -p "$PROJECT_ROOT/.claude" 2>/dev/null || true

MODE_TYPE="cli"
HOOK_STAGE="unknown"
RAW_STDIN=""

if [ "${1:-}" = "--hook-stdin" ]; then
  MODE_TYPE="stdin"
  HOOK_STAGE="${2:-unknown}"
  RAW_STDIN=$(cat)
  if echo "$RAW_STDIN" | grep -qE '"(conversationId|toolCall|invocationNum|executionNum)"'; then
    ENGINE="antigravity"
  else
    ENGINE="claude"
  fi

  if [ "$HOOK_STAGE" = "read" ]; then
    READ_PATH=$(echo "$RAW_STDIN" | grep -oE '"(Path|file_path)"[[:space:]]*:[[:space:]]*"(\\.|[^"\\])*"' | head -1 | sed -E 's/^"(Path|file_path)"[[:space:]]*:[[:space:]]*"//;s/"$//;s/\\"/"/g')
    if [ -n "$READ_PATH" ] && echo "$READ_PATH" | grep -qE '((^|/)(\.env($|\.)|.*\.(pem|key|p12|keystore|jks|sqlite|db)$)|(^|/)(\.ssh|\.aws|\.kube|\.gnupg)(/|$)|(^|/)\.(netrc|npmrc|pypirc)$)'; then
      bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$ENGINE" --node "core" --status "blocked" --detail "Blocked reading sensitive file: $READ_PATH" >/dev/null 2>&1 || true
      if [ "$ENGINE" = "antigravity" ]; then
        printf '{"decision":"deny","reason":"ไม่อนุญาตให้อ่านไฟล์ความลับ (.env/key/db) หรือโฟลเดอร์ Credential ของเครื่องโฮสต์ (~/.ssh, ~/.aws, ~/.kube) โดยตรง (%s)"}\n' "$READ_PATH"
        exit 0
      else
        echo "❌ [Hook Blocked - Secrets & Host Credential Guard]: ไม่อนุญาตให้อ่านไฟล์ความลับ (.env/key/db) หรือโฟลเดอร์ Credential ของเครื่องโฮสต์ (~/.ssh, ~/.aws, ~/.kube) โดยตรง ($READ_PATH)" >&2
        exit 2
      fi
    fi
    # Zero-Python Fast-Path (~20ms) for all allowed reads
    printf '1' >> "$PROJECT_ROOT/.claude/.read_buf.cnt" 2>/dev/null || true
    if [ "$ENGINE" = "antigravity" ]; then
      printf '{"decision":"allow"}\n'
    fi
    exit 0
  fi
else
  ENGINE="claude"
  NODE="core"
  STATUS="working"
  STRIKE=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --engine) ENGINE="${2:-claude}"; shift 2 ;;
      --node)   NODE="${2:-core}"; shift 2 ;;
      --status) STATUS="${2:-working}"; shift 2 ;;
      --strike) STRIKE="${2:-}"; shift 2 ;;
      --detail|--file|--model|--skill|--command|--rule|--hook|--prompt|--diff) shift 2 ;;
      *) shift ;;
    esac
  done
fi

if command -v python3 >/dev/null 2>&1; then
  python3 - "$PROJECT_ROOT" "$TELEMETRY_FILE" "$MODE_TYPE" "$HOOK_STAGE" "$ENGINE" "${NODE:-core}" "${STATUS:-working}" "${STRIKE:-}" "$RAW_STDIN" <<'PYEOF' 2>/dev/null || true
import json, os, sys
from datetime import datetime, timezone

project_root, t_file, mode_type, stage, engine, node, status, strike_arg, raw_in = sys.argv[1:10]

state = {
    "updatedAt": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "activeEngine": engine,
    "activeNode": "core",
    "systemStatus": "ready",
    "strikeCount": 0,
    "maxStrikes": 3,
    "lastIsSubagent": False,
    "stats": {
        "claudeCalls": 0,
        "antigravityCalls": 0,
        "explorerReads": 0,
        "implementerEdits": 0,
        "verifierRuns": 0,
        "blockedCount": 0,
        "filesEdited": 0,
        "subagentSpawns": 0,
    },
}

if os.path.exists(t_file):
    try:
        loaded = json.load(open(t_file, encoding="utf-8"))
        if isinstance(loaded, dict):
            old_stats = state["stats"].copy()
            if isinstance(loaded.get("stats"), dict):
                old_stats.update(loaded["stats"])
            # Preserve lightweight session/audit keys only (drop legacy HUD bloat)
            for k in (
                "strikeCount", "activeNode", "sessionProof", "sessionId", "opusTurns",
                "lastCacheTokens", "lastIsSubagent", "lastConversationId",
                "lastTranscriptPath", "lastAuditBaseline", "prevAuditBaseline", "promptBaseline",
            ):
                if k in loaded:
                    state[k] = loaded[k]
            state["stats"] = old_stats
    except Exception:
        pass

stats = state["stats"]

# Flush buffered fast-path read counts atomically
buf = os.path.join(project_root, ".claude", ".read_buf.cnt")
if os.path.isfile(buf):
    tmp_buf = f"{buf}.flushing.{os.getpid()}"
    try:
        os.replace(buf, tmp_buf)
        with open(tmp_buf, "rb") as bf:
            n_reads = len(bf.read())
        if n_reads > 0:
            stats["explorerReads"] = int(stats.get("explorerReads", 0)) + n_reads
    except Exception:
        pass
    finally:
        try:
            if os.path.exists(tmp_buf):
                os.remove(tmp_buf)
        except Exception:
            pass

payload = {}
if raw_in:
    try:
        payload = json.loads(raw_in)
    except Exception:
        payload = {}

if engine == "antigravity":
    stats["antigravityCalls"] = int(stats.get("antigravityCalls", 0)) + 1
else:
    stats["claudeCalls"] = int(stats.get("claudeCalls", 0)) + 1

if mode_type == "stdin":
    cid = str(payload.get("conversationId") or payload.get("session_id") or "")
    if cid:
        state["lastConversationId"] = cid
    if stage == "prompt":
        state["activeNode"] = "core"
        state["systemStatus"] = "working"
        state["lastIsSubagent"] = bool(payload.get("isSubagent") or False)
    elif stage == "agent":
        stats["subagentSpawns"] = int(stats.get("subagentSpawns", 0)) + 1
        state["systemStatus"] = "working"
    elif stage == "stop":
        state["systemStatus"] = "ready"
else:
    state["activeNode"] = node
    state["systemStatus"] = status
    if status == "blocked":
        stats["blockedCount"] = int(stats.get("blockedCount", 0)) + 1
    elif node == "implementer" and status == "working":
        stats["implementerEdits"] = int(stats.get("implementerEdits", 0)) + 1
        stats["filesEdited"] = int(stats.get("filesEdited", 0)) + 1
    elif node == "reviewer" or status == "verified":
        stats["verifierRuns"] = int(stats.get("verifierRuns", 0)) + 1
    if strike_arg != "":
        try:
            state["strikeCount"] = int(strike_arg)
        except ValueError:
            pass

state["updatedAt"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
tmp_out = f"{t_file}.tmp.{os.getpid()}"
with open(tmp_out, "w", encoding="utf-8") as out:
    json.dump(state, out, indent=2, ensure_ascii=False)
os.replace(tmp_out, t_file)
PYEOF
fi

if [ "$MODE_TYPE" = "stdin" ] && [ "$ENGINE" = "antigravity" ]; then
  if [ "$HOOK_STAGE" = "stop" ] || [ "$HOOK_STAGE" = "agent" ]; then
    printf '{"decision":"allow"}\n'
  elif [ "$HOOK_STAGE" = "prompt" ]; then
    if grep -q '"lastIsSubagent"[[:space:]]*:[[:space:]]*true' "$TELEMETRY_FILE" 2>/dev/null; then
      printf '{}\n'
    else
      AG_CUR_SID=$(echo "$RAW_STDIN" | grep -oE '"conversationId"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 | sed -E 's/^"conversationId"[[:space:]]*:[[:space:]]*"//;s/"$//' | cut -c1-8)
      AG_PREV_SID=$(grep -oE '"sessionId"[[:space:]]*:[[:space:]]*"[^"]+"' "$TELEMETRY_FILE" 2>/dev/null | head -1 | sed -E 's/^"sessionId"[[:space:]]*:[[:space:]]*"//;s/"$//' | cut -c1-8)
      AG_OPUS_TURNS=$(grep -oE '"opusTurns"[[:space:]]*:[[:space:]]*[0-9]+' "$TELEMETRY_FILE" 2>/dev/null | head -1 | grep -oE '[0-9]+' || echo "0")
      if [ -n "$AG_CUR_SID" ] && [ "$AG_CUR_SID" = "$AG_PREV_SID" ] && [ "${AG_OPUS_TURNS:-0}" -ge 120 ] 2>/dev/null; then
        printf '{"injectSteps":[{"systemMessage":{"systemMessage":"[🛡️ SURVIVAL MODE — Parent %s turns]: แชทสะสมรอบสูงมากแล้ว ให้ delegate งานแก้โค้ด/ไล่ล็อกให้ subagent ใหม่ ตอบกระชับ และอัปเดต TASK_STATE.md ทุกรอบ"}}]}\n' "$AG_OPUS_TURNS"
      else
        printf '{}\n'
      fi
    fi
  else
    printf '{}\n'
  fi
elif [ "$MODE_TYPE" = "stdin" ] && [ "$ENGINE" = "claude" ] && [ "$HOOK_STAGE" = "prompt" ]; then
  CUR_SID=$(echo "$RAW_STDIN" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 | sed -E 's/^"session_id"[[:space:]]*:[[:space:]]*"//;s/"$//' | cut -c1-8)
  PREV_SID=$(grep -oE '"sessionId"[[:space:]]*:[[:space:]]*"[^"]+"' "$TELEMETRY_FILE" 2>/dev/null | head -1 | sed -E 's/^"sessionId"[[:space:]]*:[[:space:]]*"//;s/"$//' | cut -c1-8)
  LAST_CTX_TOK=$(grep -oE '"lastCacheTokens"[[:space:]]*:[[:space:]]*[0-9]+' "$TELEMETRY_FILE" 2>/dev/null | head -1 | grep -oE '[0-9]+' || echo "0")
  LAST_OPUS_TURNS=$(grep -oE '"opusTurns"[[:space:]]*:[[:space:]]*[0-9]+' "$TELEMETRY_FILE" 2>/dev/null | head -1 | grep -oE '[0-9]+' || echo "0")
  SAME_SESSION=0
  if [ -z "$CUR_SID" ] || [ -z "$PREV_SID" ] || [ "$CUR_SID" = "$PREV_SID" ]; then
    SAME_SESSION=1
  fi
  if [ "$SAME_SESSION" -eq 1 ] && { [ "${LAST_CTX_TOK:-0}" -ge 150000 ] || [ "${LAST_OPUS_TURNS:-0}" -ge 120 ]; } 2>/dev/null; then
    echo "[🛡️ SURVIVAL MODE (Parent ${LAST_OPUS_TURNS} turns · ${LAST_CTX_TOK} tokens/turn)]: แชทสะสมรอบสูงมากแล้ว ให้ delegate งานให้ fresh subagent ตอบกระชับ และอัปเดต TASK_STATE.md ทุกรอบ"
  elif [ "$SAME_SESSION" -eq 1 ] && { [ "${LAST_CTX_TOK:-0}" -ge 130000 ] || [ "${LAST_OPUS_TURNS:-0}" -ge 100 ]; } 2>/dev/null; then
    echo "[🚨 AUTO-HANDOFF NUDGE (Parent ${LAST_OPUS_TURNS} turns · ${LAST_CTX_TOK} tokens/turn)]: แชทสะสมรอบสูงแล้ว ท้ายคำตอบให้สรุป TASK_STATE.md (<=2,500B) พร้อมแนะนำสั้นๆ ให้ /clear + 'ทำต่อ'"
  fi
fi
exit 0
