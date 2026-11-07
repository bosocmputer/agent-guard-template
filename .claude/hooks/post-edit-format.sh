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
  echo "last_agent=$MODE | last_edited_file=$FILE_PATH | updated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)" > .agent-last-state.log
  bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "implementer" --status "working" --detail "✂️ Surgical Edit: $FILE_PATH" --file "$FILE_PATH" >/dev/null 2>&1 || true
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
