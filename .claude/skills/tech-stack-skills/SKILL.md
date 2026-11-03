---
name: tech-stack-skills
description: โหลดอัตโนมัติเมื่อผู้ใช้เริ่มต้นโปรเจกต์ใหม่ แจ้ง Tech Stack ที่ใช้ หรือขอให้ติดตั้ง Skill เฉพาะทางเพิ่มเติมจาก jeffallan/claude-skills
---
# On-Demand Tech Stack Skill Installer (jeffallan/claude-skills)
เมื่อผู้ใช้ระบุ Tech Stack ของโปรเจกต์ หรือขอให้เพิ่มความรู้เฉพาะทางของ Framework (เช่น React, NestJS, FastAPI, Vue, Go, Rust, Playwright, Docker, Kubernetes):

1. **เลือกเฉพาะไม่เกิน 2–4 Skills ที่ตรงกับโปรเจกต์จริง** (ห้ามลงทั้งหมดเพื่อประหยัด Context Token):
   - **Frontend:** `react-expert`, `vue-expert`, `angular-expert`, `tailwind-expert`, `react-native-expert`
   - **Backend:** `nestjs-expert`, `fastapi-expert`, `django-architect`, `go-engineer`, `rust-engineer`, `java-architect`, `python-expert`
   - **API / DB / Arch:** `api-designer`, `database-architect`, `graphql-expert`, `architecture-designer`
   - **Testing / DevOps / Security:** `playwright-expert`, `test-master`, `docker-expert`, `kubernetes-expert`, `terraform-expert`, `ci-cd-engineer`, `auth-expert`, `security-auditor`
2. **รันคำสั่งติดตั้งอัตโนมัติลงทั้ง `.claude/skills/` และ `.agents/skills/`:**
   ```bash
   bash .claude/hooks/install-skill.sh <skill-1> <skill-2>
   ```
3. เมื่อติดตั้งเสร็จแล้ว Skill เหล่านั้นจะถูกโหลดอัตโนมัติเมื่อคุณแก้ไขไฟล์ใน Stack นั้นทันที
