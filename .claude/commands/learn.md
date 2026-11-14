---
description: Distill a bug root cause, resolved [BLOCKER], or user correction into a 1-line rule in project-pitfalls.md (สกัดบทเรียนและข้อตกลงเฉพาะโปรเจกต์เก็บเข้าความจำถาวร)
argument-hint: [lesson-or-correction-to-remember]
allowed-tools: Read, Edit, Write
---
# /learn — Project-Specific Pitfall & Convention Distillation

Distill the lesson, resolved `[BLOCKER]`, or user correction from `$ARGUMENTS` (or from the most recent bug fix / review in this session if `$ARGUMENTS` is empty) into permanent project memory:

## Execution Steps (`Harness Engineering Layer 1: The Ratchet Pattern`)
1. **Sensor-First Check (Prevent Guide Bloat):**
   - Ask first: *Can this failure class be prevented deterministically by a unit test, linter rule, or hook?*
   - If an automated test or hook already blocks this exact mistake (or if you just added a regression test for it), keep the guide rule strictly to a non-redundant 1-line architectural constraint or skip adding duplicate syntax rules.
2. **Read Existing Memory & Prune Stale Rules:**
   - Read `.claude/rules/project-pitfalls.md` to check existing rules, avoid duplicates, and prune any rule that refers to deleted files or obsolete architecture.
3. **Distill into 1 Concise Negative Constraint:** Format the rule strictly as a sharp boundary (`NEVER do X` / `ALWAYS do Y`):
   `- **[Category]:** <What to always do / never do in this project + concise reason>`
4. **Enforce Anti-Bloat Cap (Max 30 Rules):**
   - If a similar rule already exists, update that single line instead of adding a duplicate.
   - If the file already has 30 rules, merge the 2 most closely related rules so the file never exceeds 30 lines of rules.
5. **Single Source of Truth:** Write the update to `.claude/rules/project-pitfalls.md` only (`.agents/rules/project-pitfalls.md` automatically imports it via `@[project-pitfalls]`).
6. **Confirm in Thai:** Report the exact 1-line rule added/updated and the current rule count (`X/30`).
