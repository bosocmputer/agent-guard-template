# 🛡️ Agent Guard Template

**Template ตั้งต้นสำหรับใช้ AI เขียนโค้ด (รองรับทั้ง Claude Code และ Antigravity ใน VS Code)**

ช่วยให้ AI ทำงานตามสั่งอย่างตรงจุด **ไม่เดามั่ว ไม่วนลูปผลาญโควต้า ไม่เขียนโค้ดเวิ่นเว้อ** และสามารถ **สลับโปรแกรมทำต่อได้ทันทีเมื่อโควต้าฝั่งใดฝั่งหนึ่งหมดกลางคัน** โดยที่คุณไม่ต้องจำคำสั่งพิเศษใดๆ (พิมพ์สั่งงานด้วยภาษาพูดตามปกติได้เลย)

---

## 🤔 ทำไมต้องใช้ Template นี้? (เปรียบเทียบให้เห็นภาพ)

เวลาเราใช้ AI เขียนโค้ดในโปรเจกต์เปล่าๆ เรามักเจอปัญหาเหล่านี้:

| ปัญหาที่เจอประจำ (เมื่อไม่ใช้ Template) | สิ่งที่เกิดขึ้นเมื่อใช้ `agent-guard-template` |
| :--- | :--- |
| 💸 **เปลืองโควต้าฟรี:** สั่งแก้บั๊กนิดเดียว แต่ AI เดาแก้แล้วรันเทสต์พังวนไป 10 รอบจนโควต้าหมด | 🛑 **หยุดเมื่อตัน (2-Strike Limit):** ถ้า AI ลองแก้ 2 ครั้งแล้วยังไม่ผ่าน ระบบจะบังคับหยุด คืนค่าไฟล์เดิม แล้วสรุปทางเลือกมาถามคุณทันที |
| 🤯 **คิดเองเออเอง:** สั่งทำฟีเจอร์สั้นๆ AI ดันคิดสูตรธุรกิจเองมั่วๆ พอทำเสร็จต้องสั่งรื้อใหม่หมด | 🤝 **ถามก่อนมั่ว (`common-ground` & `0-Strike`):** ถ้าข้อมูลสำคัญขาดหาย AI จะสรุปสิ่งที่มันเข้าใจ 3–4 ข้อมาถามคุณสั้นๆ ก่อนลงมือเขียนโค้ด |
| 🐘 **โค้ดบวมเกินสั่ง:** สั่งแก้ปุ่มเดียว แต่ AI แถมเปลี่ยนชื่อตัวแปรและรื้อไฟล์ข้างเคียงมาให้เพียบ | ✂️ **แก้เฉพาะจุด (Surgical Edit):** แก้เฉพาะบรรทัดที่สั่ง ไม่แตะโค้ดส่วนอื่นที่ไม่ได้ขอ (จากการทดสอบจริงช่วยลดโค้ดส่วนเกินลง 40–65%) |
| 🎨 **หน้าเว็บ/แอปดูเป็น AI ราคาถูก:** ชอบใช้สีม่วงไล่เฉด วาด `<svg>` เบี้ยวๆ เอง หรือเอา Emoji มาแปะแทนไอคอน | ✨ **สวยระดับ Production ในรอบเดียว (`ui-anti-slop`):** บังคับเกณฑ์ออกแบบ 9 ด้านอัตโนมัติเมื่อแตะไฟล์เว็บ/Flutter (ใช้ `lucide-react` / `lucide_icons` ห้ามวาด SVG เอง) |
| 🔄 **รีวิวไม่รู้จบ:** พอสั่งให้ตรวจโค้ด ก็จับผิดเรื่องจุกจิก (เช่น ชื่อตัวแปร/ย่อหน้า) แก้ไปมาไม่จบสักที | ✅ **ตรวจเฉพาะจุดตาย (Blocker-Only):** ตรวจเฉพาะบั๊กที่ทำให้ระบบพังหรือรั่วไหล พอแก้เสร็จและเทสต์ผ่านจะอนุมัติ (`APPROVE`) จบงานใน 2 รอบ |
| 🔌 **โควต้าตัดกลางอากาศ:** กำลังทำค้างไว้ใน Claude Code แล้วโควต้าหมด ต้องมานั่งพิมพ์เล่าใหม่ใน VS Code | 🏃 **ส่งไม้ต่ออัตโนมัติ (Auto-Handoff):** บันทึกจุดที่แก้ค้างไว้ทุกครั้งอัตโนมัติ พอเปิดอีกโปรแกรมขึ้นมา แค่พิมพ์ว่า *"ทำต่อเลย"* ก็ลุยต่อได้ทันที |

---

## 🚀 วิธีติดตั้ง (ใช้เวลาไม่ถึง 2 นาที)

### วิธีที่ 1: เริ่มโปรเจกต์ใหม่
กดปุ่มสีเขียว **"Use this template"** ด้านบนของหน้า GitHub นี้ หรือรันคำสั่ง:
```bash
git clone https://github.com/bosocmputer/agent-guard-template.git my-project
cd my-project
chmod +x .claude/hooks/*.sh
```

### วิธีที่ 2: นำไปใส่ในโปรเจกต์เดิมที่มีอยู่แล้ว
ก๊อปปี้แค่ 4 ส่วนนี้ไปวางที่โฟลเดอร์นอกสุด (Root) ของโปรเจกต์คุณ:
1. ไฟล์ `AGENTS.md`
2. ไฟล์ `CLAUDE.md`
3. โฟลเดอร์ `.agents/`
4. โฟลเดอร์ `.claude/`

จากนั้นรันคำสั่งเปิดสิทธิ์สคริปต์ 1 ครั้ง:
```bash
chmod +x .claude/hooks/*.sh
```

### วิธีที่ 3: อัปเดตโปรเจกต์เดิมที่ใช้ Template เวอร์ชันเก่าอยู่แล้ว
รันคำสั่งนี้ที่โฟลเดอร์นอกสุดของโปรเจกต์เดิม เพื่ออัปเดตเฉพาะไฟล์มาตรฐานของ Template โดย**ไม่ลบ** Skill เสริมที่เคยดึงเพิ่มไว้ (`install-skill.sh`) และไม่กระทบโค้ดในโปรเจกต์:
```bash
git clone --depth 1 https://github.com/bosocmputer/agent-guard-template.git /tmp/agt-update && \
rsync -a /tmp/agt-update/CLAUDE.md /tmp/agt-update/AGENTS.md /tmp/agt-update/.claude /tmp/agt-update/.agents ./ && \
chmod +x .claude/hooks/*.sh && \
rm -rf /tmp/agt-update
```

---

## 🖥️ ศูนย์บัญชาการและจอมอนิเตอร์ 3D เรียลไทม์ (`3D Command & Monitor Center`)

Template นี้มาพร้อมหน้าจอ **3D Command & Monitor Center** (สร้างด้วยมาตรฐาน [`mrdoob/three.js`](https://github.com/mrdoob/three.js) `r187` แบบไฟล์เดียวจบใน `.claude/hud/index.html` ไม่ต้อง `npm install` ไม่เพิ่ม `node_modules` ลงในโปรเจกต์) สำหรับเปิดเป็นจอมอนิเตอร์ดูการทำงานของ AI สดๆ หรือใช้พิมพ์สั่งงานแทน CLI ได้ทันที:

```bash
bash .claude/hooks/open-hud.sh
```

### สิ่งที่ทำได้บนหน้าจอ 3D Command & Monitor Center:
1. **แสดงสถาปัตยกรรม 3D สดตามจังหวะ Hook จริง (0 Token Cost):**
   * **แกนกลาง `Sentinel Core`:** เปลี่ยนสีและความเร็วตามสถานะจริง (`READY` สีเขียวมรกต ➔ `WORKING` สีฟ้า ➔ `WARNING` สีเหลืองอำพัน ➔ `CIRCUIT BREAKER / BLOCKED` กางกรงล็อก 3D สีแดง)
   * **ดาวบริวารลูกมือ 4 ดวง (`ADK 2.0 Subagent Graph`):** ยิงลำแสงข้อมูล (`State-Delta Packet`) ไปยังโหนด `Explorer [Haiku]`, `Implementer [Sonnet]`, `Debugger [Sonnet]`, หรือ `Reviewer [Sonnet]` ตามงานที่กำลังรันจริง
   * **โหนดไฟล์ที่ถูกแตะ (`Touched File Satellites`):** สร้างคริสตัล 3D พร้อมป้ายชื่อไฟล์ลอยรอบโหนด `Implementer` ทุกครั้งที่มีการแก้โค้ด ช่วยเช็กขอบเขต `Surgical Edit` ด้วยสายตา
2. **ตรวจเช็ก % โควต้าคงเหลือจริงของทั้ง 2 ค่าย (`Live Provider Quota Monitor`):**
   * ดึงค่า **% โควต้าคงเหลือราย 5 ชั่วโมง (`5-Hour Remaining %`)** และ **รายสัปดาห์ (`7-Day Remaining %`)** พร้อมเวลา Reset จริงจาก CLI ของทั้ง **Claude Code** (`control_request: get_usage`) และ **Antigravity / Google AI Ultra** (`agy -p /usage`)
3. **สั่งงาน AI และสลับค่ายจากหน้าจอ 3D ได้โดยตรง:**
   * มีช่องพิมพ์คำสั่งด้านล่างจอ เลือกสลับระหว่าง **`Claude Code CLI`** กับ **`Antigravity CLI (agy)`** และเลือก Model (`Sonnet`, `Opus`, `Haiku`, `Gemini 4 Argon`, `Claude 5.5`) ได้ในคลิกเดียว
   * เมื่อค่ายใดค่ายหนึ่งโควต้าหมด กดปุ่ม **`[Switch & Resume]`** บนจอ 3D เพื่อสลับค่ายและสั่งลุยงานที่ค้างไว้ต่อได้ทันที
4. **ประหยัดพลังงานอัตโนมัติ (`Smart Eco FPS`):**
   * เมื่อพับหน้าต่างเบราว์เซอร์จะหยุดใช้การ์ดจอทันที และเมื่อ AI พักรอคำสั่งเกิน 6 วินาทีจะลดความเร็วลงเหลือ `12 FPS (ECO)` อัตโนมัติ (ถ้าไม่ได้รัน `open-hud.sh` จะไม่เปิดเซิร์ฟเวอร์และไม่กินทรัพยากรเครื่องเลย)
   * *(หมายเหตุตามจริง: ข้อมูลสถานะบนจอ 3D อัปเดตตามจังหวะ Event ของระบบ Hook ได้แก่ ตอนส่งคำสั่ง, ตอนเริ่มใช้เครื่องมือค้นหา/แก้ไฟล์/รันเทสต์, และตอนจบงาน ไม่ได้ดึงข้อความคิดในใจแบบไหลทีละตัวอักษร)*

---

## 🎯 วิธีเลือก Model ใน Claude Code (VS Code Extension / CLI) สำหรับมือใหม่

หลายคนโควต้าหมดไวเพราะเผลอเปิดโมเดลตัวแพงสุดทิ้งไว้ตลอดเวลา ใน **Claude Code** จะมีโมเดลหลักให้เลือกดังนี้ครับ:

| ชื่อ Model ใน Claude Code | เปรียบเทียบให้เข้าใจง่าย | กินโควต้าแค่ไหน? | ควรเลือกใช้ตอนไหน? |
| :--- | :--- | :---: | :--- |
| **🟢 `Sonnet` (ค่าเริ่มต้นที่แนะนำ)** | **ช่างฝีมืออาวุโส (Senior Dev)** เขียนโค้ดเก่ง ไว และทำตามกฎใน Template ได้ครบ | **ประหยัด คุ้มค่าที่สุด** | **ใช้เป็นตัวหลัก 85% ของเวลาทั้งหมด** (สร้างฟีเจอร์, แก้โค้ด, เขียนเทสต์, แก้บั๊กทั่วไป) |
| **🟣 `Opus`** | **สถาปนิกใหญ่ (Architect)** คิดวิเคราะห์ซับซ้อนเก่งมาก แต่ทำงานช้ากว่า | **กินโควต้าหนักมาก (หมดไวกว่าหลายเท่า)** | **ใช้เฉพาะ 15% ของงาน** ตอนคิดโครงสร้างระบบใหญ่ หรือตอนแก้บั๊กที่ `Sonnet` ลองแก้ครบ 2 ครั้งแล้วยังติด |
| **⚡ `Haiku`** | **ลูกมือวิ่งหาเอกสาร** เร็วมากแต่ไม่เหมาะกับงานคิดซับซ้อน | **ประหยัดสุดๆ (ถูกกว่า 10–20 เท่า)** | **ไม่ต้องกดเลือกเอง** เพราะ Template นี้ตั้งให้ตัวค้นหาไฟล์ (`explorer.md`) ใช้ `Haiku` อยู่เบื้องหลังให้อัตโนมัติแล้ว |

> **💡 ความลับที่ Template นี้ตั้งค่าช่วยคุณไว้แล้วใน `.claude/agents/`:**
> ปกติถ้าคุณเปิด **`Opus`** ไว้ในหน้าแชทหลัก แล้วสั่งงาน ระบบของ Claude Code จะใช้ `Opus` กับลูกมือทุกตัวจนโควต้าไหลเป็นน้ำ แต่ใน Template นี้ เราล็อกค่าในไฟล์ `.claude/agents/` ไว้ให้แล้วว่า:
> * ลูกมือค้นหาไฟล์ (`explorer.md`) ➔ บังคับใช้ **`haiku`** เสมอ
> * ลูกมือเขียนโค้ด/แก้บั๊ก/ตรวจโค้ด (`implementer.md`, `debugger.md`, `reviewer.md`) ➔ บังคับใช้ **`sonnet`** เสมอ
> *(หมายเหตุ: เราใช้ชื่อย่อ `sonnet` และ `haiku` ตามมาตรฐาน Official ของ Claude Code เพื่อให้ระบบดึงรุ่นล่าสุดให้อัตโนมัติโดยไม่ต้องคอยแก้เลขรุ่นในไฟล์)*

### วิธีเปลี่ยน Model ในหน้าแชทหลักของ Claude Code:
* **ใน VS Code Extension:** กดคลิกที่ชื่อโมเดลตรงแถบด้านล่างของช่องพิมพ์แชท แล้วเลือก `Sonnet` หรือ `Opus`
* **ในจอดำ (Terminal CLI):** พิมพ์ `/model sonnet` หรือ `/model opus` แล้วกด Enter

---

### 💡 ตัวอย่างสูตรใช้งานจริงให้โควต้าอยู่ได้นานที่สุด (Step-by-Step)

#### กรณีที่ 1: งานทั่วไปในชีวิตประจำวัน (ใช้ `Sonnet` ตัวเดียวจบ)
เมื่อต้องการเพิ่มปุ่ม แก้หน้าเว็บ สร้าง API หรือแก้บั๊กทั่วไป:
1. ตั้งโมเดลไว้ที่ **`Sonnet`**
2. พิมพ์สั่งงานตามปกติ เช่น:
   > *"เพิ่มช่องกรอกเบอร์โทรศัพท์ในหน้าสมัครสมาชิก และเช็กว่าต้องเป็นตัวเลข 10 หลัก"*
3. `Sonnet` จะแก้เฉพาะไฟล์ที่เกี่ยวข้องและรันเทสต์ตรวจให้จบในตัวโดยกินโควต้าน้อยมาก

#### กรณีที่ 2: งานยากหรือวางระบบใหญ่ (สูตร "คิดด้วย `Opus` ➔ เขียนโค้ดด้วย `Sonnet`")
เมื่อต้องทำระบบใหญ่หลายไฟล์ หรือเจอบั๊กยากที่ติดเบรกเกอร์ `2-Strike`:
1. **จังหวะที่ 1 (วางแผน):** สลับโมเดลไปที่ **`Opus`** แล้วพิมพ์ว่า:
   > *"/plan ออกแบบระบบตัดสต็อกสินค้าแบบจองคิวล่วงหน้าพร้อมป้องกันการกดซื้อพร้อมกัน"*
   *(ขั้นนี้ `Opus` จะใช้สมองระดับสูงสุดวางแผนออกมาสั้นๆ 10 บรรทัด โดยยังไม่เสียโควต้าเขียนโค้ดยาวๆ)*
2. **จังหวะที่ 2 (ลงมือเขียนโค้ด):** พอคุณอ่านแผนแล้วโอเค **ให้กดสลับโมเดลกลับมาเป็น `Sonnet` ทันที!** แล้วพิมพ์ว่า:
   > *"ตกลงตามแผนนี้ ลงมือเขียนโค้ดและรันเทสต์ได้เลย"*
   *(คุณจะได้โค้ดที่วางโครงสร้างโดย `Opus` แต่จ่ายค่าโควต้าตอนเขียนโค้ดในราคาประหยัดของ `Sonnet`!)*

---

## 💬 6 ตัวอย่างการใช้งานจริง (Use Cases)

คุณ**ไม่ต้องจำคำสั่งลัดใดๆ** แค่พิมพ์บอกความต้องการตามปกติ ระบบจะเลือกโหมดทำงานให้เองอัตโนมัติ:

---

### Use Case ที่ 1: เริ่มโปรเจกต์ใหม่ แล้วอยากให้ AI เก่งเฉพาะทางในภาษานั้นๆ
แทนที่จะยัดคู่มือทุกภาษาไว้ในโปรเจกต์จนเปลืองโควต้า คุณสามารถสั่งให้ AI ดึงเฉพาะคู่มือของภาษาที่ใช้จริงมาจากคลัง [`jeffallan/claude-skills`](https://github.com/jeffallan/claude-skills) ได้เลย

> 💬 **คุณพิมพ์แค่:**
> *"โปรเจกต์นี้ใช้ React, Tailwind และ NestJS ช่วยดึง skill ที่เกี่ยวข้องมาลงให้หน่อย"*

**สิ่งที่ระบบทำให้อัตโนมัติ:**
1. AI จะรันสคริปต์ `install-skill.sh` ไปดึงเฉพาะคู่มือ `react-expert`, `tailwind-expert`, และ `nestjs-expert` มาวางให้ทั้งใน `.claude/skills/` และ `.agents/skills/`
2. หลังจากนั้น เวลาคุณสั่งแก้หน้าเว็บ React หรือแก้ API ใน NestJS AI จะเปิดอ่านคู่มือของภาษานั้นเองโดยอัตโนมัติ

---

### Use Case ที่ 2: สั่งสร้างฟีเจอร์ใหม่ (ป้องกัน AI คิดเองเออเอง)
สมมติคุณสั่งสั้นๆ โดยยังไม่ได้บอกรายละเอียดทั้งหมด:

> 💬 **คุณพิมพ์แค่:**
> *"ช่วยสร้างระบบจองคิวร้านอาหาร พร้อมระบบเก็บเงินมัดจำและคืนเงินเวลากดยกเลิกให้หน่อย"*

**สิ่งที่ระบบทำให้อัตโนมัติ:**
* **ถ้าไม่มี Template:** AI จะมั่วตัวเลขขึ้นมาเอง เช่น คิดมัดจำคนละ 100 บาท และเขียนโค้ดยาวเหยียดเกือบ 200 บรรทัดซึ่งไม่ตรงกับที่ร้านคุณใช้จริง
* **เมื่อมี Template นี้:**
  1. AI จะเช็กก่อนว่าในโฟลเดอร์ `docs/llms/` มีไฟล์กฎของร้านวางไว้ไหม
  2. ถ้าจุดไหนยังไม่ชัดเจน AI จะสรุปสมมติฐานสั้นๆ 3–4 ข้อมาถามคุณก่อน เช่น:
     > *"ก่อนเริ่มเขียนโค้ด ขอเช็กความเข้าใจ 3 ข้อครับ: 1. เก็บมัดจำคงที่กี่บาทต่อคิว? 2. ต้องยกเลิกล่วงหน้ากี่ชั่วโมงถึงจะได้เงินคืน? 3. รอบนี้เก็บข้อมูลในหน่วยความจำก่อนใช่ไหมครับ?"*
  3. พอคุณตอบยืนยัน AI จึงเขียนโค้ดที่ตรงกับความต้องการของคุณในรอบเดียว ไม่ต้องรื้อแก้ใหม่

---

### Use Case ที่ 3: สั่งแก้บั๊กยากๆ (ป้องกัน AI เดาแก้จนโควต้าหมด)
สมมติเทสต์พัง หรือมีบั๊กที่ซับซ้อน:

> 💬 **คุณพิมพ์แค่:**
> *"หน้าคำนวณภาษีพัง ช่วยเช็กและแก้ให้หน่อย"*

**สิ่งที่ระบบทำให้อัตโนมัติ:**
1. AI จะอ่าน Error จริงและลองแก้ที่ต้นเหตุ (ครั้งที่ 1) แล้วรันเทสต์เฉพาะไฟล์นั้น
2. ถ้ายังไม่ผ่าน จะปรับสมมติฐานแล้วลองแก้ทับอีก 1 ครั้ง (ครั้งที่ 2)
3. **ถ้าครบ 2 ครั้งแล้วยังไม่ผ่าน (หรือติดที่ขาดสูตรคำนวณของบริษัท):**
   AI จะ**หยุดทันที** ย้อนโค้ดไฟล์นั้นกลับสู่สภาพเดิม แล้วรายงานว่าลองวิธีไหนไปแล้วบ้าง ติด Error อะไร และมีทางเลือกไหนให้คุณตัดสินใจต่อ (ไม่แอบรันเทสต์วนซ้ำ 10 รอบจนโควต้าเกลี้ยง)

---

### Use Case ที่ 4: โควต้า Claude Code หมดกลางคัน ➔ สลับมาทำต่อใน Antigravity (VS Code)
สมมติคุณกำลังให้ Claude Code เขียนระบบตะกร้าสินค้าอยู่ แล้วขึ้นแจ้งเตือน `Quota reached` กลางอากาศ:

> 💬 **คุณแค่สลับมาเปิด Antigravity ใน VS Code แล้วพิมพ์ว่า:**
> *"ทำส่วนที่ค้างไว้ต่อให้เสร็จเลย"*

**สิ่งที่ระบบทำให้อัตโนมัติ:**
1. ทุกครั้งที่ AI แก้ไฟล์ สคริปต์ `post-edit-format.sh` จะแอบจดบันทึกไว้ในไฟล์ `.agent-last-state.log` ว่าทำถึงไฟล์ไหนแล้ว
2. ทันทีที่คุณเปิดแชทใหม่ใน Antigravity สคริปต์ `auto-resume.sh` จะส่งข้อมูลงานค้างเข้าสมอง AI ตัวใหม่ตั้งแต่เริ่มแชท
3. Antigravity จะเช็ก `git diff` ดูโค้ดที่ Claude Code เขียนค้างไว้ รันเทสต์เช็กสถานะ แล้วเขียนต่อจากบรรทัดเดิมให้จบได้ทันที โดยที่คุณไม่ต้องนั่งพิมพ์อธิบายงานใหม่ตั้งแต่ต้น

---

### Use Case ที่ 5: สั่งตรวจโค้ดก่อนขึ้นระบบ (ไม่จับผิดจุกจิก)
เมื่อเขียนฟีเจอร์เสร็จแล้วอยากให้ AI ช่วยตรวจความเรียบร้อย:

> 💬 **คุณพิมพ์แค่:**
> *"ช่วยรีวิวโค้ดที่เพิ่งแก้ไปหน่อย"* (หรือพิมพ์ `/review` ใน Claude Code)

**สิ่งที่ระบบทำให้อัตโนมัติ:**
1. AI จะตรวจเฉพาะ **`[BLOCKER]`** เท่านั้น (เช่น บั๊กคำนวณผิด, ช่องโหว่ความปลอดภัย, ลืมเช็กสิทธิ์ผู้ใช้) โดย**ไม่บ่นเรื่องจุกจิก** เช่น ชื่อตัวแปรสั้นไป หรือการจัดย่อหน้า
2. เมื่อแก้ Blocker เสร็จและรันเทสต์ผ่านในรอบที่ 2 AI จะส่งคำตัดสิน `VERDICT: APPROVE` เพื่อจบงานทันที ไม่หาเรื่องรื้อโค้ดไปเรื่อยๆ

---

### Use Case ที่ 6: สั่งสร้างหน้าเว็บหรือแอป Flutter (ป้องกันหน้าตาแบบ "AI Slop" อัตโนมัติ)
เวลาสั่ง AI สร้างหน้า Dashboard หรือฟอร์มสมัครสมาชิก มักจะได้หน้าเว็บสีม่วงไล่เฉด มี Emoji แปะหน้าปุ่ม และวาด `<svg>` เบี้ยวๆ เอง:

> 💬 **คุณพิมพ์แค่:**
> *"สร้างหน้า Dashboard แสดงยอดขายรายวันและตารางรายการคำสั่งซื้อล่าสุด"*

**สิ่งที่ระบบทำให้อัตโนมัติ:**
1. ทันทีที่ AI แตะไฟล์หน้าบ้าน (`*.tsx`, `*.jsx`, `*.vue`, `*.dart`, `*.css`) ระบบจะโหลดกฎ **`ui-anti-slop.md`** (สกัดจาก [`heydamir/unslop`](https://github.com/heydamir/unslop)) ขึ้นมาทำงานอัตโนมัติในรอบเดียว (ส่วนตอนทำไฟล์ Backend กฎนี้จะปิดตัวเองเพื่อไม่ให้เปลืองโควต้า)
2. บังคับใช้ไอคอนจาก `lucide-react` / `simple-icons` (เว็บ) หรือ `lucide_icons` (Flutter) เท่านั้น ห้ามวาด `<svg>` เอง และห้ามใช้ Emoji แทนไอคอน
3. บังคับใช้โทนสีสะอาดตา ระยะห่างสเกล `4px/8px` ตัวเลขตารางตรงหลัก (`tabular-nums`) และใส่สถานะ `Loading / Empty / Error` ให้ครบตั้งแต่รอบแรก

---

## 🧠 อธิบายแนวคิดและหน้าที่ของทุกส่วนใน Template (ครบทุก Concept)

Template นี้ออกแบบตามหลัก **3-Layer Graph Engineering** (*Harness ➔ Bounded Agent Loop ➔ Graph State-Delta*) โดยแบ่งไฟล์ออกเป็น **6 ส่วนหลัก** ที่ทำงานประสานกันดังนี้ครับ:

### 1. สมองสั่งการหลัก (`CLAUDE.md` และ `AGENTS.md`)
* **ทำหน้าที่เป็น Auto-Router (ตัวคัดแยกงานอัตโนมัติ):** วิเคราะห์ประโยคที่คุณพิมพ์ว่าควรทำเองทันที (งานแก้ 1–2 ไฟล์) หรือควรส่งให้ลูกมือเฉพาะทางทำ (งานใหญ่ >3 ไฟล์ / งานแก้บั๊ก / งานรีวิว)
* **ตาราง Auto-Detect 5 ภาษาหลัก:** ตรวจจับจากไฟล์ในโปรเจกต์อัตโนมัติว่าเป็น **Node.js/TypeScript** (`package.json`), **Go** (`go.mod`), **Flutter/Dart** (`pubspec.yaml`), **Python** (`pyproject.toml`), หรือ **Rust** (`Cargo.toml`) เพื่อเลือกคำสั่งรันเทสต์เฉพาะไฟล์ให้ถูกต้องโดยที่คุณไม่ต้องตั้งค่าเอง

### 2. กฎเหล็กที่โหลดตามชนิดไฟล์ (`rules/*.md` — 4 ไฟล์)
อยู่ใน `.claude/rules/` และ `.agents/rules/` จะถูกดึงมาใช้เฉพาะเมื่อ AI กำลังแก้ไฟล์ที่ตรงกับงานนั้น:
* **`code-simplicity.md` (Karpathy 4 Principles):** บังคับ *Think Before Coding* (คิดก่อนทำ), *Simplicity First* (ทำวิธีที่ง่ายที่สุด ห้ามสร้าง Class/Helper เผื่ออนาคต), *Surgical Changes* (แก้เฉพาะบรรทัดที่สั่ง), และ *Goal-Driven Execution* (ตั้งเป้าหมายการเทสต์ก่อนจบงาน)
* **`execution-discipline.md` (Context Hygiene & Graph `State-Delta`):**
  * ห้ามกวาดอ่านไฟล์ทั้งโปรเจกต์เข้าหน้าแชทหลัก
  * **Graph `State-Delta` Handoff:** เวลาลูกมือส่งงานต่อกัน (`explorer` ➔ `implementer` ➔ `reviewer`) ห้ามก๊อปปี้ประวัติแชทยาวๆ ส่งต่อ ให้ส่งเฉพาะก้อนข้อมูลสั้นๆ ไม่เกิน 8 บรรทัด (*ชื่อไฟล์:บรรทัด + เงื่อนไข + คำสั่งเทสต์*)
  * **Safe Rollback:** เวลาแก้บั๊กไม่ผ่านแล้วต้องย้อนโค้ด บังคับใช้เครื่องมือ `Edit` แก้กลับเฉพาะบรรทัดเดิม ห้ามรัน `git checkout .` หรือ `git reset --hard` ทับโค้ดของคุณ
* **`testing-and-api.md` (`obra/superpowers` TDD & OWASP API Security):** โหลดเฉพาะตอนแก้ไฟล์เทสต์หรือ API บังคับเทสต์กับโค้ดจริง (ห้าม Mock ฟังก์ชันที่กำลังเทสต์), แก้บั๊กต้องเห็นเทสต์พังก่อนแก้จริง (*Verify RED*), และบังคับตรวจสิทธิ์เข้าถึงข้อมูล (ป้องกันช่องโหว่ IDOR/BOLA)
* **`ui-anti-slop.md` (`heydamir/unslop` 1-Pass UI & 3D Standards):** โหลดเฉพาะตอนแก้ไฟล์หน้าบ้าน บังคับเกณฑ์ออกแบบ UI 9 ด้าน และกฎมาตรฐาน Three.js `r187+` ตั้งแต่การเขียนโค้ดรอบแรก

### 3. ตำราเฉพาะทางที่เปิดอ่านเมื่อถึงจังหวะใช้งาน (`skills/*/SKILL.md` — 8 ไฟล์)
ใช้เทคนิค **Progressive Disclosure** (ปกติจะซ่อนเนื้อหาไว้เพื่อประหยัดโควต้า และจะเปิดอ่านเฉพาะเมื่อคำสั่งของคุณตรงกับเรื่องนั้น):
* **`common-ground`:** สกัดสมมติฐานที่ซ่อนอยู่ 3–4 ข้อพร้อมระบุขอบเขตที่จะไม่ทำ (*YAGNI Out of Scope*) มาถามคุณก่อนเริ่มเขียนฟีเจอร์ใหม่
* **`root-cause-debug`:** บังคับ 4 ขั้นตอนหาต้นตอบั๊ก พร้อมเบรกเกอร์ **`0-Strike`** (ถ้าขาดสูตรธุรกิจให้หยุดถามทันที ห้ามเดาเลข) และ **`2-Strike`** (ลองแก้ไม่เกิน 2 ครั้ง ถ้ายังพังให้คืนค่าไฟล์เดิมแล้วสรุปทางเลือก A/B มาถามคุณ)
* **`pragmatic-review`:** ตรวจโค้ดเฉพาะจุดที่เป็นอันตราย (**Blocker-Only** + **Enum Completeness** ตรวจไฟล์ที่เกี่ยวข้องนอก `git diff` + **Gate Integrity `RH-1..RH-16`** ดักจับ AI แอบแก้เงื่อนไขเทสต์หรือเขียน `if (NODE_ENV === 'test')` โกงผลเทสต์) ห้ามติเรื่องความสวยงาม และบังคับจบภายในไม่เกิน **2 รอบ (`MAX_ROUNDS = 2`)**
* **`verification-before-completion`:** กฎเหล็กห้ามพูดว่า *"เสร็จแล้ว"* ถ้ายังไม่ได้รันคำสั่งเทสต์สดในเทิร์นนั้น พร้อมดักจับ **`Zero-Run Green (PL-2)`** (ถ้ารันได้ `Exit Code 0` แต่รันเทสต์ไป `0 ข้อ` ถือว่าไม่ผ่าน ต้องรันเทสต์จริงอย่างน้อย 1 ข้อเสมอ)
* **`db-migration`:** กฎแก้ไขฐานข้อมูลแบบ Zero-Downtime (*Expand & Contract*), ห้ามแก้ไฟล์ Migration เก่า, บังคับใส่ Index ที่ Foreign Key, ห้ามยิง Query ในลูป (N+1), และบังคับใช้ Transaction
* **`auto-resume-handoff`:** ขั้นตอนกู้คืนงานค้าง 3 จังหวะ (อ่าน `.agent-last-state.log` ➔ เช็ก `git diff` ➔ รันเทสต์เช็กสถานะปัจจุบัน) เมื่อสลับโปรแกรมหลังโควต้าหมด
* **`tech-stack-skills`:** ตารางจับคู่และวิธีดึงคู่มือภาษาเฉพาะทาง (เช่น `react-expert`, `nestjs-expert`, `golang-pro`, `flutter-expert`, `unslop`) มาลงเฉพาะตัวที่ใช้จริง (2–4 ตัวต่อโปรเจกต์)
* **`threejs-expert` (`mrdoob/three.js r187+`):** คู่มือผู้เชี่ยวชาญสำหรับสร้าง 3D Viewer และ Interactive 3D UI บนเว็บ บังคับใช้ API รุ่นใหม่ (`three/addons/*`, `HDRLoader`, `SRGBColorSpace`, `OutputPass`, `CSS2DRenderer`, `setAnimationLoop`) พร้อมสูตรคำนวณมุมกล้องอัตโนมัติและฟังก์ชันคืนค่าหน่วยความจำการ์ดจอ (`disposeViewer`) ป้องกันอาการการ์ดจอค้าง

### 4. ลูกมือเฉพาะทาง 4 ตัว (`.claude/agents/*.md` — Bounded Agent Loops)
ทำหน้าที่แยกงานหนักออกไปทำข้างนอกเพื่อไม่ให้หน้าแชทหลักรก พร้อมล็อกเพดานรอบ (`maxTurns`), ล็อกเครื่องมือ (`disallowedTools`), และผูกตำรา (`skills` preload) ไว้ล่วงหน้า:
* **`explorer.md` (`model: haiku`, สูงสุด 6 รอบ):** ค้นหาไฟล์และจุดเชื่อมต่อแบบอ่านอย่างเดียว (ห้ามแก้ไฟล์) ใช้โมเดล `haiku` ที่เร็วและประหยัดโควต้ากว่า 10–20 เท่า
* **`implementer.md` (`model: sonnet`, สูงสุด 15 รอบ):** คนลงมือเขียนและแก้โค้ดแบบ Surgical Edit พร้อมผูกตำรา `verification-before-completion`, `db-migration`, และ `threejs-expert`
* **`debugger.md` (`model: sonnet`, สูงสุด 10 รอบ):** คนวิเคราะห์และแก้บั๊กตามกฎ `0-Strike` / `2-Strike` พร้อมผูกตำรา `root-cause-debug`
* **`reviewer.md` (`model: sonnet`, สูงสุด 8 รอบ):** คนตรวจโค้ดแบบอ่านอย่างเดียว (ห้ามแอบแก้ไฟล์เอง) พร้อมผูกตำรา `pragmatic-review`

### 5. คำสั่งลัดเมื่อต้องการสั่งตรง (`.claude/commands/*.md` — 6 คำสั่ง)
ถึงแม้ระบบจะเลือกโหมดให้อัตโนมัติอยู่แล้ว แต่ถ้าคุณอยากสั่งบังคับโหมดเองใน Claude Code ก็พิมพ์คำสั่งลัดเหล่านี้ได้ทันที:
* `/plan` — สำรวจและวางแผนงานใหญ่ไม่เกิน 12 บรรทัดก่อนเขียนโค้ด
* `/common-ground` — สรุปสมมติฐานและขอบเขตงานให้ตรงกันก่อนทำฟีเจอร์ใหม่
* `/fix` — วิเคราะห์และแก้บั๊กด้วยกฎ `0-Strike` / `2-Strike`
* `/review` — ตรวจรีวิวโค้ดเฉพาะ `[BLOCKER]` ไม่เกิน 2 รอบ
* `/verify` — รันเทสต์ + ตรวจ Type/Analyze + เช็กพอร์ตยืนยันผลจริง
* `/handoff` — บันทึกสถานะงานค้างลง `TASK_STATE.md` ก่อนล้างแชท (`/clear`) หรือก่อนสลับโปรแกรม

### 6. ยามรักษาความปลอดภัยเบื้องหลัง 0-Token (`.claude/hooks/*.sh` — Deterministic Function Nodes)
แทนที่จะเปลืองโควต้าให้ AI คอยระวังเอง งานที่ตายตัวจะถูกควบคุมด้วยสคริปต์ Bash ที่ทำงานอัตโนมัติทั้งใน Claude Code (`.claude/settings.json`) และ Antigravity (`.agents/hooks.json`) โดย**ไม่เสียโควต้า AI แม้แต่ Token เดียว**:
* **`validate-bash.sh`:** ใช้ตัวสกัด JSON ที่ปลอดภัยต่อเครื่องหมายฟันหนูซ้อน (`\"` — ป้องกันช่องโหว่คำสั่งพ่วงท้ายอย่าง `git commit -m "wip" && rm -rf /`), ดักจับการพลางคำสั่งด้วย `${IFS}` / `base64 -d | sh`, บล็อกคำสั่งอันตราย (`rm -rf`, `git push --force` / `+main`, `git restore` / `git checkout .`), และบล็อกการแอบลงแพ็กเกจใหม่โดยไม่ถามคุณก่อน (`npm install`, `flutter pub add`, `go get`, `pip install`, `cargo add`)
* **`protect-sensitive-files.sh`:** บล็อกการอ่านหรือแก้ไขไฟล์ความลับ (`.env`, `.pem`, `.key`, `.keystore`, `.jks`, `.p12`) และห้ามแก้ไฟล์ Lockfile โดยตรง (`package-lock.json`, `pubspec.lock`, `go.sum`, `poetry.lock`, `Cargo.lock`)
* **`post-edit-format.sh`:** จัด Format โค้ดอัตโนมัติตามภาษา (`prettier`, `gofmt`, `dart format`, `ruff format`, `rustfmt`) และบันทึกจุดแก้ล่าสุดลง `.agent-last-state.log` ทุกครั้ง
* **`loop-circuit-breaker.sh`:** นับจำนวนครั้งที่ AI รันคำสั่งเทสต์/บิลด์เดิมซ้ำๆ ถ้าเกิน 3 ครั้งจะตัดเบรกเกอร์บังคับหยุดทันที
* **`auto-resume.sh`:** ตรวจหาไฟล์ `.agent-last-state.log` และ `git status` ตอนเปิดแชทใหม่ เพื่อส่งต่องานค้างให้อัตโนมัติ
* **`telemetry-tracker.sh` & `open-hud.sh`:** บันทึกสถานะการทำงานสดจากทุก Hook ลงไฟล์ `.claude/.telemetry.json` และเปิดเซิร์ฟเวอร์ศูนย์บัญชาการ 3D (`.claude/hud/index.html`) พร้อมระบบเช็กโควต้าคงเหลือจริงของทั้ง Claude Code และ Antigravity
* **`install-skill.sh`:** ดึงเฉพาะโฟลเดอร์ Skill ที่สั่งจาก `jeffallan/claude-skills` หรือ `heydamir/unslop` มาติดตั้งให้ทั้ง 2 โปรแกรมพร้อมกันภายในไม่กี่วินาที

---

## 📂 โครงสร้างไฟล์ทั้งหมดใน Template นี้

```text
project-root/
├── AGENTS.md                                   # กฎหลัก + Auto-Router สำหรับ Antigravity / VS Code / Cursor
├── CLAUDE.md                                   # กฎหลัก + Auto-Router สำหรับ Claude Code
├── .mcp.json                                   # ตั้งค่า MCP (เริ่มต้นเป็นค่าว่างเพื่อประหยัดโควต้า)
├── .gitignore                                  # ป้องกันไฟล์ความลับและไฟล์สถานะชั่วคราวขึ้น Git
│
├── .agents/                                    # ⚡ ตั้งค่าอัตโนมัติสำหรับ Antigravity (VS Code)
│   ├── hooks.json                              # ผูก SessionStart, PreInvocation, PreToolUse, PostToolUse, Stop
│   ├── rules/
│   │   ├── code-simplicity.md                  # Karpathy 4 Principles (Think, Simplicity, Surgical, Goal-Driven)
│   │   ├── execution-discipline.md             # Context Hygiene (trailofbits) + Graph State-Delta (ADK 2) & Safe Rollback
│   │   ├── testing-and-api.md                  # Real Testing (obra/superpowers TDD) & OWASP API Security
│   │   └── ui-anti-slop.md                     # กฎออกแบบ UI 9 ด้าน (heydamir/unslop) + มาตรฐาน Three.js r187+
│   └── skills/
│       ├── auto-resume-handoff/SKILL.md        # 3-Phase Harness รับไม้ต่ออัตโนมัติ (Anthropic Long-Running Harness)
│       ├── common-ground/SKILL.md              # Socratic Discovery & YAGNI Scope (obra/superpowers brainstorming)
│       ├── db-migration/SKILL.md               # Zero-Downtime Migration (supabase/agent-skills + postgres-pro)
│       ├── pragmatic-review/SKILL.md           # Blocker-Only Review ไม่เกิน 2 รอบ (obra/superpowers + gstack)
│       ├── root-cause-debug/SKILL.md           # 4-Phase Debugging (obra/superpowers) + 0/2-Strike Breaker
│       ├── tech-stack-skills/SKILL.md          # ดึง Skill เฉพาะทางจาก jeffallan/claude-skills อัตโนมัติ
│       ├── threejs-expert/SKILL.md             # คู่มือผู้เชี่ยวชาญ Three.js r187+ (3D Viewer, HDRLoader, OutputPass, Disposal)
│       └── verification-before-completion/     # Iron Law & 5-Step Gate Function (Test + Zero-Run Check + Build)
│
└── .claude/                                    # 🤖 ตั้งค่าอัตโนมัติสำหรับ Claude Code
    ├── settings.json                           # สิทธิ์คำสั่งปลอดภัย + ผูกสคริปต์ Hooks ($CLAUDE_PROJECT_DIR)
    ├── hud/
    │   └── index.html                          # 🖥️ 3D Command & Monitor Center (Three.js r187 Single-File HUD)
    ├── agents/                                 # 4 Sub-Agents (พร้อม model, maxTurns, disallowedTools & skills preload)
    │   ├── explorer.md                         # สำรวจโค้ดแบบ Read-only (haiku, maxTurns: 6)
    │   ├── implementer.md                      # แก้โค้ดแบบ Surgical Edit (sonnet, maxTurns: 15 + skills preload)
    │   ├── debugger.md                         # วิเคราะห์ต้นตอและตัดลูป 2-Strike (sonnet, maxTurns: 10 + skills preload)
    │   └── reviewer.md                         # ตรวจเฉพาะ Blocker แบบ Read-only (sonnet, maxTurns: 8 + skills preload)
    ├── rules/                                  # กฎโหลดตาม Path ไฟล์ (ชุดเดียวกับ .agents/rules)
    ├── skills/                                 # ทักษะอัตโนมัติ (ชุดเดียวกับ .agents/skills)
    ├── commands/                               # คำสั่งลัด (/plan, /common-ground, /fix, /review, /verify, /handoff)
    └── hooks/                                  # 🛡️ สคริปต์ยามรักษาความปลอดภัย Dual-Mode (Claude + Antigravity)
        ├── auto-resume.sh                      # ฉีดสถานะงานค้างเข้าแชทใหม่อัตโนมัติ (SessionStart)
        ├── validate-bash.sh                    # บล็อก rm -rf, git restore/checkout ทับโค้ด, และการลง pkg มั่ว
        ├── protect-sensitive-files.sh          # บล็อกการแก้ไขไฟล์ .env, .pem, .key, และ lockfiles
        ├── loop-circuit-breaker.sh             # บล็อกเมื่อ AI รันคำสั่งเทสต์/บิลด์เดิมซ้ำเกิน 3 ครั้ง
        ├── post-edit-format.sh                 # จัด Format อัตโนมัติ + บันทึกจุด Checkpoint ล่าสุด
        ├── telemetry-tracker.sh                # บันทึกสถานะการทำงานสดจากทุก Hook ลง .claude/.telemetry.json
        ├── open-hud.sh                         # เปิดเซิร์ฟเวอร์ 3D Command & Monitor Center + เช็กโควต้าจริง
        └── install-skill.sh                    # ดึง Skill เฉพาะทางจาก jeffallan/claude-skills แบบ Sparse Checkout
```

---

## 📚 มาตรฐานและงานวิจัยที่นำมาพัฒนา (Built On)

* **Anthropic Claude Code Official Specification & Engineering:** ใช้การจำกัด `model`, `maxTurns`, `disallowedTools`, และการ Preload `skills` ในระดับ Sub-agent Frontmatter ร่วมกับ `$CLAUDE_PROJECT_DIR` Hooks และรูปแบบ *Effective Harnesses for Long-Running Agents*
* **Antigravity Customization System (`.agents/`):** รองรับ Progressive Disclosure ของ Rules/Skills และ JSON Lifecycle Hooks (`hooks.json`)
* **[`forrestchang/andrej-karpathy-skills`](https://github.com/forrestchang/andrej-karpathy-skills):** กฎ 4 ข้อของ Karpathy (*Think Before Coding*, *Simplicity First*, *Surgical Changes*, *Goal-Driven Execution*)
* **[`obra/superpowers`](https://github.com/obra/superpowers):** โปรโตคอล *Verification Before Completion*, *4-Phase Systematic Debugging*, *Socratic Brainstorming*, *Code Review Convergence*, และ *Real-Code TDD*
* **[`garrytan/gstack`](https://github.com/garrytan/gstack):** ระบบ *Gate Integrity & Anti-Reward-Hacking (`RH-1..RH-16`)*, การดักจับ *Zero-Run Green (`PL-1/PL-2`)*, การตรวจ *Enum Completeness / TOCTOU / LLM Trust Boundary* ในการรีวิวโค้ด, และการป้องกันช่องโหว่ *Escaped-Quote JSON Truncation & Shell Obfuscation* ใน `PreToolUse` Hook
* **[`trailofbits/claude-code-config`](https://github.com/trailofbits/claude-code-config) & Google ADK 2.0 Graph Engineering:** สถาปัตยกรรม 3 ชั้น (*Harness ➔ Bounded Loop ➔ Graph*), *Two-Layer Context Hygiene*, และการส่งต่อข้อมูลระหว่าง Sub-agent แบบบีบอัด (`State-Delta` Handoff ไม่เกิน 8 บรรทัด)
* **[`supabase/agent-skills`](https://github.com/supabase/agent-skills) & [`jeffallan/claude-skills`](https://github.com/jeffallan/claude-skills):** กฎ *Zero-Downtime Postgres Migration / RLS* และระบบดึงทักษะเฉพาะทางตาม Tech Stack จริงแบบ Sparse Checkout (`install-skill.sh`)
* **[`heydamir/unslop`](https://github.com/heydamir/unslop):** สกัดเกณฑ์ตรวจสอบ UI 9 ด้าน (*Spacing, Color, Icons, Copy, Type, Layout, Details, Visuals, Motion*) มาเป็นกฎ `ui-anti-slop.md` ที่ทำงานอัตโนมัติในรอบเดียวเมื่อแก้ไขไฟล์หน้าบ้าน และรองรับการดึง Skill ตัวเต็มผ่าน `install-skill.sh unslop`
* **[`mrdoob/three.js`](https://github.com/mrdoob/three.js) (`r187+`):** สกัดมาตรฐานสถาปัตยกรรม Three.js รุ่นล่าสุด (`three/addons/*`, `HDRLoader`, `OutputPass`, `CSS2DRenderer`, `setAnimationLoop`, และระบบคืนค่าหน่วยความจำการ์ดจอ `dispose()`) มาเป็นทักษะ `threejs-expert` และใช้สร้าง **3D Command & Monitor Center** ประจำตัว Template
