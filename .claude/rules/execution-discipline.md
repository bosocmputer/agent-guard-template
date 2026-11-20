---
description: "(กฎส่งต่องานระหว่างแผนกอย่างกระชับและรักษาความสะอาดของหน่วยความจำ)"
---
# Execution Discipline & Non-Destructive Rollback

## 1. Compact `State-Delta` Handoff
- When chaining subagents (`explorer` ➔ `implementer` ➔ `reviewer` / `debugger`), pass at most an **8-line `State Delta` payload**: (1) exact `path/to/file:LXX-LYY`, (2) confirmed business rules or blocker IDs (`[BLK-01]`), and (3) exact Tier 1 + Tier 2 test commands. Never paste raw file dumps or chat history.

## 2. Non-Destructive Rollback Protocol
- Revert failed edits with targeted `Edit` (`edit_file`) on the modified lines only.
- **Strictly Forbidden:** `git checkout .`, `git checkout -- <file>`, `git restore`, `git reset --hard`, or `git clean -f` (preserves uncommitted user work).

## 3. Goal-Driven Execution & Hard Stop
- **Grep First, Read Line-Range Second (`> 200 lines`):** Locate line numbers with `Grep` first, then read only the relevant slice (±40 lines) instead of full files.
- Read the target function and 1 adjacent sibling file before editing; run only the single target test file (Tier 1) during active coding/debugging.
- Once the stated objective passes verification with fresh terminal output, **STOP IMMEDIATELY** (no unsolicited refactors or > 5 unconfirmed files per turn).
