---
name: tech-stack-skills
description: Use when initializing a project, declaring the project tech stack, or installing framework-specific skills from jeffallan/claude-skills (ใช้เมื่อเริ่มโปรเจกต์ใหม่หรือต้องการดึง Skill เฉพาะทางของภาษามาติดตั้ง)
---
# On-Demand Tech Stack Skill Installer (`jeffallan/claude-skills`)

ใช้สำหรับดึงคู่มือผู้เชี่ยวชาญเฉพาะทางของแต่ละภาษา/Framework จากคลัง [`jeffallan/claude-skills`](https://github.com/jeffallan/claude-skills) มาติดตั้งในโปรเจกต์แบบคัดเฉพาะตัวที่ใช้จริง

## 1. กฎเหล็กประหยัดโควต้า (Selective Cherry-Picking Rule)
- ในคลัง `jeffallan/claude-skills` มีทั้งหมดกว่า 67 Skills **ห้ามติดตั้งทั้งหมดลงในโปรเจกต์เดียวเด็ดขาด** เพราะชื่อและคำอธิบายของทุก Skill จะถูกโหลดเข้า Context ทุกเทิร์น
- ให้เลือกติดตั้ง **เฉพาะ 2–4 Skills ที่ตรงกับ Tech Stack ของโปรเจกต์นี้จริงๆ เท่านั้น**

## 2. ตารางจับคู่ Tech Stack กับชื่อ Skill ที่ควรติดตั้ง

| หมวดหมู่ของโปรเจกต์ | ชื่อ Skill ที่สามารถสั่งติดตั้งได้ |
| :--- | :--- |
| **Frontend Web & Mobile** | `react-expert`, `vue-expert`, `angular-expert`, `tailwind-expert`, `react-native-expert`, `ui-ux-designer`, `accessibility-engineer` |
| **Backend Frameworks** | `nestjs-expert`, `fastapi-expert`, `django-architect`, `laravel-specialist`, `java-architect` |
| **Systems & Languages** | `typescript-pro` *(หรือใช้คู่กับ `react-expert`/`nestjs-expert`)*, `python-expert`, `go-engineer`, `rust-engineer` |
| **API, Database & Architecture** | `api-designer`, `database-architect`, `graphql-expert`, `architecture-designer`, `microservices-architect` |
| **Testing & QA** | `playwright-expert`, `test-master`, `fullstack-guardian` |
| **DevOps, Cloud & Security** | `docker-expert`, `kubernetes-expert`, `terraform-expert`, `cloud-architect`, `ci-cd-engineer`, `auth-expert`, `security-auditor` |

## 3. ขั้นตอนการติดตั้งอัตโนมัติ (Dual-Agent Installation)
เมื่อทราบ Tech Stack จากผู้ใช้ (หรือตรวจพบจากไฟล์ `package.json` / `pyproject.toml` / `go.mod`) ให้รันสคริปต์ต่อไปนี้:

```bash
bash .claude/hooks/install-skill.sh <skill-1> <skill-2>
```

### สิ่งที่สคริปต์ `install-skill.sh` ทำให้โดยอัตโนมัติ:
1. ใช้ `git clone --depth 1 --filter=blob:none --sparse` ดึงเฉพาะโฟลเดอร์ที่ระบุจาก GitHub (ใช้เวลาเพียง 2–3 วินาที ไม่โหลดทั้ง Repo)
2. คัดลอกทั้งไฟล์ `SKILL.md` และโฟลเดอร์ย่อย `references/` ไปวางให้ทั้ง 2 ฝั่งพร้อมกัน:
   - `.claude/skills/<skill-name>/` *(สำหรับ Claude Code)*
   - `.agents/skills/<skill-name>/` *(สำหรับ Antigravity / VS Code)*
3. รายงานรายชื่อ Skill ที่ติดตั้งสำเร็จให้ผู้ใช้ทราบสั้นๆ
