#!/usr/bin/env bash
# Dual-Mode Hook (Claude Code + Antigravity): จัด Format อัตโนมัติ + บันทึก Auto-Checkpoint เผื่อโควต้าหมดกลางคัน
INPUT=$(cat)

if echo "$INPUT" | grep -q '"toolCall"'; then
  MODE="antigravity"
  FILE_PATH=$(echo "$INPUT" | grep -o '"Path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"Path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
else
  MODE="claude"
  FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
fi

if [ -n "$FILE_PATH" ]; then
  echo "last_agent=$MODE | last_edited_file=$FILE_PATH | updated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)" > .agent-last-state.log
fi

if [[ "$FILE_PATH" =~ \.(ts|tsx|js|jsx|json)$ ]] && [ -f "node_modules/.bin/prettier" ]; then
  npx prettier --write "$FILE_PATH" >/dev/null 2>&1
fi

if [ "$MODE" = "antigravity" ]; then
  printf '{}\n'
fi
exit 0
