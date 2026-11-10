# 🚀 My Agent Skills

คลังรวบรวม **Antigravity Skills** แบบพกพาครบวงจรที่สุด (**รวมทั้งหมด 66 Skills**) พร้อมชุดสคริปต์ติดตั้งอัตโนมัติด้วยคำสั่งเดียว (`1-Line Installer`) และระบบซิงค์ข้อมูลกับ GitHub สามารถนำไปติดตั้งใช้งานได้ทันทีในทุกเครื่อง, ทุก Environment หรือทุก Workspace ใหม่

---

## ⚡ วิธีติดตั้งด่วน (Quick Install)

เพียงรันคำสั่งด้านล่างนี้ใน Terminal ของเครื่องหรือ Environment ใดก็ได้ที่ใช้ Antigravity:

### 1. ติดตั้งระดับ Global (แนะนำ - ใช้ได้กับทุกโปรเจกต์ในเครื่องทันที)
คำสั่งนี้จะติดตั้ง Skills ทั้งหมด 66 รายการลงใน `~/.gemini/config/skills/` ทำให้ Agent ในเครื่องนั้นมองเห็นและเรียกใช้ได้ทันทีทุก Workspace:

```bash
curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash
```

### 2. ติดตั้งเฉพาะโปรเจกต์ปัจจุบัน (Workspace Scope)
หากต้องการติดตั้งลงเฉพาะโฟลเดอร์โปรเจกต์ปัจจุบัน (`.agents/skills/`):

```bash
curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash -s -- --workspace
```

---

## 📦 สารบัญ Skills ทั้งหมดในคลัง (66 รายการ)

### 🧩 1. Matt Pocock Engineering & Spec Workflow Suite
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `setup-matt-pocock-skills` | ตั้งค่า Issue Tracker, Triage Labels, และโครงสร้างเอกสารของโปรเจกต์ |
| `grill-with-docs` | สัมภาษณ์และเจาะลึกความต้องการร่วมกับเอกสารก่อนเริ่มโค้ด |
| `to-spec` | แปลงบทสนทนาและข้อสรุปให้เป็น Technical Specification |
| `to-tickets` | ซอย Spec ออกเป็น Tracer-bullet Tickets ลงใน Issue Tracker |
| `implement` / `implement-spec` | นำ Ticket หรือ Spec มาพัฒนาเป็นโค้ดจริงทีละสเต็ป |
| `tdd` | Test-Driven Development เขียน Test นำก่อนเขียนฟีเจอร์ |
| `triage` | จัดการและคัดแยกประเด็นใน Issue Tracker |
| `diagnosing-bugs` | วินิจฉัยและระบุต้นตอของบักอย่างเป็นระบบ |
| `improve-codebase-architecture` | ปรับปรุงสถาปัตยกรรมโค้ดเบสใหญ่ให้เป็นระเบียบ |
| `codebase-design` | ออกแบบโครงสร้างระบบและโมดูลของโปรเจกต์ |
| `prototype` | สร้าง Proof of Concept (PoC) และ Prototype รวดเร็ว |
| `retro` | ประเมินผลและ Retrospective หลังจบงาน |
| `wayfinder` | ค้นหาและทำความเข้าใจไฟล์สำคัญในโค้ดเบสขนาดใหญ่ |
| `wizard` | ผู้ช่วยแนะนำการใช้งาน Skills และเครื่องมือ |
| `research` | วิจัยและค้นคว้าข้อมูลเชิงลึกจาก Primary Sources |
| `teach` | สอนและอธิบายแนวคิด คอนเซ็ปต์ หรือเครื่องมือใหม่ๆ ในโปรเจกต์ |
| `handoff` | ส่งต่อ Context ข้ามเซสชันหรือข้ามเอเจนต์ |
| `writing-for-agents` | เขียนและปรับแต่ง Instructions สำหรับ AI Agents |
| `ask-matt` | ถามคำถามและขอคำแนะนำทางเทคนิค |
| `pr` | จัดการ Pull Request สรุปการเปลี่ยนแปลงและตรวจสอบความพร้อม |
| `grill-me` / `grilling` | สัมภาษณ์ถามตอบทีละขั้นจนกว่าจะได้ข้อสรุปที่ตรงกัน |
| `to-questionnaire` | สร้างแบบสอบถามเพื่อเจาะลึกความต้องการ |
| `wait-what` | ตรวจสอบสมมติฐานและหยุดทบทวนความถูกต้อง |

### 🎨 2. UI & Design Polish Suite (Uizze & UI Taste)
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `ui-taste` | ยกระดับ UI ให้ดูเป็นมืออาชีพ ป้องกันปัญหา AI UI Slop |
| `anti-ui-slop` | กฎและ Playbook ห้ามไม่ให้เอเจนต์สร้าง UI ที่ดูโหลหรือไม่ประณีต |
| `ui-design` | ออกแบบหน้าตาและส่วนประกอบตามมาตรฐานโมเดิร์น |
| `ui-radar` | ตรวจสอบจุดบกพร่องด้านการจัดวางและ Hierarchy บนหน้าจอ |
| `uizze-ui` | ดึงตัวอย่าง Real App References และ Design Tokens |
| `image-to-ui` | แปลงภาพดีไซน์หรือภาพสเก็ตช์ให้เป็นโค้ด UI |

### 🎯 3. Custom & Domain Specific Skills
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `project-memory` | จัดการระบบความจำถาวรของโปรเจกต์ สร้างไฟล์ `PROJECT_CONTEXT.md` |
| `summary-text` | สรุปความจากข้อความอย่างเป็นทางการระดับผู้บริหาร (Executive Summary) |
| `website-design` | ออกแบบหน้าเว็บไซต์และ UI/UX ระดับมืออาชีพ พร้อม Component สวยงาม |
| `product-impact-assessment` | Pharmaceutical Product Impact Assessment (PIA) ประเมินผลกระทบ GMP/Change Control |
| `schema-mapping` | วิเคราะห์ จัดทำ และแมปปิ้งโครงสร้างข้อมูลระหว่างระบบ |
| `skill-repair` | ตรวจสอบ ซ่อมแซม และติดตั้ง Skills ที่มีปัญหา syntax/permissions |

### 💻 4. Professional Engineering & Architecture
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `code-reviewer` | รีวิวโค้ดเชิงลึก ตรวจสอบบั๊ก Logic, Security, Performance |
| `unit-test-generator` | สร้าง Unit และ Integration Tests ครอบคลุม Edge Cases และ Mocks |
| `refactoring-clean-code` | ปรับโครงสร้างโค้ดให้อ่านง่าย ลดความซับซ้อนตามหลัก SOLID |
| `api-architect` | ออกแบบ RESTful API, OpenAPI 3.0 Specs, GraphQL, และ gRPC |
| `database-architect` | ออกแบบ Database Schema, ER Diagram, Migration และ Indexing |
| `docker-devops` | สร้าง Dockerfile (Multi-stage), Docker Compose และ CI/CD Pipelines |
| `security-auditor` | ตรวจสอบช่องโหว่ความปลอดภัยตาม OWASP Top 10 และ Secrets Leak |
| `technical-writer` | ผลิตเอกสารเทคนิค ADRs, API Reference, Runbook และ Architecture Guide |

### 🔍 5. Chrome DevTools & Web Debugging
- `chrome-devtools` : ตรวจสอบ ดีบักเว็บ ออโตเมชันเบราว์เซอร์
- `chrome-devtools-cli` : ควบคุมและทดสอบเบราว์เซอร์ผ่าน CLI
- `debug-optimize-lcp` : วิเคราะห์และปรับแต่งความเร็ว Core Web Vitals (LCP)
- `memory-leak-debugging` : ตรวจจับและวิเคราะห์ปัญหา Memory Leak / Heap Snapshot
- `a11y-debugging` : ตรวจสอบ Accessibility (a11y), Semantic HTML, ARIA, Focus
- `cookie-debugging` : ดีบัก Cookies, Session State, Headers, Cookie Consent
- `troubleshooting` : วิเคราะห์และแก้ปัญหาเชื่อมต่อ DevTools Server

### 🤖 6. Built-in & Web Tools
- `web-app-development` : สร้างและปรับแต่ง Web App, UI, React, Next.js, Vite
- `generative_ui` : เรนเดอร์ Rich Interactive Widgets, Charts, Dashboard ในแชต
- `run-workflow` : รัน Autonomous Workflows และ Tasks ที่มีความซับซ้อน
- `migrate-workflows` : แปลง Legacy Workflows เป็น Modern Skills อัตโนมัติ

### ☁️ 7. Git & Google Workspace Apps
- `github` : จัดการ Pull Requests, Issues, Repos, และ GitHub Actions ผ่าน CLI
- `gdrive` : ค้นหา จัดการ อัปโหลด/ดาวน์โหลดไฟล์บน Google Drive
- `gsheets` : จัดการ อ่าน เขียน และคำนวณข้อมูลใน Google Sheets
- `gcalendar` : ตรวจสอบนัดหมายและตารางเวลาใน Google Calendar
- `gdocs` : อ่าน เขียน และจัดรูปแบบเอกสาร Google Docs
- `gslides` : ออกแบบและสร้างสไลด์ Google Slides

### 🛠️ 8. Management & Template
- `sync-agent-skills` : ซิงค์ Skills อัตโนมัติระหว่างเครื่องกับ GitHub Repo นี้
- `example-custom-skill` : โครงสร้างแม่แบบสำหรับการสร้าง Custom Skill เพิ่มเติมในอนาคต

---

## 🔄 วิธีเพิ่ม Custom Skill ใหม่ และซิงค์ขึ้น GitHub

```bash
./sync.sh push "Add my new skill"
```

## 📥 วิธีอัปเดต Skills ให้เป็นเวอร์ชันล่าสุด

```bash
curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash
```
