---
paths:
  - "**/*.{test,spec}.{js,ts,tsx}"
  - "src/**/routes/**"
  - "src/**/controllers/**"
---
# Testing & API Conventions
- **Testing (AAA Pattern):** แบ่งโครงสร้างเทสต์เป็น Arrange, Act, Assert และห้ามแก้ไขเทสต์เดิมเพื่อให้ผ่านแบบผิดๆ
- **API Validation:** ตรวจสอบ Input ทุกครั้งก่อนส่งเข้า Business Logic และส่งกลับ Error Code ที่ชัดเจน
