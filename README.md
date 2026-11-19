# 🛡️ Agent Guard Template

[![Agent Guard CI](https://github.com/bosocmputer/agent-guard-template/actions/workflows/ci.yml/badge.svg)](https://github.com/bosocmputer/agent-guard-template/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-emerald.svg)](LICENSE)
[![Engines: Claude Code + Antigravity IDE](https://img.shields.io/badge/Engines-Claude%20Code%20%7C%20Antigravity%20IDE-6366f1)](CLAUDE.md)
[![Zero-Dependency Hooks](https://img.shields.io/badge/Hooks-0--Token%20Bash%2FPython-f59e0b)](.claude/hooks/)

> **🇬🇧 English Summary (For Global Developers):**
> **Agent Guard Template** is a battle-tested, 6-layer **AI Coding Agent Harness & Governance Framework** for **Claude Code** and **Antigravity IDE** (built on a Single Source of Truth in `.claude/`).
> - **Save 70–83% of Main-Window Quota:** Enforces the **`Opus Architect ➔ Sonnet Builder (3+ files) ➔ Opus Gatekeeper`** pipeline plus a **6-turn Investigation/Debug Ceiling** on 1–2 file fixes — automatically offloading codebase exploration (`haiku`/`flash`, capped at 10 turns), multi-file implementation (`sonnet`, capped at 40 turns with `Edit`-over-`Write` safety), and batched Playwright MCP QA (`sonnet`, capped at 35 turns) out of your expensive `Opus`/`Fable` orchestrator window.
> - **0-Token OS, Git & Anti-Loop Safety Shields:** Deterministic Bash/Python hooks block `git reset --hard`, `git checkout .`, `.env`/credential dumps, unapproved dependencies, test-tampering during bug fixes, and stuck read/search loops via a **Sticky Per-Actor Read-Loop Circuit Breaker** (`> 14` consecutive reads without editing, `exit 2`).
> - **Zero-Prompt Cross-Agent Handoff & 5-Hour Quota Radar:** Auto-syncs git/session state into `TASK_STATE.md` before context compaction or 5-hour quota cutoffs, tracks rolling 5-hour token burn across all local projects, and distills project-specific lessons into `.claude/rules/project-pitfalls.md`.

**🇹🇭 ระบบควบคุมวินัย AI Coding Agent แบบ Dual-Engine (`Claude Code` & `Antigravity IDE`) — เน้นแก้โค้ดเฉพาะจุด ประหยัดโควต้าหน้าต่างหลัก 70–83% ด้วย Subagents อัตโนมัติ พร้อมระบบป้องกันคำสั่งอันตราย 0-Token, ตัววัดอัตราเผาโควต้า 5 ชั่วโมงข้ามโปรเจกต์ และความจำระยะยาวเฉพาะโปรเจกต์**

ออกแบบตามหลัก **Single Source of Truth (แก้ที่ `CLAUDE.md` และ `.claude/` จุดเดียว)**, **No Over-Claiming (รายงานตามจริงพร้อมหลักฐานเทสต์)**, และ **No Ceremony Overhead (ไม่เพิ่มพิธีกรรมหรือไฟล์ขยะ)**

---

## 📈 ผลลัพธ์จากการใช้งานจริงบน Production (Verified Benchmarks)

ตัวเลขจริงจากการวัดผลด้วย `audit-session-proof.sh` บนระบบ ERP/OMS ระดับ Production (`Go + React 19 + PostgreSQL RLS`):

| ตัวชี้วัด (Metric) | ก่อนใช้ / แชทสะสมแบบไม่แยก Subagent | หลังใช้ `agent-guard-template` (v2) | ผลลัพธ์ที่ได้ |
| :--- | :---: | :---: | :---: |
| **จำนวนรอบรวมต่อ 1 ฟีเจอร์ใหญ่ (Full-Stack + CI + QA)** | `392 รอบ` | **`66 รอบ`** (`Parent 12` + `Sonnet 54`) | ⚡ **ลดลง 83.2%** |
| **การตรวจหน้าเว็บจริงด้วย Playwright MCP (`reviewer`)** | `120 รอบ` (`8.67M tokens`) | **`11 รอบ`** (Batching + Turn Reserve) | 🎯 **ลดลง 90.8%** |
| **ขนาด Context ต่อรอบในหน้าต่างหลัก (`Opus`/`Fable`)** | `234,820 tokens/turn` | **`83,109 – 94,653 tokens/turn`** | 💰 **ประหยัดโควต้า 60–65%** |

---

## 🎯 ทำไมต้องใช้ Template นี้? (ปัญหาที่แก้ได้จริง)

| ปัญหาที่พบบ่อยเมื่อใช้ AI เขียนโค้ดแบบเปล่าๆ | กลไกของ `agent-guard-template` |
| :--- | :--- |
| 💸 **หน้าแชทหลักตันไว & เปลืองโควต้า `Opus`:** สั่งงานใหญ่ทีไร AI กวาดอ่านไฟล์และรันเทสต์วนลูปในหน้าต่างหลักจนโควต้าหมดกลางคัน | 🤖 **Auto-Subagent Offload (ลดภาระหน้าต่างหลัก 50–70%):** บังคับแยกงานสำรวจ (`explorer` / `flash`) และงานเขียนโค้ด+รันเทสต์ (`implementer` / `reviewer`) ออกไปทำใน Subagent อัตโนมัติ เก็บหน้าต่างหลักไว้สั่งการได้ยาวหลายชั่วโมง |
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
mkdir -p ~/.claude/agents && cp .claude/agents/*.md ~/.claude/agents/
chmod +x .claude/hooks/*.sh
```

### วิธีที่ 2: นำไปติดตั้งหรืออัปเดตในโปรเจกต์ที่มีอยู่แล้ว (`rsync` One-Liner)
รันคำสั่งนี้ที่โฟลเดอร์นอกสุดของโปรเจกต์ เพื่อติดตั้งหรืออัปเดตไฟล์มาตรฐานของ Template (พร้อมซิงก์ Custom Subagents ลง `~/.claude/agents/` สำหรับ Claude Code Desktop รุ่นล่าสุด) โดย**เก็บรักษาบทเรียนเฉพาะโปรเจกต์ (`.claude/rules/project-pitfalls.md`) และสถิติ (`.telemetry.json`) เดิมไว้ครบถ้วน**:

```bash
rm -rf /tmp/agt-update
git clone --depth 1 https://github.com/bosocmputer/agent-guard-template.git /tmp/agt-update
rsync -av --exclude='.git' --exclude='README.md' --exclude='LICENSE' --exclude='tests' --exclude='.github' --exclude='docs' --exclude='.mcp.json' --exclude='.gitignore' --exclude='TASK_STATE.md' --exclude='.agent-last-state.log' --exclude='.telemetry.json*' --exclude='.quota_cache.json*' --exclude='.task-state-archive.md' --exclude='/.claude/rules/project-pitfalls.md' /tmp/agt-update/ ./
[ -f .claude/rules/project-pitfalls.md ] || cp /tmp/agt-update/.claude/rules/project-pitfalls.md .claude/rules/project-pitfalls.md
mkdir -p ~/.claude/agents && cp .claude/agents/*.md ~/.claude/agents/
rm -rf /tmp/agt-update .agents/skills
chmod +x .claude/hooks/*.sh
```

### โหมดความเข้มงวด (`strict` vs `relaxed`) และสคริปต์เสริม `0-Token`
- **สลับโหมดสำหรับช่วงปั้น Prototype วันแรก (`AGENT_GUARD_MODE=relaxed`):**
  - ค่าเริ่มต้นคือ `strict` (บังคับถามก่อนลง Package ใหม่ และล็อกไม่ให้แก้ไฟล์เทสต์เดิมขณะซ่อมบั๊ก)
  - หากกำลังทดลองปั้น Prototype เร็วๆ สามารถรัน `echo relaxed > .agent-guard-mode` (หรือตั้ง `export AGENT_GUARD_MODE=relaxed`) เพื่อปลดล็อกการลง Package และการแก้ไฟล์เทสต์ชั่วคราว โดยที่ระบบป้องกันไฟล์ความลับ `.env` และคำสั่งลบ Git (`reset --hard`) ยังทำงานเต็ม 100%
- **สร้างโพยสรุปงาน / PR Changelog อัตโนมัติแบบ `0-Token`:**
  ```bash
  bash .claude/hooks/release-summary.sh
  ```
- **รันชุดทดสอบสคริปต์ยาม (Hook Regression Test Suite — 29 เคส):**
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
│       ├── model-routing.md                    # @[model-routing](../../.claude/rules/model-routing.md)
│       ├── execution-discipline.md             # @[execution-discipline](../../.claude/rules/execution-discipline.md)
│       ├── project-pitfalls.md                 # @[project-pitfalls](../../.claude/rules/project-pitfalls.md)
│       ├── code-simplicity.md                  # @[code-simplicity](../../.claude/rules/code-simplicity.md)
│       ├── testing-and-api.md                  # @[testing-and-api](../../.claude/rules/testing-and-api.md)
│       └── ui-anti-slop.md                     # @[ui-anti-slop](../../.claude/rules/ui-anti-slop.md)
│
└── .claude/                                    # 🤖 แหล่งข้อมูลต้นฉบับ (Master Single Source of Truth)
    ├── settings.json                           # สิทธิ์คำสั่งปลอดภัย + ผูกสคริปต์ Hooks สำหรับ Claude Code
    ├── agents/                                 # ลูกมือ Subagents 4 ตำแหน่ง (พร้อม Capability Budgets ตาม Harness Engineering Layer 3)
    │   ├── explorer.md                         # สำรวจโค้ด & ค้นคว้าเว็บ WebSearch/WebFetch (haiku / flash, maxTurns: 10 + Zero-Citation Stop)
    │   ├── implementer.md                      # แก้โค้ดแบบ Surgical Edit (เน้น Edit แทน Write ทับไฟล์) + รันเทสต์ Tier 1–2 เอง (sonnet / inherit, maxTurns: 40)
    │   ├── debugger.md                         # วิเคราะห์ต้นตอและตัดลูป 2-Strike (sonnet / inherit, 8-Turn Target / maxTurns: 12)
    │   └── reviewer.md                         # ตรวจเฉพาะ Blocker และรัน E2E/Playwright MCP แบบ Batch (sonnet / browser flash, maxTurns: 35)
    ├── rules/                                  # กฎต้นฉบับ 7 ไฟล์
    │   ├── guard-core.md                       # กฎแกนกลาง Universal (โหลดอัตโนมัติทุกโปรเจกต์แม้มี CLAUDE.md Custom: Opus->Sonnet, SSH/Ops Ceiling, Byte Budget, Auto-Handoff 100t)
    │   ├── model-routing.md                    # Pipeline Opus Architect ➔ Sonnet Builder (3+ ไฟล์), เพดานดีบัก/SSH 6 รอบ, Edit-over-Write/Bash & ห้ามรัน Browser ในหน้าต่างหลัก
    │   ├── execution-discipline.md             # ส่งต่องาน State-Delta (<=8 บรรทัด), Grep ก่อนอ่านเฉพาะบรรทัด (>200 บรรทัด) & ห้าม git reset/restore
    │   ├── project-pitfalls.md                 # ความจำระยะยาวเฉพาะโปรเจกต์ตามหลัก The Ratchet Pattern (สกัดอัตโนมัติ สูงสุด 30 ข้อ)
    │   ├── code-simplicity.md                  # กฎ Karpathy: คิดก่อนทำ, เรียบง่ายที่สุด, แก้เฉพาะจุด, ไม่สร้างไฟล์ขยะ
    │   ├── testing-and-api.md                  # บังคับเทสต์โค้ดจริง (Verify RED ➔ GREEN) & ตรวจสิทธิ์ BOLA/IDOR
    │   └── ui-anti-slop.md                     # มาตรฐานออกแบบ UI 9 ด้าน (ใช้ lucide, tabular-nums, ห้ามวาด SVG เอง)
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
        ├── auto-resume.sh                      # ฉีดสถานะงานค้างตอนเปิดแชทใหม่ (SessionStart) และบันทึกความจำก่อนย่อแชท (PreCompact)
        ├── validate-bash.sh                    # บล็อก rm -rf, git restore/reset ทับโค้ด, ลง pkg มั่ว & กั้น Deploy Production
        ├── protect-sensitive-files.sh          # บล็อกการอ่าน/แก้ .env/.key, lockfiles & บล็อกการแอบแก้ไฟล์เทสต์เดิมขณะซ่อมบั๊ก
        ├── loop-circuit-breaker.sh             # ตัดวงจรเมื่อรันคำสั่งเทสต์/บิลด์ซ้ำเกิน 3 ครั้ง หรืออ่าน/ค้นโค้ดวนเกิน 14 ครั้งโดยไม่แก้ไฟล์ (Sticky + แยกตาม Actor)
        ├── post-edit-format.sh                 # จัด Format อัตโนมัติ + บันทึก Checkpoint + ล้างตัวนับลูปเฉพาะ Actor เมื่อแก้โค้ดจริง
        ├── telemetry-tracker.sh                # บันทึกสถานะการทำงานสดและแคชสถิติ Subagents ลง .claude/.telemetry.json
        ├── audit-session-proof.sh              # สแกนไฟล์ .jsonl สรุปผลการใช้โมเดล, Subagent tokens, Hooks และบทเรียนที่สกัดได้
        ├── release-summary.sh                  # สร้างโพยสรุปงาน / PR Changelog อัตโนมัติแบบ 0-Token จาก git log
        ├── install-skill.sh                    # ดึง Skill เสริมเฉพาะทางลง .claude/skills/ แบบ Sparse Checkout
        └── open-hud.sh                         # เปิดหน้าจอมอนิเตอร์ 3D Voxel Studio (อุปกรณ์เสริม)
```

---

## 🧠 เจาะลึก 6 กลไกหลักของระบบ

### 1. การคัดแยกงานและแตก Subagent อัตโนมัติ (`Zero-Command Auto-Routing`)
คุณสามารถพิมพ์สั่งงานด้วยภาษาไทยตามปกติ ระบบใน [`CLAUDE.md`](CLAUDE.md) จะประเมินขนาดงานให้อัตโนมัติ:
* **งานแก้จุดย่อยที่รู้พิกัดไฟล์อยู่แล้ว (`1–2 ไฟล์`, `<= 6 รอบ`):** หน้าต่างหลักลงมือแก้แบบ Surgical `Edit` และรันเทสต์เฉพาะไฟล์ทันที พร้อมมัดรวมคำสั่ง `ssh`/`docker logs`/`psql`/`gh run view` เป็น `1–2` คำสั่งต่อรอบ โดยมี **เพดานดีบัก & SSH/Ops (`6-Turn Investigation, Debug & SSH/Ops Ceiling`)** — หากอ่าน/ดีบัก/ไล่ล็อกเซิร์ฟเวอร์เกิน `6 ครั้ง` แล้วยังไม่จบ ให้หยุดในหน้าต่างหลักและโยนให้ `debugger` (`sonnet`) หรือ `explorer` (`haiku`) ทันที เพื่อไม่ให้ตัวแม่ `Opus` เผาโควต้า 20–100+ รอบ
* **งานสำรวจโค้ดข้ามหลายโฟลเดอร์ (`>3 ไฟล์`) หรือค้นคว้าข้อมูลจากอินเทอร์เน็ต:** แตก `explorer` (`haiku` บน Claude พร้อม `WebSearch`/`WebFetch` / `research` `flash` บน Antigravity พร้อม `search_web`) ไปสแกนหาพิกัดไฟล์+เลขบรรทัดหรือค้นเอกสารเว็บ แล้วส่งกลับมาเฉพาะสรุปสั้นๆ ไม่เกิน 15 บรรทัด
* **งานสร้างฟีเจอร์หรือแก้โค้ดหลายไฟล์ (`3+ ไฟล์` — Pipeline `Opus Architect ➔ Sonnet Builder ➔ Opus Gatekeeper`):** แม้โจทย์จะระบุไฟล์ครบแล้ว ตัวแม่ `Opus` **ห้าม** เขียน/แก้โค้ดเองทั้งหมดในหน้าต่างหลัก ให้ทำตาม 3 ขั้น: **(1) Architect (`2–4 รอบ`):** อ่านไฟล์อ้างอิง 1–2 ไฟล์ (หรือให้ `explorer` หาพิกัดก่อน — **ห้าม Spawn `implementer` แบบตาบอดโดยไม่มีชื่อไฟล์+เลขบรรทัด**); **(2) Builder (`implementer` บน `sonnet` / `self`):** เปิดหน้าต่างสะอาด (**Fresh Context — ห้าม Fork ประวัติแชทหลัก**) รับ `State-Delta Brief (<=8 บรรทัด)` พร้อมเพดาน **อ่านไม่เกิน 10 รอบก่อนเริ่มแก้**, บังคับใช้ **`Edit` แทน `Write` ทับไฟล์เดิม** (กัน Claude Code Auto Mode บล็อก), และ **รันเทสต์ Tier 1 + Tier 2 (`analyze` + `test`) ให้จบในตัว** (หากแก้ต่อในฟีเจอร์เดิมและยังไม่เกิน `40 รอบ` ให้ `send_message` ใช้ตัวเดิมต่อ); **(3) Gatekeeper (`2–3 รอบ`):** ตรวจ `git diff --stat`, อัปเดต `TASK_STATE.md` / `project-pitfalls.md`, และรัน `audit-session-proof.sh --brief`
* **กฎประหยัด Token ตอนอ่านไฟล์ใหญ่ (`Grep First, Read Line-Range Second`):** สำหรับไฟล์ที่ยาวเกิน `200 บรรทัด` บังคับใช้ `Grep`/`grep_search` หาเลขบรรทัดก่อน แล้วอ่านเฉพาะช่วงบรรทัด (`StartLine`–`EndLine` หรือ `offset`–`limit` ±40 บรรทัด) แทนการดึงไฟล์เต็มเข้า Context ซ้ำๆ (ประหยัด Input Tokens 70–80%)
* **งานซ่อมบั๊ก (`debugger`) และงานตรวจรับโค้ด/รัน E2E (`reviewer`):** แยกออกไปรันใน Subagent (`debugger`/`reviewer` ใช้ `sonnet` บน Claude หรือ `browser` `flash` สำหรับตรวจเว็บ / `self` สำหรับ E2E บน Antigravity) เพื่อไม่ให้ Log ของเทสต์และ Browser กินพื้นที่หน้าต่างแชทหลัก

### 2. ยามรักษาความปลอดภัยเบื้องหลัง 0-Token (`.claude/hooks/*.sh`)
ทำงานด้วยสคริปต์ Bash/Python ก่อนและหลังการเรียกเครื่องมือของ AI โดยไม่เสีย Token (พร้อมการันตี Fail-Open สำหรับส่วน Telemetry):
1. **`validate-bash.sh` (Git, Dependency, Production & MITRE Execution/Exfiltration Gate):**
   * บล็อกคำสั่งทำลายงานค้าง เช่น `rm -rf`, `git reset --hard`, `git checkout .`, `git restore`, `git push --force` (แต่อนุญาตการสร้างและสลับกิ่ง `git checkout -b` / `git switch` ตามปกติ)
   * บล็อกการรันสคริปต์ภายนอกเข้าสู่ Shell โดยตรง (`curl/wget ... | sh/bash/python/node`), การพลางคำสั่ง (`base64 -d | sh`, `$IFS`), และการดึงค่า Environment Secrets ทั้งระบบด้วย `printenv` หรือ `env` เปล่าๆ
   * บล็อกการแอบอ่าน `.env*`/`*.key` ผ่านคำสั่ง Shell (`cat/grep/awk/sed`) และการแตะต้องโฟลเดอร์ Credential หรือ Shell Profile ของโฮสต์ (`~/.ssh`, `~/.aws`, `~/.kube`, `~/.zshrc`, `crontab`)
   * บล็อกการแอบติดตั้ง Package ใหม่ (`npm install`, `flutter pub add`, `go get`, `pip install`, `cargo add`) จนกว่าคุณจะอนุมัติ (`DEPS_APPROVED=1`)
   * บล็อกการสั่ง Deploy ขึ้น Production หรือยิง Migration ขึ้นฐานข้อมูลจริง (`vercel --prod`, `supabase db push`, `prisma migrate deploy`) จนกว่าคุณจะอนุมัติ (`RELEASE_APPROVED=1`) แต่อนุญาต `supabase db reset` บน Local Docker สำหรับรันเทสต์
2. **`protect-sensitive-files.sh` & `telemetry-tracker.sh` (Secrets, Host Credentials & Stage 4 Anti-Test-Tampering):**
   * ห้ามอ่านหรือแก้ไขไฟล์ `.env*`, `*.key`, `*.pem`, `*.sqlite`, `*.db`, โฟลเดอร์ Credential ของโฮสต์ (`~/.ssh/*`, `~/.aws/*`, `~/.kube/*`, `~/.netrc`, `~/.npmrc`), Shell Profile (`~/.zshrc`, `~/.bashrc`), ไฟล์ `.git/config` / `.git/hooks/*` และไฟล์ Lockfile
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
2. **`### 📊 ผลชี้วัด Agent Guard Template — เฉพาะคำสั่งนี้` (5 บรรทัดจากสคริปต์จริง แยกเฉพาะคำสั่งล่าสุด + ยอดสะสมทั้งแชท + `Harness Tripwires`):**
   ```markdown
   ### 📊 ผลชี้วัด Agent Guard Template — เฉพาะคำสั่งนี้ (Antigravity Session `#7217c67b`)
   - **สัดส่วนโมเดลคำสั่งนี้ (26 รอบ):** Parent (Fable 5.2) `73.1%` (19 รอบ) | Subagents (Sonnet) `26.9%` (7 รอบ) | Subagents (Haiku) `0.0%` (0 รอบ) ➔ **Offload รอบนี้: `26.9%`** *(สะสมทั้งแชท: 535 รอบ, Offload 58.9%)*
   - **Subagents ที่เรียกในคำสั่งนี้:** `2` ตัว (`Explorer: 0`, `Implementer: 2`, `Debugger: 0`, `Reviewer: 0`) — รับภาระรอบนี้ `450,873 tokens` *(สะสมทั้งแชท: 10 ตัว)*
   - **Hooks ที่ทำงานในคำสั่งนี้:** สแกนไฟล์ `2` ครั้ง | แก้ไฟล์+Checkpoint `0` ครั้ง | รันเทสต์ `0` ครั้ง | บล็อกผิดกฎ `0` ครั้ง | 2-Strike: `0/3` *(สะสมทั้งโปรเจกต์: สแกน 63, แก้ 71, เทสต์ 13)*
   - **ความจำ & ส่งต่องาน:** Pitfalls `7/30` (รอบนี้ไม่มีเพิ่มใหม่) | `TASK_STATE.md`: ✅ ซิงก์อัตโนมัติ (`feat/sprint1-foundation@3bddbed`)
   - **⚡ Harness Tripwires (Layer 6 SLA):** ✅ `ปกติ (No Behavioral Drift)` — รอบคำสั่ง `12/20` · สะสมหน้าต่างหลัก `50/80`
   ```
   *(หากหน้าต่างหลักสะสมเกิน 80 รอบ, คำสั่งเดียวรันเกิน 20 รอบ, หรือ Offload ต่ำกว่า 30% บรรทัด `⚡ Harness Tripwires` จะเปลี่ยนเป็นป้ายเตือน `⚠️ CONTEXT_WINDOW_BLOAT` / `⚠️ TURN_BUDGET_EXCEEDED` เพื่อเตือนให้พิมพ์ `/compact` หรือเปิดแชทใหม่ทันที)*

### 6. ส่งต่องานข้ามค่ายเมื่อโควต้าตัดกลางอากาศ & กันความจำเสื่อมตอนย่อแชทอัตโนมัติ (`Zero-Prompt Resume + PreCompact Continuity Ledger`)
คุณสามารถสลับไปมาระหว่าง **Claude Code ⇄ Antigravity IDE** ได้ทันทีแม้ในจังหวะที่โควต้า 5 ชั่วโมงตัดกลางอากาศ (`You've hit your 5-hour limit`) โดย**แค่เปิดแชทใหม่แล้วพิมพ์สั้นๆ ว่า `"ทำต่อ"` หรือ `"ลุยต่อ"` คำเดียว**:
* **ชั้นที่ 1 (สรุปงานอัตโนมัติ + 0-Token Auto-Trim & Archive):** AI อัปเดตสถานะปัจจุบันไว้ด้านบนของ `TASK_STATE.md` (`<= 20 บรรทัด` และ `<= 2,500 bytes`) หากไฟล์เกิน `2,800 bytes` สคริปต์ `audit-session-proof.sh` จะเก็บเฉพาะสถานะล่าสุดและย้ายประวัติ deploy เก่าลง `.claude/.task-state-archive.md` อัตโนมัติแบบ `0-Token` เพื่อไม่ให้กิน Input Tokens ฟรีทุกเทิร์น (และเมื่อหน้าต่างหลักสะสมถึง `>= 100 รอบ` หรือ `>= 130k tokens` ในแชทเดิม `telemetry-tracker.sh` จะยิง **Auto-Handoff Nudge** แนะนำให้ `/clear` แล้วพิมพ์ `"ทำต่อ"` อัตโนมัติ)
* **ชั้นที่ 2 (แกะรอยงานที่โดนตัดกลางคันแบบ `0-Token` ใน `auto-resume.sh` & `audit-session-proof.sh`):** ทันทีที่คุณเปิดแชทใหม่ (`SessionStart`) สคริปต์จะไปอ่านท้ายไฟล์ `.jsonl` ของแชทล่าสุดที่เพิ่งดับไป ดึง **`Last User Prompt`** (โจทย์ที่คุณสั่งไว้), **`Last Agent Summary`** (สิ่งที่ตัวแม่ทำเสร็จไปแล้วก่อนดับ), และ **`Last Dispatched Subagent Task`** (คำสั่งที่ส่งให้ลูกน้องทำค้างไว้ก่อนโควต้าตัด) มาเขียนต่อท้าย `TASK_STATE.md` พร้อมกิ่งและ 5 คอมมิตล่าสุดให้อัตโนมัติ!
* **ชั้นที่ 3 (`PreCompact` Continuity Hook):** ก่อนที่ระบบจะสั่งย่อหน้าต่างความจำอัตโนมัติ (`/compact` หรือ Auto-Compaction) `auto-resume.sh --pre-compact` จะบังคับซิงก์ `TASK_STATE.md` ล่าสุดและฉีดเตือนให้ AI ยึด `TASK_STATE.md` + `project-pitfalls.md` เป็นหลักหลังย่อความจำ ป้องกันอาการความจำเสื่อมกลางแชท (`Post-Compaction Amnesia`)

---

## ⚡ ตารางคำสั่งลัด (ใช้ได้ทั้งใน Claude Code และ Antigravity IDE)

| คำสั่งลัด | ใช้เมื่อไหร่ | สิ่งที่เกิดขึ้นเบื้องหลัง |
| :--- | :--- | :--- |
| **`/plan <โจทย์>`** | ก่อนเริ่มงานใหญ่ที่ต้องแก้เกิน 3 ไฟล์ | ส่ง `explorer` สแกนหาพิกัดไฟล์และสรุปแผนสั้นๆ มาให้ตรวจอนุมัติก่อนแก้โค้ด |
| **`/common-ground <โจทย์>`** | ก่อนทำฟีเจอร์ใหม่ที่มีเงื่อนไขธุรกิจหลายแง่มุม | สกัดสมมติฐาน 3–4 ข้อและขอบเขตที่จะไม่ทำ (*YAGNI*) มาถามให้ตรงกันก่อนลงมือ |
| **`/fix <อาการบั๊ก>`** | เมื่อเทสต์พังหรือเจออาการบั๊ก | วิเคราะห์ต้นตอ 4 ขั้นตอน + ล็อกไฟล์เทสต์เดิม (`Stage 4`) + ตัดเบรกเกอร์เมื่อแก้ไม่ผ่านครบ 2 ครั้ง (`2-Strike`) |
| **`/review`** | เมื่อเขียนโค้ดเสร็จและต้องการตรวจก่อนส่ง | ส่ง `reviewer` ตรวจเฉพาะ `[BLOCKER]` และช่องโหว่ความปลอดภัย (จบภายในไม่เกิน 2 รอบ) |
| **`/security-audit`** | เมื่อต้องการตรวจความปลอดภัยเชิงลึกก่อนปล่อยของ | ส่ง `explorer` หาพื้นผิวโจมตี + `reviewer` ไล่เส้นทาง `entrypoint ➔ sink` ตามเกณฑ์ Cloudflare |
| **`/verify`** | ก่อนประกาศจบงานหรือปิด Milestone | รันเทสต์จริง + ตรวจ Type/Analyze + สรุป `Next Steps` และรัน `audit-session-proof.sh --brief` |
| **`/learn <บทเรียน>`** | เมื่อต้องการสั่งให้จำข้อตกลงเฉพาะโปรเจกต์ | บันทึกกฎสั้นๆ 1 บรรทัดลง `.claude/rules/project-pitfalls.md` (ไม่เกิน 30 ข้อ) |
| **`/handoff`** | ก่อนล้างแชท `/clear` หรือก่อนสลับค่าย AI | สรุปสถานะงานค้างลง `TASK_STATE.md`, สกัดบทเรียนของรอบนั้นลง `project-pitfalls.md`, และแสดงผลชี้วัดประจำแชท |

---

## 🖥️ อุปกรณ์เสริม (Optional): หน้าจอมอนิเตอร์ 3D (`Agent Guard Voxel Studio`)

หากต้องการเปิดหน้าจอจำลองการทำงานของทีม AI ทั้ง 5 แผนกแบบเรียลไทม์ สำรวจผังไฟล์จริง หรือดู % โควต้าคงเหลือ สามารถรันคำสั่งนี้ใน Terminal (เปิด `http://127.0.0.1:4317/` อัตโนมัติ):

```bash
bash .claude/hooks/open-hud.sh
```

![ภาพรวมศูนย์บัญชาการ 3D Voxel Studio](docs/screenshots/01-studio-overview.jpg)

---

## 📚 มาตรฐานและงานวิจัยอ้างอิง

* **Harness Engineering (*Agent = Model + Harness: The 6-Layer Production Playbook*, 2026):** สถาปัตยกรรม 6 ชั้น (*Guides, Computational vs. Inferential Sensors, Capability Budgets, 4-Tier Externalized Memory, Graduated Permissions, และ Layer 6 Behavioral Drift Tripwires*) รวมถึง *The Ratchet Pattern* ของ Mitchell Hashimoto (Ghostty)
* **[Anthropic AI-Native SDLC Playbook](https://claude.com/resources/articles/the-ai-native-sdlc-playbook) & [`anthropics/skills`](https://github.com/anthropics/skills):** กลไก *Stage 3 Pitfall Memory Distillation*, *Stage 4 Anti-Test-Tampering Guard*, *Stage 5 Production Approval Gate*, และคลังทักษะจัดการเอกสารทางการ
* **[`SkillsBench` (2026)](https://arxiv.org/abs/2602.12670) & *The Bitter Lesson*:** ตัดทักษะสอนไวยากรณ์ภาษาพื้นฐานที่ซ้ำกับ Pre-trained Weights ออก คงไว้เฉพาะ *Hard Guardrails*, *Project-Specific Pitfalls*, และ *Capability Tooling*
* **[`cloudflare/security-audit-skill`](https://github.com/cloudflare/security-audit-skill):** การไล่เส้นทางช่องโหว่ `entrypoint ➔ propagation ➔ sink` และการตรวจสิทธิ์ `Multi-Tenant Data Isolation (BOLA/IDOR)`
* **[`forrestchang/andrej-karpathy-skills`](https://github.com/forrestchang/andrej-karpathy-skills) & [`obra/superpowers`](https://github.com/obra/superpowers):** กฎ *Surgical Changes*, *4-Phase Root-Cause Debugging*, และ *Verification Before Completion*
* **[`garrytan/gstack`](https://github.com/garrytan/gstack) & [`trailofbits/claude-code-config`](https://github.com/trailofbits/claude-code-config):** ระบบป้องกัน *Reward Hacking (`RH-1..RH-16`)*, การดักจับ *Zero-Run Green (`PL-2`)*, และการส่งต่องานระหว่าง Subagents แบบ `State-Delta`
