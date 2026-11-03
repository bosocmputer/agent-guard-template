---
paths:
  - "src/**/*"
---
# Surgical Changes & Anti-Over-Engineering (Karpathy Guidelines)
1. **Simplicity First:** เขียนโค้ดให้ตรงไปตรงมาที่สุด ห้ามสร้าง Abstract Class, Factory, หรือ Helper Function สำหรับโค้ดที่เรียกใช้แค่จุดเดียว
2. **Surgical Edits Only:** แก้เฉพาะบรรทัดที่จำเป็นต่องานที่สั่ง **ห้ามจัด Format, เปลี่ยนชื่อตัวแปร, หรือ Refactor โค้ดส่วนอื่นในไฟล์เดียวกันที่ไม่ได้เกี่ยวกับงาน (No Drive-by Refactoring)**
3. **No Speculative Code:** ห้ามเขียนโค้ดหรือ Config เผื่ออนาคตที่ยังไม่ได้ใช้งานจริงในงานนี้
4. **No Unrequested Files:** ห้ามสร้างไฟล์ `README.md`, `SUMMARY.md`, หรือไฟล์เอกสารสรุปงานใดๆ เว้นแต่ผู้ใช้สั่งโดยตรง
