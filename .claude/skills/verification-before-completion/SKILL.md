---
name: verification-before-completion
description: Use when about to claim a task is complete, fixed, or passing, or before committing/opening a PR. Enforces the Iron Law of Verification and the 5-step Gate Function.
---
# Verification Before Completion (`obra/superpowers` Protocol)

## 1. The Iron Law
> **NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.**

If you have not run the verification command in the current turn, you cannot claim it passes.

## 2. The 5-Step Gate Function
Before making any claim of success ("Done", "Fixed", "Tests pass"):
1. **IDENTIFY:** What exact terminal command proves this claim?
2. **RUN:** Execute the full command fresh in this turn:
   - **Tier 1 (Unit/Logic):** `node --test <path>` or `npm test -- <path>`
   - **Tier 2 (Typecheck/Build):** `npx tsc --noEmit` or `npm run build`
   - **Tier 3 (Non-Blocking Smoke Check):** Check active ports via `lsof -i :<port>` and test via `curl -s -i` (never run `npm run dev` in the foreground where it hangs).
3. **READ:** Read the full terminal output, check the exit code, and count failures.
4. **VERIFY:** Does the output confirm the claim?
   - **If NO:** State the actual status with the actual error output.
   - **If YES:** State the claim WITH the evidence.
5. **ONLY THEN:** Conclude the task.

## 3. Red Flags & Rationalization Prevention Table

| Common LLM Excuse / Rationalization | Reality & Mandatory Rule |
| :--- | :--- |
| *"Should work now"* / *"Probably fixed"* | **STOP.** Run the verification command first. |
| *"I'm confident"* / *"It's a 1-line change"* | Confidence ≠ evidence. 1-line changes break builds constantly. |
| *"Linter passed, so it compiles"* | Linters do not check types or runtime behavior. Run the test/build. |
| *"Tests passed earlier in the session"* | Any edit after the last test run invalidates that run. Run it fresh. |
| *"No test server is running"* | Explicitly state: `"ยังไม่ได้รันทดสอบในส่วน Runtime Server เนื่องจาก..."` |

## 4. Required Reporting Format
```markdown
### ✅ สรุปผลการดำเนินงานและหลักฐานการตรวจสอบ
- **สิ่งที่แก้ไข:**
  - `path/to/file.ext:LXX`: [สรุปการแก้ไขแบบ Surgical 1–2 บรรทัด]
- **หลักฐานการตรวจสอบสด (Fresh Verification):**
  - **Command:** `<คำสั่งที่รันจริง>`
  - **Output:** `<ผลลัพธ์จริง เช่น pass X, fail 0 (Exit Code: 0)>`
  - **Unverified Scope:** `<ระบุตรงๆ หากส่วนใดยังไม่ได้รันทดสอบ>`
```
