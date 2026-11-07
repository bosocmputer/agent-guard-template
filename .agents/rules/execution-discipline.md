# Execution Discipline, Context Hygiene & Subagent Delegation

> **Reference Architecture:** [`trailofbits/claude-code-config`](https://github.com/trailofbits/claude-code-config) (Two-Layer Context Hygiene), **Google ADK 2.0 Graph Engineering** (`State-Delta` Node Passing), & [`forrestchang/andrej-karpathy-skills`](https://github.com/forrestchang/andrej-karpathy-skills) (*Goal-Driven Execution*)

## 1. Context Window Protection & Graph `State-Delta` Delegation
- **Keep Primary Context Lean:** Never dump entire large files or run broad, unfiltered recursive searches (`grep -R` across `node_modules/` or `dist/`) in the main conversation window.
- **When to Delegate vs Execute Directly (Deterministic Routing):**
  - **1–2 Known Files (Direct Execution):** Read the target line ranges and apply surgical edits directly in the main session. Do not spawn subagents for trivial edits.
  - **>3 Files or Unknown Codebase Layout (Delegate to `explorer`):** Offload broad codebase searches to the `explorer` subagent (`model: haiku`, `maxTurns: 6`) so only its 15-line summary enters the main context window.
- **Graph `State-Delta` Handoff Between Subagents (Google ADK 2 Pattern):**
  - When chaining subagents (`explorer` ➔ `implementer` ➔ `reviewer` or `debugger`), **never paste full chat history or raw file dumps into the next subagent's prompt**.
  - Pass only a compact **`State Delta` payload (maximum 8 lines)** containing:
    1. **Target Files & Lines:** Exact `path/to/file:LXX-LYY` discovered by the previous node.
    2. **Confirmed Constraints:** Business rules or blocker IDs (`[BLK-01]`) to satisfy.
    3. **Verification Command:** Exact single-file test command to run.
- **Targeted Single-File Testing:** During active implementation or debugging, execute only the specific test file (`node --test <path>`, `go test -v ./pkg -run <TestName>`, `flutter test test/<file>_test.dart`, or `pytest <path>`) rather than running the entire repository test suite on every edit.

## 2. Non-Destructive Rollback Protocol
- When reverting a failed hypothesis or broken edit, **always use the `Edit` (`edit_file`) tool to restore the exact lines modified**.
- **Strictly Forbidden:** Never run `git checkout .`, `git restore`, `git reset --hard`, or `git clean -f`—the working tree may contain uncommitted work authored by the user.

## 3. Goal-Driven Execution & Hard Stop
- Define the exact verification command before editing code.
- Once the stated objective is implemented and verified passing with fresh terminal output, **STOP IMMEDIATELY**. Do not perform unsolicited refactoring, add extra features, or run exploratory commands after completion.

## 4. Constraints (`MUST DO` / `MUST NOT DO`)
- **MUST** read the target function and 1 adjacent file before writing or editing code.
- **MUST** report changes concisely (`file:line` + 1-line summary) without pasting entire modified files into chat.
- **MUST NOT** modify more than 5 files in a single turn without prior user confirmation.
