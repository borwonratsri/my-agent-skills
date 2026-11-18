---
name: project-memory
description: จัดการระบบความจำถาวรของโปรเจกต์ สร้างไฟล์ PROJECT_CONTEXT.md, handoff-latest.md (สรุปรายงานแต่ละงานสำหรับเปิดแชทใหม่ทำงานต่อได้ทันที) และ bridge.json พร้อมระบบ Auto-Handoff เมื่อ Context Window ถึง 450,000 tokens
---

# Project Memory: ระบบบันทึกบริบทและความจำถาวรของโปรเจกต์

ระบบสำหรับบันทึกและถ่ายทอดบริบทการทำงานของโปรเจกต์ (Persistent Project Memory & Session Handoff) เพื่อให้เมื่อเปิดแชทใหม่ (หรือสลับเครื่อง) AI Agent สามารถอ่านสรุปแต่ละงานแบบครบถ้วนและทำงานต่อได้ทันทีโดยไม่ต้องเริ่มต้นอธิบายใหม่

## Trigger Scenarios

1. **Manual Trigger**:
   - Slash command: `/project-memory`
   - ผู้ใช้สั่ง: `"บันทึก memory ของโปรเจกต์นี้"`, `"สร้าง PROJECT_CONTEXT.md"`, `"สรุปสถานะโปรเจกต์ไว้ส่งต่อ"`, `"Save project context"`
2. **Automatic Context-Window Trigger (`>= 450,000` tokens)**:
   - ระบบ `Stop` Hook ([context-memory-gate.mjs](../../hooks/context-memory-gate.mjs) + [stop-verify-gate.mjs](../../hooks/stop-verify-gate.mjs)) จะตรวจยอด Token จริง (`input_tokens + cache_read_tokens + output_tokens`) จาก `transcript.jsonl`
   - เมื่อถึง **`450,000` tokens** (และไม่เคยสรุปในรอบนั้น) Hook จะสั่งให้ทำ `/project-memory` อัตโนมัติทันทีที่จบ Turn พร้อมแจ้งเตือนให้ผู้ใช้ย้ายไปเปิดแชทใหม่
   - หากผู้ใช้คุยต่อในแชทเดิม ระบบจะสรุปอัปเดตซ้ำให้อีกครั้งเมื่อ Token เพิ่มขึ้นอีกทุกๆ **`+50,000` tokens** (`500,000`, `550,000`, ...)

## โครงสร้างไฟล์ความจำ (Active Workspace)

1. **`PROJECT_CONTEXT.md` (ไฟล์ภาพรวมหลักที่ Root — Git-tracked, กระชับไม่เกิน ~1,800 chars)**:
   - **Project Overview**: วัตถุประสงค์หลักของระบบและเป้าหมายทางธุรกิจ
   - **Tech Stack & Toolchain**: ภาษา Framework ฐานข้อมูล และ Libraries สำคัญ
   - **Architecture & Directory Map**: แผนผังโฟลเดอร์และหน้าที่ของแต่ละโมดูล
   - **Key Conventions & Rules**: กฎการเขียนโค้ด (Coding standard, Git flow, Error handling)
   - **Current Status & Milestones**: สิ่งที่ทำเสร็จแล้ว (Done) และงานที่กำลังทำอยู่ (In-Progress)
   - **Next Actions (Backlog)** + Pointer ไปยัง `.agents/memory/handoff-latest.md`

2. **`.agents/memory/handoff-latest.md` (สรุปส่งต่อฉบับเต็มแบบรายแต่ละงาน — Auto-loaded ตอนเปิดแชทใหม่)**:
   - ไฟล์นี้ถูกโหลดเข้า Context อัตโนมัติเมื่อเปิดแชทใหม่ผ่าน [session-start.mjs](../../hooks/session-start.mjs) (สูงสุด `6,000` ตัวอักษรแรก หากยาวกว่านั้นให้ Agent `read_file` เพิ่มเติม)
   - ต้องเขียนให้ **เนื้อหาครบถ้วน อ่านแล้วทำงานต่อได้ทันที** โดยแยกเป็นหัวข้อ **รายแต่ละงาน (Task-by-Task Breakdown)** สำหรับทุกงานที่ทำในเซสชันนี้:
     - **Session Metadata**: วันที่/เวลา, Conversation ID, Token Count ล่าสุด, Branch / Last Commit
     - **Task N: `<ชื่องาน>` (`Done` | `In Progress` | `Blocked`)**:
       - **Goal / Requirement**: เป้าหมายและขอบเขตของงาน
       - **What Was Done & Verification Results**: สิ่งที่ทำเสร็จจริง + ผลรัน Test / Build / Typecheck / Browser verify (ระบุเฉพาะผลที่รันจริง)
       - **Key Decisions & Rationale**: ข้อตกลงหรือเหตุผลสถาปัตยกรรมที่เลือก (และทางเลือกที่ตัดทิ้ง)
       - **Modified / Created Files**: รายการไฟล์ที่แก้ไข/สร้างพร้อมบทบาทสั้นๆ
       - **Open Issues / Blockers**: จุดติดขัดหรือสิ่งที่ยังต้องระวัง
     - **Next Immediate Step & Resume Guide**: ขั้นตอนแรกที่ต้องทำต่อทันทีเมื่อเปิดแชทใหม่, คำสั่ง CLI ที่เกี่ยวข้อง, และ **Suggested Skills** ที่ควรเรียกใช้

3. **`.agents/memory/archive/handoff-YYYYMMDD-HHmm.md` (สำรองประวัติก่อนหน้า)**:
   - **ห้ามเขียนทับโดยไม่สำรอง**: หากมี `.agents/memory/handoff-latest.md` เดิมอยู่แล้ว ให้ย้ายหรือคัดลอกไฟล์เดิมไปเก็บใน `.agents/memory/archive/` ก่อนทุกครั้ง

4. **`.agents/memory/bridge.json` (Bridge File แบบ Machine-Readable)**:
   - บันทึก `lastUpdated`, `conversationId`, `tokenCountAtSummary`, `lastWorkingCommit`, `modifiedFiles`, `openBlockers`, `nextImmediateTask`, และ `handoffFile`

## No-Workspace Fallback (แชทที่ไม่ได้เปิดโฟลเดอร์โปรเจกต์)

หากไม่มี Active Workspace เปิดอยู่ (เช่น แชทปรึกษาทั่วไปหรือเอกสารนอกโปรเจกต์):
1. ไม่ต้องสร้าง `PROJECT_CONTEXT.md` ในโฟลเดอร์ผู้ใช้ทั่วไป
2. สำรองไฟล์เดิม (ถ้ามี) และบันทึกไฟล์สรุปแบบ Task-by-Task ลงที่:
   - `~/.gemini/antigravity/scratch/handoffs/handoff-latest.md`
   - สำรองเดิมไปที่ `~/.gemini/antigravity/scratch/handoffs/archive/handoff-YYYYMMDD-HHmm.md`
   - อัปเดต `~/.gemini/antigravity/scratch/handoffs/bridge.json`
3. **ไม่ต้อง auto-load ข้ามแชท** (เพื่อไม่ให้ปนกับแชทเรื่องอื่น) ให้แสดง **ลิงก์ไฟล์ที่คลิกได้ + สรุปพร้อมก๊อปไปวางต่อในแชทใหม่** ในคำตอบสุดท้ายแทน

## Security & Git Governance

- **Gitignore Policy (Active Workspace)**:
  - คง `PROJECT_CONTEXT.md` ไว้ให้ Git track ตามปกติ
  - ตรวจสอบ `.gitignore` (ถ้ามี `.git`): หาก `.agents/memory/` ยังไม่ได้ถูก track ใน Git (`git ls-files .agents/memory/` ว่างเปล่า) และยังไม่อยู่ใน `.gitignore` ให้เพิ่ม `.agents/memory/` ลงใน `.gitignore` เพื่อไม่ให้ประวัติรายแชทไปรก Git log ของทีม
- **Privacy & Secret Redaction**:
  - **ห้าม** บันทึก API keys, tokens, passwords, connection strings, ข้อมูลส่วนบุคคล (PII) หรือข้อมูลลับองค์กรลงในไฟล์ความจำใดๆ ให้ Mask/Redact เสมอ

## Instructions for the Agent

1. **สำรวจบริบทปัจจุบัน**:
   - หากมี Active Workspace: อ่าน `package.json` / `pyproject.toml` / `PROJECT_CONTEXT.md` (ถ้ามี) และตรวจ `git status` + `git log -n 5`
   - รวบรวมงานทั้งหมดที่ทำในเซสชันปัจจุบัน (เป้าหมาย, การตัดสินใจ, ไฟล์ที่แก้, ผลทดสอบจริง, งานค้าง)
2. **สำรองไฟล์ Handoff เดิม**:
   - ตรวจสอบว่ามี `handoff-latest.md` เดิมอยู่หรือไม่ หากมีให้คัดลอก/ย้ายไป `archive/handoff-YYYYMMDD-HHmm.md` ก่อนเขียนฉบับใหม่
3. **เขียน/อัปเดตไฟล์ความจำ**:
   - เขียน `handoff-latest.md` แบบ **รายแต่ละงาน** ให้ครบถ้วนตามโครงสร้างด้านบน (ตรวจสอบไม่ให้มี Secrets)
   - อัปเดต `bridge.json` และ (กรณีมี Workspace) สร้าง/อัปเดต `PROJECT_CONTEXT.md` โดยคงส่วนประวัติเดิมที่สำคัญไว้และอัปเดต Status, Milestones, Next Actions
   - ตรวจสอบ `.gitignore` สำหรับ `.agents/memory/` ในโปรเจกต์ Git
4. **แจ้งผลและคำแนะนำต่อผู้ใช้**:
   - แสดงสรุปสั้นๆ พร้อมลิงก์คลิกได้ไปยังไฟล์ที่สร้าง/อัปเดต
   - หากถูกกระตุ้นจากเกณฑ์ **`450,000` tokens** ให้แจ้งยอด Token ปัจจุบันชัดเจน และแนะนำให้ผู้ใช้ **เปิดแชทใหม่** (แชทใหม่ใน Workspace จะโหลด `handoff-latest.md` ให้อัตโนมัติทันที) หรือรัน `/compact`
