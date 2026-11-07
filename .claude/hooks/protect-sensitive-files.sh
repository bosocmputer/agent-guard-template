#!/usr/bin/env bash
# Dual-Mode Hook (Claude Code + Antigravity): บล็อกการแก้ไขไฟล์ความลับ Keystore ฐานข้อมูล หรือ Lockfile โดยตรง (รองรับ JS/TS, Go, Flutter, Python, Rust)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INPUT=$(cat)

if echo "$INPUT" | grep -q '"toolCall"'; then
  MODE="antigravity"
  FILE_PATH=$(echo "$INPUT" | grep -oE '"Path"[[:space:]]*:[[:space:]]*"(\\.|[^"\\])*"' | head -1 | sed -E 's/^"Path"[[:space:]]*:[[:space:]]*"//;s/"$//;s/\\"/"/g')
else
  MODE="claude"
  FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"(\\.|[^"\\])*"' | head -1 | sed -E 's/^"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//;s/\\"/"/g')
fi

if echo "$FILE_PATH" | grep -qE '(^|/)(\.env($|\.)|.*\.(pem|key|p12|keystore|jks|sqlite|db)$|(package-lock\.json|pnpm-lock\.yaml|yarn\.lock|bun\.lockb|go\.sum|pubspec\.lock|poetry\.lock|uv\.lock|Cargo\.lock)$)'; then
  bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "core" --status "blocked" --detail "🛡️ Blocked sensitive file: $FILE_PATH" >/dev/null 2>&1 || true
  if [ "$MODE" = "antigravity" ]; then
    printf '{"decision":"deny","reason":"ไม่อนุญาตให้แก้ไขไฟล์ความลับ Keystore หรือ Lockfile โดยตรง (%s)"}\n' "$FILE_PATH"
    exit 0
  else
    echo "❌ [Hook Blocked - protect-sensitive-files.sh]: ไม่อนุญาตให้แก้ไขไฟล์ความลับ Keystore หรือ Lockfile โดยตรง ($FILE_PATH)" >&2
    exit 2
  fi
fi

if [ "$MODE" = "antigravity" ]; then
  printf '{"decision":"allow"}\n'
fi
exit 0
