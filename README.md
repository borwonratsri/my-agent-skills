# 🚀 My Agent Skills Library (Curated & Consolidated Edition)

คลังรวบรวม **Antigravity Skills** แบบพกพาที่ผ่านการจัดหมวดหมู่ รวมทักษะที่ทับซ้อน และคัดสรรเฉพาะเครื่องมือที่จำเป็นและทรงพลังที่สุด (**รวม 55 Skills**) พร้อมคู่มือการตั้งค่า **MCP Servers** ที่จำเป็นต่อการพัฒนาซอฟต์แวร์

---

## ⚡ วิธีติดตั้งด่วน (Quick 1-Line Install)

เพียงรันคำสั่งด้านล่างนี้ใน Terminal ของเครื่องหรือ Environment ใดก็ได้ที่ใช้ Antigravity:

### 1. ติดตั้งระดับ Global (แนะนำ - ใช้ได้กับทุกโปรเจกต์ในเครื่องทันที)
คำสั่งนี้จะติดตั้ง Skills ทั้งหมดลงใน `~/.gemini/config/skills/` ทำให้ Agent ในเครื่องนั้นมองเห็นและเรียกใช้ได้ทันทีทุก Workspace:

```bash
curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash
```

### 2. ติดตั้งเฉพาะโปรเจกต์ปัจจุบัน (Workspace Scope)
หากต้องการติดตั้งลงเฉพาะโฟลเดอร์โปรเจกต์ปัจจุบัน (`.agents/skills/`):

```bash
curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash -s -- --workspace
```

---

## 🔌 คู่มือการตั้งค่า MCP Servers ที่จำเป็น (Essential MCPs Guide)

Model Context Protocol (MCP) ช่วยให้ AI Agent เชื่อมต่อกับเครื่องมือจริงภายนอกได้โดยตรง แนะนำให้เพิ่มการตั้งค่าด้านล่างนี้ลงในไฟล์คอนฟิก MCP ของคุณ (`settings.json` หรือ client MCP configuration):

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest", "--categoryExtensions", "--memoryDebugging"]
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://USER:PASSWORD@localhost:5432/DBNAME"]
    },
    "sqlite": {
      "command": "uvx",
      "args": ["mcp-server-sqlite", "--db-path", "/path/to/database.db"]
    }
  }
}
```

### 🌟 ประโยชน์ของแต่ละ MCP:
1. **Chrome DevTools MCP (`chrome-devtools-mcp`)**: ควบคุม Google Chrome จริง ทำการคลิก, พิมพ์, แคปหน้าจอ, ดึง DOM Snapshot, ตรวจวัดความเร็ว Core Web Vitals (LCP), ตรวจสอบ Cookies และหา Memory Leaks
2. **Postgres / SQLite MCP**: เปิดให้ Agent สามารถอ่าน Schema ตาราง, รันคำสั่ง SQL วิเคราะห์ข้อมูล และตรวจสอบ Migration ได้อย่างปลอดภัยโดยไม่ต้องสลับหน้าจอ

---

## 📦 สารบัญ Skills ทั้งหมดในคลัง (55 รายการหลังรวมและคัดสรร)

### 🧩 1. Matt Pocock Engineering & Spec Workflow (23 Skills)
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

### 🎨 2. UI & Frontend Design (คัดสรรและรวมเหลือ 5 ทักษะตัวท็อป)
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `ui-taste` | **(Master Consolidated)** รวมกฎ Anti-UI-Slop, Design Tokens, และ Polish Playbooks ของ Uizze เข้าไว้ในตัวเดียว |
| `image-to-ui` | แปลงภาพดีไซน์ ภาพสเก็ตช์ หรือ Mockup ให้เป็นโค้ด UI |
| `website-design` | ออกแบบหน้าเว็บไซต์และ UI/UX ระดับมืออาชีพ พร้อมจัดวาง Section Landing Page |
| `web-app-development` | สร้างและปรับแต่ง Web App, React, Next.js, Vite, HTML/CSS/JS |
| `generative_ui` | แสดงผล Rich Interactive Widgets, Charts, Dashboard ในแชต |

### 💻 3. Professional Engineering & Architecture (8 Skills)
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

### 🏥 4. Enterprise, Pharma & Data Domain (5 Skills)
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `product-impact-assessment` | Pharmaceutical Product Impact Assessment (PIA) ประเมินผลกระทบ GMP/Change Control/OOS |
| `schema-mapping` | วิเคราะห์ จัดทำ และแมปปิ้งโครงสร้างข้อมูลระหว่างระบบ API/Database |
| `project-memory` | จัดการระบบความจำถาวรของโปรเจกต์ สร้างไฟล์ `PROJECT_CONTEXT.md` |
| `summary-text` | สรุปความจากข้อความอย่างเป็นทางการระดับผู้บริหาร (Executive Summary) |
| `skill-repair` | ตรวจสอบ ซ่อมแซม และติดตั้ง Skills ที่มีปัญหา syntax/permissions |

### 🔍 5. Chrome DevTools MCP (รวม 7 ทักษะเดิมเป็น 1 ทักษะ Master)
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `chrome-devtools` | **(Master Consolidated)** ควบคุมเบราว์เซอร์, Debug เว็บ, ปรับแต่ง Core Web Vitals (LCP), ตรวจสอบ Memory Leaks, Accessibility (a11y) และ Cookies |

### ☁️ 6. Cloud, Google Workspace & Management (8 Skills)
- `github` : จัดการ Pull Requests, Issues, Repos, และ GitHub Actions ผ่าน CLI
- `gdrive` : ค้นหา จัดการ อัปโหลด/ดาวน์โหลดไฟล์บน Google Drive
- `gsheets` : จัดการ อ่าน เขียน และคำนวณข้อมูลใน Google Sheets
- `gcalendar` : ตรวจสอบนัดหมายและตารางเวลาใน Google Calendar
- `gdocs` : อ่าน เขียน และจัดรูปแบบเอกสาร Google Docs
- `gslides` : ออกแบบและสร้างสไลด์ Google Slides
- `run-workflow` : รัน Autonomous Workflows และ Tasks ที่มีความซับซ้อน
- `migrate-workflows` : แปลง Legacy Workflows เป็น Modern Skills อัตโนมัติ
- `sync-agent-skills` : ซิงค์ Skills อัตโนมัติระหว่างเครื่องกับ GitHub Repo นี้

---

## 🔄 วิธีเพิ่ม Custom Skill ใหม่ และซิงค์ขึ้น GitHub

```bash
./sync.sh push "Add my new skill"
```

## 📥 วิธีอัปเดต Skills ให้เป็นเวอร์ชันล่าสุด

```bash
curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash
```
