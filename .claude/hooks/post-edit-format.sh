#!/usr/bin/env bash
# Dual-Mode Hook (Claude Code + Antigravity): จัด Format อัตโนมัติตามภาษา (JS/TS, Go, Flutter/Dart, Python, Rust) + บันทึก Auto-Checkpoint
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT" || exit 0
INPUT=$(cat)

if echo "$INPUT" | grep -q '"toolCall"'; then
  MODE="antigravity"
  FILE_PATH=$(echo "$INPUT" | grep -oE '"Path"[[:space:]]*:[[:space:]]*"(\\.|[^"\\])*"' | head -1 | sed -E 's/^"Path"[[:space:]]*:[[:space:]]*"//;s/"$//;s/\\"/"/g')
else
  MODE="claude"
  FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"(\\.|[^"\\])*"' | head -1 | sed -E 's/^"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//;s/\\"/"/g')
fi

if [ -n "$FILE_PATH" ]; then
  # ล้างประวัติการรันคำสั่งซ้ำและตัวนับการอ่านไฟล์ติดต่อกัน (เฉพาะ actor/session นี้) เมื่อมีการแก้ไขไฟล์โค้ดจริง
  PWD_HASH="$(pwd | cksum | cut -d' ' -f1)"
  ACTOR_KEY=$(echo "$INPUT" | grep -oE '"(agent_id|session_id|conversation_id)"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 | sed -E 's/^"[^"]+"[[:space:]]*:[[:space:]]*"//;s/"$//' | tr -cd 'A-Za-z0-9_-' | cut -c1-32)
  ACTOR_KEY="${ACTOR_KEY:-default}"
  rm -f "/tmp/claude_cmd_history_${PWD_HASH}.log" "/tmp/claude_read_streak_${PWD_HASH}_${ACTOR_KEY}.cnt" "/tmp/claude_read_streak_${PWD_HASH}.cnt" 2>/dev/null || true
  DIFF_STAT=""
  if command -v git >/dev/null 2>&1; then
    DIFF_STAT=$(git --no-optional-locks diff --numstat -- "$FILE_PATH" 2>/dev/null | awk '{printf "+%s/-%s บรรทัด", $1, $2}')
  fi
  echo "last_agent=$MODE | last_edited_file=$FILE_PATH | diff=${DIFF_STAT:-modified} | updated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)" > .agent-last-state.log
  bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "implementer" --status "working" --detail "✂️ แก้ไขไฟล์จริง: $FILE_PATH ${DIFF_STAT:+($DIFF_STAT)}" --file "$FILE_PATH" --diff "$DIFF_STAT" --hook ".claude/hooks/post-edit-format.sh" >/dev/null 2>&1 || true
fi

if [ -f "$FILE_PATH" ]; then
  if [[ "$FILE_PATH" =~ \.(ts|tsx|js|jsx|json)$ ]] && [ -f "node_modules/.bin/prettier" ]; then
    npx prettier --write "$FILE_PATH" >/dev/null 2>&1
  elif [[ "$FILE_PATH" =~ \.go$ ]] && command -v gofmt >/dev/null 2>&1; then
    gofmt -w "$FILE_PATH" >/dev/null 2>&1
  elif [[ "$FILE_PATH" =~ \.dart$ ]] && command -v dart >/dev/null 2>&1; then
    dart format "$FILE_PATH" >/dev/null 2>&1
  elif [[ "$FILE_PATH" =~ \.py$ ]] && command -v ruff >/dev/null 2>&1; then
    ruff format "$FILE_PATH" >/dev/null 2>&1
  elif [[ "$FILE_PATH" =~ \.rs$ ]] && command -v rustfmt >/dev/null 2>&1; then
    rustfmt "$FILE_PATH" >/dev/null 2>&1
  fi
fi

if [ "$MODE" = "antigravity" ]; then
  printf '{}\n'
fi
exit 0
