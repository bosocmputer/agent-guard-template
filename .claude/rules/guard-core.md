---
description: "(กฎแกนกลาง Universal Guard — โหลดอัตโนมัติทุกโปรเจกต์: Safety Gates, Native Subagent Budget, Compact Memory, Auto-Handoff)"
---
# Universal Agent Guard Core (v3 — Slim Safety & Memory Harness)

These non-negotiable guardrails apply to **every repository** (including repos with a custom `CLAUDE.md`):

1. **Native Subagent Discipline & Quota Budget:**
   - Let each engine use its built-in native subagents (`Agent` in Claude Code / `invoke_subagent` in Antigravity) naturally for multi-file changes (`>= 3` files) or broad exploration — **never** pass `model="opus"` to a subagent.
   - **Pre-Mapped Fast Path & Cap:** When the prompt already names exact target files/lines (or `<= 5` known modules), **skip explorer subagents** and stay within **`<= 4` subagents per prompt** to prevent token bursts (`>= 6M` tokens).
2. **6-Turn Investigation, Debug & SSH/Ops Ceiling:**
   - Batch remote checks (`ssh`, `docker logs`, `docker ps`, `psql`, `gh run view`) into **1–2 compound commands per step**.
   - If tracing/debugging exceeds **6 read/inspect/SSH calls** without a verified fix, stop looping in the main window and delegate root-cause tracing to a fresh subagent (under the 2-Strike rule).
3. **Prefer `Edit` Tool Over Full-File `Write` or Bash `python3` File Edits:**
   - For existing files (including worktrees in `/private/tmp/...`), ALWAYS use targeted `Edit` (`edit_file`) instead of full-file `Write` overwrites or Bash `python3`/`cat >` edits so security & formatting hooks always execute.
4. **Compact Cross-Engine Memory (`TASK_STATE.md` & `project-pitfalls.md`):**
   - **`TASK_STATE.md` (above `## 🔄 Auto-Synced Git & Session State`):** Replace current status in place; keep **`<= 20 lines` AND `<= 2,500 bytes`** (older entries auto-archive to `.claude/.task-state-archive.md`).
   - **`.claude/rules/project-pitfalls.md`:** Strictly **1 concise line (`<= 180 chars`) per rule**, max 30 rules and **`<= 4,500 bytes`** total.
5. **Auto-Handoff Nudge (`100t`) & Survival Mode (`120t`):**
   - At `100–119` parent turns: update `TASK_STATE.md` and suggest `/compact` (Antigravity) / `/clear` (Claude Code) or starting a new chat + `"ทำต่อ"` in 1 line.
   - At `>= 120` parent turns (or `>= 150k` tokens): switch to thin-dispatcher mode, delegating edits/log tracing to fresh subagents and syncing `TASK_STATE.md` every turn.
6. **Zero-Token Production Safety Gates (`validate-bash.sh` & `protect-sensitive-files.sh`):**
   - Never read, print, edit, or commit `.env*` (root or subfolders), `*.key`, `*.pem`, `*.sqlite`, `*.db`, or host credentials (`~/.ssh`, `~/.aws`, `~/.kube`).
   - Never `git push` commits containing new SQL migrations (`migrations/*.sql`) to `main`/`master` until applied on Production DB (`MIGRATION_PROD_VERIFIED=1` or `RELEASE_APPROVED=1`; `uat`/preview branches unaffected).
   - Never stage/commit local template files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `TASK_STATE.md`, `.claude/.telemetry.json`) into consumer repos (`ALLOW_TEMPLATE_COMMIT=1` to override).
   - Never pass tokens/passwords via `docker login -p/--password`, `echo $(gh auth token)`, or `ssh` positional args — always pipe via `--password-stdin`.
7. **Mandatory Session Proof Footer (Multi-File / Feature / Deploy Tasks):**
   - At the end of every feature, bug-fix, multi-file edit, or deploy task (skip only on pure Q&A or trivial 1–2 line edits), **MUST** run `bash .claude/hooks/audit-session-proof.sh --brief` and **append its exact 4-line `### 📊 ผลชี้วัด Agent Guard Template` block verbatim at the bottom of the final response** (right after `### ⏭️ ขั้นตอนถัดไป (Next Steps)`).
