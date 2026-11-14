---
description: Run a pragmatic Blocker-Only code and security review capped at 2 convergence rounds (สั่งตรวจรีวิวโค้ดและความปลอดภัยเฉพาะจุดสำคัญไม่เกิน 2 รอบ)
argument-hint: [optional-file-or-diff-scope]
allowed-tools: Agent, Read, Edit, Grep, Glob, Bash
---
# /review — Convergent Code & Security Review (Max 2 Rounds)

## Pre-Flight Computational Sensor Gate (`Harness Engineering Layer 2 Sequencing`)
Before invoking the inferential `reviewer` subagent (which costs LLM tokens), confirm that deterministic **Computational Sensors** pass first:
1. Syntax & static typecheck (`tsc --noEmit`, `go vet ./...`, `flutter analyze`, or `ruff check .`)
2. Unit / integration tests covering the modified scope (`vitest`, `go test`, `flutter test`, `pytest`)
*(Never waste LLM review tokens on code that fails compilation or deterministic unit tests.)*

Once computational checks pass, invoke `Agent(subagent_type="reviewer", model="sonnet")` (or `research` + `flash` on Antigravity) to inspect recent changes (`git diff` $ARGUMENTS):

## Convergence Protocol
1. **Round 1 (Blocker-Only Scan):**
   - Flag ONLY `[BLOCKER]` defects (broken logic, calculation bugs, security vulnerabilities, data loss). Ignore stylistic nitpicks.
   - If no blockers exist, output `VERDICT: APPROVE` and stop immediately.
2. **Surgical Repair (If `CHANGES_REQUESTED`):**
   - Fix only the flagged `[BLK-XX]` items using minimal edits.
3. **Round 2 (Final Verification & Scope Freeze):**
   - Verify that Round 1 blockers are resolved and run the relevant test file once to confirm zero regressions.
   - Do not raise new issues in untouched code. Output `VERDICT: APPROVE` (or `VERDICT: ESCALATE_TO_USER` if deadlocked).
