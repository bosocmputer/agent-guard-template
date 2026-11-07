#!/usr/bin/env bash
# Dual-Mode Hook (Claude Code + Antigravity): บล็อกคำสั่งอันตราย ทับโค้ดที่ยังไม่ Commit การพลางคำสั่ง (Obfuscation) หรือลงแพ็กเกจใหม่โดยไม่ขออนุญาต
# อ้างอิงเทคนิค Escaped-Quote Safe Extraction & Shell Obfuscation Tripwire จาก garrytan/gstack (careful/bin/check-careful.sh)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INPUT=$(cat)

if echo "$INPUT" | grep -q '"toolCall"'; then
  MODE="antigravity"
  COMMAND=$(echo "$INPUT" | grep -oE '"CommandLine"[[:space:]]*:[[:space:]]*"(\\.|[^"\\])*"' | head -1 | sed 's/\\"/"/g')
else
  MODE="claude"
  COMMAND=$(echo "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"(\\.|[^"\\])*"' | head -1 | sed 's/\\"/"/g')
fi

block_action() {
  local REASON="$1"
  bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "core" --status "blocked" --detail "🛡️ Shield Blocked: $REASON" >/dev/null 2>&1 || true
  if [ "$MODE" = "antigravity" ]; then
    printf '{"decision":"deny","reason":"%s"}\n' "$REASON"
    exit 0
  else
    echo "❌ [Hook Blocked - validate-bash.sh]: $REASON" >&2
    exit 2
  fi
}

allow_action() {
  if [ "$MODE" = "antigravity" ]; then
    printf '{"decision":"allow"}\n'
  fi
  exit 0
}

# 1. ดักจับการพลางคำสั่ง (Shell Obfuscation Tripwire — garrytan/gstack)
if echo "$COMMAND" | grep -qE '(\$\{IFS\}|\$IFS|base64[[:space:]]+(-d|--decode)[^|]*\|[[:space:]]*(sh|bash|zsh))'; then
  block_action "ตรวจพบการพลางคำสั่งด้วย IFS หรือ base64 decode เข้าสู่ Shell (Shell Obfuscation Blocked)"
fi

# 2. ดักจับคำสั่งทำลายข้อมูล ทับโค้ดที่ยังไม่ Commit หรือบังคับ Push ทับกิ่งหลัก (รวมถึง git push +main)
if echo "$COMMAND" | grep -qE '(rm -rf /|rm -rf ~|rm -rf \$HOME|rm -rf \*|DROP DATABASE|TRUNCATE TABLE|git push.*(--force|-f)|git push[[:space:]]+[^[:space:]]+[[:space:]]+\+[a-zA-Z0-9_/.-]+|git reset --hard|git checkout (\.|--|HEAD)|git restore |git clean -[fd]|git branch -D|chmod 777)'; then
  block_action "คำสั่งถูกระงับเพื่อป้องกันข้อมูลสูญหายหรือทับโค้ดที่ยังไม่ได้ Commit"
fi

# 3. ดักจับการแอบติดตั้งแพ็กเกจใหม่โดยไม่ขออนุญาต (รองรับ JS/TS, Go, Flutter/Dart, Python, Rust)
if echo "$COMMAND" | grep -qE '(npm (install|i) [a-zA-Z0-9@_]|pnpm add |yarn add |bun add |flutter pub add |dart pub add |go get [a-zA-Z0-9]|pip install [a-zA-Z0-9]|uv add |poetry add |cargo add )'; then
  block_action "ห้ามติดตั้งแพ็กเกจหรือ Library ใหม่โดยไม่ถามผู้ใช้ก่อนตามกฎ No Unapproved Dependencies"
fi

allow_action
