# 🛡️ Agent Guard Template

**Universal Anti-Loop & Quota-Safe Starter Template สำหรับ Claude Code และ Antigravity (VS Code)**

โครงสร้างมาตรฐานสำหรับควบคุมพฤติกรรม AI Coding Agent ให้ทำงานแบบตรงจุด (Surgical Changes), ประหยัดโควต้า Token, ไม่วนลูปแก้บั๊กหรือรีวิวไม่รู้จบ, ไม่เคลมเกินจริง, ดึงทักษะเฉพาะทางจาก [`jeffallan/claude-skills`](https://github.com/jeffallan/claude-skills) มาติดตั้งตาม Tech Stack ได้อัตโนมัติ และสามารถ **สลับทำงานต่อกันระหว่าง Claude Code ↔ Antigravity ได้ทันทีเมื่อโควต้าหมดกลางคัน**

---

## ✨ จุดเด่นและปัญหาที่ Template นี้แก้ไข

| ปัญหาที่พบบ่อยใน AI Agent | กลไกป้องกันใน `agent-guard-template` |
| :--- | :--- |
| **1. คิดเองเออเองเวลาสั่งทำฟีเจอร์ใหม่** | **Common Ground Protocol (`common-ground`):** สรุปสมมติฐานที่ซ่อนอยู่ 3–4 ข้อสั้นๆ ให้ผู้ใช้ยืนยันก่อนลงมือเขียนโค้ดเมื่อโจทย์มีหลายทางเลือก |
| **2. เดาตัวเลขหรือเขียนโค้ดมั่วเมื่อสเปกไม่ครบ** | **0-Strike for Missing Spec:** หากรากของงานขาดสูตรทางธุรกิจหรือค่าคงที่เฉพาะ ระบบจะหยุดและส่ง `CIRCUIT_BREAKER: MISSING_SPEC` เพื่อถามทันที (ไม่เขียนโค้ดเผื่ออนาคต) |
| **3. วนลูปแก้บั๊กซ้ำๆ จนโควต้าหมด** | **2-Strike Bug Limit + Hook Circuit Breaker:** จำกัดการลองแก้บั๊กทางเทคนิคไม่เกิน 2 ครั้ง และมีสคริปต์ `loop-circuit-breaker.sh` บล็อกอัตโนมัติเมื่อรันคำสั่งเดิมซ้ำเกิน 3 ครั้ง |
| **4. รีวิวโค้ดจับผิดจุกจิกไม่รู้จบ (Non-Converging Review)** | **Blocker-Only & Max 2 Rounds:** ตรวจเฉพาะ `[BLOCKER]` (บั๊กพัง, ข้อมูลหาย, ช่องโหว่ Security) เมินเรื่องจุกจิก และออก `VERDICT: APPROVE` ทันทีเมื่อแก้ Blocker ครบ |
| **5. เขียนโค้ดเวิ่นเว้อ เกินคำสั่ง (Over-Engineering)** | **Karpathy Surgical Guidelines:** แก้เฉพาะบรรทัดที่จำเป็น ห้ามสร้าง Helper ที่ใช้ครั้งเดียว ห้าม Refactor โค้ดส่วนอื่นที่ไม่ได้สั่ง (ลดขนาดโค้ดส่วนเกินลง ~65%) |
| **6. เคลมว่า "เสร็จ 100%" โดยไม่ได้รันตรวจจริง** | **3-Tier Full-Stack Verification (`/verify`):** ตรวจครบทั้ง Unit Test, Build/Typecheck และ Runtime Smoke Check (`curl`) โดยห้ามรัน Dev Server ค้างจนบล็อกแชท |
| **7. โควต้าหมดกลางคัน ต้องเสียเวลาเล่างานใหม่** | **Auto-Checkpoint & SessionStart Handoff:** บันทึกไฟล์ล่าสุดที่แก้ลง `.agent-last-state.log` อัตโนมัติ และฉีดสถานะงานค้างเข้าสู่ Agent ตัวใหม่ทันทีที่เปิดแชท |
| **8. ต้องการความเชี่ยวชาญเฉพาะทางโดยไม่เปลืองโควต้า** | **On-Demand Skill Installer (`install-skill.sh`):** ดึงเฉพาะ Skill ที่ตรงกับ Tech Stack (เช่น `react-expert`, `nestjs-expert`) จาก `jeffallan/claude-skills` มาลงทั้ง `.claude/` และ `.agents/` อัตโนมัติ |

---

## 📁 โครงสร้างไฟล์ในโปรเจกต์ (Dual-Agent Architecture)

รองรับทั้ง **Claude Code** (`.claude/` + `CLAUDE.md`) และ **Antigravity / VS Code / Cursor** (`.agents/` + `AGENTS.md`) โดยใช้ชุดสคริปต์ป้องกันร่วมกัน:

```text
project-root/
├── AGENTS.md                                   # กฎหลัก + Auto-Router สำหรับ Antigravity / VS Code / Cursor
├── CLAUDE.md                                   # กฎหลัก + Auto-Router สำหรับ Claude Code
├── .mcp.json                                   # ตั้งค่า MCP (เริ่มต้นเป็นค่าว่างเพื่อไม่ให้กิน Token แฝง)
├── .gitignore                                  # ป้องกันไฟล์ความลับและไฟล์สถานะชั่วคราวขึ้น Git
│
├── .agents/                                    # ⚡ โฟลเดอร์ตั้งค่าอัตโนมัติสำหรับ Antigravity (VS Code)
│   ├── hooks.json                              # ผูก SessionStart, PreToolUse, PostToolUse
│   ├── rules/                                  # กฎการเขียนโค้ด (Surgical Edits, Discipline, Testing)
│   └── skills/                                 # ทักษะโหลดอัตโนมัติตามบริบทงาน
│       ├── auto-resume-handoff/SKILL.md        # รับไม้ต่ออัตโนมัติเมื่อสลับมาจาก Agent อื่น
│       ├── common-ground/SKILL.md              # เคลียร์สมมติฐานที่ซ่อนอยู่ก่อนเริ่มฟีเจอร์ใหม่
│       ├── pragmatic-review/SKILL.md           # รีวิวเฉพาะ Blocker ไม่เกิน 2 รอบ
│       ├── root-cause-debug/SKILL.md           # แก้บั๊กด้วยกฎ 0-Strike / 2-Strike
│       ├── tech-stack-skills/SKILL.md          # ติดตั้ง Skill เฉพาะทางจาก jeffallan/claude-skills อัตโนมัติ
│       ├── verification-before-completion/     # บังคับรันตรวจ 3 ระดับ (Test + Build + Smoke Check)
│       └── db-migration/                       # กฎความปลอดภัยเมื่อแก้ไข Schema ฐานข้อมูล
│
└── .claude/                                    # 🤖 โฟลเดอร์ตั้งค่าอัตโนมัติสำหรับ Claude Code
    ├── settings.json                           # สิทธิ์คำสั่งปลอดภัย + ผูก Hooks ทั้งหมด
    ├── agents/                                 # 4 Sub-Agents (explorer, implementer, debugger, reviewer)
    ├── rules/                                  # กฎโหลดตาม Path ไฟล์
    ├── skills/                                 # ทักษะโหลดอัตโนมัติ (ชุดเดียวกับ .agents/skills)
    ├── commands/                               # คำสั่งลัด (/plan, /common-ground, /fix, /review, /verify, /handoff)
    └── hooks/                                  # 🛡️ สคริปต์ Dual-Mode (ทำงานได้ทั้ง Claude และ Antigravity)
        ├── auto-resume.sh                      # ฉีดสถานะงานค้างเข้าแชทใหม่อัตโนมัติ (SessionStart)
        ├── validate-bash.sh                    # บล็อก rm -rf, git restore/checkout ทับโค้ด, และการลง pkg มั่ว
        ├── protect-sensitive-files.sh          # บล็อกการแก้ไขไฟล์ .env, .pem, .key, และ lockfiles
        ├── loop-circuit-breaker.sh             # บล็อกเมื่อ AI รันคำสั่งเทสต์/บิลด์เดิมซ้ำเกิน 3 ครั้ง
        ├── post-edit-format.sh                 # จัด Format อัตโนมัติ + บันทึกจุด Checkpoint ล่าสุด
        └── install-skill.sh                    # ดึง Skill เฉพาะทางจาก jeffallan/claude-skills แบบ Sparse Checkout
```

---

## 🚀 วิธีนำไปใช้งาน (Quick Start ภายใน 2 นาที)

### 1. เริ่มโปรเจกต์ใหม่ หรือนำไปใส่โปรเจกต์เดิม
* **สำหรับโปรเจกต์ใหม่:** กดปุ่ม **"Use this template"** บน GitHub หรือโคลนโปรเจกต์นี้ไปเริ่มต้นได้เลย:
  ```bash
  git clone https://github.com/bosocmputer/agent-guard-template.git my-project
  cd my-project
  chmod +x .claude/hooks/*.sh
  ```

### 2. บอก Tech Stack ของคุณในแชทเพื่อให้ AI ดึง Skill เฉพาะทางมาลงให้อัตโนมัติ
เมื่อเปิดโปรเจกต์ใน Claude Code หรือ Antigravity ครั้งแรก คุณสามารถพิมพ์บอกตามปกติ เช่น:
> *"โปรเจกต์นี้ใช้ React, Tailwind และ NestJS ช่วยดึง skill ที่เกี่ยวข้องมาลงให้หน่อย"*

AI จะรัน `bash .claude/hooks/install-skill.sh react-expert tailwind-expert nestjs-expert` เพื่อดึงเฉพาะ 3 โฟลเดอร์นั้นจาก [`jeffallan/claude-skills`](https://github.com/jeffallan/claude-skills) มาติดตั้งลงทั้ง `.claude/skills/` และ `.agents/skills/` ให้ทันทีโดยไม่ต้องโหลดทั้ง 67 ตัวมาให้เปลืองโควต้า!

---

## 💬 วิธีใช้งานในชีวิตประจำวัน (พิมพ์แค่ความต้องการ ระบบทำงาน Auto ทั้งหมด)

1. **สั่งสร้างฟีเจอร์ใหม่:**
   * หากโจทย์มีหลายทางเลือก ระบบจะใช้ **`common-ground`** สรุปสมมติฐาน 3–4 ข้อให้คุณพยักหน้าก่อนเขียนโค้ด
   * หากมี Skill เฉพาะทาง (เช่น `react-expert`) ระบบจะเปิดอ่านเฉพาะบทที่เกี่ยวข้องอัตโนมัติ
2. **สั่งแก้บั๊ก:**
   * ระบบใช้กฎ **0-Strike** (ถ้าขาดสเปกธุรกิจจะถามทันที ไม่เดามั่ว) และ **2-Strike** (ถ้าลองแก้ทางเทคนิค 2 ครั้งยังไม่ผ่าน จะคืนค่าไฟล์เดิมและสรุปทางเลือกให้คุณตัดสินใจ)
3. **สั่งตรวจโค้ดและยืนยันผล:**
   * ระบบใช้ **`pragmatic-review`** ตรวจเฉพาะจุดที่เป็น **`[BLOCKER]`** ไม่เกิน 2 รอบ และใช้ **`verification-before-completion`** ตรวจทั้ง Test, Build, และ Smoke Check ก่อนส่งงาน
4. **เมื่อโควต้า Claude Code หมดกลางคัน ➔ สลับมาเปิด Antigravity (หรือสลับกลับ):**
   * เปิดอีกโปรแกรมขึ้นมา ระบบ `auto-resume.sh` จะดึงจุดที่ทำค้างไว้จาก `.agent-last-state.log` และ `git status` เข้าสู่ระบบอัตโนมัติ
   * คุณแค่พิมพ์ต่อสั้นๆ ว่า: *"ทำส่วนที่ค้างไว้ต่อให้เสร็จเลย"*
