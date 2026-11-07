#!/usr/bin/env bash
# Dual-Mode Real-Time Telemetry Tracker (Claude Code + Antigravity -> .claude/.telemetry.json)
# บันทึกทั้งสถานะโต๊ะ 3D, โจทย์จริง (Prompt), Skill ที่ถูกดึงใช้จริง (SKILL.md), Agent, Rule และ Hook แบบเรียลไทม์
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT" || exit 0

TELEMETRY_FILE="$PROJECT_ROOT/.claude/.telemetry.json"
mkdir -p "$PROJECT_ROOT/.claude"

# โหมด 1: รับจาก Hook stdin โดยตรง (--hook-stdin <prompt|read|stop>)
if [ "${1:-}" = "--hook-stdin" ]; then
  HOOK_STAGE="${2:-unknown}"
  INPUT=$(cat)
  if echo "$INPUT" | grep -qE '"(conversationId|toolCall|invocationNum|executionNum)"'; then
    MODE="antigravity"
  else
    MODE="claude"
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$TELEMETRY_FILE" "$HOOK_STAGE" "$MODE" "$INPUT" <<'PYEOF' 2>/dev/null || true
import sys, os, re, json, time
from datetime import datetime, timezone

t_file, stage, mode, raw_in = sys.argv[1:5]
try:
    payload = json.loads(raw_in) if raw_in.strip() else {}
except Exception:
    payload = {}

state = {
    "updatedAt": "",
    "updatedEpochMs": 0,
    "activeEngine": mode,
    "activeModel": "opus" if mode == "claude" else "gemini-4-argon",
    "activeNode": "core",
    "systemStatus": "ready",
    "currentTask": "รอรับคำสั่ง (Waiting for command...)",
    "currentAction": "System Ready",
    "activeCommand": "Auto-Route (Zero-Command)",
    "activeAgentFile": "CLAUDE.md / AGENTS.md",
    "activeSkill": "common-ground",
    "activeSkillFile": ".claude/skills/common-ground/SKILL.md",
    "activeRuleFile": ".claude/rules/execution-discipline.md",
    "activeHook": "telemetry-tracker.sh",
    "strikeCount": 0,
    "maxStrikes": 3,
    "touchedFiles": [],
    "usedItemsHistory": [],
    "stats": {"claudeCalls": 0, "antigravityCalls": 0, "blockedCount": 0, "filesEdited": 0},
    "events": []
}
if os.path.exists(t_file):
    try:
        loaded = json.load(open(t_file, encoding="utf-8"))
        if isinstance(loaded, dict):
            state.update(loaded)
    except Exception:
        pass

now_local = datetime.now().strftime("%H:%M:%S")

def push_used_item(kind, name, path, desk):
    hist = state.get("usedItemsHistory") or []
    entry = {
        "time": now_local,
        "kind": kind,
        "name": name,
        "path": path,
        "desk": desk,
    }
    # ไม่ใส่ซ้ำติดกันถ้าเป็นตัวเดิมเป๊ะ
    if not hist or hist[0].get("path") != path or hist[0].get("kind") != kind:
        hist.insert(0, entry)
    state["usedItemsHistory"] = hist[:18]

state["activeEngine"] = mode
if payload.get("modelName") and payload.get("modelName") != "auto":
    state["activeModel"] = str(payload["modelName"])

prompt_txt = payload.get("prompt") or payload.get("lastUserInput") or ""
if prompt_txt:
    clean_p = " ".join(str(prompt_txt).split())
    if len(clean_p) > 160:
        clean_p = clean_p[:157] + "..."
    state["currentTask"] = clean_p

if stage == "prompt":
    state["activeNode"] = "core"
    if mode == "claude" and not payload.get("modelName"):
        state["activeModel"] = "opus"
    state["systemStatus"] = "working"
    state["activeAgentFile"] = "CLAUDE.md / AGENTS.md"
    state["activeHook"] = ".claude/hooks/telemetry-tracker.sh (UserPromptSubmit)"

    p_low = state["currentTask"].lower()
    if "/plan" in p_low:
        state["activeCommand"] = "/plan (.claude/commands/plan.md)"
        state["activeSkill"] = "common-ground"
        state["activeSkillFile"] = ".claude/skills/common-ground/SKILL.md"
        push_used_item("COMMAND", "/plan", ".claude/commands/plan.md", "core")
    elif "/common-ground" in p_low:
        state["activeCommand"] = "/common-ground (.claude/commands/common-ground.md)"
        state["activeSkill"] = "common-ground"
        state["activeSkillFile"] = ".claude/skills/common-ground/SKILL.md"
        push_used_item("COMMAND", "/common-ground", ".claude/commands/common-ground.md", "core")
    elif "/fix" in p_low or "บั๊ก" in p_low or "พัง" in p_low or "error" in p_low:
        state["activeCommand"] = "/fix (.claude/commands/fix.md)"
        state["activeSkill"] = "root-cause-debug"
        state["activeSkillFile"] = ".claude/skills/root-cause-debug/SKILL.md"
        push_used_item("SKILL", "root-cause-debug", ".claude/skills/root-cause-debug/SKILL.md", "debugger")
    elif "/review" in p_low or "รีวิว" in p_low or "ตรวจโค้ด" in p_low:
        state["activeCommand"] = "/review (.claude/commands/review.md)"
        state["activeSkill"] = "pragmatic-review"
        state["activeSkillFile"] = ".claude/skills/pragmatic-review/SKILL.md"
        push_used_item("SKILL", "pragmatic-review", ".claude/skills/pragmatic-review/SKILL.md", "reviewer")
    elif "/verify" in p_low or "รันเทสต์" in p_low:
        state["activeCommand"] = "/verify (.claude/commands/verify.md)"
        state["activeSkill"] = "verification-before-completion"
        state["activeSkillFile"] = ".claude/skills/verification-before-completion/SKILL.md"
        push_used_item("SKILL", "verification-before-completion", ".claude/skills/verification-before-completion/SKILL.md", "reviewer")
    elif "/handoff" in p_low or "ค้างไว้" in p_low:
        state["activeCommand"] = "/handoff (.claude/commands/handoff.md)"
        state["activeSkill"] = "auto-resume-handoff"
        state["activeSkillFile"] = ".claude/skills/auto-resume-handoff/SKILL.md"
        push_used_item("SKILL", "auto-resume-handoff", ".claude/skills/auto-resume-handoff/SKILL.md", "core")
    elif "3d" in p_low or "three" in p_low or "webgl" in p_low:
        state["activeCommand"] = "Auto-Route ➔ 3D Specialist"
        state["activeSkill"] = "threejs-expert"
        state["activeSkillFile"] = ".claude/skills/threejs-expert/SKILL.md"
        state["activeRuleFile"] = ".claude/rules/ui-anti-slop.md"
        push_used_item("SKILL", "threejs-expert", ".claude/skills/threejs-expert/SKILL.md", "implementer")
    elif "db" in p_low or "sql" in p_low or "migration" in p_low or "ตาราง" in p_low:
        state["activeCommand"] = "Auto-Route ➔ DB Migration"
        state["activeSkill"] = "db-migration"
        state["activeSkillFile"] = ".claude/skills/db-migration/SKILL.md"
        push_used_item("SKILL", "db-migration", ".claude/skills/db-migration/SKILL.md", "implementer")
    else:
        state["activeCommand"] = "Auto-Route (CLAUDE.md)"
        state["activeSkill"] = "common-ground"
        state["activeSkillFile"] = ".claude/skills/common-ground/SKILL.md"

    push_used_item("PROMPT", state["currentTask"][:60], "CLAUDE.md", "core")
    state["currentAction"] = f"👑 หัวหน้า Opus รับโจทย์: {state['currentTask'][:75]}"

elif stage == "read":
    tool_name = (payload.get("toolCall") or {}).get("name") or payload.get("tool_name") or "Read/Search"
    tool_args = (payload.get("toolCall") or {}).get("args") or payload.get("tool_input") or {}
    raw_target = str(tool_args.get("Path") or tool_args.get("file_path") or tool_args.get("pattern") or tool_args.get("Query") or "")
    rel_target = os.path.relpath(raw_target, os.getcwd()) if (raw_target and os.path.isabs(raw_target)) else raw_target
    short_target = os.path.basename(raw_target.rstrip("/")) if raw_target else ""

    state["activeHook"] = ".claude/hooks/telemetry-tracker.sh (PreToolUse:Read)"
    state["systemStatus"] = "working"

    # ตรวจจับทันทีหาก AI กำลังเปิดอ่านไฟล์ Skill, Command, Agent หรือ Rule จริงๆ!
    m_skill = re.search(r"(?:\.claude|\.agents)/skills/([^/]+)/SKILL\.md", rel_target)
    m_cmd = re.search(r"\.claude/commands/([^/]+)\.md", rel_target)
    m_agent = re.search(r"\.claude/agents/([^/]+)\.md", rel_target)
    m_rule = re.search(r"(?:\.claude|\.agents)/rules/([^/]+\.md)", rel_target)

    if m_skill:
        skill_slug = m_skill.group(1)
        state["activeSkill"] = skill_slug
        state["activeSkillFile"] = f".claude/skills/{skill_slug}/SKILL.md"
        # โยงโต๊ะตามประเภท Skill
        if skill_slug in ("threejs-expert", "db-migration"):
            state["activeNode"] = "implementer"
            state["activeAgentFile"] = ".claude/agents/implementer.md"
        elif skill_slug == "root-cause-debug":
            state["activeNode"] = "debugger"
            state["activeAgentFile"] = ".claude/agents/debugger.md"
        elif skill_slug in ("pragmatic-review", "verification-before-completion"):
            state["activeNode"] = "reviewer"
            state["activeAgentFile"] = ".claude/agents/reviewer.md"
        else:
            state["activeNode"] = "core"
            state["activeAgentFile"] = "CLAUDE.md / AGENTS.md"
        push_used_item("SKILL", skill_slug, state["activeSkillFile"], state["activeNode"])
        state["currentAction"] = f"📚 กำลังดึง Skill จริงเข้าสมอง AI: {skill_slug} ({state['activeSkillFile']})"
    elif m_cmd:
        cmd_slug = m_cmd.group(1)
        state["activeCommand"] = f"/{cmd_slug} (.claude/commands/{cmd_slug}.md)"
        push_used_item("COMMAND", f"/{cmd_slug}", f".claude/commands/{cmd_slug}.md", state.get("activeNode", "core"))
        state["currentAction"] = f"⚡ กำลังอ่านคำสั่ง Prompt: /{cmd_slug} (.claude/commands/{cmd_slug}.md)"
    elif m_agent:
        ag_slug = m_agent.group(1)
        if ag_slug in ("explorer", "implementer", "debugger", "reviewer"):
            state["activeNode"] = ag_slug
        state["activeAgentFile"] = f".claude/agents/{ag_slug}.md"
        push_used_item("AGENT", ag_slug, state["activeAgentFile"], state["activeNode"])
        state["currentAction"] = f"🤖 เรียกใช้งานโปรไฟล์พนักงาน: {ag_slug} ({state['activeAgentFile']})"
    elif m_rule:
        r_name = m_rule.group(1)
        state["activeRuleFile"] = f".claude/rules/{r_name}"
        push_used_item("RULE", r_name, state["activeRuleFile"], state.get("activeNode", "core"))
        state["currentAction"] = f"📏 โหลดกฎเหล็ก: {r_name} ({state['activeRuleFile']})"
    else:
        state["activeNode"] = "explorer"
        state["activeModel"] = "haiku" if mode == "claude" else state.get("activeModel", "auto")
        state["activeAgentFile"] = ".claude/agents/explorer.md"
        state["activeRuleFile"] = ".claude/rules/execution-discipline.md"
        if rel_target and not rel_target.startswith(".."):
            push_used_item("READ", short_target or rel_target, rel_target, "explorer")
        state["currentAction"] = f"🔍 ฝ่ายสำรวจ (Haiku • {tool_name}): {short_target}" if short_target else f"🔍 ฝ่ายสำรวจ ({tool_name})"

elif stage == "stop":
    term_reason = payload.get("terminationReason") or "COMPLETED"
    state["activeHook"] = ".claude/hooks/telemetry-tracker.sh (Stop)"
    if term_reason == "MAX_TOKEN_BUDGET_EXCEEDED":
        state["activeNode"] = "core"
        state["systemStatus"] = "blocked"
        state["activeSkill"] = "auto-resume-handoff"
        state["activeSkillFile"] = ".claude/skills/auto-resume-handoff/SKILL.md"
        state["currentAction"] = "🔴 โควต้าเต็ม (MAX_TOKEN_BUDGET_EXCEEDED) — แนะนำสลับค่าย AI!"
    else:
        state["activeNode"] = "reviewer"
        state["systemStatus"] = "ready"
        state["activeAgentFile"] = ".claude/agents/reviewer.md"
        state["activeSkill"] = "verification-before-completion"
        state["activeSkillFile"] = ".claude/skills/verification-before-completion/SKILL.md"
        state["currentAction"] = "✅ ทำงานรอบนี้เสร็จสิ้น (พร้อมรับคำสั่งถัดไป)"

stats = state.get("stats") or {"claudeCalls": 0, "antigravityCalls": 0, "blockedCount": 0, "filesEdited": 0}
if stage in ("prompt", "read"):
    if mode == "claude":
        stats["claudeCalls"] = int(stats.get("claudeCalls", 0)) + 1
    else:
        stats["antigravityCalls"] = int(stats.get("antigravityCalls", 0)) + 1
state["stats"] = stats

events = state.get("events") or []
events.insert(0, {
    "time": now_local,
    "engine": mode,
    "node": state["activeNode"],
    "status": state["systemStatus"],
    "detail": state["currentAction"],
    "skill": state.get("activeSkill", ""),
    "agentFile": state.get("activeAgentFile", ""),
})
state["events"] = events[:25]
state["updatedAt"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
state["updatedEpochMs"] = int(time.time() * 1000)

tmp = f"{t_file}.tmp.{os.getpid()}"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(state, f, ensure_ascii=False, indent=2)
os.replace(tmp, t_file)
PYEOF
  fi

  if [ "$MODE" = "antigravity" ]; then
    if [ "$HOOK_STAGE" = "read" ] || [ "$HOOK_STAGE" = "stop" ]; then
      printf '{"decision":"allow"}\n'
    else
      printf '{}\n'
    fi
  fi
  exit 0
fi

# โหมด 2: เรียกจาก Hook อื่นๆ หรือปุ่มจำลอง (--engine <mode> --node <node> --status <status> --detail <msg> [--file <path>] [--strike <n>] [--model <model>] [--skill <skill>] [--command <cmd>] [--rule <rule>] [--hook <hook>] [--prompt <task>])
ENGINE="claude"
NODE="core"
STATUS="working"
DETAIL=""
FILE_TOUCHED=""
STRIKE=""
MODEL_ARG=""
SKILL_ARG=""
CMD_ARG=""
RULE_ARG=""
HOOK_ARG=""
PROMPT_ARG=""

while [ $# -gt 0 ]; do
  case "$1" in
    --engine)  ENGINE="${2:-claude}"; shift 2 ;;
    --node)    NODE="${2:-core}"; shift 2 ;;
    --status)  STATUS="${2:-working}"; shift 2 ;;
    --detail)  DETAIL="${2:-}"; shift 2 ;;
    --file)    FILE_TOUCHED="${2:-}"; shift 2 ;;
    --strike)  STRIKE="${2:-}"; shift 2 ;;
    --model)   MODEL_ARG="${2:-}"; shift 2 ;;
    --skill)   SKILL_ARG="${2:-}"; shift 2 ;;
    --command) CMD_ARG="${2:-}"; shift 2 ;;
    --rule)    RULE_ARG="${2:-}"; shift 2 ;;
    --hook)    HOOK_ARG="${2:-}"; shift 2 ;;
    --prompt)  PROMPT_ARG="${2:-}"; shift 2 ;;
    *) shift ;;
  esac
done

if command -v python3 >/dev/null 2>&1; then
  python3 - "$TELEMETRY_FILE" "$ENGINE" "$NODE" "$STATUS" "$DETAIL" "$FILE_TOUCHED" "$STRIKE" "$MODEL_ARG" "$SKILL_ARG" "$CMD_ARG" "$RULE_ARG" "$HOOK_ARG" "$PROMPT_ARG" <<'PYEOF' 2>/dev/null || true
import sys, os, json, time
from datetime import datetime, timezone

(
    t_file,
    engine,
    node,
    status,
    detail,
    file_touched,
    strike,
    model_arg,
    skill_arg,
    cmd_arg,
    rule_arg,
    hook_arg,
    prompt_arg,
) = sys.argv[1:14]

state = {
    "updatedAt": "",
    "updatedEpochMs": 0,
    "activeEngine": engine,
    "activeModel": "opus" if (engine == "claude" and node == "core") else ("sonnet" if engine == "claude" else "gemini-4-argon"),
    "activeNode": node,
    "systemStatus": status,
    "currentTask": "กำลังดำเนินงานในโปรเจกต์...",
    "currentAction": detail or "กำลังประมวลผล...",
    "activeCommand": "Auto-Route (CLAUDE.md)",
    "activeAgentFile": "CLAUDE.md / AGENTS.md",
    "activeSkill": "common-ground",
    "activeSkillFile": ".claude/skills/common-ground/SKILL.md",
    "activeRuleFile": ".claude/rules/code-simplicity.md",
    "activeHook": ".claude/hooks/telemetry-tracker.sh",
    "strikeCount": 0,
    "maxStrikes": 3,
    "touchedFiles": [],
    "usedItemsHistory": [],
    "stats": {"claudeCalls": 0, "antigravityCalls": 0, "blockedCount": 0, "filesEdited": 0},
    "events": []
}
if os.path.exists(t_file):
    try:
        loaded = json.load(open(t_file, encoding="utf-8"))
        if isinstance(loaded, dict):
            state.update(loaded)
    except Exception:
        pass

now_local = datetime.now().strftime("%H:%M:%S")

def push_used_item(kind, name, path, desk):
    hist = state.get("usedItemsHistory") or []
    entry = {
        "time": now_local,
        "kind": kind,
        "name": name,
        "path": path,
        "desk": desk,
    }
    if not hist or hist[0].get("path") != path or hist[0].get("kind") != kind:
        hist.insert(0, entry)
    state["usedItemsHistory"] = hist[:18]

state["activeEngine"] = engine
state["activeNode"] = node
state["systemStatus"] = status

if model_arg:
    state["activeModel"] = model_arg
elif engine == "claude":
    if node == "core":
        state["activeModel"] = "opus"
    elif node == "explorer":
        state["activeModel"] = "haiku"
    elif node in ("implementer", "debugger", "reviewer"):
        state["activeModel"] = "sonnet"
else:
    state["activeModel"] = "gemini-4-argon"

# ผูกไฟล์ Agent, Skill, Command และ Rule อัตโนมัติตามโต๊ะหรือไฟล์ที่กำลังทำจริง
NODE_DEFAULTS = {
    "core": {
        "agent": "CLAUDE.md / AGENTS.md",
        "skill": "common-ground",
        "cmd": "/plan (.claude/commands/plan.md)",
        "rule": ".claude/rules/execution-discipline.md",
    },
    "explorer": {
        "agent": ".claude/agents/explorer.md",
        "skill": "tech-stack-skills",
        "cmd": "/plan (.claude/commands/plan.md)",
        "rule": ".claude/rules/execution-discipline.md",
    },
    "implementer": {
        "agent": ".claude/agents/implementer.md",
        "skill": "verification-before-completion",
        "cmd": "Surgical Edit (.claude/rules/code-simplicity.md)",
        "rule": ".claude/rules/code-simplicity.md",
    },
    "debugger": {
        "agent": ".claude/agents/debugger.md",
        "skill": "root-cause-debug",
        "cmd": "/fix (.claude/commands/fix.md)",
        "rule": ".claude/rules/testing-and-api.md",
    },
    "reviewer": {
        "agent": ".claude/agents/reviewer.md",
        "skill": "pragmatic-review",
        "cmd": "/review (.claude/commands/review.md)",
        "rule": ".claude/rules/testing-and-api.md",
    },
}

nd = NODE_DEFAULTS.get(node, NODE_DEFAULTS["core"])
state["activeAgentFile"] = nd["agent"]

d_low = (detail or "").lower()
ALL_SKILLS = [
    "threejs-expert",
    "db-migration",
    "root-cause-debug",
    "pragmatic-review",
    "verification-before-completion",
    "auto-resume-handoff",
    "tech-stack-skills",
    "common-ground",
]
ALL_CMDS = ["/plan", "/common-ground", "/fix", "/review", "/verify", "/handoff"]

if not skill_arg:
    for sk in ALL_SKILLS:
        if sk in d_low:
            skill_arg = sk
            break
    if not skill_arg:
        if "สลับค่าย" in d_low or "handoff" in d_low or "antigravity" in d_low:
            skill_arg = "auto-resume-handoff"
        elif "3d" in d_low or "three" in d_low:
            skill_arg = "threejs-expert"
        elif "ซ่อมบั๊ก" in d_low or "เทสต์พัง" in d_low or "เบรกเกอร์" in d_low:
            skill_arg = "root-cause-debug"
        elif "ตรวจรับงาน" in d_low or "รีวิว" in d_low:
            skill_arg = "pragmatic-review"
        elif "สำรวจ" in d_low or "haiku" in d_low:
            skill_arg = "tech-stack-skills"

if not cmd_arg:
    for cm in ALL_CMDS:
        if cm in d_low:
            cmd_arg = f"{cm} (.claude/commands/{cm[1:]}.md)"
            break
    if not cmd_arg:
        if "บล็อก" in d_low or "shield" in d_low:
            cmd_arg = "OS Shield Guard (validate-bash.sh)"
        elif "เบรกเกอร์" in d_low or "circuit" in d_low:
            cmd_arg = "CIRCUIT_BREAKER: 2_STRIKES_REACHED"
        elif "สลับค่าย" in d_low:
            cmd_arg = "/handoff (.claude/commands/handoff.md)"

if not hook_arg:
    if "บล็อก" in d_low or "shield" in d_low:
        hook_arg = ".claude/hooks/validate-bash.sh + protect-sensitive-files.sh"
    elif "เบรกเกอร์" in d_low or "เทสต์พัง" in d_low or "repeat" in d_low:
        hook_arg = ".claude/hooks/loop-circuit-breaker.sh"
    elif "สลับค่าย" in d_low or "handoff" in d_low:
        hook_arg = ".claude/hooks/auto-resume.sh"
    elif node == "implementer":
        hook_arg = ".claude/hooks/post-edit-format.sh"
    elif node == "explorer":
        hook_arg = ".claude/hooks/telemetry-tracker.sh (PreToolUse:Read)"
    elif node == "reviewer":
        hook_arg = ".claude/hooks/telemetry-tracker.sh (Stop)"
    else:
        hook_arg = ".claude/hooks/telemetry-tracker.sh (UserPromptSubmit)"

chosen_skill = skill_arg or nd["skill"]
if file_touched:
    fl = file_touched.lower()
    if fl.endswith((".tsx", ".jsx", ".html", ".css", ".vue", ".svelte")):
        if not rule_arg:
            rule_arg = ".claude/rules/ui-anti-slop.md"
        if "hud" in fl or "three" in fl or "3d" in fl:
            chosen_skill = skill_arg or "threejs-expert"
    elif "migration" in fl or "schema" in fl or fl.endswith(".sql"):
        chosen_skill = skill_arg or "db-migration"

state["activeSkill"] = chosen_skill
state["activeSkillFile"] = f".claude/skills/{chosen_skill}/SKILL.md"
state["activeCommand"] = cmd_arg or nd["cmd"]
state["activeRuleFile"] = rule_arg or nd["rule"]
state["activeHook"] = hook_arg

if detail and not prompt_arg:
    state["currentTask"] = detail[:160]

if prompt_arg:
    state["currentTask"] = prompt_arg[:160]
    push_used_item("PROMPT", prompt_arg[:60], "CLAUDE.md", node)

if detail:
    state["currentAction"] = detail

push_used_item("AGENT", os.path.basename(state["activeAgentFile"]), state["activeAgentFile"].split(" ")[0], node)
push_used_item("SKILL", state["activeSkill"], state["activeSkillFile"], node)
if hook_arg:
    push_used_item("HOOK", os.path.basename(hook_arg), hook_arg, node)

if strike != "":
    try:
        state["strikeCount"] = int(strike)
    except Exception:
        pass

stats = state.get("stats") or {"claudeCalls": 0, "antigravityCalls": 0, "blockedCount": 0, "filesEdited": 0}
if engine == "claude":
    stats["claudeCalls"] = int(stats.get("claudeCalls", 0)) + 1
else:
    stats["antigravityCalls"] = int(stats.get("antigravityCalls", 0)) + 1

if status == "blocked":
    stats["blockedCount"] = int(stats.get("blockedCount", 0)) + 1

if file_touched:
    short_f = os.path.relpath(file_touched, os.getcwd()) if os.path.isabs(file_touched) else file_touched
    if short_f.startswith(".."):
        short_f = os.path.basename(file_touched)
    touched = state.get("touchedFiles") or []
    if short_f in touched:
        touched.remove(short_f)
    touched.insert(0, short_f)
    state["touchedFiles"] = touched[:6]
    stats["filesEdited"] = int(stats.get("filesEdited", 0)) + 1

state["stats"] = stats

events = state.get("events") or []
events.insert(0, {
    "time": now_local,
    "engine": engine,
    "node": node,
    "status": status,
    "detail": detail or status,
    "skill": state.get("activeSkill", ""),
    "agentFile": state.get("activeAgentFile", ""),
})
state["events"] = events[:25]
state["updatedAt"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
state["updatedEpochMs"] = int(time.time() * 1000)

tmp = f"{t_file}.tmp.{os.getpid()}"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(state, f, ensure_ascii=False, indent=2)
os.replace(tmp, t_file)
PYEOF
fi
exit 0
