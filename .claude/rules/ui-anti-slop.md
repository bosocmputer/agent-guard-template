---
paths:
  - "**/*.{tsx,jsx,vue,svelte,html,css,scss}"
  - "lib/**/*.dart"
  - "src/**/components/**"
  - "src/**/pages/**"
  - "src/**/app/**"
---
# UI Anti-Slop & Production Design Standards (`heydamir/unslop` 1-Pass Protocol)

> **Reference Architecture:** [`heydamir/unslop`](https://github.com/heydamir/unslop) (9-Dimension Anti-Slop UI Audit condensed into 1-Pass Prevention)
> **Activation:** โหลดอัตโนมัติเฉพาะเมื่อสร้างหรือแก้ไขไฟล์ Frontend Web (`React`, `Next.js`, `Vue`) หรือ Mobile (`Flutter / Dart`) เท่านั้น (ไม่กินโควต้างาน Backend)

## 1. The Iron Law of UI Implementation
> **NO GENERIC "AI SLOP" UI — APPLY ALL 9 DESIGN DIMENSIONS IN A SINGLE PASS.**

ห้ามเขียน UI แบบบล็อกสำเร็จรูปของ AI แล้วค่อยมาวนแก้ 9 รอบทีหลัง ให้บังคับใช้มาตรฐานทั้ง 9 ด้านตั้งแต่การเขียนโค้ดรอบแรก:

### 1. Icons (ห้ามวาด `<svg>` เอง และห้ามใช้ Emoji แทนไอคอน)
- **ห้ามเด็ดขาด:** ห้ามเขียนแท็ก `<svg><path d="..."/></svg>` เองด้วยมือ และห้ามนำ Emoji (เช่น 🚀, ✨, 📊, 🔒) มาวางเป็นไอคอนหน้าปุ่ม เมนู หรือหัวข้อเด็ดขาด
- **ไลบรารีมาตรฐานที่ต้องใช้:**
  - **Web (React / Next.js / Vue):** ใช้ `lucide-react` (`lucide-icons`) สำหรับไอคอนระบบ และใช้ `simple-icons` สำหรับโลโก้แบรนด์
  - **Flutter / Dart:** ใช้ `lucide_icons` หรือ `Icons.*` มาตรฐานของ Material/Cupertino

### 2. Color & Gradients (ห้ามใช้สีม่วง-น้ำเงินไล่เฉดแบบ AI)
- ห้ามใช้สีม่วงไล่เฉด (`from-indigo-500 via-purple-500 to-pink-500`), ขอบเรืองแสงนีออน (unearned neon glows), หรือพื้นหลังรุ้งที่ไม่ได้อยู่ใน Design System ของโปรเจกต์
- ใช้พื้นหลังสีพื้นสะอาดตา (Neutral Slate/Zinc/Gray) และใช้สีหลัก (Primary Accent) เพียง 1 สีเฉพาะจุดที่ต้องการให้ผู้ใช้กด (Call-to-Action)

### 3. Spacing & Rhythm (ระบบระยะห่างที่สม่ำเสมอ)
- ใช้สเกลระยะห่างมาตรฐาน `4px / 8px` (`gap-2`, `gap-4`, `gap-6`, `p-4`, `p-6`) อย่างสม่ำเสมอ
- ห้ามเว้นระยะขอบด้านในของการ์ด (`padding`) น้อยกว่าระยะห่างระหว่างการ์ด (`gap`) จนเนื้อหาเบียดขอบ

### 4. Typography Hierarchy (ลำดับขั้นของตัวอักษร)
- แยกความต่างของหัวข้อหลัก (`font-semibold tracking-tight`), หัวข้อย่อย, และเนื้อหารอง (`text-sm text-muted-foreground`) ให้ชัดเจนด้วยน้ำหนักและสี ไม่ใช่แค่ขยายขนาดตัวอักษรอย่างเดียว
- ตัวเลขในตารางหรือราคาเงินต้องใส่ `tabular-nums` (`FontFeature.tabularFigures()` ใน Flutter) เพื่อให้หลักตัวเลขตรงกันเสมอ

### 5. Copywriting (ข้อความกระชับ ไม่ใช้คำโฆษณาเวอร์เกินจริง)
- ห้ามเขียนข้อความสไตล์ AI Marketing เช่น *"Revolutionize your workflow with AI-powered synergy!"*
- ใช้ข้อความที่บอกหน้าที่ตรงไปตรงมา เช่น *"บันทึกข้อมูล"*, *"รายการคำสั่งซื้อ"*, *"ไม่พบข้อมูลที่ค้นหา"*

### 6. Layout & Alignment (การจัดวางที่ได้สัดส่วน)
- หลีกเลี่ยงการวางการ์ด 3 ใบเรียงกันแบบไร้ความหมายทุกหน้า ให้เลือกโครงสร้างตามข้อมูลจริง (เช่น Table สำหรับข้อมูลเปรียบเทียบ, Split View สำหรับตั้งค่า)
- จัดแนวเส้นขอบซ้าย (Left Alignment) ของหัวข้อ ฟอร์ม และตารางให้ตรงแนวเดียวกัน

### 7. Interactive Details & States (ครบทุกสถานะการใช้งานจริง)
- ทุกหน้าจอที่ดึงข้อมูลหรือมีปุ่มกด ต้องรองรับสถานะ `Loading` (Skeleton/Spinner), `Empty State` (เมื่อยังไม่มีข้อมูล), และ `Error State` เสมอ
- ปุ่มและช่องกรอกข้อมูลต้องมี `focus-visible`, `hover`, และ `disabled` state ที่ชัดเจน

### 8. Visuals & Media (รูปภาพและสัดส่วน)
- กำหนด `aspect-ratio` และ `object-cover` ให้รูปภาพเสมอเพื่อป้องกันหน้าจอกระตุก (Layout Shift)

### 9. Subtle Motion (แอนิเมชันที่พอดี)
- ใช้ Transition เฉพาะจุดที่ช่วยบอกสถานะ (`150ms–200ms ease-out`) ห้ามใส่แอนิเมชันเด้งหรือหมุนค้างที่รบกวนสายตาผู้ใช้
