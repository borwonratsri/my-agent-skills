# 🏛️ My Agent Skills & Factory Droids Library (Unified Master Edition)

คลังรวบรวม **Antigravity Skills** แบบพกพาที่รวมระบบ **Factory AI Architecture** (Autonomous Subagent Droids + Token Context Presets) เข้ากับ **Curated 57 Skills** และ **Essential MCP Servers** ไว้ในที่เดียวอย่างสมบูรณ์แบบ

---

## ⚡ วิธีติดตั้งด่วน (Quick 1-Line Install)

เปิด Terminal แล้วคัดลอกคำสั่งบรรทัดเดียวไปวางและรันได้ทันที:

### 🪟 สำหรับ Windows (PowerShell)

**1. ติดตั้งครบทั้งหมด 118 สกิลทันที (58 มาตรฐาน + 60 PStack Production Rigor):**
```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1))) -All
```

**2. ติดตั้งเฉพาะชุดหลัก Curated 58 สกิล (เร็ว เบา ประหยัด Token):**
```powershell
irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1 | iex
```

> [!TIP]
> ตัวติดตั้งรองรับ **Smart Update**: หากในเครื่องคุณมีสกิลอยู่แล้ว ระบบจะอัปเดตทับเฉพาะสกิลที่ชื่อตรงกันให้เป็นเวอร์ชันล่าสุดจาก GitHub แต่จะคง Custom Skills อื่นๆ ที่คุณมีไว้ตามเดิม ไม่มีการลบของเก่าทิ้งครับ

---

### 🐧 สำหรับ Linux / macOS / Git Bash / WSL

**1. ติดตั้งครบทั้งหมด 118 สกิล (รวม PStack):**
```bash
curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash -s -- --pstack
```

**2. ติดตั้งชุดหลัก 58 สกิล:**
```bash
curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash
```

**3. ติดตั้งเฉพาะในโฟลเดอร์โปรเจกต์ปัจจุบัน (Workspace Scope):**
```bash
curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash -s -- --workspace
```

---

## 🏭 สถาปัตยกรรมระดับ Factory (Autonomous Droids & Dark Factory)

ระบบนำโมเดล **Factory AI x Anthropic Claude** มาใช้แยกบทบาทของ AI ออกเป็น 3 เอเจนต์ย่อยอิสระ พร้อมระบบ **Tool Gating** เพื่อป้องกัน Bias และช่องโหว่ความปลอดภัย:

```mermaid
flowchart LR
    Task[User Task / Requirement] --> Coder["👨‍💻 Coder Droid<br/>(Full Edit & Exec)"]
    Coder -->|Implementation| Tester["🧪 Tester Droid<br/>(Write Tests & Run)"]
    Tester -->|Tests Fail| Coder
    Tester -->|Tests Pass| Reviewer["🛡️ Reviewer Droid<br/>(🔒 Strictly Read-Only)"]
    Reviewer -->|Changes Requested| Coder
    Reviewer -->|APPROVED| PR["✅ Ready for Merge / PR"]
```

- **Coder Droid (`coder-droid`)**: Senior Software Engineer ทำหน้าที่วางแผนและเขียนโค้ด (Full Read/Write/Exec)
- **Tester Droid (`tester-droid`)**: QA Engineer เขียน Unit/Integration Tests และรันเทสสวีท ส่ง Feedback กลับหา Coder ทันทีที่เทสไม่ผ่าน
- **Reviewer Droid (`reviewer-droid`)**: Staff Engineer & Security Auditor ตรวจสอบโค้ดและช่องโหว่แบบ **Read-Only 100%** ป้องกันการแอบแก้โค้ดเพื่อหลบการตรวจ

### 💬 วิธีสั่งงาน Droids ผ่านแชต:
- พิมพ์คำสั่ง `/factory-droids` หรือสั่ง *"รัน Autonomous Pipeline สำหรับงานสร้างระบบ Login"*
- AI จะกระจายงานให้ Coder -> Tester -> Reviewer ตามลำดับโดยอัตโนมัติ

---

## 🎛️ ระบบบริหาร Token ด้วย Presets (`skill_manager.py`)

แก้ปัญหา Context Window เต็ม เมื่อมี Skills จำนวนมาก สามารถสลับ Preset เพื่อเปิดเฉพาะทักษะที่ต้องใช้ในงานนั้นๆ:

```bash
# ดูรายการ Presets ทั้งหมด
python skill_manager.py preset list

# สลับ Preset เฉพาะสายงาน (ลด Token ที่ไม่จำเป็นลง 65%)
python skill_manager.py preset apply web-fullstack   # สำหรับงาน Web / Next.js / APIs
python skill_manager.py preset apply mobile-app      # สำหรับงาน Flutter / Android
python skill_manager.py preset apply data-cloud      # สำหรับงาน GCP / BigQuery / dbt
python skill_manager.py preset apply pstack-rigor    # สำหรับเปิดระบบ PStack Production Rigor (60 skills)
python skill_manager.py preset apply minimal         # ประหยัด Token สูงสุด (เปิดเฉพาะทักษะหลัก)
python skill_manager.py preset apply full            # เปิดครบทุกทักษะ

# หรือสั่งผ่านแชตด้วยคำสั่ง:
/skill-manager
```

---

## 🛡️ PStack Production Rigor Subsystem (ระบบวิศวกรรมความถูกต้องระดับสูงสุด)

ระบบ **PStack** พัฒนาขึ้นโดย Lauren Tan ([@poteto](https://github.com/poteto)) เพื่อยกระดับ AI Agent จากการเขียนโค้ดแบบรีบร้อน ให้กลายเป็น **Principal Systems Engineer** ที่ทำงานด้วยความรอบคอบสูงสุด:

- **Isolated Ecosystem**: แยกเก็บ 60 ทักษะเฉพาะทางไว้ในไดเรกทอรี `pstack/` โดยไม่ปะปนกับทักษะทั่วไป ช่วยให้ Context สะอาดและไม่เปลือง Token
- **4-Phase Rigor Lifecycle**:
  1. **Setup & Budgeting** (`/setup-pstack`): กำหนด Reasoning Budget และจับคู่โมเดลตามความยากของงาน
  2. **Architectural Exploration** (`/why`, `/how`, `/architect`): สำรวจความจริงเชิงประจักษ์ และออกแบบสถาปัตยกรรมแข่งขันกัน 2 แบบ (Design Twice)
  3. **Multi-Agent Competition** (`/arena`, `/swarm`, `/interrogate`): ให้ Agent แข่งกันแก้ปัญหา และใช้ Cross-Judge จากโมเดลค่ายอื่นตัดสิน
  4. **Verification & Proofs** (`/create-verification-skill`, `/statechart`, `/unslop`): ขับเคลื่อนแอปจริง, พิสูจน์ด้วยแบบจำลองคณิตศาสตร์ TLA+, และล้าง AI Slop
- **Universal Compatibility**: รองรับทั้ง Cursor (`.cursor/rules/pstack-models.mdc`) และ Antigravity/Gemini (`pro`/`flash`/`inherit` tiers)

📖 **อ่านคู่มือขั้นตอนการทำงานและสถาปัตยกรรมฉบับสมบูรณ์ได้ที่:** [`PSTACK_WORKFLOW.md`](file:///home/antigravity/borwonratsri/my-agent-skills/PSTACK_WORKFLOW.md)

---

## 🔌 คู่มือการตั้งค่า MCP Servers ที่จำเป็น (Essential MCPs Guide)

เพิ่มการตั้งค่านี้ลงในไฟล์คอนฟิก MCP ของคุณ เพื่อให้ Agent เชื่อมต่อเครื่องมือภายนอกได้โดยตรง:

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

---

## 📦 สารบัญ Skills ทั้งหมดในคลัง (58 รายการ Curated + 60 รายการ PStack Isolated)

### 🤖 1. Factory Droids, Presets & Rigor Engine (3 Skills)
| ชื่อ Skill | คำอธิบาย | Slash Command |
| :--- | :--- | :--- |
| `factory-droids` | สั่งรัน Dark Factory Pipeline (Coder -> Tester -> Reviewer Droids) ในแชต | `/factory-droids` |
| `skill-manager` | สลับ Presets คัดกรอง Token และค้นหาแคตตาล็อกทักษะผ่านแชต | `/skill-manager` |
| `setup-pstack` | ตั้งค่าโมเดลและงบประมาณการคิดสำหรับระบบ PStack Production Rigor | `/setup-pstack` |

### 🧩 2. Matt Pocock Engineering & Spec Workflow (23 Skills)
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

### 🎨 3. UI & Frontend Design (5 Skills)
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `ui-taste` | **(Master Consolidated)** รวมกฎ Anti-UI-Slop, Design Tokens, และ Polish Playbooks ของ Uizze เข้าไว้ในตัวเดียว |
| `image-to-ui` | แปลงภาพดีไซน์ ภาพสเก็ตช์ หรือ Mockup ให้เป็นโค้ด UI |
| `website-design` | ออกแบบหน้าเว็บไซต์และ UI/UX ระดับมืออาชีพ พร้อมจัดวาง Section Landing Page |
| `web-app-development` | สร้างและปรับแต่ง Web App, React, Next.js, Vite, HTML/CSS/JS |
| `generative_ui` | แสดงผล Rich Interactive Widgets, Charts, Dashboard ในแชต |

### 💻 4. Professional Engineering & Architecture (8 Skills)
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

### 🏥 5. Enterprise, Pharma & Data Domain (5 Skills)
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `product-impact-assessment` | Pharmaceutical Product Impact Assessment (PIA) ประเมินผลกระทบ GMP/Change Control/OOS |
| `schema-mapping` | วิเคราะห์ จัดทำ และแมปปิ้งโครงสร้างข้อมูลระหว่างระบบ API/Database |
| `project-memory` | จัดการระบบความจำถาวรของโปรเจกต์ สร้างไฟล์ `PROJECT_CONTEXT.md` |
| `summary-text` | สรุปความจากข้อความอย่างเป็นทางการระดับผู้บริหาร (Executive Summary) |
| `skill-repair` | ตรวจสอบ ซ่อมแซม และติดตั้ง Skills ที่มีปัญหา syntax/permissions |

### 🔍 6. Chrome DevTools MCP (1 Master Skill)
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `chrome-devtools` | **(Master Consolidated)** ควบคุมเบราว์เซอร์, Debug เว็บ, ปรับแต่ง Core Web Vitals (LCP), ตรวจสอบ Memory Leaks, Accessibility (a11y) และ Cookies |

### ☁️ 7. Cloud, Google Workspace & Management (8 Skills)
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
