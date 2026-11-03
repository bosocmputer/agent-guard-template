ตรวจสอบความพร้อมของโค้ดแบบ Full-Stack Verification (ห้ามรัน Dev Server ค้างไว้จนบล็อกแชท):
1. รัน Unit Test ของไฟล์ที่เกี่ยวข้อง
2. รัน Typecheck / Build (`npx tsc --noEmit` หรือ `npm run build`)
3. หากมีการแก้ API/Server ให้เช็กพอร์ตด้วย `lsof -i` และยิง Smoke Check ด้วย `curl` เพื่อยืนยันว่าระบบตอบกลับจริง
สรุปผลลัพธ์จริงพร้อมคำสั่งที่รันทุกขั้นตอน
