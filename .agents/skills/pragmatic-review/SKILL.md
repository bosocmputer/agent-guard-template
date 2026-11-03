---
name: pragmatic-review
description: โหลดอัตโนมัติเมื่อผู้ใช้ขอให้ตรวจโค้ด รีวิวโค้ด หรือเช็กความถูกต้องของโค้ด โดยเน้นเฉพาะ Blocker และตัดลูปไม่ให้รีวิวซ้ำเกิน 2 รอบ
---
# Pragmatic Code & Security Review (Convergence Circuit Breaker)
1. **Blocker-Only Policy:** รายงานเฉพาะ **[BLOCKER]** (บั๊กพัง/คำนวณผิด, ข้อมูลสูญหาย, ช่องโหว่ความปลอดภัย Auth/Injection/Secrets, และ Performance รุนแรง) ห้ามติเรื่องความสวยงามหรือการตั้งชื่อตัวแปรเล็กน้อย
2. **No Moving Goalposts (รอบที่ 2):** หากตรวจซ้ำรอบที่ 2 ให้เช็กเฉพาะว่า Blocker เดิมถูกแก้แล้วและรันเทสต์ผ่าน ห้ามขุดประเด็นใหม่ในโค้ดส่วนอื่น
3. **Clear Verdict:** หากไม่พบ Blocker ให้ตอบบรรทัดแรกว่า `VERDICT: APPROVE` และจบการรีวิวทันที (จำกัดวงจรแก้ไขสูงสุดไม่เกิน 2 รอบ)
