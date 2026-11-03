# 🛡️ Agent Guard Template

**Universal Anti-Loop & Quota-Safe Starter Templateสำหรับ Claude Code และ Antigravity (VS Code)**

โครงสร้างมาตรฐานสำหรับควบคุมพฤติกรรม AI Coding Agent ให้ทำงานแบบตรงจุด (Surgical Changes), ประหยัดโควต้า Token, ไม่วนลูปแก้บั๊กหรือรีวิวไม่รู้จบ, ไม่เคลมเกินจริง และสามารถ **สลับทำงานต่อกันระหว่าง Claude Code ↔ Antigravity ได้อัตโนมัติเมื่อโควต้าหมดกลางคัน**

---

## ✨ จุดเด่นและปัญหาที่ Template นี้แก้ไข

| ปัญหาที่พบบ่อยใน AI Agent | กลไกป้องกันใน `agent-guard-template` |
| :--- | :--- |
| **1. เดาตัวเลขหรือเขียนโค้ดมั่วเมื่อสเปกไม่ครบ** | **0-Strike for Missing Spec:** หากรากของงานขาดสูตรทางธุรกิจหรือค่าคงที่เฉพาะ ระบบจะหยุดและส่ง `CIRCUIT_BREAKER: MISSING_SPEC` เพื่อถามทันที (ไม่เขียนโค้ดเผื่ออนาคต) |
| **2. วนลูปแก้บั๊กซ้ำๆ จนโควต้าหมด** | **2-Strike Bug Limit + Hook Circuit Breaker:** จำกัดการลองแก้บั๊กทางเทคนิคไม่เกิน 2 ครั้ง และมีสคริปต์ `loop-circuit-breaker.sh` บล็อกอัตโนมัติเมื่อรันคำสั่งเดิมซ้ำเกิน 3 ครั้ง |
| **3. รีวิวโค้ดจับผิดจุกจิกไม่รู้จบ (Non-Converging Review)** | **Blocker-Only & Max 2 Rounds:** ตรวจเฉพาะ `[BLOCKER]` (บั๊กพัง, ข้อมูลหาย, ช่องโหว่ Security) เมินเรื่องจุกจิก และออก `VERDICT: APPROVE` ทันทีเมื่อแก้ Blocker ครบ |
| **4. เขียนโค้ดเวิ่นเว้อ เกินคำสั่ง (Over-Engineering)** | **Karpathy Surgical Guidelines:** แก้เฉพาะบรรทัดที่จำเป็น ห้ามสร้าง Helper ที่ใช้ครั้งเดียว ห้าม Refactor โค้ดส่วนอื่นที่ไม่ได้สั่ง (ลดขนาดโค้ดส่วนเกินลง ~65%) |
| **5. เคลมว่า "เสร็จ 100%" โดยไม่ได้รันเทสต์จริง** | **Iron Law of Verification:** บังคับรันเทสต์หรือ Typecheck สดในรอบปัจจุบัน และต้องแสดง `คำสั่งที่รัน` + `ผลลัพธ์จริง` ทุกครั้งก่อนจบงาน |
| **6. โควต้าหมดกลางคัน ต้องเสียเวลาเล่างานใหม่** | **Auto-Checkpoint & SessionStart Handoff:** บันทึกไฟล์ล่าสุดที่แก้ลง `.agent-last-state.log` อัตโนมัติ และฉีดสถานะงานค้างเข้าสู่ Agent ตัวใหม่ทันทีที่เปิดแชท |

---

## 📁 โครงสร้างไฟล์ในโปรเจกต์ (Dual-Agent Architecture)

รองรับทั้ง **Claude Code** (`.claude/` + `CLAUDE.md`) และ **Antigravity / VS Code / Cursor** (`.agents/` + `AGENTS.md`) โดยใช้ชุดสคริปต์ป้องกันร่วมกัน:

```text
project-root/
├── AGENTS.md                                   # กฎหลักสำหรับ Antigravity / VS Code / Cursor
├── CLAUDE.md                                   # กฎหลักสำหรับ Claude Code
├── .mcp.json                                   # ตั้งค่า MCP (เริ่มต้นเป็นค่าว่างเพื่อไม่ให้กิน Token แฝง)
├── .gitignore                                  # ป้องกันไฟล์ความลับและไฟล์สถานะชั่วคราวขึ้น Git
│
├── .agents/                                    # ⚡ โฟลเดอร์ตั้งค่าอัตโนมัติสำหรับ Antigravity (VS Code)
│   ├── hooks.json                              # ผูก SessionStart, PreToolUse, PostToolUse
│   ├── rules/                                  # กฎการเขียนโค้ด (Surgical Edits, Discipline, Testing)
│   └── skills/                                 # ทักษะโหลดอัตโนมัติตามบริบทงาน
│       ├── auto-resume-handoff/SKILL.md        # รับไม้ต่ออัตโนมัติเมื่อสลับมาจาก Agent อื่น
│       ├── pragmatic-review/SKILL.md           # รีวิวเฉพาะ Blocker ไม่เกิน 2 รอบ
│       ├── root-cause-debug/SKILL.md           # แก้บั๊กด้วยกฎ 0-Strike / 2-Strike
│       ├── verification-before-completion/     # บังคับรันตรวจจริงก่อนแจ้งจบงาน
│       └── db-migration/                       # กฎความปลอดภัยเมื่อแก้ไข Schema ฐานข้อมูล
│
└── .claude/                                    # 🤖 โฟลเดอร์ตั้งค่าอัตโนมัติสำหรับ Claude Code
    ├── settings.json                           # สิทธิ์คำสั่งปลอดภัย + ผูก Hooks ทั้งหมด
    ├── agents/                                 # 4 Sub-Agents (explorer, implementer, debugger, reviewer)
    ├── rules/                                  # กฎโหลดตาม Path ไฟล์
    ├── skills/                                 # ทักษะโหลดอัตโนมัติ (ชุดเดียวกับ .agents/skills)
    ├── commands/                               # คำสั่งลัด (/plan, /fix, /review, /handoff)
    └── hooks/                                  # 🛡️ สคริปต์ Dual-Mode (ทำงานได้ทั้ง Claude และ Antigravity)
        ├── auto-resume.sh                      # ฉีดสถานะงานค้างเข้าแชทใหม่อัตโนมัติ (SessionStart)
        ├── validate-bash.sh                    # บล็อก rm -rf, git restore/checkout ทับโค้ด, และการลง pkg มั่ว
        ├── protect-sensitive-files.sh          # บล็อกการแก้ไขไฟล์ .env, .pem, .key, และ lockfiles
        ├── loop-circuit-breaker.sh             # บล็อกเมื่อ AI รันคำสั่งเทสต์/บิลด์เดิมซ้ำเกิน 3 ครั้ง
        └── post-edit-format.sh                 # จัด Format อัตโนมัติ + บันทึกจุด Checkpoint ล่าสุด
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
* **สำหรับใส่ในโปรเจกต์เดิมที่มีอยู่แล้ว:** คัดลอกไฟล์ `AGENTS.md`, `CLAUDE.md`, `.agents/`, และ `.claude/` ไปวางที่ Root ของโปรเจกต์เดิม แล้วรัน `chmod +x .claude/hooks/*.sh`

### 2. ปรับข้อมูลเฉพาะโปรเจกต์ของคุณ (3 บรรทัดบนสุด)
เปิดไฟล์ `AGENTS.md` และ `CLAUDE.md` แล้วอัปเดตคำสั่งรันจริงของโปรเจกต์คุณ ởส่วนบนสุด:
```markdown
- **Stack:** Next.js 15, TypeScript, Prisma, PostgreSQL
- **Build / Typecheck:** `pnpm build` | `npx tsc --noEmit`
- **Test (Single File Preferred):** `pnpm test <path>`
```

---

## 💬 วิธีใช้งานในชีวิตประจำวัน (พิมพ์แค่ความต้องการ ไม่ต้องจำคำสั่ง)

ระบบมี **Zero-Command Auto-Routing** คุณสามารถพิมพ์สั่งงานตามปกติได้เลย:

1. **สั่งสร้างหรือแก้ฟีเจอร์ทั่วไป:**
   > *"เพิ่มปุ่มยกเลิกออเดอร์ในหน้า Order Detail และเช็กสถานะก่อนยกเลิก"*
   * AI จะประเมินขนาดงาน แก้เฉพาะจุดที่เกี่ยวข้อง และรันเทสต์ยืนยันผลจริงก่อนตอบกลับ
2. **สั่งแก้บั๊ก:**
   > *"เทสต์หน้าคำนวณส่วนลดพัง ช่วยเช็กและแก้ให้หน่อย"*
   * AI จะใช้กฎ **0-Strike** (ถ้าขาดสเปกธุรกิจจะถามทันที ไม่เดามั่ว) และ **2-Strike** (ถ้าลองแก้ทางเทคนิค 2 ครั้งยังไม่ผ่าน จะคืนค่าไฟล์เดิมและสรุปทางเลือกให้คุณตัดสินใจ)
3. **สั่งตรวจโค้ด:**
   > *"ช่วยรีวิวโค้ดที่เพิ่งแก้ไปหน่อย"* (หรือพิมพ์ `/review` ใน Claude Code)
   * AI จะตรวจเฉพาะจุดที่เป็น **`[BLOCKER]`** เท่านั้น ไม่บ่นเรื่องจุกจิก และจบภายในไม่เกิน 2 รอบ
4. **เมื่อโควต้า Claude Code หมดกลางคัน ➔ สลับมาเปิด Antigravity (หรือสลับกลับ):**
   * เปิดอีกโปรแกรมขึ้นมา ระบบ `auto-resume.sh` จะดึงจุดที่ทำค้างไว้จาก `.agent-last-state.log` และ `git status` เข้าสู่ระบบอัตโนมัติ
   * คุณแค่พิมพ์ต่อสั้นๆ ว่า:
     > *"ทำส่วนที่ค้างไว้ต่อให้เสร็จเลย"*
