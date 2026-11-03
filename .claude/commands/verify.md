---
description: Execute the 5-step Gate Function and 3-tier verification (Unit Test, Typecheck/Build, Runtime Smoke Check)
argument-hint: [target-test-or-module]
allowed-tools: Read, Grep, Glob, Bash
---
# /verify — Evidence-Based Verification Gate (`obra/superpowers`)

Run the mandatory **Verification Gate Function** for: $ARGUMENTS

## The 5-Step Gate Function
1. **IDENTIFY:** Determine the exact commands that prove the recent changes work.
2. **RUN:** Execute the fresh commands now:
   - **Tier 1 (Unit/Logic):** `node --test <path>` or `npm test -- <path>`
   - **Tier 2 (Typecheck/Build):** `npx tsc --noEmit` or `npm run build` (if configured)
   - **Tier 3 (Non-Blocking Smoke Check):** Check active ports via `lsof -i :<port>` and test via `curl -s -i` (never run `npm run dev` in the foreground).
3. **READ:** Inspect the full terminal output, exit code, and pass/fail counts.
4. **VERIFY:** Confirm whether the output actually proves the claim.
5. **REPORT:** Output the exact command run and actual terminal result, explicitly stating any tier that was not run.
