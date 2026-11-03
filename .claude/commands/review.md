# /review — ตรวจคุณภาพและความปลอดภัยของโค้ด (Blocker-Only & Max 2 Rounds)

เรียกใช้ `reviewer` sub-agent (หรือโปรโตคอล `pragmatic-review`) เพื่อตรวจโค้ดที่เปลี่ยนแปลงล่าสุด (`git diff`):
$ARGUMENTS

## กฎการตัดลูป Non-Converging Review:
1. **Blocker-Only:** รายงานเฉพาะจุดที่เป็น `[BLOCKER]` (บั๊กคำนวณผิด/ระบบพัง, ข้อมูลสูญหาย, ช่องโหว่ความปลอดภัย Auth/Injection/Secrets) ห้ามติเรื่องความสวยงามหรือการตั้งชื่อตัวแปรเล็กน้อย
2. **Round 1:** หากได้ `VERDICT: APPROVE` ให้จบงานทันที หากได้ `VERDICT: CHANGES_REQUESTED` ให้แก้ไขเฉพาะจุดที่เป็น `[BLOCKER]` ด้วย Surgical Edit
3. **Round 2 (เพดานสูงสุด):** ตรวจยืนยันเฉพาะว่า `[BLOCKER]` เดิมถูกแก้แล้ว และรันเทสต์ของไฟล์นั้นผ่าน (ห้ามขุดประเด็นใหม่ในโค้ดส่วนอื่น) แล้วจบด้วย `VERDICT: APPROVE`
