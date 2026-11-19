---
description: "(กฎแกนกลาง Universal Guard — โหลดอัตโนมัติทุกโปรเจกต์แม้มี CLAUDE.md เฉพาะตัว: Opus->Sonnet, SSH/Debug Ceiling, Compact Memory, Auto-Handoff)"
---
# Universal Agent Guard Core (Auto-Loaded Across Custom `CLAUDE.md` Projects)

These non-negotiable operational guardrails apply to **every repository** (including repos with a custom `CLAUDE.md`):

1. **Opus Architect ➔ Sonnet Builder (3+ Files) ➔ Opus Gatekeeper:**
   - Never pass `model="opus"` to any subagent (`explorer` = `haiku`, `implementer`/`debugger`/`reviewer` = `sonnet`).
   - Any feature/fix creating or editing **`>= 3` files** MUST be delegated to `implementer (sonnet)` with exact file paths + line numbers (never spawn `implementer` blind; max 10 reads before first edit).
2. **6-Turn Investigation, Debug & SSH/Ops Ceiling (Zero-Command Protection):**
   - Batch remote checks (`ssh`, `docker logs`, `docker ps`, `psql`, `gh run view`) into **1–2 compound commands per step** instead of sequential single-command SSH loops.
   - If debugging a `1–2` file issue OR tracing server/CI/DB logs exceeds **6 read/inspect/SSH calls** in the main window without a verified fix, STOP in Parent `Opus` and delegate root-cause tracing to `debugger (sonnet)` or `explorer (haiku)`.
3. **Prefer `Edit` Tool Over Full-File `Write` or Bash `python3` File Edits:**
   - For existing files—including files in external git worktrees (e.g. `/private/tmp/...`)—ALWAYS use targeted `Edit` with absolute paths instead of full-file `Write` overwrites (avoids Auto Mode blocks) or `python3`/`cat >` writes via `Bash` (ensures security & formatting hooks run).
4. **Compact External Memory Budgets (Byte + Line Caps):**
   - **`TASK_STATE.md` (above `## 🔄 Auto-Synced Git & Session State`):** Replace/update current status in place; keep strictly **`<= 20 lines` AND `<= 2,500 bytes`**. Never append unbounded deploy history (older entries are auto-archived to `.claude/.task-state-archive.md`).
   - **`.claude/rules/project-pitfalls.md`:** Strictly **1 concise line (`<= 180 chars`) per rule**, max 30 rules and **`<= 4,500 bytes`** total.
5. **Mandatory End-of-Task Proof, Auto-Handoff Nudge (`100t`) & No-`/clear` Survival Mode (`120t`):**
   - After completing any code edit, deploy, or UAT milestone, run `bash .claude/hooks/audit-session-proof.sh --brief` and append its 5-line proof summary.
   - At **`100–119` parent turns**: update `TASK_STATE.md` concisely and add a brief 1-line note suggesting `/clear` + `"ทำต่อ"` before the next multi-file slice.
   - At **`>= 120` parent turns (or `>= 150k` tokens) if the user keeps working without `/clear`**: do NOT nag repeatedly; enter **Ultra-Thin Dispatcher Survival Mode** — delegate even `1–2` file edits or `> 2` log/SSH commands to fresh `sonnet`/`haiku` subagents so the heavy main window stays at `1–2` orchestration turns per prompt and keeps `TASK_STATE.md` synced every turn.
6. **Migration-Before-Main Safety Gate:**
   - Never `git push` commits containing new SQL migrations (`migrations/*.sql`) to `main`/`master` (Production) until the SQL migration is confirmed applied on Production DB (`validate-bash.sh` blocks unless `MIGRATION_PROD_VERIFIED=1` or `RELEASE_APPROVED=1`; pushing to `uat`/`preview`/feature branches is unaffected).
