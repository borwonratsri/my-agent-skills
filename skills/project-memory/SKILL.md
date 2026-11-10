---
name: project-memory
description: จัดการระบบความจำถาวรของโปรเจกต์ สร้างไฟล์ PROJECT_CONTEXT.md พร้อม Bridge Files ข้ามเซสชัน เพื่อรักษาบริบทการพัฒนาอย่างต่อเนื่อง
---

# Project Memory: ระบบบันทึกบริบทและความจำถาวรของโปรเจกต์

ระบบสำหรับบันทึกและถ่ายทอดบริบทการทำงานของโปรเจกต์ (Persistent Project Memory) เพื่อให้ AI Agent ในเซสชันถัดไป หรือในเครื่องอื่น สามารถเข้าใจสถานะ ลำดับขั้นตอน สถาปัตยกรรม และงานคงค้างได้ทันทีโดยไม่ต้องเริ่มต้นอธิบายใหม่

## Trigger Scenarios
- Slash command: `/project-memory`
- ผู้ใช้สั่ง: "บันทึก memory ของโปรเจกต์นี้", "สร้าง PROJECT_CONTEXT.md", "สรุปสถานะโปรเจกต์ไว้ส่งต่อ", "Save project context"

## โครงสร้างไฟล์ความจำ (Core Memory Files)

1. **`PROJECT_CONTEXT.md` (ไฟล์ความจำหลักที่ Root ของโปรเจกต์)**:
   - **Project Overview**: วัตถุประสงค์หลักของระบบและเป้าหมายทางธุรกิจ
   - **Tech Stack & Toolchain**: ภาษา Framework ฐานข้อมูล และ Libraries สำคัญ
   - **Architecture & Directory Map**: แผนผังโฟลเดอร์และหน้าที่ของแต่ละโมดูล
   - **Key Conventions & Rules**: กฎการเขียนโค้ด (Coding standard, Git flow, Error handling)
   - **Current Status & Milestones**: สิ่งที่ทำเสร็จแล้ว (Done) และงานที่กำลังทำอยู่ (In-Progress)
   - **Next Actions (Backlog)**: งานที่ต้องทำต่อในเซสชันหน้า

2. **`.agents/memory/bridge.json` (Bridge File ข้ามเซสชัน)**:
   - บันทึก Last Working Commit, Modified Files ล่าสุด, Open Blockers, และ Next Immediate Task แบบ Machine-Readable

## Instructions for the Agent

1. **สแกนโปรเจกต์**:
   - อ่าน `package.json`, `pyproject.toml`, `go.mod`, หรือ README เพื่อรวบรวมข้อมูลสถาปัตยกรรม
   - ตรวจสอบ `git status` และ `git log -n 5` เพื่อดูการเปลี่ยนแปลงล่าสุด
2. **สร้างหรืออัปเดต `PROJECT_CONTEXT.md`**:
   - หากยังไม่มีไฟล์ ให้สร้างโครงสร้างมาตรฐานขึ้นมา
   - หากมีไฟล์อยู่แล้ว ให้คงประวัติเดิมไว้ และอัปเดตเฉพาะส่วน Status, Milestones และ Next Actions
3. **ยืนยันและสรุปผล**:
   - แสดงสรุปสั้นๆ ให้ผู้ใช้ทราบว่าได้บันทึกบริบทหัวข้อใดบ้างเรียบร้อยแล้ว
