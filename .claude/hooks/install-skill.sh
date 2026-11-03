#!/usr/bin/env bash
# ดึงเฉพาะโฟลเดอร์ Skill ที่ต้องการจาก jeffallan/claude-skills หรือ heydamir/unslop มาติดตั้งทั้งฝั่ง Claude Code (.claude/skills) และ Antigravity (.agents/skills)
set -e
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

if [ "$#" -eq 0 ]; then
  echo "Usage: bash .claude/hooks/install-skill.sh <skill-name> [skill-name-2 ...]"
  echo "Example: bash .claude/hooks/install-skill.sh react-expert nestjs-expert unslop"
  exit 1
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p .claude/skills .agents/skills

JEFFALLAN_SKILLS=()
INSTALL_UNSLOP=0

for SKILL in "$@"; do
  if [ "$SKILL" = "unslop" ]; then
    INSTALL_UNSLOP=1
  else
    JEFFALLAN_SKILLS+=("$SKILL")
  fi
done

if [ "$INSTALL_UNSLOP" -eq 1 ]; then
  echo "🎨 Fetching 'unslop' UI skill from github.com/heydamir/unslop..."
  git clone --depth 1 https://github.com/heydamir/unslop.git "$TMP_DIR/unslop" >/dev/null 2>&1
  if [ -d "$TMP_DIR/unslop/skills/unslop" ]; then
    cp -R "$TMP_DIR/unslop/skills/unslop" ".claude/skills/unslop"
    cp -R "$TMP_DIR/unslop/skills/unslop" ".agents/skills/unslop"
    echo "✅ Installed 'unslop' into both .claude/skills/unslop and .agents/skills/unslop"
  elif [ -f "$TMP_DIR/unslop/SKILL.md" ]; then
    mkdir -p ".claude/skills/unslop" ".agents/skills/unslop"
    cp -R "$TMP_DIR/unslop/"* ".claude/skills/unslop/"
    cp -R "$TMP_DIR/unslop/"* ".agents/skills/unslop/"
    echo "✅ Installed 'unslop' into both .claude/skills/unslop and .agents/skills/unslop"
  fi
fi

if [ "${#JEFFALLAN_SKILLS[@]}" -gt 0 ]; then
  echo "📦 Fetching requested skill(s) from github.com/jeffallan/claude-skills..."
  git clone --depth 1 --filter=blob:none --sparse https://github.com/jeffallan/claude-skills.git "$TMP_DIR/repo" >/dev/null 2>&1

  cd "$TMP_DIR/repo"
  SPARSE_PATHS=()
  for SKILL in "${JEFFALLAN_SKILLS[@]}"; do
    SPARSE_PATHS+=("skills/$SKILL")
  done
  git sparse-checkout set "${SPARSE_PATHS[@]}" >/dev/null 2>&1
  cd - >/dev/null

  for SKILL in "${JEFFALLAN_SKILLS[@]}"; do
    if [ -d "$TMP_DIR/repo/skills/$SKILL" ]; then
      cp -R "$TMP_DIR/repo/skills/$SKILL" ".claude/skills/$SKILL"
      cp -R "$TMP_DIR/repo/skills/$SKILL" ".agents/skills/$SKILL"
      echo "✅ Installed '$SKILL' into both .claude/skills/$SKILL and .agents/skills/$SKILL"
    else
      echo "⚠️ Skill '$SKILL' not found in jeffallan/claude-skills/skills/" >&2
    fi
  done
fi
