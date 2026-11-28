#!/usr/bin/env bash
# Dual-Mode Hook (Claude Code + Antigravity): บล็อกเมื่อ AI รันคำสั่งเทสต์หรือบิลด์เดิมซ้ำเกิน 3 ครั้งในหน้าต่าง 6 คำสั่งล่าสุด
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT" || exit 0
INPUT=$(cat)

if echo "$INPUT" | grep -q '"toolCall"'; then
  MODE="antigravity"
  COMMAND=$(echo "$INPUT" | grep -oE '"CommandLine"[[:space:]]*:[[:space:]]*"(\\.|[^"\\])*"' | head -1 | sed -E 's/^"CommandLine"[[:space:]]*:[[:space:]]*"//;s/"$//;s/\\"/"/g')
  DESC=$(echo "$INPUT" | grep -oE '"toolSummary"[[:space:]]*:[[:space:]]*"(\\.|[^"\\])*"' | head -1 | sed -E 's/^"toolSummary"[[:space:]]*:[[:space:]]*"//;s/"$//;s/\\"/"/g')
else
  MODE="claude"
  COMMAND=$(echo "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"(\\.|[^"\\])*"' | head -1 | sed -E 's/^"command"[[:space:]]*:[[:space:]]*"//;s/"$//;s/\\"/"/g')
  DESC=$(echo "$INPUT" | grep -oE '"description"[[:space:]]*:[[:space:]]*"(\\.|[^"\\])*"' | head -1 | sed -E 's/^"description"[[:space:]]*:[[:space:]]*"//;s/"$//;s/\\"/"/g')
fi

allow_action() {
  if [ "$MODE" = "antigravity" ]; then
    printf '{"decision":"allow"}\n'
  fi
  exit 0
}

if [ -z "$COMMAND" ]; then
  allow_action
fi

# Always allow internal session proof / release summary hooks so final reporting is never blocked
if echo "$COMMAND" | grep -qE '^[[:space:]]*(cd[[:space:]]+[^;&|]+[;&]+[[:space:]]*)*bash[[:space:]]+[^;&|]*\.claude/hooks/(audit-session-proof|release-summary)\.sh([[:space:]][^;&|]*)?$'; then
  allow_action
fi

# 1) แยกตัวนับตาม agent_id/session_id + pwd เพื่อไม่ให้ Subagent ที่รันขนานกันนับปนกัน
PWD_HASH="$(pwd | cksum | cut -d' ' -f1)"
ACTOR_KEY=$(echo "$INPUT" | grep -oE '"(agent_id|session_id|conversation_id)"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 | sed -E 's/^"[^"]+"[[:space:]]*:[[:space:]]*"//;s/"$//' | tr -cd 'A-Za-z0-9_-' | cut -c1-32)
ACTOR_KEY="${ACTOR_KEY:-default}"
READ_STREAK_FILE="/tmp/claude_read_streak_${PWD_HASH}_${ACTOR_KEY}.cnt"

# ตรวจจับการเขียน/แก้ไขไฟล์ผ่านสคริปต์ใน Bash (เช่น open(...,'w'), write_text(, cat > path <<'EOF', sed -i)
WRITE_TARGET=""
if echo "$COMMAND" | grep -qE "(open\([^)]*,[[:space:]]*['\"]w|write_text\(|cat[[:space:]]*>+[[:space:]]*[^[:space:]<]+|cat[[:space:]]+<<[^>]*>[[:space:]]*[^[:space:]]+|sed[[:space:]]+-i)"; then
  WRITE_TARGET=$(echo "$COMMAND" | grep -oE "[A-Za-z0-9_./-]+\.(dart|sql|ts|tsx|js|jsx|mjs|cjs|py|go|rs|sh|md|json|yaml|yml)" | head -1)
  if [ -z "$WRITE_TARGET" ]; then
    WRITE_TARGET="source-file"
  fi
  # Stage 4 Anti-Test-Tampering ผ่าน Bash/Python: หากอยู่ในโหมดซ่อมบั๊ก (strikeCount >= 1 หรือ activeNode == debugger) ห้ามแอบเขียนทับไฟล์เทสต์เดิมผ่าน python3/cat/sed
  GUARD_MODE="${AGENT_GUARD_MODE:-strict}"
  if [ -f "$PROJECT_ROOT/.agent-guard-mode" ]; then
    GUARD_MODE="$(head -n 1 "$PROJECT_ROOT/.agent-guard-mode" | tr -d '[:space:]')"
  fi
  if [ "$GUARD_MODE" != "relaxed" ] && [ "${ALLOW_TEST_EDIT:-0}" != "1" ] && echo "$COMMAND" | grep -qE '(\.(test|spec)\.(ts|tsx|js|jsx|mjs|cjs)|_test\.(go|dart|py|rs)|(^|[[:space:]'"'"'"/])test_[^/'"'"'"[:space:]]+\.py)'; then
    TELEMETRY_FILE="$PROJECT_ROOT/.claude/.telemetry.json"
    if [ -f "$TELEMETRY_FILE" ]; then
      IS_DEBUG_FIX=$(python3 - "$TELEMETRY_FILE" <<'PYEOF' 2>/dev/null || echo "0"
import sys, json
try:
    d = json.load(open(sys.argv[1], encoding="utf-8"))
    strike = int(d.get("strikeCount", 0) or 0)
    node = str(d.get("activeNode", ""))
    print("1" if (strike >= 1 or node == "debugger") else "0")
except Exception:
    print("0")
PYEOF
)
      if [ "$IS_DEBUG_FIX" = "1" ]; then
        bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "debugger" --status "blocked" --detail "🛡️ Anti-Test-Tampering (Bash): บล็อกการแอบแก้ไฟล์เทสต์เดิม ($WRITE_TARGET) ผ่าน Bash/Python ระหว่างซ่อมบั๊ก" --hook ".claude/hooks/loop-circuit-breaker.sh" --rule ".claude/rules/testing-and-api.md" >/dev/null 2>&1 || true
        if [ "$MODE" = "antigravity" ]; then
          printf '{"decision":"deny","reason":"ห้ามแอบแก้ไขไฟล์เทสต์เดิม (%s) ผ่าน Bash/Python ระหว่างซ่อมบั๊ก ให้แก้ที่โค้ดต้นเหตุด้วย Edit เท่านั้น (Stage 4 Anti-Test-Tampering)"}\n' "$WRITE_TARGET"
          exit 0
        else
          echo "❌ [Hook Blocked - loop-circuit-breaker.sh]: ห้ามแอบแก้ไขไฟล์เทสต์เดิม ($WRITE_TARGET) ผ่าน Bash/Python ระหว่างซ่อมบั๊ก ให้แก้ที่โค้ดต้นเหตุด้วย Edit เท่านั้น (Stage 4 Anti-Test-Tampering)" >&2
          exit 2
        fi
      fi
    fi
  fi
  rm -f "/tmp/claude_cmd_history_${PWD_HASH}.log" "$READ_STREAK_FILE" 2>/dev/null || true
  ACTION_LBL="${DESC:-แก้ไขไฟล์จริง}"
  bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "implementer" --status "working" --file "$WRITE_TARGET" --detail "✍️ $ACTION_LBL ($WRITE_TARGET)" --hook ".claude/hooks/post-edit-format.sh" >/dev/null 2>&1 || true
fi

# 2) คำสั่งอ่าน/สแกนค้นหาข้อมูล (ห้ามมี cat > หรือ sed -i เด็ดขาด) + Sticky Read-Loop Circuit Breaker (ดักการค้นหาวนลูปเกิน 14 ครั้งโดยไม่แก้โค้ด)
if [ -z "$WRITE_TARGET" ] && echo "$COMMAND" | grep -qE '^([[:space:]]*cd[[:space:]]+[^;&|]+[;&]+[[:space:]]*)*(git[[:space:]]+(status|diff|log|branch|show)|ls|pwd|cat[[:space:]]+[^><-]|head|tail|sed[[:space:]]+-n|grep|rg|find|wc|awk|stat|which|echo)[[:space:]]' && ! echo "$COMMAND" | grep -qE '(^|[;&|[:space:]])(flutter[[:space:]]+(test|analyze)|dart[[:space:]]+(test|analyze)|npm[[:space:]]+(test|run)|npx[[:space:]]+(vitest|jest|tsc|playwright)|pytest|go[[:space:]]+(test|vet|build)|cargo[[:space:]]+(test|check|clippy)|supa\.sh[[:space:]]+test)'; then
  CUR_STREAK=0
  if [ -f "$READ_STREAK_FILE" ]; then
    CUR_STREAK=$(cat "$READ_STREAK_FILE" 2>/dev/null | tr -dc '0-9')
    CUR_STREAK=${CUR_STREAK:-0}
  fi
  CUR_STREAK=$((CUR_STREAK + 1))
  echo "$CUR_STREAK" > "$READ_STREAK_FILE"
  if [ "$CUR_STREAK" -ge 15 ]; then
    # คงค่าไว้ที่ 14 (Sticky Block) เพื่อให้การลองยิง grep/sed ซ้ำทันทีถูกบล็อกต่อ จนกว่าจะมีการ Edit/Write ไฟล์จริง
    echo "14" > "$READ_STREAK_FILE"
    bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "debugger" --status "blocked" --detail "🛑 Read-Loop Circuit Breaker ($CUR_STREAK reads without edit): $COMMAND" --strike "3" --hook ".claude/hooks/loop-circuit-breaker.sh" >/dev/null 2>&1 || true
    if [ "$MODE" = "antigravity" ]; then
      printf '{"decision":"deny","reason":"🛑 [Read-Loop Circuit Breaker]: รันคำสั่งค้นหา/อ่านไฟล์ติดต่อกันเกิน 14 ครั้งโดยยังไม่เริ่มแก้โค้ด! หยุดรัน grep/sed ซ้ำและลงมือ Edit ไฟล์ทันที (หรือเรียก Explorer model=flash แทน)"}\n'
      exit 0
    else
      echo "🛑 [Read-Loop Circuit Breaker - loop-circuit-breaker.sh]: รันคำสั่งค้นหา/อ่านไฟล์ติดต่อกันเกิน 14 ครั้งโดยยังไม่เริ่มแก้โค้ด! หยุดรัน grep/sed ซ้ำและลงมือ Edit ไฟล์ทันที (หรือคืนงานให้ Parent เรียก explorer model=haiku)" >&2
      exit 2
    fi
  fi
  READ_DETAIL="🔍 ${DESC:-Inspecting} ($CUR_STREAK/14): $COMMAND"
  bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "explorer" --status "working" --detail "$READ_DETAIL" --hook ".claude/hooks/loop-circuit-breaker.sh" >/dev/null 2>&1 || true
  allow_action
fi

STATE_FILE="/tmp/claude_cmd_history_$(pwd | cksum | cut -d' ' -f1).log"
# สำหรับ Antigravity แยกสถานะ Sandbox vs BypassSandbox เพื่อไม่ให้กฎ "Try Sandboxed First" ถูกนับเป็นลูปซ้ำ
SANDBOX_PREFIX=""
if [ "$MODE" = "antigravity" ]; then
  if echo "$INPUT" | grep -qE '"BypassSandbox"[[:space:]]*:[[:space:]]*true'; then
    SANDBOX_PREFIX="[unsandboxed] "
  else
    SANDBOX_PREFIX="[sandboxed] "
  fi
fi
# บีบอัดคำสั่งหลายบรรทัดให้เป็น 1 บรรทัดก่อนบันทึกนับลูป
ONE_LINE_CMD="${SANDBOX_PREFIX}$(echo "$COMMAND" | tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g' | cut -c1-240)"
echo "$ONE_LINE_CMD" >> "$STATE_FILE"
tail -n 6 "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

REPEAT_COUNT=$(grep -Fx "$ONE_LINE_CMD" "$STATE_FILE" | wc -l | tr -d ' ')

if [ "$REPEAT_COUNT" -ge 4 ]; then
  rm -f "$STATE_FILE"
  bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "debugger" --status "blocked" --detail "🛑 Circuit Breaker Tripped (Repeat $REPEAT_COUNT): $ONE_LINE_CMD" --strike "3" --skill "root-cause-debug" --hook ".claude/hooks/loop-circuit-breaker.sh" >/dev/null 2>&1 || true
  if [ "$MODE" = "antigravity" ]; then
    printf '{"decision":"deny","reason":"🛑 [Circuit Breaker Triggered]: รันคำสั่งซ้ำเกิน 3 ครั้งแล้ว หยุดวนลูปและรายงานผู้ใช้ทันที!"}\n'
    exit 0
  else
    echo "🛑 [Circuit Breaker Triggered - loop-circuit-breaker.sh]: รันคำสั่งซ้ำเกินโควต้า (เกิน 3 ครั้งใน 6 คำสั่งล่าสุด) หยุดวนลูปและรายงานผู้ใช้ทันที!" >&2
    exit 2
  fi
elif [ "$REPEAT_COUNT" -ge 2 ]; then
  bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "debugger" --status "warning" --detail "⚠️ Repeat ($REPEAT_COUNT/3): $ONE_LINE_CMD" --strike "$((REPEAT_COUNT - 1))" --skill "root-cause-debug" --hook ".claude/hooks/loop-circuit-breaker.sh" >/dev/null 2>&1 || true
elif [ -z "$WRITE_TARGET" ]; then
  if echo "$COMMAND" | grep -qE '(^|[;&|[:space:]])(flutter[[:space:]]+(test|analyze)|dart[[:space:]]+(test|analyze)|npm[[:space:]]+(test|run[[:space:]]+(test|lint|build|check))|pnpm[[:space:]]+(test|lint|build)|yarn[[:space:]]+(test|lint|build)|npx[[:space:]]+(vitest|jest|tsc|playwright)|vitest|jest|pytest|go[[:space:]]+(test|vet|build)|cargo[[:space:]]+(test|check|clippy)|ruff[[:space:]]+check|mypy|golangci-lint|[^\n;&]*supa\.sh[[:space:]]+test|[^\n;&]*pgtap)'; then
    VERIFY_LBL="${DESC:-Verifying}"
    bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "reviewer" --status "working" --detail "🧪 $VERIFY_LBL: $COMMAND" --strike "0" --skill "verification-before-completion" --hook ".claude/hooks/loop-circuit-breaker.sh" >/dev/null 2>&1 || true
  else
    BASH_LBL="${DESC:-Bash}"
    bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "core" --status "working" --detail "⚡ $BASH_LBL: $COMMAND" --strike "0" --hook ".claude/hooks/loop-circuit-breaker.sh" >/dev/null 2>&1 || true
  fi
fi

allow_action
