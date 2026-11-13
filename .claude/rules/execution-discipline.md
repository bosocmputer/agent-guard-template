---
description: "(กฎส่งต่องานระหว่างแผนกอย่างกระชับและรักษาความสะอาดของหน่วยความจำ)"
---
# Execution Discipline & Non-Destructive Rollback

## 1. Compact `State-Delta` Handoff & Smart Subagent Lifecycle
- When chaining subagents (`explorer` ➔ `implementer` ➔ `reviewer` / `debugger`), never paste full chat history or raw file dumps.
- Pass at most an **8-line `State Delta` payload**: (1) exact `path/to/file:LXX-LYY`, (2) confirmed business rules or blocker IDs (`[BLK-01]`), and (3) exact Tier 1 + Tier 2 test commands.
- **No Micro-Verifier Spawning:** The `Surgical Implementer` that edits code MUST run Tier 1 (`single-file test`) and Tier 2 (`analyze` / `typecheck` / `build`) verification itself before returning. Never spawn a separate `QA Verifier` (`self`) subagent just to run 1–3 CLI commands (`analyze`, `build`, `git commit/push`). Reserve separate `QA Verifier` subagents for live `browser` (`Model="flash"`) UI checks or full end-of-feature reviews.
- **Same-Feature Reuse (`< 40 turns`) vs Unrelated Task Isolation:** For small follow-up adjustments within the **same feature** where the active `Implementer` has used `< 40 turns`, reuse it via `send_message` to avoid cold-start context reload. Once a subagent exceeds `40 turns` or when switching to an **unrelated task/feature**, spawn a fresh subagent (`invoke_subagent` / `Agent`).

## 2. Non-Destructive Rollback Protocol
- When reverting a failed hypothesis or broken edit, **always use `Edit` (`edit_file`) to restore the exact lines modified**.
- **Strictly Forbidden:** Never run `git checkout .`, `git checkout -- <file>`, `git restore`, `git reset --hard`, or `git clean -f`—the working tree may contain uncommitted user work.

## 3. Goal-Driven Execution & Hard Stop
- **Grep First, Read Line-Range Second (`> 200 lines`):** For files longer than 200 lines, use `Grep`/`grep_search` to locate target line numbers first, then read only the relevant slice (`offset`/`limit` or `StartLine`–`EndLine` ±40 lines) instead of repeatedly loading full files into context (saves 70–80% input tokens).
- Read the target function and 1 adjacent sibling file before editing.
- During active coding/debugging, run only the single target test file (Tier 1) rather than the full repository suite on every edit.
- Once the stated objective passes verification with fresh terminal output, **STOP IMMEDIATELY**. Do not perform unsolicited refactoring or add unrequested files.
- Do not modify more than 5 files in a single turn without confirming the file list with the user first.
