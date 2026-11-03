#!/usr/bin/env bash
# Dual-Mode Hook (Claude Code + Antigravity): บล็อกคำสั่งอันตราย ทับโค้ดที่ยังไม่ Commit หรือลงแพ็กเกจโดยไม่ขออนุญาต
INPUT=$(cat)

if echo "$INPUT" | grep -q '"toolCall"'; then
  MODE="antigravity"
  COMMAND=$(echo "$INPUT" | grep -o '"CommandLine"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1)
else
  MODE="claude"
  COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1)
fi

block_action() {
  local REASON="$1"
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

if echo "$COMMAND" | grep -qE '(rm -rf /|rm -rf \*|DROP DATABASE|TRUNCATE TABLE|git push.*--force|git reset --hard|git checkout (\.|--|HEAD)|git restore |git clean -[fd]|git branch -D|chmod 777)'; then
  block_action "คำสั่งถูกระงับเพื่อป้องกันข้อมูลสูญหายหรือทับโค้ดที่ยังไม่ได้ Commit"
fi

if echo "$COMMAND" | grep -qE '(npm (install|i) [^"-]|pnpm add |yarn add )'; then
  block_action "ห้ามติดตั้งแพ็กเกจใหม่โดยไม่ถามผู้ใช้ก่อนตามกฎ No Unapproved Dependencies"
fi

allow_action
