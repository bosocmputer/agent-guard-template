---
paths:
  - "**/*.{test,spec}.{js,ts,tsx,py,go}"
  - "src/**/routes/**"
  - "src/**/controllers/**"
  - "src/**/services/**"
  - "src/app/api/**"
---
# Testing Standards, API Conventions & Error Handling

กฎมาตรฐานเมื่อต้องเขียนเทสต์ ออกแบบ API หรือจัดการ Business Logic

## 1. Unit & Integration Testing Standards
- **AAA Pattern:** จัดโครงสร้างทุก Test Case ให้ชัดเจนเป็น 3 ส่วน:
  1. `// Arrange` — เตรียมข้อมูลตั้งต้นและ Mock เฉพาะระบบภายนอก
  2. `// Act` — เรียกฟังก์ชันหรือ Endpoint ที่ต้องการทดสอบ
  3. `// Assert` — ตรวจสอบผลลัพธ์ที่คาดหวัง
- **Minimum Test Coverage for New Logic:** ทุกฟังก์ชันสำคัญที่สร้างใหม่หรือแก้บั๊ก ต้องมีเทสต์ครอบคลุมอย่างน้อย:
  - **Happy Path:** ข้อมูลปกติทำงานผ่านถูกต้อง
  - **Boundary / Validation Case:** ข้อมูลขาดหาย, ค่าเป็น `0` หรือติดลบ, หรือผิดชนิดข้อมูล
  - **Regression Case (กรณีแก้บั๊ก):** เทสต์ที่จำลองอาการบั๊กเดิมเพื่อยืนยันว่าแก้หายขาดแล้ว
- **No Tautological Mocks:** ห้าม Mock ฟังก์ชันตัวที่กำลังทดสอบอยู่ ให้ Mock เฉพาะ External I/O (เช่น API ภายนอก, การส่งอีเมล, เวลาปัจจุบัน) เท่านั้น

---

## 2. API Design & Boundary Validation
- **Validate at the Door:** ทุก Request Body, Query Params, และ Path Params ต้องผ่านการตรวจสอบความถูกต้อง (Validation) ก่อนส่งเข้าสู่ชั้น Service เสมอ
- **Strict Separation of Concerns:**
  - `Route / Controller`: รับ Request ➔ ตรวจ Validation/Auth ➔ เรียก Service ➔ ส่ง Response
  - `Service`: ประมวลผล Business Logic (ห้ามผูกกับ HTTP `req`/`res` โดยตรง)
  - `Repository / Data Access`: ติดต่อฐานข้อมูล (ห้ามนำคอลัมน์ความลับ เช่น `passwordHash` ออกนอกชั้นนี้)
- **Consistent Error Handling:**
  - ห้ามใช้ `catch (err) {}` เปล่าที่กลืน Error หายไปเงียบๆ
  - ส่งกลับ HTTP Status Code ที่ตรงความหมาย: `200/201` (สำเร็จ), `400` (ข้อมูลขาเข้าผิด), `401` (ยังไม่ล็อกอิน), `403` (ไม่มีสิทธิ์เข้าถึง), `404` (ไม่พบข้อมูล), `409` (ข้อมูลซ้ำ/ขัดแย้ง), `500` (ข้อผิดพลาดระบบ)
