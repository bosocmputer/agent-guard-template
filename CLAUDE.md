# Project Overview & Universal Agent Governance (v3 — Slim Safety & Memory Harness)
> **Communication Mandate:** Always respond to the user in **Thai (ภาษาไทย)**, keeping technical terms, file paths, commands, and code identifiers in English.

## 0. Auto-Detect Tech Stack & Verification Commands
Inspect root manifest files (including monorepo subfolders) to run the exact Tier 1 (scoped) and Tier 2 (full) checks:

| Tech Stack / Manifest | Tier 1: Scoped Test (During edits) | Tier 2: Typecheck / Lint / Build |
| :--- | :--- | :--- |
| **Node.js / TypeScript** (`package.json`) | `node --test <path>` or `npm test -- <path>` | `npx tsc --noEmit` \| `npm run lint` \| `npm run build` |
| **Go** (`go.mod`) | `go test -v ./path/to/pkg -run <TestName>` | `go vet ./...` \| `go build ./...` |
| **Flutter / Dart** (`pubspec.yaml`) | `flutter test test/<file>_test.dart` | `flutter analyze` |
| **Supabase / PostgreSQL** (`supabase/config.toml`) | `supabase test db` (local Docker) | `supabase db reset` (local Docker only) |
| **Python** (`pyproject.toml` / `requirements.txt`) | `pytest <path/to/test_file.py>` | `ruff check .` \| `mypy .` |
| **Rust** (`Cargo.toml`) | `cargo test <test_name>` | `cargo check` \| `cargo clippy` |

- Never run long-lived foreground dev servers (`npm run dev`, `go run`, `flutter run`) in the agent shell; inspect ports via `lsof -i :<port>` instead.

---

## 1. Native Subagent Delegation & Quota Discipline
- Use each engine's native subagents (`Agent` in Claude Code / `invoke_subagent` in Antigravity) naturally — never pass `model="opus"` to a subagent (use `model="sonnet"` for workers).
- **Pre-Mapped Fast Path (Skip Explorers ONLY, NOT Workers):** When target files/lines are already given in the prompt, skip explorer subagents, **but for `>= 6` files or `>= 2` independent modules/tracks, MUST delegate parallel worker subagents (`2–4` `model="sonnet"` workers)** so the main Opus window stays `<= 20` turns instead of burning 50+ turns at high context. Stay within **`<= 4` subagents per prompt**.
- **6-Turn Investigation / SSH Ceiling:** Batch remote checks (`ssh`/`docker`/`psql`/`gh`) into 1–2 compound commands; if tracing exceeds 6 calls without a fix, stop and delegate to a fresh subagent.
- **One Slice Per Prompt:** Complete the requested slice, verify with fresh terminal output, report, and stop.

---

## 2. Integrity, Git Safety & Security (Enforced by 0-Token Hooks)
- **Secrets & Host Credentials:** Never read, print, edit, or commit `.env*` (root or subfolders), `*.key`, `*.pem`, `*.sqlite`, `*.db`, `~/.ssh`, `~/.aws`, `~/.kube`, or `.git/hooks/*`.
- **Non-Destructive Git:** Never run `git reset --hard`, `git checkout .`, `git checkout -- <file>`, `git restore`, `git clean -f`, or `git push --force`. Revert mistakes with targeted `Edit`.
- **Production & Template Gates:** Never push new SQL migrations to `main`/`master` before Production DB application (`MIGRATION_PROD_VERIFIED=1`), never stage local template files (`AGENTS.md`, `CLAUDE.md`, `TASK_STATE.md`) into consumer repos (`ALLOW_TEMPLATE_COMMIT=1`), and never pass secrets on CLI args (`docker login -p`, `$(gh auth token)`).
- **2-Strike & Anti-Test-Tampering:** Stop and escalate after 2 failed fix attempts on the same error; never weaken or `.skip` existing tests to fake a pass.

---

## 3. Evidence-Based Reporting (No Over-Claiming) & No Ceremony Overhead
- Claim only what was actually run and verified in this turn (exact command + pass/fail output). State explicitly anything not tested or unverified.
- Never use exaggerated claims ("100% bug-free", "perfect") or invent data/specs (stop with `CIRCUIT_BREAKER: MISSING_SPEC` if a business formula is undefined).
- Keep responses concise and end multi-file / feature / deploy tasks with `### ⏭️ ขั้นตอนถัดไป (Next Steps)` (1–3 actionable items), then **MUST** run `bash .claude/hooks/audit-session-proof.sh --brief` and **append its 4-line `### 📊 ผลชี้วัด Agent Guard Template` output verbatim at the bottom of your final response** (skip only on pure Q&A or trivial 1–2 line edits).

---

## 4. Cross-Engine Memory (`TASK_STATE.md` & `.claude/rules/project-pitfalls.md`)
- Update `TASK_STATE.md` (`<= 20 lines`, `<= 2,500 bytes` above the `Auto-Synced` marker) on milestones or before `/compact` (Antigravity) / `/clear` (Claude Code) so switching between Claude Code and Antigravity resumes seamlessly on `"ทำต่อ"`.
- Distill real blockers/bugs/corrections into 1 concise line (`<= 180 chars`, max 30 rules) in `.claude/rules/project-pitfalls.md`.
- Detailed domain rules load automatically from `.claude/rules/` (`guard-core.md`, `code-simplicity.md`, `execution-discipline.md`, `testing-and-api.md`, `ui-anti-slop.md`, `project-pitfalls.md`) and `.claude/skills/`.
