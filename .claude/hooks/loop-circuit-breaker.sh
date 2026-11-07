#!/usr/bin/env bash
# Dual-Mode Hook (Claude Code + Antigravity): บล็อกเมื่อ AI รันคำสั่งเทสต์หรือบิลด์เดิมซ้ำเกิน 3 ครั้งในหน้าต่าง 6 คำสั่งล่าสุด
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT" || exit 0
INPUT=$(cat)

if echo "$INPUT" | grep -q '"toolCall"'; then
  MODE="antigravity"
  COMMAND=$(echo "$INPUT" | grep -oE '"CommandLine"[[:space:]]*:[[:space:]]*"(\\.|[^"\\])*"' | head -1 | sed -E 's/^"CommandLine"[[:space:]]*:[[:space:]]*"//;s/"$//;s/\\"/"/g')
else
  MODE="claude"
  COMMAND=$(echo "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"(\\.|[^"\\])*"' | head -1 | sed -E 's/^"command"[[:space:]]*:[[:space:]]*"//;s/"$//;s/\\"/"/g')
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

# ข้ามคำสั่งอ่านข้อมูลทั่วไปเพื่อไม่ให้มาคั่นจังหวะการนับลูปแก้บั๊ก
if echo "$COMMAND" | grep -qE '^(git (status|diff|log|branch)|ls|pwd|cat|head|tail)'; then
  bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "explorer" --status "working" --detail "🔍 Inspecting: $COMMAND" --hook ".claude/hooks/loop-circuit-breaker.sh" >/dev/null 2>&1 || true
  allow_action
fi

STATE_FILE="/tmp/claude_cmd_history_$(pwd | cksum | cut -d' ' -f1).log"
echo "$COMMAND" >> "$STATE_FILE"
tail -n 6 "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

REPEAT_COUNT=$(grep -Fx "$COMMAND" "$STATE_FILE" | wc -l | tr -d ' ')

if [ "$REPEAT_COUNT" -ge 4 ]; then
  rm -f "$STATE_FILE"
  bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "debugger" --status "blocked" --detail "🛑 Circuit Breaker Tripped (Repeat $REPEAT_COUNT): $COMMAND" --strike "3" --skill "root-cause-debug" --hook ".claude/hooks/loop-circuit-breaker.sh" >/dev/null 2>&1 || true
  if [ "$MODE" = "antigravity" ]; then
    printf '{"decision":"deny","reason":"🛑 [Circuit Breaker Triggered]: รันคำสั่ง %s ซ้ำเกิน 3 ครั้งแล้ว หยุดวนลูปและรายงานผู้ใช้ทันที!"}\n' "$COMMAND"
    exit 0
  else
    echo "🛑 [Circuit Breaker Triggered - loop-circuit-breaker.sh]: รันคำสั่ง $COMMAND ซ้ำเกินโควต้า (เกิน 3 ครั้งใน 6 คำสั่งล่าสุด) หยุดวนลูปและรายงานผู้ใช้ทันที!" >&2
    exit 2
  fi
elif [ "$REPEAT_COUNT" -ge 2 ]; then
  bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "debugger" --status "warning" --detail "⚠️ Repeat ($REPEAT_COUNT/3): $COMMAND" --strike "$((REPEAT_COUNT - 1))" --skill "root-cause-debug" --hook ".claude/hooks/loop-circuit-breaker.sh" >/dev/null 2>&1 || true
else
  if echo "$COMMAND" | grep -qE '(test|vitest|jest|pytest|tsc|vet|analyze|clippy|lint|check|build)'; then
    bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "reviewer" --status "working" --detail "🧪 Verifying: $COMMAND" --strike "0" --skill "verification-before-completion" --hook ".claude/hooks/loop-circuit-breaker.sh" >/dev/null 2>&1 || true
  else
    bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "core" --status "working" --detail "⚡ Bash: $COMMAND" --strike "0" --hook ".claude/hooks/loop-circuit-breaker.sh" >/dev/null 2>&1 || true
  fi
fi

allow_action
