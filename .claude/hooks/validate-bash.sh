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
  bash "$PROJECT_ROOT/.claude/hooks/telemetry-tracker.sh" --engine "$MODE" --node "core" --status "blocked" --detail "🛡️ Shield Blocked: $REASON" --hook ".claude/hooks/validate-bash.sh" --rule "CLAUDE.md (OS Shield)" >/dev/null 2>&1 || true
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

# 1. ดักจับการพลางคำสั่ง และการรันสคริปต์จากภายนอกเข้าสู่ Shell โดยตรง (gstack + agent-beacon MITRE Execution Guard)
if echo "$COMMAND" | grep -qE '(\$\{IFS\}|\$IFS|base64[[:space:]]+(-d|--decode)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(sh|bash|zsh)|(curl|wget)[[:space:]][^|;]*\|[[:space:]]*(sudo[[:space:]]+)?(sh|bash|zsh|python3?|node))'; then
  block_action "ตรวจพบการพลางคำสั่งด้วย IFS/base64 หรือการรันสคริปต์ภายนอกเข้าสู่ Shell โดยตรง (curl/wget | sh Blocked)"
fi

# 1.1 ดักจับการดูดค่า Environment Secrets การแอบอ่านไฟล์ความลับผ่าน Shell และการแก้ไฟล์ระดับโฮสต์/ฝังตัว (agent-beacon MITRE Credential Access & Persistence Guard)
if echo "$COMMAND" | grep -qE '(^|[;&|"])[[:space:]]*(printenv([[:space:]]|$|[|>;"])|env[[:space:]]*($|[|>;"]))'; then
  block_action "ไม่อนุญาตให้ดึงค่า Environment Variables ทั้งระบบด้วย printenv หรือ env เพื่อป้องกันข้อมูลความลับรั่วไหล (Credential Dump Blocked)"
fi
if echo "$COMMAND" | grep -qE '((cat|less|more|head|tail|grep|awk|sed)[[:space:]]+([^;&|]*[[:space:]/])?(\.env([[:space:]"'\'']|$|\.[a-zA-Z0-9_-]+)|[^[:space:]"'\'']+\.(pem|key|p12|keystore|jks)([[:space:]"'\'']|$))|(~|\$HOME|\$\{HOME\}|/Users/[^/[:space:]]+|/home/[^/[:space:]]+)/\.(ssh|aws|kube|gnupg|netrc|npmrc|pypirc|zshrc|bashrc|bash_profile|zprofile)|crontab[[:space:]]+-[er])'; then
  block_action "ไม่อนุญาตให้อ่านไฟล์ความลับ (.env/key) หรือเข้าถึงโฟลเดอร์ Credential และ Shell Profile ของเครื่องโฮสต์ (~/.ssh, ~/.aws, ~/.kube, ~/.zshrc, crontab)"
fi

# 1.2 ดักจับ Token Leak บน CLI Arguments / Stdout (docker login -p/--password และ echo/ssh positional arg ของ gh auth token)
if echo "$COMMAND" | grep -qE 'docker([[:space:]]+--config[[:space:]]+[^[:space:];&|]+)?[[:space:]]+login([[:space:]]+[^;&|]*)?[[:space:]]+(-p([[:space:]]|$|=)|--password([[:space:]]|=))'; then
  block_action "ห้ามส่งรหัสผ่าน/Token ผ่าน docker login -p หรือ --password บน CLI (ป้องกันรั่วลง ps/history/terminal) — ต้องใช้ --password-stdin ผ่าน pipe เท่านั้น"
fi
if echo "$COMMAND" | grep -qE '((echo|printf)[[:space:]][^;&|]*(\$\([[:space:]]*gh[[:space:]]+auth[[:space:]]+token|`[[:space:]]*gh[[:space:]]+auth[[:space:]]+token)|ssh[[:space:]][^|;]*(\$\([[:space:]]*gh[[:space:]]+auth[[:space:]]+token|`[[:space:]]*gh[[:space:]]+auth[[:space:]]+token))'; then
  block_action "ห้ามพิมพ์หรือส่ง \$(gh auth token) เป็น argument ของ echo/printf/ssh (เสี่ยง Token รั่วลง terminal output เมื่อคำสั่งล้มเหลว) — ให้ส่งผ่าน pipe stdin (เช่น gh auth token | ssh ... 'docker login --password-stdin')"
fi

# 2. ดักจับคำสั่งทำลายข้อมูล ทับโค้ดที่ยังไม่ Commit หรือบังคับ Push ทับกิ่งหลัก (รวมถึง git push +main และ git switch -f โดยไม่กวาดข้าม && หรือ ; ไปโดนคำสั่งอื่น)
if echo "$COMMAND" | grep -qE '(rm -rf /|rm -rf ~|rm -rf \$HOME|rm -rf \*|DROP DATABASE|TRUNCATE TABLE|git[[:space:]]+push([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+(--force|--force-with-lease|-f)([[:space:]]|$|;|"|\|)|git[[:space:]]+push[[:space:]]+[^;&|[:space:]]+[[:space:]]+\+[a-zA-Z0-9_/.-]+|git reset --hard|git checkout[[:space:]]+(\.|--|HEAD|-f|--force)|git[[:space:]]+switch([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+(-f|--force|--discard-changes)([[:space:]]|$|;|"|\|)|git restore |git clean -[fd]|git branch -D|chmod 777)'; then
  block_action "คำสั่งถูกระงับเพื่อป้องกันข้อมูลสูญหายหรือทับโค้ดที่ยังไม่ได้ Commit"
fi

# 2.1 ดักจับ git checkout <filepath> (กรณีไม่ได้ใส่ -- แต่ระบุพาธไฟล์ที่มีอยู่จริงในโปรเจกต์ ซึ่งจะทับไฟล์ที่แก้ค้างไว้ทันที)
if echo "$COMMAND" | grep -qE 'git[[:space:]]+checkout[[:space:]]+'; then
  CO_ARGS=$(echo "$COMMAND" | sed -E 's/.*git[[:space:]]+checkout[[:space:]]+//; s/[;&|"].*//')
  if ! echo "$CO_ARGS" | grep -qE '^(-b|-B|--orphan)[[:space:]]+'; then
    for tok in $CO_ARGS; do
      case "$tok" in
        -*) continue ;;
      esac
      if [ -e "$PROJECT_ROOT/$tok" ] || [ -e "$PROJECT_ROOT/app/$tok" ] || echo "$tok" | grep -qE '\.(dart|ts|tsx|js|jsx|py|go|rs|sql|json|yaml|yml|md|sh|html|css|scss)$'; then
        block_action "ระงับ git checkout ทับไฟล์ ($tok) เพื่อป้องกันโค้ดที่ยังไม่ Commit สูญหาย (อนุญาตเฉพาะ git checkout -b <branch> หรือสลับกิ่งเท่านั้น)"
      fi
    done
  fi
fi

# 3. ดักจับการแอบติดตั้งแพ็กเกจใหม่โดยไม่ขออนุญาต (รองรับ JS/TS, Go, Flutter/Dart, Python, Rust — ปลดล็อกด้วย DEPS_APPROVED=1 หรือโหมด AGENT_GUARD_MODE=relaxed)
GUARD_MODE="${AGENT_GUARD_MODE:-strict}"
if [ -f "$PROJECT_ROOT/.agent-guard-mode" ]; then
  GUARD_MODE="$(head -n 1 "$PROJECT_ROOT/.agent-guard-mode" | tr -d '[:space:]')"
fi
if [ "$GUARD_MODE" != "relaxed" ] && [ "${DEPS_APPROVED:-0}" != "1" ] && ! echo "$COMMAND" | grep -q 'DEPS_APPROVED=1'; then
  if echo "$COMMAND" | grep -qE '(npm (install|i) [a-zA-Z0-9@_]|pnpm add |yarn add |bun add |flutter pub add |dart pub add |go get [a-zA-Z0-9]|pip install [a-zA-Z0-9]|uv add |poetry add |cargo add )'; then
    block_action "ห้ามติดตั้งแพ็กเกจหรือ Library ใหม่โดยไม่ถามผู้ใช้ก่อนตามกฎ No Unapproved Dependencies (หากผู้ใช้อนุญาตในแชทแล้ว ให้รันโดยใส่ DEPS_APPROVED=1 นำหน้าคำสั่ง หรือตั้งโหมด AGENT_GUARD_MODE=relaxed สำหรับช่วงปั้น Prototype)"
  fi
fi

# 4. ดักจับการปล่อยของขึ้น Production หรือยิง Migration ฐานข้อมูลจริงโดยไม่ผ่านคนอนุมัติ (Anthropic AI-Native SDLC Playbook Stage 5 — Approval Gate)
# หมายเหตุ: อนุญาต supabase db reset ในเครื่อง (Local Docker) สำหรับรันเทสต์ แต่บล็อก supabase db push และ supabase db reset --linked/--db-url
if [ "${RELEASE_APPROVED:-0}" != "1" ] && ! echo "$COMMAND" | grep -q 'RELEASE_APPROVED=1'; then
  if echo "$COMMAND" | grep -qE '(vercel([[:space:]]+deploy)?[[:space:]]+.*--prod|netlify[[:space:]]+deploy.*--prod|firebase[[:space:]]+deploy|wrangler[[:space:]]+(deploy|publish)|fly(ctl)?[[:space:]]+deploy|prisma[[:space:]]+migrate[[:space:]]+deploy|prisma[[:space:]]+db[[:space:]]+push.*--accept-data-loss|supabase[[:space:]]+db[[:space:]]+push|supabase[[:space:]]+db[[:space:]]+reset[[:space:]]+.*(--linked|--db-url)|drizzle-kit[[:space:]]+push|terraform[[:space:]]+(apply|destroy)|kubectl[[:space:]]+(apply|delete)|helm[[:space:]]+(upgrade|uninstall))'; then
    block_action "ระงับคำสั่ง Deploy ขึ้น Production หรือแก้ไขฐานข้อมูลจริงโดยพลการ (Stage 5 Approval Gate: ต้องให้ผู้ใช้อนุมัติก่อน หากอนุมัติในแชทแล้วให้ใส่ RELEASE_APPROVED=1 นำหน้าคำสั่ง)"
  fi
fi

# 6. Migration-Before-Main Push Gate: ป้องกันการ push คอมมิตที่มีไฟล์ SQL migration ใหม่ขึ้น main/master (Production) ก่อนรัน SQL บน Production DB
if [ "$GUARD_MODE" != "relaxed" ] && [ "${RELEASE_APPROVED:-0}" != "1" ] && [ "${MIGRATION_PROD_VERIFIED:-0}" != "1" ] && ! echo "$COMMAND" | grep -qE '(RELEASE_APPROVED=1|MIGRATION_PROD_VERIFIED=1)'; then
  if echo "$COMMAND" | grep -qE '(^|[;&|[:space:]"'"'"'])git([[:space:]]+-C[[:space:]]+[^;&|[:space:]]+)?[[:space:]]+push([[:space:]"'"'"']|$)'; then
    PUSH_CMD=$(echo "$COMMAND" | sed -E 's/^.*"command"[[:space:]]*:[[:space:]]*"//;s/^.*"CommandLine"[[:space:]]*:[[:space:]]*"//;s/"$//')
    PUSH_CHECK=$(python3 - "$PUSH_CMD" "$PROJECT_ROOT" <<'PYEOF' 2>/dev/null || echo "0|"
import os, re, shlex, subprocess, sys
cmd, root = sys.argv[1], sys.argv[2]
for seg in re.split(r'[;&|]+', cmd):
    try:
        toks = shlex.split(seg)
    except Exception:
        toks = seg.split()
    i = 0
    while i < len(toks):
        if toks[i] == "git":
            repo = root
            j = i + 1
            while j < len(toks) and toks[j].startswith("-"):
                if toks[j] == "-C" and j + 1 < len(toks):
                    cand = toks[j + 1]
                    repo = cand if os.path.isabs(cand) else os.path.abspath(os.path.join(root, cand))
                    j += 2
                elif toks[j].startswith("-C") and len(toks[j]) > 2:
                    cand = toks[j][2:]
                    repo = cand if os.path.isabs(cand) else os.path.abspath(os.path.join(root, cand))
                    j += 1
                else:
                    j += 1
            if j < len(toks) and toks[j] == "push":
                args = [t for t in toks[j+1:] if not t.startswith("-")]
                refspecs = args[1:] if len(args) >= 2 else []
                if not refspecs:
                    try:
                        br = subprocess.check_output(["git", "--no-optional-locks", "-C", repo, "rev-parse", "--abbrev-ref", "HEAD"], stderr=subprocess.DEVNULL).decode().strip()
                    except Exception:
                        br = ""
                    if br in ("main", "master"):
                        print(f"1|{repo}"); sys.exit(0)
                for ref in refspecs:
                    dst = ref.split(":", 1)[1] if ":" in ref else ref
                    dst = dst.lstrip("+").replace("refs/heads/", "")
                    if dst in ("main", "master"):
                        print(f"1|{repo}"); sys.exit(0)
            i = j
        i += 1
print("0|")
PYEOF
)
    PUSH_TARGETS_MAIN="${PUSH_CHECK%%|*}"
    PUSH_REPO="${PUSH_CHECK#*|}"
    [ -z "$PUSH_REPO" ] && PUSH_REPO="$PROJECT_ROOT"
    if [ "$PUSH_TARGETS_MAIN" = "1" ]; then
      # หา ref ปลายทางของ origin/main หรือ origin/master ใน repo/worktree เป้าหมายจริง
      BASE_REF=""
      if git --no-optional-locks -C "$PUSH_REPO" rev-parse --verify origin/main >/dev/null 2>&1; then
        BASE_REF="origin/main"
      elif git --no-optional-locks -C "$PUSH_REPO" rev-parse --verify origin/master >/dev/null 2>&1; then
        BASE_REF="origin/master"
      fi
      if [ -n "$BASE_REF" ]; then
        NEW_MIGS=$(git --no-optional-locks -C "$PUSH_REPO" diff --name-only --diff-filter=A "${BASE_REF}...HEAD" 2>/dev/null | grep -E '(^|/)migrations/.*\.sql$' | head -n 3 | tr '\n' ',' | sed 's/,$//')
        if [ -n "$NEW_MIGS" ]; then
          block_action "พบไฟล์ SQL Migration ใหม่ (${NEW_MIGS}) ที่กำลังจะ push ขึ้น main (Production)! กรุณารัน migration บน Production DB ก่อน (หรือ push เฉพาะกิ่ง uat/preview ก่อน) — หากรันบน Prod แล้วหรือโปรเจกต์รัน migration อัตโนมัติตอน deploy ให้ใส่ MIGRATION_PROD_VERIFIED=1 นำหน้าคำสั่ง"
        fi
      fi
    fi
  fi
fi

# 7. Template Local-State Commit Guard: ป้องกันการเผลอ stage/commit ไฟล์เทมเพลตเฉพาะเครื่อง (AGENTS.md, CLAUDE.md, GEMINI.md, TASK_STATE.md) ในโปรเจกต์ปลายทาง
if [ "$GUARD_MODE" != "relaxed" ] && [ "${ALLOW_TEMPLATE_COMMIT:-0}" != "1" ] && ! echo "$COMMAND" | grep -q 'ALLOW_TEMPLATE_COMMIT=1'; then
  if echo "$COMMAND" | grep -qE '(^|[;&|[:space:]"'"'"'])git([[:space:]]+-C[[:space:]]+[^;&|[:space:]]+)?[[:space:]]+(add|stage)([[:space:]"'"'"']|$)'; then
    HELPER_PY="$PROJECT_ROOT/.claude/hooks/lib/guard_helpers.py"
    if [ -f "$HELPER_PY" ] && command -v python3 >/dev/null 2>&1; then
      STAGE_CMD=$(echo "$COMMAND" | sed -E 's/^.*"command"[[:space:]]*:[[:space:]]*"//;s/^.*"CommandLine"[[:space:]]*:[[:space:]]*"//;s/"$//')
      STAGE_RES=$(python3 "$HELPER_PY" check-template-stage "$STAGE_CMD" "$PROJECT_ROOT" 2>/dev/null || echo "")
      if echo "$STAGE_RES" | grep -q '"blocked":[[:space:]]*true'; then
        STAGE_REASON=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1]).get("reason",""))' "$STAGE_RES" 2>/dev/null || echo "ห้าม stage ไฟล์เทมเพลตเข้าโปรเจกต์")
        block_action "$STAGE_REASON"
      fi
    fi
  fi
fi

allow_action
