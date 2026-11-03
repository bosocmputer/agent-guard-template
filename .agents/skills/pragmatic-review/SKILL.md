---
name: pragmatic-review
description: Use when reviewing code changes or diffs for logic bugs and security vulnerabilities using a Blocker-Only policy capped at 2 rounds (ใช้เมื่อต้องการตรวจรีวิวโค้ดเฉพาะจุดที่เป็น Blocker ไม่เกิน 2 รอบ)
---
# Pragmatic Code & Security Review (Convergence Circuit Breaker)

ใช้เมื่อต้องตรวจสอบคุณภาพและความปลอดภัยของโค้ด โดยมีเป้าหมายหลักคือ **การทำให้โค้ดพร้อมใช้งานอย่างรวดเร็ว (Convergence)** ไม่ใช่การจับผิดจุกจิกไม่รู้จบ

## 1. กฎเหล็ก Blocker-Only Policy (สิ่งที่ต้องตรวจ vs สิ่งที่ห้ามติ)

### 🔴 สิ่งที่ต้องรายงาน (`[BLOCKER]` เท่านั้น):
1. **Broken Logic & Edge Cases:** บั๊กที่ทำให้โปรแกรมพัง คำนวณเงิน/จำนวนผิดพลาด ค่า `null`/`undefined`/`NaN` ที่ทำให้ระบบล่ม หรือการเรียกซ้ำแล้วข้อมูลเพี้ยน (Idempotency/Double-submit)
2. **Security Vulnerabilities:**
   - ลืมตรวจสิทธิ์เข้าถึงข้อมูล (Missing Auth / IDOR)
   - ช่องโหว่ SQL Injection, XSS, Command Injection
   - ข้อมูลความลับ (API Key, Token, Password, PII) หลุดออกไปใน Response หรือ Log
3. **Data Loss & Race Conditions:** การตัดสต็อกหรือเงินโดยไม่ตรวจยอดก่อน หรือไม่มี Transaction รองรับ
4. **Severe Performance Issues:** การยิง N+1 Query ในลูป หรือการดึงข้อมูลทั้งตารางโดยไม่มี Limit

### ⚪ สิ่งที่ห้ามนำมารายงานเด็ดขาด (Ignore Nitpicks):
- ความสวยงามของการจัดย่อหน้า การเว้นบรรทัด หรือเครื่องหมาย `;` (เป็นหน้าที่ของ Prettier/Linter)
- การตั้งชื่อตัวแปรภายในฟังก์ชันสั้นๆ ที่ไม่ได้ทำให้เกิดบั๊ก
- การแนะนำให้เขียนโค้ดใหม่ด้วยสไตล์ส่วนตัวที่มีผลลัพธ์การทำงานเหมือนเดิมทุกประการ

---

## 2. กฎป้องกันการวนลูปรีวิว (Convergence & Hard Cap `MAX_ROUNDS = 2`)
- **รอบที่ 1 (Round 1 of 2):** ตรวจ `git diff` หรือไฟล์ที่ระบุ หากพบปัญหาในกลุ่ม 🔴 ให้รายงานเฉพาะ `[BLOCKER]` พร้อมวิธีแก้ที่ชัดเจน
- **รอบที่ 2 (Round 2 of 2 — No Moving Goalposts):**
  - ตรวจเฉพาะว่า `[BLOCKER]` จากรอบที่ 1 ได้รับการแก้ไขครบหรือยัง
  - รันเทสต์ของไฟล์นั้น 1 ครั้งเพื่อยืนยันว่าการแก้ Blocker ไม่ได้ทำให้เทสต์เดิมพัง (Regression Check)
  - **ห้ามขุดประเด็นใหม่ในโค้ดส่วนอื่นที่ไม่ได้เพิ่งแก้ขึ้นมาติในรอบที่ 2 เด็ดขาด**

---

## 3. รูปแบบคำตัดสินมาตรฐาน (Required Verdict Output)
บรรทัดแรกของผลการรีวิวต้องขึ้นต้นด้วยคำตัดสินใดคำตัดสินหนึ่งต่อไปนี้เสมอ:

- กรณีไม่พบ `[BLOCKER]` และเทสต์ผ่าน:
  ```markdown
  VERDICT: APPROVE
  - ตรวจสอบโค้ดและผลการรันเทสต์เรียบร้อยแล้ว ไม่พบปัญหาในระดับ Blocker
  ```
- กรณีพบ `[BLOCKER]`:
  ```markdown
  VERDICT: CHANGES_REQUESTED
  - **[BLK-01] [หมวดหมู่ปัญหา] (`ชื่อไฟล์:เลขบรรทัด`)**
    - **ปัญหา:** [อธิบายสั้นๆ ว่าทำไมถึงพังหรือเสี่ยงอย่างไร]
    - **วิธีแก้:** [ระบุโค้ดหรือเงื่อนไขที่ต้องแก้ให้ชัดเจน]
  ```
- กรณีครบ 2 รอบแล้วยังตกลงแนวทางแก้ไม่ได้:
  ```markdown
  VERDICT: ESCALATE_TO_USER
  - [สรุปประเด็นที่ติดขัด 2 บรรทัดเพื่อให้ผู้ใช้ตัดสินใจ]
  ```
