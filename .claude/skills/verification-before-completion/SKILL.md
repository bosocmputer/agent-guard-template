---
name: verification-before-completion
description: โหลดอัตโนมัติทุกครั้งก่อนที่จะสรุปจบงาน ส่งมอบงาน หรือแจ้งผู้ใช้ว่าแก้ไข/ทดสอบเสร็จสิ้นแล้ว
---
# Iron Law of Verification & Full-Stack Smoke Check
ห้ามแจ้งว่างานเสร็จสิ้น หรือโค้ดทำงานได้ถูกต้อง โดยไม่มีหลักฐานการรันตรวจในรอบปัจจุบัน:

1. **Tier 1 — Unit / Logic Check:** รันเทสต์เฉพาะไฟล์ที่แก้ไข (เช่น `node --test <path>` หรือ `npm test -- <path>`)
2. **Tier 2 — Build / Type Check:** รัน `npx tsc --noEmit` หรือ `npm run build` เพื่อดักจับไฟล์อื่นที่พังจากการเปลี่ยน Type/Import
3. **Tier 3 — Runtime Smoke Check (เมื่อแก้ API / Full-Stack):**
   - **ห้ามรัน `npm run dev` ค้างไว้ใน Foreground จนบล็อกแชทเด็ดขาด!**
   - ให้เช็กพอร์ตก่อนด้วย `lsof -i :<port>` หากเซิร์ฟเวอร์รันอยู่แล้ว ให้ยิงทดสอบด้วย `curl -s -i http://localhost:<port>/...` เพื่อตรวจ HTTP Status และ Response จริง
4. **Honest Summary Format:** สรุปท้ายคำตอบสั้นๆ เสมอ:
   - **สิ่งที่แก้ไข:** (ระบุไฟล์และสิ่งที่เปลี่ยน 1–2 บรรทัด)
   - **หลักฐานการตรวจสอบ:** (ระบุคำสั่งที่รันจริง + ผลลัพธ์จริง หรือระบุตรงๆ ว่ายังไม่ได้รันเพราะอะไร)
