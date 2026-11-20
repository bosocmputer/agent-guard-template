---
description: "(กฎคัดแยกโมเดลอัตโนมัติ Opus วางแผน ➔ Haiku สำรวจไว ➔ Sonnet เขียนโค้ด/ซ่อมบั๊ก/รันเทสต์)"
---
# Automatic Model Routing & Quota Guard

Extends `guard-core.md` (Opus Architect ➔ Sonnet Builder for `3+` files, `<= 6` main-window debug/SSH ceiling, `Edit` over `Write`) with subagent turn caps & isolation rules:
- **`explorer` (`haiku` / `flash`, `maxTurns: 15`):** Read-only search (`>3` files), caller tracing, impact mapping, and web research (`WebSearch`/`WebFetch`).
- **`implementer` (`sonnet` / `inherit`, `maxTurns: 40`, `maxReadsBeforeEdit: 10`):** Multi-file surgical implementation (`3+` files) + self-running Tier 1 & Tier 2 verification (`test` + `analyze`/`build`) before returning. Locate exact files/lines first with `explorer` or `2–4` scoped `Grep` calls—never spawn `implementer` blind.
- **`debugger` (`sonnet` / `inherit`, `maxTurns: 18`):** Root-cause investigation under the `2-Strike` circuit breaker once main-window tracing exceeds 6 calls.
- **`reviewer` (`sonnet` / `flash` for `browser` or `inherit` for full E2E, `maxTurns: 35`):** Live `browser` UI inspection, blocker-only diff review, or full milestone E2E verification. Never spawn a separate `reviewer` subagent just to run 1–3 CLI check/build/git commands.
- **Anti-Quota-Drain & No Main-Window Browser Bloat:** Do not spawn subagents for quick `1–2` known file edits (`<= 6` turns) or short shell checks (unless in `>= 120t` Survival Mode). Never call `mcp__playwright__browser_*` or multi-page `WebFetch` inside the main window—delegate to `reviewer` or `explorer`.
- **One Slice Per Prompt (No Unbounded Auto-Chaining):** Spawn at most 1–2 `implementer` subagents for the current slice, verify, report back to the user, and stop. Never auto-chain multiple sprint steps without user confirmation.
- **Subagent Reuse & Fresh Context:** Reuse an active `implementer` via `send_message` for small follow-ups within the **same feature** while under `40 turns`; spawn a fresh subagent (clean context + `<= 8 lines` `State-Delta`, never forking parent history) for unrelated tasks or once `>= 40 turns`.
- **Parallel Subagent Safety:** Assign strictly non-overlapping target files (parent alone updates `TASK_STATE.md` / `project-pitfalls.md`); use worktree isolation (`isolation: "worktree"` or `Workspace: "share"`) when parallel tasks touch overlapping files or builds.
