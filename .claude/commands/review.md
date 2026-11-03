เรียกใช้ `reviewer` sub-agent เพื่อตรวจโค้ดที่เปลี่ยนแปลงล่าสุด (`git diff`) โดยใช้กฎ Blocker-Only และจำกัดวงจรแก้ไขสูงสุดไม่เกิน 2 รอบ (MAX_ROUNDS = 2)
- หากได้ `VERDICT: APPROVE` ให้จบงานทันที
- หากได้ `VERDICT: CHANGES_REQUESTED` ให้แก้เฉพาะจุดที่เป็น `[BLOCKER]` แล้วส่งตรวจซ้ำอีกเพียง 1 รอบเท่านั้น
