# 🛡️ Agent Guard Template

[![Agent Guard CI](https://github.com/bosocmputer/agent-guard-template/actions/workflows/ci.yml/badge.svg)](https://github.com/bosocmputer/agent-guard-template/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-emerald.svg)](LICENSE)
[![Engines: Claude Code + Antigravity IDE](https://img.shields.io/badge/Engines-Claude%20Code%20%7C%20Antigravity%20IDE-6366f1)](CLAUDE.md)
[![Zero-Dependency Hooks](https://img.shields.io/badge/Hooks-0--Token%20Bash%2FPython-f59e0b)](.claude/hooks/)

> **🇬🇧 English Summary (For Global Developers):**
> **Agent Guard Template (v3 — Slim Production Safety & Memory Harness)** is a lightweight, zero-dependency **Safety, Circuit-Breaker & Cross-Engine Memory Harness** for **Claude Code** and **Antigravity IDE** (Single Source of Truth in `.claude/`).
> - **Built for Native Subagents (Zero Duplication):** Modern Claude Code & Antigravity IDEs already orchestrate native subagents natively. v3 removes redundant custom agent definitions and heavy 3D HUD/telemetry bloat (`-6,642 lines` / `-74%` `CLAUDE.md` size) and focuses purely on what IDEs still don't enforce for you.
> - **0-Token OS, Git & Production Safety Shields:** Deterministic Bash/Python hooks (`24ms` Read Fast-Path) block nested `.env*`/credential reads, `git reset --hard`, `git push` of unapplied SQL migrations to `main`, accidental template-file commits, CLI token leaks, unapproved deps, test-tampering during bug fixes, and stuck read/test loops (`exit 2`).
> - **Zero-Prompt Cross-Engine Handoff & Pitfall Memory:** Auto-syncs git/session state into `TASK_STATE.md` (with stale-Objective detection & 100t/120t Survival Mode), tracks 5-hour rolling burn across both Claude Code & Antigravity, and distills project-specific lessons into `.claude/rules/project-pitfalls.md`.

**🇹🇭 ระบบเกราะป้องกันความปลอดภัยและหน่วยความจำข้ามค่ายสำหรับ AI Coding Agent (`v3 — Slim Safety & Memory Harness`) รองรับทั้ง `Claude Code` และ `Antigravity IDE` — ปล่อยให้แต่ละค่ายใช้ Native Subagents ได้เต็มที่ แล้วโฟกัสเฉพาะสิ่งที่ค่ายยังทำให้ไม่ได้: 0-Token Security/Production Gates, ตัวตัดลูปกันเผาโควต้า, ส่งต่องานข้ามค่าย (`TASK_STATE.md`) และความจำระยะยาวเฉพาะโปรเจกต์ (`project-pitfalls.md`)**

ออกแบบตามหลัก **Single Source of Truth (`.claude/` จุดเดียว)**, **No Over-Claiming (รายงานตามจริงพร้อมหลักฐานเทสต์)**, และ **No Ceremony Overhead (ตัดไขมันและไฟล์ซ้ำซ้อนออกหมด)**

---

## 📈 ผลลัพธ์จากการใช้งานจริงบน Production (Verified Benchmarks)

ตัวเลขจริงจากการวัดผลบนระบบ ERP/OMS ระดับ Production (`Next.js 16 + Supabase`, `Go + React 18 + PostgreSQL`):

| ตัวชี้วัด (Metric) | ก่อนใช้ / เวอร์ชัน v2 เดิม | หลังใช้ `agent-guard-template` (v3 Slim) | ผลลัพธ์ที่ได้ |
| :--- | :---: | :---: | :---: |
| **จำนวนรอบรวมต่อ 1 ฟีเจอร์ใหญ่ (Full-Stack + CI + QA)** | `392 รอบ` | **`66 รอบ`** (`Parent 12` + `Subagents 54`) | ⚡ **ลดลง 83.2%** |
| **การตรวจหน้าเว็บจริงด้วย Playwright MCP** | `120 รอบ` (`8.67M tokens`) | **`11 รอบ`** (Batching + Turn Reserve) | 🎯 **ลดลง 90.8%** |
| **ขนาด Context ต่อรอบในหน้าต่างหลัก** | `234,820 tokens/turn` | **`83,109 – 94,653 tokens/turn`** | 💰 **ประหยัดโควต้า 60–65%** |
| **ขนาดไฟล์กฎหลัก `CLAUDE.md` (โหลดทุกรอบ)** | `17.4 KB` (v2) | **`4.4 KB`** (v3 Slim) | 🪶 **เล็กลง 74%** |
| **ขนาด `telemetry-tracker.sh` + `.telemetry.json`** | `88 KB` (`1,560` บรรทัด) / `325 KB` | **`11.5 KB`** (`228` บรรทัด) / **`< 1 KB`** | 🧹 **ตัดโค้ดส่วนเกิน 87%** |
| **ความหน่วงของ Read Hook (`PreToolUse:Read`) ต่อครั้ง** | `0.211s` (`211ms` บูต Python ทุกครั้ง) | **`0.024s`** (`24ms` Zero-Python Fast-Path) | 🚀 **เร็วขึ้น 8.8× (-89%)** |
| **ชุดทดสอบอัตโนมัติ (`tests/test-hooks.sh` + Python `unittest`)** | `33 เคส` | **`52 / 52 ผ่าน (0 failed)`** *(รวม 5 unit tests ของ `guard_helpers.py` + 4 เคส Antigravity telemetry)* | ✅ **ผ่านครบ** |

---

## ✂️ ทำไม v3 ถึงตัดส่วนซ้ำซ้อนออก? (v3 Slim Architecture Rationale)

เมื่อทั้ง **Claude Code** และ **Antigravity IDE** พัฒนาระบบ Native Subagents (`Agent` / `invoke_subagent` / worktree / `/teamwork`) และหน้าจอสถานะในตัวได้เก่งขึ้นแล้ว เราจึงทบทวนทุกไฟล์จากข้อมูลการใช้งานจริงและปรับลดโครงสร้างลง **`-6,642` บรรทัด (~2.1 MB)** ด้วยเหตุผลชัดเจน 4 ข้อ:

| สิ่งที่เปลี่ยนใน v3 | เหตุผลจากการใช้งานจริง | ผลลัพธ์ที่ได้ |
| :--- | :--- | :--- |
| **1. ลบ `.claude/agents/*.md` และ `model-routing.md`** | ค่ายมี Native Subagent ในตัวอยู่แล้ว การเขียนกฎบังคับแตก `explorer`/`implementer` แบบแข็งตัวใน v2 ทำให้ AI แตก `Explorer` 3–4 ตัวซ้ำซ้อนจนเกิด `TOKEN_BURST_WARNING` (`7–13M tokens`) แม้ Prompt จะระบุไฟล์เป้าหมายชัดแล้ว | ปล่อยให้ค่ายใช้ Native Subagents ตามธรรมชาติ + คุมแค่ **Pre-Mapped Fast Path** (ข้ามสำรวจเมื่อรู้ไฟล์ชัด) และเพดาน **`<= 4` subagents/คำสั่ง** |
| **2. ลบ 3D Voxel HUD (`open-hud.sh`, `.claude/hud/`, `docs/screenshots/`) และย่อ `telemetry-tracker.sh` (`88 KB → 10 KB`)** | IDE แสดงสถานะ Subagent ใน UI แล้ว การรันสคริปต์ `1,560` บรรทัดสแกนไฟล์ทุกครั้งที่อ่านโค้ดทำให้เสียดีเลย์สะสม (`211ms/read` ≈ `17.6 นาที` ต่อ 5,000 reads) และ `.telemetry.json` บวมถึง `325 KB` | Read Hook เหลือ **`24ms` (เร็วขึ้น 8.8×)**, `.telemetry.json` เล็กลงเหลือ **`< 1 KB`** (คงตัวบล็อก `.env`, `strikeCount`, และ Survival Mode ครบ 100%) |
| **3. ย่อ `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` (`17.4 KB → 4.4 KB`)** | ลด Base Input Tokens ที่ถูกโหลดซ้ำทุก Turn และย้ายเช็กลิสต์ Self-Audit ของ UI (`<=974px`, post-mutation refresh) กับ SQL (`qty=0` edge simulation) ไปไว้ใน `ui-anti-slop.md` และ `testing-and-api.md` ที่โหลดเฉพาะตอนแตะไฟล์ตรงโดเมน | ประหยัด Context ทุกรอบทุกแชทโดยไม่สูญเสียมาตรฐานคุณภาพ |
| **4. คงแก่นแท้ 4 ชั้นที่ IDE ยังทำแทนไม่ได้** | ต่อให้ Subagent ของค่ายเก่งแค่ไหน ก็ยัง **ไม่มี** (1) **0-Token OS/Git/Production Hooks** ที่บล็อกจริงแม้โมเดลเบลอ (บล็อกคำสั่งผิดกฎจริงไปแล้ว `100+` ครั้งในงาน Production), (2) **Cross-Engine Handoff** ข้ามค่าย (`Claude Code ⇄ Antigravity`), (3) **Sticky Read-Loop & 2-Strike Circuit Breakers**, และ (4) **Project Pitfalls Memory** ที่จำบทเรียนเฉพาะโปรเจกต์ข้ามแชท | ได้เกราะป้องกัน Production เต็ม 100% ด้วยน้ำหนักโค้ดที่เบาและดูแลรักษาง่ายกว่าเดิมมาก |

---

## 🎯 ทำไมต้องใช้ Template นี้? (ปัญหาที่แก้ได้จริง)

| ปัญหาที่พบบ่อยเมื่อใช้ AI เขียนโค้ดแบบเปล่าๆ | กลไกของ `agent-guard-template` |
| :--- | :--- |
| 💸 **หน้าแชทหลักตันไว & เปลืองโควต้า:** สั่งงานใหญ่ทีไร AI กวาดอ่านไฟล์และรันเทสต์วนลูปในหน้าต่างหลักจนโควต้าหมดกลางคัน | 🤖 **Native Subagent Discipline (ลดภาระหน้าต่างหลัก 50–70%):** ปล่อยให้ Claude Code (`Agent`) และ Antigravity (`invoke_subagent`) แตก Native Subagents สำหรับงานหลายไฟล์ (`3+ ไฟล์`) โดยคุม **Pre-Mapped Fast Path** (ข้ามสำรวจเมื่อรู้ไฟล์ชัด) และเพดาน **`<= 4` subagents/คำสั่ง** |
| 🔄 **ต้องคอยแก้ไฟล์กฎ 2 ที่ (`.claude/` กับ `.agents/`):** เวลาปรับกฎหรือจดบทเรียนต้องตามแก้ทั้งสองค่ายจนข้อมูลไม่ตรงกัน | 🔗 **Single Source of Truth (`.claude/` Master):** เก็บกฎย่อยและทักษะต้นฉบับไว้ที่ `.claude/` จุดเดียว ส่วน `.agents/` ใช้ตัวชี้ `@[...]` และ `.agents/skills.json` ดึงไปใช้อัตโนมัติ (โดยมี `AGENTS.md` / `GEMINI.md` ที่ root เป็น Mirror ของ `CLAUDE.md` เพื่อให้ทุก IDE อ่านครบ) |
| 🔁 **เดาแก้บั๊กมั่ว & แอบแก้เทสต์หนีบั๊ก:** ลองแก้สุ่มวนไป 10 รอบ หรือแอบลบ `expect` ในไฟล์เทสต์เพื่อให้เทสต์ผ่านหลอกๆ | 🛑 **2-Strike Circuit Breaker & Stage 4 Test Lock:** หากแก้บั๊กครบ 2 ครั้งแล้วยังไม่ผ่านจะบังคับหยุดและย้อนโค้ดกลับด้วย `Edit` ทันที และระหว่างซ่อมบั๊ก สคริปต์ยามจะบล็อกไม่ให้ AI แอบแก้ไฟล์เทสต์เดิม (`exit 2`) |
| 🧠 **ลืมข้อตกลงเดิมเมื่อเปิดแชทใหม่:** พอขึ้นแชทใหม่ AI ก็ทำผิดจุดเดิมซ้ำ (เช่น หน่วยเงินสตางค์, สิทธิ์ RLS, หรือวิธีรันเทสต์) | 📝 **Self-Learning Pitfall Memory (`project-pitfalls.md`):** สกัดบทเรียนจาก `[BLOCKER]` และคำสั่งสอนของคุณเก็บเป็นกฎบรรทัดเดียวใน `.claude/rules/project-pitfalls.md` อัตโนมัติ และไม่ถูกเขียนทับเวลาอัปเดต Template |
| 🐘 **โค้ดบวม & คำอ้างเกินจริง:** แก้ปุ่มเดียวแต่รื้อไฟล์ข้างเคียงมาเพียบ หรืออ้างว่า *"เสร็จสมบูรณ์ 100%"* ทั้งที่ไม่ได้รันเทสต์ | ✂️ **Surgical Diffs + No Over-Claiming & Next Steps:** แก้เฉพาะบรรทัดที่สั่ง รายงานผลพร้อมคำสั่งเทสต์จริง สรุป `### ⏭️ ขั้นตอนถัดไป` (1–3 ข้อ) และแสดงตารางพิสูจน์ผล `### 📊 ผลชี้วัด Agent Guard Template` ท้ายงาน |
| 🔌 **โควต้าตัดกลางอากาศ:** กำลังทำค้างใน Claude Code แล้วโควต้าเต็ม ต้องมานั่งพิมพ์เล่าใหม่ใน Antigravity IDE | 🏃 **Auto-Handoff ข้ามค่าย:** บันทึกจุดแก้ล่าสุดลง `.agent-last-state.log` ทุกครั้งที่แก้ไฟล์ พอสลับไปเปิดอีกค่าย แค่พิมพ์ว่า *"ทำต่อจากที่ค้างไว้"* ก็ลุยต่อได้ทันที |

---

## 🚀 วิธีติดตั้งและอัปเดต (ใช้เวลาไม่ถึง 1 นาที)

> **Zero-Dependency:** ไม่ต้องรัน `npm install` หรือ `pip install` ลงในโปรเจกต์ ใช้เพียง `bash`, `git`, และ `python3` มาตรฐานที่มีติดเครื่อง macOS / Linux / WSL อยู่แล้ว

### วิธีที่ 1: เริ่มโปรเจกต์ใหม่
```bash
git clone https://github.com/bosocmputer/agent-guard-template.git my-project
cd my-project
chmod +x .claude/hooks/*.sh
```

### วิธีที่ 2: นำไปติดตั้งหรืออัปเดตในโปรเจกต์ที่มีอยู่แล้ว (`rsync` One-Liner)
รันคำสั่งนี้ที่โฟลเดอร์นอกสุดของโปรเจกต์ เพื่อติดตั้งหรืออัปเดตไฟล์มาตรฐานของ Template โดย**เก็บรักษาบทเรียนเฉพาะโปรเจกต์ (`.claude/rules/project-pitfalls.md`) และสถิติ (`.telemetry.json`) เดิมไว้ครบถ้วน**:

```bash
rm -rf /tmp/agt-update
git clone --depth 1 https://github.com/bosocmputer/agent-guard-template.git /tmp/agt-update
rsync -av --exclude='.git' --exclude='README.md' --exclude='LICENSE' --exclude='tests' --exclude='.github' --exclude='docs' --exclude='.mcp.json' --exclude='.gitignore' --exclude='TASK_STATE.md' --exclude='.agent-last-state.log' --exclude='.telemetry.json*' --exclude='.read_buf.cnt*' --exclude='__pycache__' --exclude='.quota_cache.json*' --exclude='.task-state-archive.md' --exclude='/.claude/rules/project-pitfalls.md' /tmp/agt-update/ ./
[ -f .claude/rules/project-pitfalls.md ] || cp /tmp/agt-update/.claude/rules/project-pitfalls.md .claude/rules/project-pitfalls.md
rm -rf /tmp/agt-update .agents/skills .claude/hud .claude/hooks/open-hud.sh .claude/agents .claude/rules/model-routing.md .agents/rules/model-routing.md
chmod +x .claude/hooks/*.sh
```
> **หมายเหตุสำหรับโปรเจกต์ที่มี `CLAUDE.md` / `AGENTS.md` เฉพาะของตัวเอง:** ให้เติม `--exclude='CLAUDE.md' --exclude='AGENTS.md'` ในคำสั่ง `rsync` ด้านบน (กฎแกนกลางทั้งหมดยังทำงานอัตโนมัติผ่าน `.claude/rules/guard-core.md` และ `.agents/rules/guard-core.md`)

### โหมดความเข้มงวด (`strict` vs `relaxed`) และสคริปต์เสริม `0-Token`
- **สลับโหมดสำหรับช่วงปั้น Prototype วันแรก (`AGENT_GUARD_MODE=relaxed`):**
  - ค่าเริ่มต้นคือ `strict` (บังคับถามก่อนลง Package ใหม่ และล็อกไม่ให้แก้ไฟล์เทสต์เดิมขณะซ่อมบั๊ก)
  - หากกำลังทดลองปั้น Prototype เร็วๆ สามารถรัน `echo relaxed > .agent-guard-mode` (หรือตั้ง `export AGENT_GUARD_MODE=relaxed`) เพื่อปลดล็อกการลง Package และการแก้ไฟล์เทสต์ชั่วคราว โดยที่ระบบป้องกันไฟล์ความลับ `.env` และคำสั่งลบ Git (`reset --hard`) ยังทำงานเต็ม 100%
- **สร้างโพยสรุปงาน / PR Changelog อัตโนมัติแบบ `0-Token`:**
  ```bash
  bash .claude/hooks/release-summary.sh
  ```
- **รันชุดทดสอบสคริปต์ยาม (Hook Regression Test Suite — 52 เคส รวม 5 Python Unit Tests):**
  ```bash
  bash tests/test-hooks.sh
  ```

---

## 📂 โครงสร้างไฟล์ (`Single Source of Truth` — แก้ที่ `.claude/` จุดเดียว)

```text
project-root/
├── CLAUDE.md                                   # 🧠 กฎหลักต้นฉบับ (Single Source of Truth สำหรับทั้ง Claude Code & Antigravity)
├── AGENTS.md                                   # 🪞 Full Mirror ของ CLAUDE.md สำหรับ Antigravity / VS Code / Codex / Cursor
├── GEMINI.md                                   # 🪞 Full Mirror ของ CLAUDE.md เพื่อให้เครื่องมือที่ไม่อ่าน @[...] โหลดกฎครบถ้วน
├── .mcp.json                                   # ตั้งค่า MCP (เริ่มต้นเป็นค่าว่างเพื่อประหยัด Context)
├── .gitignore                                  # ป้องกันไฟล์ความลับและไฟล์สถานะชั่วคราวขึ้น Git
│
├── .agents/                                    # ⚡ ตัวชี้สำหรับ Antigravity IDE (ไม่ต้องตามแก้ไฟล์ในโฟลเดอร์นี้)
│   ├── hooks.json                              # ผูก Lifecycle Hooks ไปรันสคริปต์ใน .claude/hooks/
│   ├── skills.json                             # ชี้โฟลเดอร์ Skills ไปที่ {"entries": [{"path": ".claude/skills"}]}
│   └── rules/                                  # ตัวชี้กฎพร้อม Frontmatter มาตรฐาน Antigravity (trigger: always_on / glob)
│       ├── guard-core.md                       # @[guard-core](../../.claude/rules/guard-core.md) — กฎแกนกลางทำงานอัตโนมัติแม้ CLAUDE.md เป็นไฟล์เฉพาะโปรเจกต์
│       ├── execution-discipline.md             # @[execution-discipline](../../.claude/rules/execution-discipline.md)
│       ├── project-pitfalls.md                 # @[project-pitfalls](../../.claude/rules/project-pitfalls.md)
│       ├── code-simplicity.md                  # @[code-simplicity](../../.claude/rules/code-simplicity.md)
│       ├── testing-and-api.md                  # @[testing-and-api](../../.claude/rules/testing-and-api.md)
│       └── ui-anti-slop.md                     # @[ui-anti-slop](../../.claude/rules/ui-anti-slop.md)
│
└── .claude/                                    # 🤖 แหล่งข้อมูลต้นฉบับ (v3 Slim Safety & Memory Harness)
    ├── settings.json                           # สิทธิ์คำสั่งปลอดภัย + deny .env ทั้ง root และ subfolder (./**/.env*) + ผูก Hooks
    ├── rules/                                  # กฎต้นฉบับ 6 ไฟล์ (ใช้ Native Subagents ของแต่ละค่ายโดยไม่ต้องเขียน custom agent ซ้ำ)
    │   ├── guard-core.md                       # กฎแกนกลาง Universal (Native Subagent Budget <=4, Pre-Mapped Fast Path, SSH/Ops Ceiling, Migration & Template-Commit Gates, Auto-Handoff)
    │   ├── execution-discipline.md             # ส่งต่องาน State-Delta (<=8 บรรทัด), Grep ก่อนอ่านเฉพาะบรรทัด (>200 บรรทัด) & ห้าม git reset/restore
    │   ├── project-pitfalls.md                 # ความจำระยะยาวเฉพาะโปรเจกต์ตามหลัก The Ratchet Pattern (สกัดอัตโนมัติ สูงสุด 30 ข้อ)
    │   ├── code-simplicity.md                  # กฎ Karpathy: คิดก่อนทำ, เรียบง่ายที่สุด, แก้เฉพาะจุด, ไม่สร้างไฟล์ขยะ
    │   ├── testing-and-api.md                  # บังคับเทสต์โค้ดจริง (Verify RED ➔ GREEN), SQL trigger edge-case simulation & ตรวจสิทธิ์ BOLA/IDOR
    │   └── ui-anti-slop.md                     # มาตรฐานออกแบบ UI 10 ด้าน (lucide, tabular-nums, 1280×800 <=974px width & post-mutation refresh Self-Audit)
    ├── skills/                                 # ตำราเฉพาะทาง 9 ตัว (โหลดเฉพาะเมื่อตรงกับงาน — Progressive Disclosure)
    │   ├── auto-resume-handoff/SKILL.md        # กู้คืนงานค้างอัตโนมัติเมื่อสลับค่ายหลังโควต้าเต็ม
    │   ├── common-ground/SKILL.md              # สกัดสมมติฐาน 3–4 ข้อมาถามก่อนทำฟีเจอร์ที่คลุมเครือ
    │   ├── db-migration/SKILL.md               # กฎสร้าง SQL Migration แบบ Zero-Downtime, RLS & SECURITY DEFINER
    │   ├── pragmatic-review/SKILL.md           # รีวิวเฉพาะจุดตาย [BLOCKER] จบภายในไม่เกิน 2 รอบ
    │   ├── root-cause-debug/SKILL.md           # ซ่อมบั๊ก 4 ขั้นตอนภายใต้เบรกเกอร์ 0-Strike / 2-Strike
    │   ├── security-audit/SKILL.md             # ตรวจความปลอดภัยเชิงลึก entrypoint ➔ sink (Cloudflare Protocol)
    │   ├── tech-stack-skills/SKILL.md          # ดึงเฉพาะเครื่องมือจัดการเอกสาร/เวิร์กโฟลว์ (pdf, xlsx, webapp-testing, mcp-builder)
    │   ├── threejs-expert/SKILL.md             # มาตรฐาน Three.js r187+ (three/addons/*, OutputPass, dispose)
    │   └── verification-before-completion/     # กฎเหล็กห้ามส่งงานโดยไม่รันเทสต์สด & ดักจับ 0 tests ran
    ├── commands/                               # คำสั่งลัด (/plan, /common-ground, /fix, /review, /security-audit, /verify, /learn, /handoff)
    └── hooks/                                  # 🛡️ สคริปต์ยามรักษาความปลอดภัย 0-Token (ทำงานทั้ง Claude Code & Antigravity)
        ├── lib/
        │   └── guard_helpers.py                # โมดูล Python กลางที่เขียน Unit Test ได้ (Template-Commit Guard, Subagent Counter Reconciliation, Antigravity 5hr Burn, Stale Objective)
        ├── auto-resume.sh                      # ฉีดสถานะงานค้างตอนเปิดแชทใหม่ (SessionStart) และบันทึกความจำก่อนย่อแชท (PreCompact)
        ├── validate-bash.sh                    # บล็อก rm -rf, git restore/reset, CLI token leak, ลง pkg มั่ว, Migration-Before-Main และ Template-Commit Guard
        ├── protect-sensitive-files.sh          # บล็อกการแก้ .env/.key, lockfiles & บล็อกการแอบแก้ไฟล์เทสต์เดิมขณะซ่อมบั๊ก
        ├── loop-circuit-breaker.sh             # ตัดวงจรเมื่อรันคำสั่งเทสต์/บิลด์ซ้ำเกิน 3 ครั้ง หรืออ่าน/ค้นโค้ดวนเกิน 14 ครั้งโดยไม่แก้ไฟล์ (Sticky + แยกตาม Actor)
        ├── post-edit-format.sh                 # จัด Format อัตโนมัติ + บันทึก Checkpoint + ล้างตัวนับลูปเฉพาะ Actor เมื่อแก้โค้ดจริง
        ├── telemetry-tracker.sh                # Slim ~220 บรรทัด: Read Secret Guard + Zero-Python Fast-Path (~24ms) + state <1KB + คง agSessions & auto-resolve Antigravity transcript + Engine-Aware Nudge/Survival Mode
        ├── audit-session-proof.sh              # สแกน .jsonl (ทั้ง Claude Code & Antigravity) วัด Context จริง (input_tokens + cache_read_tokens), 5hr Burn, Hooks, Stale Objective และเตือนแยกตามค่าย (/compact vs /clear)
        ├── release-summary.sh                  # สร้างโพยสรุปงาน / PR Changelog อัตโนมัติแบบ 0-Token จาก git log
        └── install-skill.sh                    # ดึง Skill เสริมเฉพาะทางลง .claude/skills/ แบบ Sparse Checkout

tests/
├── test-hooks.sh                               # ชุดทดสอบ Regression 52 เคส (Bash Hooks + Security + Migration + Template-Commit + Read Fast-Path + Antigravity Telemetry)
└── test_guard_helpers.py                       # Python unittest 5 เคสสำหรับ .claude/hooks/lib/guard_helpers.py
```

---

## 🧠 เจาะลึก 6 กลไกหลักของระบบ

### 1. การใช้ Native Subagents อย่างมีวินัย & คุมเพดานโควต้า (`Native Subagent Discipline`)
ใน v3 เราปล่อยให้ **Claude Code (`Agent`)** และ **Antigravity (`invoke_subagent`)** แตก Native Subagents ตามธรรมชาติ โดยคุมเฉพาะ 4 กฎที่ช่วยประหยัดโควต้าจริง:
* **งานแก้จุดย่อยที่รู้พิกัดอยู่แล้ว (`1–2 ไฟล์`, `<= 6 รอบ`):** แก้ตรงๆ ด้วย `Edit` และมัดรวมคำสั่ง `ssh`/`docker`/`psql`/`gh` เป็น `1–2` คำสั่งต่อรอบ โดยมี **เพดานดีบัก & SSH/Ops 6 รอบ** — ถ้าไล่ล็อกหรือดีบักเกิน 6 ครั้งแล้วยังไม่จบ ให้โยนให้ Subagent สดช่วยวิเคราะห์ต่อทันที
* **Pre-Mapped Fast Path & เพดาน `<= 4` Subagents/คำสั่ง:** หาก Prompt ระบุไฟล์และบรรทัดเป้าหมายชัดเจนอยู่แล้ว (หรือ ≤ 5 โมดูล) ให้ **ข้ามขั้นตอนแตก explorer** แล้วส่งให้ Subagent ลงมือแก้+รันเทสต์ตรงๆ พร้อมจำกัดไม่เกิน `4` Subagents/คำสั่ง เพื่อกัน `TOKEN_BURST_WARNING`
* **งานหลายไฟล์ (`3+ ไฟล์`):** แตก Native Subagent พร้อมขอบเขตไฟล์ไม่ทับซ้อนกัน (ห้ามส่ง `model="opus"` ให้ Subagent), ใช้ `Edit` แทน `Write` ทับไฟล์เดิม, และทำ **Pre-Return Self-Audit** (UI ตาราง `<=974px` + post-mutation refresh, SQL trigger edge-case simulation) ก่อนส่งกลับ
* **กฎประหยัด Token ตอนอ่านไฟล์ใหญ่ (`Grep First, Read Line-Range Second`):** สำหรับไฟล์ที่ยาวเกิน `200 บรรทัด` ให้ `Grep` หาเลขบรรทัดก่อนแล้วอ่านเฉพาะช่วงบรรทัดแทนการโหลดไฟล์เต็มซ้ำๆ

### 2. ยามรักษาความปลอดภัยเบื้องหลัง 0-Token (`.claude/hooks/*.sh`)
ทำงานด้วยสคริปต์ Bash/Python ก่อนและหลังการเรียกเครื่องมือของ AI โดยไม่เสีย Token (พร้อมการันตี Fail-Open สำหรับส่วน Telemetry):
1. **`validate-bash.sh` (Git, Dependency, Production & MITRE Execution/Exfiltration Gate):**
   * บล็อกคำสั่งทำลายงานค้าง เช่น `rm -rf`, `git reset --hard`, `git checkout .`, `git restore`, `git push --force` (แต่อนุญาตการสร้างและสลับกิ่ง `git checkout -b` / `git switch` ตามปกติ)
   * บล็อกการรันสคริปต์ภายนอกเข้าสู่ Shell โดยตรง (`curl/wget ... | sh/bash/python/node`), การพลางคำสั่ง (`base64 -d | sh`, `$IFS`), และการดึงค่า Environment Secrets ทั้งระบบด้วย `printenv` หรือ `env` เปล่าๆ
   * บล็อกการแอบอ่าน `.env*`/`*.key` ผ่านคำสั่ง Shell (`cat/grep/awk/sed`) และการแตะต้องโฟลเดอร์ Credential หรือ Shell Profile ของโฮสต์ (`~/.ssh`, `~/.aws`, `~/.kube`, `~/.zshrc`, `crontab`)
   * บล็อกการแอบติดตั้ง Package ใหม่ (`npm install`, `flutter pub add`, `go get`, `pip install`, `cargo add`) จนกว่าคุณจะอนุมัติ (`DEPS_APPROVED=1`)
   * บล็อกการส่งรหัสผ่าน/Token ผ่าน CLI args (`docker login -p/--password`, `echo/ssh $(gh auth token)`) โดยบังคับส่งผ่าน `--password-stdin`
   * บล็อกการสั่ง Deploy ขึ้น Production หรือยิง Migration ขึ้นฐานข้อมูลจริง (`vercel --prod`, `supabase db push`, `prisma migrate deploy`) รวมถึงบล็อก **`git push origin main` เมื่อมีไฟล์ SQL migration ใหม่ที่ยังไม่ยืนยันบน Prod DB** (รองรับทั้ง repo หลักและ `git -C <worktree>`, ปลดล็อกด้วย `MIGRATION_PROD_VERIFIED=1` หรือ `RELEASE_APPROVED=1` โดยยังอนุญาต `git push origin main:uat` / กิ่ง preview ตามปกติ) และอนุญาต `supabase db reset` บน Local Docker สำหรับรันเทสต์
   * **Template Local-State Commit Guard:** บล็อกการเผลอ `git add` ไฟล์เทมเพลตเฉพาะเครื่อง (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `TASK_STATE.md`) รวมถึง `git add .`/`-A` เมื่อไฟล์เหล่านั้นค้างแก้ในโปรเจกต์ปลายทาง (ปลดล็อกด้วย `ALLOW_TEMPLATE_COMMIT=1` และอนุญาตอัตโนมัติใน repo `agent-guard-template` เอง)
2. **`protect-sensitive-files.sh` & `telemetry-tracker.sh` (Secrets, Nested `.env*`, Zero-Python Read Fast-Path & Stage 4 Anti-Test-Tampering):**
   * ห้ามอ่านหรือแก้ไขไฟล์ `.env*` ทั้งที่ root และโฟลเดอร์ย่อย (`./**/.env*`), `*.key`, `*.pem`, `*.sqlite`, `*.db`, โฟลเดอร์ Credential ของโฮสต์ (`~/.ssh/*`, `~/.aws/*`, `~/.kube/*`, `~/.netrc`, `~/.npmrc`), Shell Profile (`~/.zshrc`, `~/.bashrc`), ไฟล์ `.git/config` / `.git/hooks/*` และไฟล์ Lockfile
   * **Zero-Python Read Fast-Path (`~24ms`, เร็วขึ้น `8.8×`):** สำหรับการอ่านไฟล์ซอร์สโค้ดปกติ (`Read|Grep|Glob`) จะตรวจความปลอดภัยใน Bash ล้วนและเก็บตัวนับใน `.claude/.read_buf.cnt` โดยไม่บูต Python ทุกครั้ง แล้วค่อย flush ลง `.telemetry.json` (`< 1 KB`) อัตโนมัติในรอบถัดไป
   * ขณะอยู่ในโหมดซ่อมบั๊ก (`strikeCount >= 1`) จะบล็อกไม่ให้ AI แอบแก้ไขไฟล์เทสต์เดิม (`*.test.*`, `*.spec.*`, `*_test.*`) บังคับให้แก้ที่โค้ดต้นเหตุเท่านั้น
3. **`post-edit-format.sh` & `loop-circuit-breaker.sh` (Command Repeat & Sticky Per-Actor Read-Loop Breaker):**
   * **Command Repeat Breaker:** ตัดวงจร (`exit 2`) เมื่อรันคำสั่งเทสต์/บิลด์เดิมซ้ำเกิน `3 ครั้ง` ในหน้าต่าง 6 คำสั่งล่าสุดโดยไม่แก้โค้ด
   * **Sticky Per-Actor Read-Loop Circuit Breaker:** นับคำสั่งอ่าน/ค้นไฟล์ต่อเนื่องแยกตาม `agent_id`/`session_id` + `pwd` (ไม่ชนกันเมื่อรัน Subagent ขนาน) หากเกิน `14 ครั้ง` โดยยังไม่เริ่มแก้ไฟล์จะบล็อกแบบ **Sticky** (คงตัวนับที่ `14` กันการยิง `grep`/`sed` ซ้ำทันที) จนกว่าจะมีการแก้ไฟล์จริง
   * **`post-edit-format.sh`:** จัด Format โค้ดอัตโนมัติหลังแก้ไฟล์ บันทึกจุดค้างงานลง `.agent-last-state.log` และล้างตัวนับลูปเฉพาะ Actor นั้นเมื่อแก้โค้ดจริง (ทำให้รันเทสต์ตรวจหลังแก้ไฟล์ได้ต่อเนื่องโดยไม่โดนบล็อกผิดพลาด)

### 3. ความจำระยะยาวเฉพาะโปรเจกต์ (`.claude/rules/project-pitfalls.md`)
AI จะสกัดบทเรียนสั้นๆ บรรทัดเดียว (`- **[หมวดหมู่]:** <สิ่งที่ต้องทำ/ห้ามทำ + เหตุผลสั้นๆ>`, สูงสุด 30 ข้อ) ลงใน `.claude/rules/project-pitfalls.md` อัตโนมัติใน 3 จังหวะ:
1. เมื่อซ่อมบั๊กหรือแก้ `[BLOCKER]` สำเร็จ
2. เมื่อคุณทักท้วงหรือสั่ง `/learn`
3. เมื่อจบ Milestone หรือสั่ง `/handoff`

### 4. นโยบายการลง Skill เสริมตามหลัก *SkillsBench* (`tech-stack-skills`)
* **ห้ามลง Skill สอนภาษา/เฟรมเวิร์กพื้นฐานอัตโนมัติ** (เช่น `react-expert`, `flutter-expert`, `python-pro`) เพราะโมเดลยุคใหม่มีความรู้ไวยากรณ์อยู่ใน Weights แล้ว การอ่านโค้ดจริงในโปรเจกต์ 1–2 ไฟล์คู่กับ `project-pitfalls.md` ให้ผลแม่นยำกว่าและไม่เปลือง Context
* ใช้คำสั่ง `bash .claude/hooks/install-skill.sh <ชื่อ-skill>` **เฉพาะเมื่อต้องการเครื่องมือจัดการเอกสารหรือเวิร์กโฟลว์เฉพาะทาง** จาก [`anthropics/skills`](https://github.com/anthropics/skills) เท่านั้น เช่น:
  ```bash
  bash .claude/hooks/install-skill.sh pdf xlsx docx pptx webapp-testing mcp-builder
  ```

### 5. มาตรฐานการส่งมอบงาน & ลวดสะดุดแจ้งเตือนอัตโนมัติ (`Next Steps` + `Harness Tripwires` ใน `audit-session-proof.sh --brief`)
ทุกครั้งที่ AI ส่งมอบงานเสร็จ จะปิดท้ายด้วย 2 ส่วนนี้เสมอ:
1. **`### ⏭️ ขั้นตอนถัดไป (Next Steps)` (1–3 ข้อกระชับ):** บอกชัดเจนว่าคุณต้องทำอะไรต่อ (เช่น มีไฟล์ Migration ใหม่ที่ต้องรัน `supabase db push`, จุดที่ควรเปิดตรวจบนหน้าเว็บ, หรือลำดับงานถัดไป) และ **หยุดรอคำสั่งถัดไป (One Slice Per Prompt — ห้ามรันลูกโซ่ข้ามขั้นเองจนโควต้าหมด)**
2. **`### 📊 ผลชี้วัด Agent Guard Template — เฉพาะคำสั่งนี้` (4 บรรทัดกระชับแบบ v3 แยกเฉพาะคำสั่งล่าสุด + ยอดสะสมทั้งแชท + `Harness Tripwires`):**
   ```markdown
   ### 📊 ผลชี้วัด Agent Guard Template — เฉพาะคำสั่งนี้ (Session `#7217c67b`)
   - **รอบทำงานคำสั่งนี้:** หน้าต่างหลัก `4` รอบ (ทำตรงไม่แตก Subagent เกินจำเป็น) *(สะสมทั้งแชท: หลัก 18 รอบ · Subagents 2 ตัว)*
   - **Hooks ที่ทำงานในคำสั่งนี้:** สแกนไฟล์ `5` ครั้ง | แก้ไฟล์+Checkpoint `7` ครั้ง | รันเทสต์ `1` ครั้ง | บล็อกผิดกฎ `0` ครั้ง | 2-Strike: `0/3` *(สะสมทั้งโปรเจกต์: สแกน 63, แก้ 71, เทสต์ 13)*
   - **ความจำ & ส่งต่องาน:** Pitfalls `7/30` (รอบนี้ไม่มีเพิ่มใหม่) | `TASK_STATE.md`: ✅ ซิงก์อัตโนมัติ (`main@2224d4d`)
   - **⚡ Harness Tripwires (Layer 6 SLA):** ✅ `ปกติ (No Behavioral Drift)` — รอบคำสั่ง `4/20` · สะสมหน้าต่างหลัก `18/80` · Context `42,000/150,000 tokens`
   ```
   *(หากหน้าต่างหลักสะสมเกิน 80 รอบ, คำสั่งเดียวรันเกิน 20 รอบ, หรือ Context เกิน 150k tokens บรรทัด `⚡ Harness Tripwires` จะเปลี่ยนเป็นป้ายเตือน `⚠️ CONTEXT_WINDOW_BLOAT` / `🚨 CONTEXT_TOKEN_BLOAT` / `⚠️ TURN_BUDGET_EXCEEDED` พร้อมคำแนะนำที่ตรงตามค่ายที่ใช้จริง: **`/compact` หรือเปิดแชทใหม่** สำหรับ Antigravity IDE และ **`/clear`** สำหรับ Claude Code — โดยวัด Context จริงจาก `input_tokens + cache_read_tokens` ของทั้งสองค่ายและตัด metric `Offload %` กับป้าย model-routing เก่าออกแล้วใน v3)*

### 6. ส่งต่องานข้ามค่ายเมื่อโควต้าตัดกลางอากาศ & กันความจำเสื่อมตอนย่อแชทอัตโนมัติ (`Zero-Prompt Resume + PreCompact Continuity Ledger`)
คุณสามารถสลับไปมาระหว่าง **Claude Code ⇄ Antigravity IDE** ได้ทันทีแม้ในจังหวะที่โควต้า 5 ชั่วโมงตัดกลางอากาศ (`You've hit your 5-hour limit`) โดย**แค่เปิดแชทใหม่แล้วพิมพ์สั้นๆ ว่า `"ทำต่อ"` หรือ `"ลุยต่อ"` คำเดียว**:
* **ชั้นที่ 1 (สรุปงานอัตโนมัติ + 0-Token Auto-Trim & Archive + Engine-Aware Survival Mode):** AI อัปเดตสถานะปัจจุบันไว้ด้านบนของ `TASK_STATE.md` (`<= 20 บรรทัด` และ `<= 2,500 bytes`) หากไฟล์เกิน `2,800 bytes` สคริปต์ `audit-session-proof.sh` จะเก็บเฉพาะสถานะล่าสุดและย้ายประวัติ deploy เก่าลง `.claude/.task-state-archive.md` อัตโนมัติแบบ `0-Token` เมื่อหน้าต่างหลักสะสม `100–119 รอบ` หรือ `>= 130k tokens` จะยิง **Auto-Handoff Nudge** แบบกระชับ (แนะนำ `/compact` หรือเปิดแชทใหม่บน Antigravity / `/clear` บน Claude Code) และหากทำต่อจนถึง **`>= 120 รอบ` หรือ `>= 150k tokens`** ระบบจะสลับเป็น **Survival Mode (Ultra-Thin Dispatcher)** โยนแม้แต่งานแก้ 1–2 ไฟล์ให้ Subagent ใหม่ทำแทนโดยไม่บ่นซ้ำ เพื่อประคองโควต้าให้ไปต่อได้ยาวๆ
* **ชั้นที่ 2 (แกะรอยงานที่โดนตัดกลางคันแบบ `0-Token` ใน `auto-resume.sh` & `audit-session-proof.sh`):** ทันทีที่คุณเปิดแชทใหม่ (`SessionStart`) สคริปต์จะไปอ่านท้ายไฟล์ `.jsonl` ของแชทล่าสุดที่เพิ่งดับไป ดึง **`Last User Prompt`** (โจทย์ที่คุณสั่งไว้), **`Last Agent Summary`** (สิ่งที่ตัวแม่ทำเสร็จไปแล้วก่อนดับ), และ **`Last Dispatched Subagent Task`** (คำสั่งที่ส่งให้ลูกน้องทำค้างไว้ก่อนโควต้าตัด) มาเขียนต่อท้าย `TASK_STATE.md` พร้อมกิ่งและ 5 คอมมิตล่าสุดให้อัตโนมัติ!
* **ชั้นที่ 3 (`PreCompact` Continuity Hook):** ก่อนที่ระบบจะสั่งย่อหน้าต่างความจำอัตโนมัติ (`/compact` หรือ Auto-Compaction) `auto-resume.sh --pre-compact` จะบังคับซิงก์ `TASK_STATE.md` ล่าสุดและฉีดเตือนให้ AI ยึด `TASK_STATE.md` + `project-pitfalls.md` เป็นหลักหลังย่อความจำ ป้องกันอาการความจำเสื่อมกลางแชท (`Post-Compaction Amnesia`)

---

## ⚡ ตารางคำสั่งลัด (ใช้ได้ทั้งใน Claude Code และ Antigravity IDE)

| คำสั่งลัด | ใช้เมื่อไหร่ | สิ่งที่เกิดขึ้นเบื้องหลัง |
| :--- | :--- | :--- |
| **`/plan <โจทย์>`** | ก่อนเริ่มงานใหญ่ที่ต้องแก้เกิน 3 ไฟล์ | ให้ Native Subagent สแกนหาพิกัดไฟล์และสรุปแผนสั้นๆ มาให้ตรวจอนุมัติก่อนแก้โค้ด |
| **`/common-ground <โจทย์>`** | ก่อนทำฟีเจอร์ใหม่ที่มีเงื่อนไขธุรกิจหลายแง่มุม | สกัดสมมติฐาน 3–4 ข้อและขอบเขตที่จะไม่ทำ (*YAGNI*) มาถามให้ตรงกันก่อนลงมือ |
| **`/fix <อาการบั๊ก>`** | เมื่อเทสต์พังหรือเจออาการบั๊ก | วิเคราะห์ต้นตอ 4 ขั้นตอน + ล็อกไฟล์เทสต์เดิม (`Stage 4`) + ตัดเบรกเกอร์เมื่อแก้ไม่ผ่านครบ 2 ครั้ง (`2-Strike`) |
| **`/review`** | เมื่อเขียนโค้ดเสร็จและต้องการตรวจก่อนส่ง | รีวิวเฉพาะ `[BLOCKER]` และช่องโหว่ความปลอดภัย (จบภายในไม่เกิน 2 รอบ) |
| **`/security-audit`** | เมื่อต้องการตรวจความปลอดภัยเชิงลึกก่อนปล่อยของ | หาพื้นผิวโจมตีและไล่เส้นทาง `entrypoint ➔ sink` ตามเกณฑ์ Cloudflare |
| **`/verify`** | ก่อนประกาศจบงานหรือปิด Milestone | รันเทสต์จริง + ตรวจ Type/Analyze + สรุป `Next Steps` และรัน `audit-session-proof.sh --brief` |
| **`/learn <บทเรียน>`** | เมื่อต้องการสั่งให้จำข้อตกลงเฉพาะโปรเจกต์ | บันทึกกฎสั้นๆ 1 บรรทัดลง `.claude/rules/project-pitfalls.md` (ไม่เกิน 30 ข้อ) |
| **`/handoff`** | ก่อนย่อ/ล้างแชท (`/compact` บน Antigravity หรือ `/clear` บน Claude Code) หรือสลับค่าย AI | สรุปสถานะงานค้างลง `TASK_STATE.md`, สกัดบทเรียนของรอบนั้นลง `project-pitfalls.md`, และแสดงผลชี้วัดประจำแชท |

---

## 📚 มาตรฐานและงานวิจัยอ้างอิง

* **Harness Engineering (*Agent = Model + Harness: The 6-Layer Production Playbook*, 2026):** สถาปัตยกรรม 6 ชั้น (*Guides, Computational vs. Inferential Sensors, Capability Budgets, 4-Tier Externalized Memory, Graduated Permissions, และ Layer 6 Behavioral Drift Tripwires*) รวมถึง *The Ratchet Pattern* ของ Mitchell Hashimoto (Ghostty)
* **[Anthropic AI-Native SDLC Playbook](https://claude.com/resources/articles/the-ai-native-sdlc-playbook) & [`anthropics/skills`](https://github.com/anthropics/skills):** กลไก *Stage 3 Pitfall Memory Distillation*, *Stage 4 Anti-Test-Tampering Guard*, *Stage 5 Production Approval Gate*, และคลังทักษะจัดการเอกสารทางการ
* **[`SkillsBench` (2026)](https://arxiv.org/abs/2602.12670) & *The Bitter Lesson*:** ตัดทักษะสอนไวยากรณ์ภาษาพื้นฐานที่ซ้ำกับ Pre-trained Weights ออก คงไว้เฉพาะ *Hard Guardrails*, *Project-Specific Pitfalls*, และ *Capability Tooling*
* **[`cloudflare/security-audit-skill`](https://github.com/cloudflare/security-audit-skill):** การไล่เส้นทางช่องโหว่ `entrypoint ➔ propagation ➔ sink` และการตรวจสิทธิ์ `Multi-Tenant Data Isolation (BOLA/IDOR)`
* **[`forrestchang/andrej-karpathy-skills`](https://github.com/forrestchang/andrej-karpathy-skills) & [`obra/superpowers`](https://github.com/obra/superpowers):** กฎ *Surgical Changes*, *4-Phase Root-Cause Debugging*, และ *Verification Before Completion*
* **[`garrytan/gstack`](https://github.com/garrytan/gstack) & [`trailofbits/claude-code-config`](https://github.com/trailofbits/claude-code-config):** ระบบป้องกัน *Reward Hacking (`RH-1..RH-16`)*, การดักจับ *Zero-Run Green (`PL-2`)*, และการส่งต่องานระหว่าง Subagents แบบ `State-Delta`
