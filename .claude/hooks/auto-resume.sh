#!/usr/bin/env bash
# Dual-Mode SessionStart & PreCompact Hook (Claude Code + Antigravity): ตรวจจับงานค้างอัตโนมัติเมื่อเปิดแชทใหม่ และบันทึกสถานะก่อนย่อความจำ (PreCompact Continuity Ledger)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT" || exit 0
STAGE_FLAG="${1:-session-start}"
INPUT=$(cat)

if echo "$INPUT" | grep -q '"conversationId"'; then
  MODE="antigravity"
else
  MODE="claude"
fi

# ซิงก์ TASK_STATE.md (รวมถึงดึงคำสั่งล่าสุดและ Subagent ที่เพิ่งค้าง/โดนตัดโควต้าจาก .jsonl ของค่ายก่อนหน้า) ทุกครั้งที่เปิดแชทใหม่และก่อนย่อความจำ
bash "$PROJECT_ROOT/.claude/hooks/audit-session-proof.sh" --brief "$PROJECT_ROOT" >/dev/null 2>&1 || true

CHECKPOINT=""
if [ -f ".agent-last-state.log" ]; then
  CHECKPOINT=$(tr '\n' ' ' < .agent-last-state.log)
fi

TASK_STATE_HINT=""
if [ -f "TASK_STATE.md" ]; then
  TASK_STATE_HINT="[TASK_STATE.md present]"
fi

GIT_DIRTY=""
if git --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  GIT_DIRTY=$(git --no-optional-locks status --short 2>/dev/null | head -n 5 | tr '\n' '; ')
fi

if [ -n "$CHECKPOINT" ] || [ -n "$GIT_DIRTY" ] || [ -n "$TASK_STATE_HINT" ]; then
  if [ "$STAGE_FLAG" = "--pre-compact" ]; then
    bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "core" --status "ready" --detail "📌 PreCompact Ledger Synced ($MODE): ซิงก์ TASK_STATE.md ก่อนย่อความจำ" --skill "auto-resume-handoff" --hook ".claude/hooks/auto-resume.sh" >/dev/null 2>&1 || true
    MSG="[PRE-COMPACT CONTINUITY LEDGER]: ซิงก์สถานะล่าสุดลง TASK_STATE.md เรียบร้อย (${TASK_STATE_HINT} ${CHECKPOINT} ${GIT_DIRTY}) หลังย่อความจำให้อ้างอิง TASK_STATE.md และ .claude/rules/project-pitfalls.md เป็นหลัก"
  else
    bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "core" --status "ready" --detail "🔄 Auto-Handoff Ready ($MODE): พบงานค้างพร้อมลุยต่อ" --skill "auto-resume-handoff" --hook ".claude/hooks/auto-resume.sh" >/dev/null 2>&1 || true
    MSG="[AUTO-HANDOFF READY]: ซิงก์สถานะล่าสุดและงานที่ค้างจากแชทก่อนหน้าลง TASK_STATE.md เรียบร้อย (${TASK_STATE_HINT} ${CHECKPOINT} ${GIT_DIRTY}) หากผู้ใช้พิมพ์สั้นๆ เช่น 'ทำต่อ', 'ลุยต่อ', หรือ 'resume' ให้อ่าน TASK_STATE.md (รวมถึงหัวข้อ Last Session Snapshot / Last Dispatched Subagent Task ด้านล่างสุด) และ .claude/rules/project-pitfalls.md แล้วรับไม้ต่อจากจุดที่ค้างทันทีโดยไม่ต้องถามซ้ำ"
  fi
  if [ "$MODE" = "antigravity" ]; then
    python3 -c 'import json,sys; print(json.dumps({"injectSteps":[{"systemMessage":{"systemMessage":sys.argv[1]}}]}, ensure_ascii=False))' "$MSG"
  else
    echo "$MSG"
  fi
else
  bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "core" --status "ready" --detail "🟢 Session Started ($MODE)" --hook ".claude/hooks/auto-resume.sh" >/dev/null 2>&1 || true
  if [ "$MODE" = "antigravity" ]; then
    printf '{}\n'
  fi
fi
exit 0
