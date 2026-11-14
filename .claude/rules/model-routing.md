---
description: "(กฎคัดแยกโมเดลอัตโนมัติ Opus วางแผน ➔ Haiku สำรวจไว ➔ Sonnet เขียนโค้ด/ซ่อมบั๊ก/รันเทสต์)"
---
# Automatic Model Routing & Quota Guard

Follow the routing table in `CLAUDE.md` / `AGENTS.md` Section 1 with synchronized subagent ceilings:
- **`explorer` (`haiku` / `flash`, `maxTurns: 15`):** Read-only search (`>3` files), caller tracing, impact mapping, and web research (`WebSearch`/`WebFetch`).
- **`implementer` (`sonnet` / `inherit`, `maxTurns: 40`):** Multi-file surgical implementation (`3+` files) + self-running Tier 1 & Tier 2 verification (`test` + `analyze`/`build`) before returning.
- **`debugger` (`sonnet` / `inherit`, `maxTurns: 18`):** Root-cause investigation under the `2-Strike` circuit breaker.
- **`reviewer` (`sonnet` / `flash` for `browser` or `inherit` for full E2E, `maxTurns: 35`):** Live `browser` UI inspection, blocker-only diff review, or full milestone E2E verification. Never spawn a separate `reviewer` subagent just to run 1–3 CLI check/build/git commands.
- **Anti-Quota-Drain & No Main-Window Playwright/Web Bloat:** Do not spawn subagents for 1–2 known file edits, config tweaks, or short shell checks. Never call `mcp__playwright__browser_*` or multi-page `WebFetch` inside the main window—always delegate browser/web tasks to `reviewer` or `explorer` so DOM snapshots do not pollute main context.
- **One Slice Per Prompt (No Unbounded Auto-Chaining):** Spawn at most 1–2 `implementer` subagents for the current slice, verify, report back to the user, and stop. Never auto-chain multiple sprint steps (`Step 1 ➔ Step 2 ➔ Step 3 ➔ Step 4`) continuously in a single turn without user confirmation.
- **Same-Feature Reuse (`< 40 turns`) vs Unrelated Task Isolation:** Reuse an existing `implementer` via `send_message` for small iterative follow-ups within the **same feature** while it is under `40 turns`; spawn a fresh subagent (`invoke_subagent` / `Agent`) when switching to an unrelated task/feature or once an agent exceeds `40 turns`.
- **Fresh Context Only (No Forking Parent History):** Always start new subagents with a clean context window and pass only the `<= 8 lines` `State-Delta` brief. Never fork or copy the bloated parent conversation history into a subagent.
- **Parallel Subagent Safety (Disjoint Files First):** When spawning 2+ `implementer` subagents concurrently, assign strictly non-overlapping target files (and let only the parent update `TASK_STATE.md` / `project-pitfalls.md`); use worktree isolation (`isolation: "worktree"` or `Workspace: "share"`) only when parallel tasks must touch overlapping files or run conflicting builds.
