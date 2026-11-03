---
name: db-migration
description: โหลดอัตโนมัติเมื่อมีการแก้ Schema ฐานข้อมูล สร้างตารางใหม่ เพิ่มคอลัมน์ หรือรัน Migration
---
# Safe Database Schema & Zero-Downtime Migration Protocol

ใช้เมื่อต้องสร้างตารางใหม่ แก้ไขคอลัมน์ เขียนไฟล์ Migration (เช่น Prisma, Drizzle, TypeORM, Knex, Alembic, หรือ Raw SQL) หรือปรับจูน Query

## 1. กฎความปลอดภัยของไฟล์ Migration (Migration Integrity)
1. **Immutable History:** ห้ามแก้ไขหรือลบไฟล์ Migration เก่าที่ถูก Commit หรือรันไปแล้วเด็ดขาด หากต้องการปรับโครงสร้างต้องสร้างไฟล์ Migration ใหม่เสมอ
2. **Backward-Compatible Changes (Expand & Contract Pattern):**
   - เมื่อเพิ่มคอลัมน์ใหม่ในตารางที่มีข้อมูลอยู่แล้ว ต้องกำหนดให้เป็น `NULLABLE` หรือมีค่า `DEFAULT` เสมอ เพื่อไม่ให้ Migration พังตอนรันจริง
   - ห้ามใช้คำสั่งที่ทำลายข้อมูลทันที เช่น `DROP TABLE`, `DROP COLUMN`, หรือ `TRUNCATE` โดยไม่ได้รับคำยืนยันเป็นลายลักษณ์อักษรจากผู้ใช้ก่อน

## 2. มาตรฐานการออกแบบตารางและ ประสิทธิภาพ (Schema & Indexing Checklist)
1. **Indexing:**
   - ทุกคอลัมน์ที่เป็น `Foreign Key` (เช่น `user_id`, `order_id`) ต้องมี Index รองรับเสมอ
   - คอลัมน์ที่ใช้ค้นหาใน `WHERE`, `JOIN`, หรือเรียงลำดับใน `ORDER BY` บ่อยๆ ต้องระบุ Index ให้ชัดเจน
2. **Prevent N+1 Queries:**
   - ห้ามเขียนคำสั่งคิวรีฐานข้อมูลไว้ข้างในลูป `for` / `map` ให้ใช้ `WHERE id IN (...)`, `JOIN`, หรือ `include`/`preload` แทนเสมอ
3. **Data Isolation & Transactions:**
   - การแก้ไขข้อมูลที่กระทบหลายตารางพร้อมกัน (เช่น การตัดสต็อกพร้อมสร้างใบเสร็จ หรือการโอนเงิน) ต้องอยู่ใน Database Transaction (`$transaction` / `BEGIN...COMMIT`) เสมอ
   - ห้ามใช้ `SELECT *` โดยไม่จำกัดจำนวนแถว (`LIMIT` / `take`) สำหรับตารางที่มีโอกาสเติบโตสูง
