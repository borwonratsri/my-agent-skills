# 🚀 My Agent Skills

คลังรวบรวม **Antigravity Skills** แบบพกพาครบวงจร (**รวมทั้งหมด 27 Skills**) พร้อมชุดสคริปต์ติดตั้งอัตโนมัติด้วยคำสั่งเดียว (`1-Line Installer`) และระบบซิงค์ข้อมูลกับ GitHub สามารถนำไปติดตั้งใช้งานได้ทันทีในทุกเครื่อง, ทุก Environment หรือทุก Workspace ใหม่

---

## ⚡ วิธีติดตั้งด่วน (Quick Install)

เพียงรันคำสั่งด้านล่างนี้ใน Terminal ของเครื่องหรือ Environment ใดก็ได้ที่ใช้ Antigravity:

### 1. ติดตั้งระดับ Global (แนะนำ - ใช้ได้กับทุกโปรเจกต์ในเครื่องทันที)
คำสั่งนี้จะติดตั้ง Skills ทั้งหมด 27 รายการลงใน `~/.gemini/config/skills/` ทำให้ Agent ในเครื่องนั้นมองเห็นและเรียกใช้ได้ทันทีทุก Workspace:

```bash
curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash
```

### 2. ติดตั้งเฉพาะโปรเจกต์ปัจจุบัน (Workspace Scope)
หากต้องการติดตั้งลงเฉพาะโฟลเดอร์โปรเจกต์ปัจจุบัน (`.agents/skills/`):

```bash
curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash -s -- --workspace
```

---

## 📦 รายชื่อ Skills ทั้งหมดในคลัง (27 รายการ)

### 💻 1. Professional Software Engineering & Quality (8 Skills)
| ชื่อ Skill | คำอธิบาย | Slash Command |
| :--- | :--- | :--- |
| `code-reviewer` | รีวิวโค้ดเชิงลึก ตรวจสอบบั๊ก ความปลอดภัย ประสิทธิภาพ และ Clean Architecture | `/code-reviewer` |
| `unit-test-generator` | สร้าง Unit และ Integration Tests คุณภาพสูง ครอบคลุม Edge Cases และ Mocks | `/unit-test-generator` |
| `refactoring-clean-code` | ปรับโครงสร้างโค้ดให้อ่านง่าย ลดความซับซ้อนตามหลัก SOLID โดยไม่กระทบการทำงานเดิม | `/refactoring-clean-code` |
| `api-architect` | ออกแบบ RESTful API, OpenAPI 3.0 Specs, GraphQL, และ gRPC พร้อม Error Handling มาตรฐาน | `/api-architect` |
| `database-architect` | ออกแบบ Database Schema, ER Diagram, Migration Scripts, Indexing, และ Query Tuning | `/database-architect` |
| `docker-devops` | สร้าง Dockerfile (Multi-stage), Docker Compose, และ GitHub Actions CI/CD Pipelines | `/docker-devops` |
| `security-auditor` | ตรวจสอบช่องโหว่ความปลอดภัยตาม OWASP Top 10, Secrets Leak, และ Dependency Vulnerabilities | `/security-auditor` |
| `technical-writer` | ผลิตเอกสารทางเทคนิคระดับมืออาชีพ Architecture Decision Records (ADRs), API Specs, Runbooks | `/technical-writer` |

### 🌐 2. Web & UI Development (2 Skills)
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `web-app-development` | สร้างและปรับแต่ง Web App, UI, React, Vite, Next.js, HTML/CSS/JS |
| `generative_ui` | แสดงผล Rich UI Widgets, แผนภูมิข้อมูล, แดชบอร์ดแบบ Interactive ในแชต |

### 🔍 3. Chrome DevTools & Web Debugging (7 Skills)
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `chrome-devtools` | ออโตเมชันเบราว์เซอร์และ Debug เว็บไซต์ผ่าน Chrome DevTools MCP |
| `chrome-devtools-cli` | สคริปต์ควบคุมและทดสอบเบราว์เซอร์ผ่าน CLI |
| `debug-optimize-lcp` | วิเคราะห์และปรับแต่ง Core Web Vitals (Largest Contentful Paint) |
| `memory-leak-debugging` | ตรวจจับและวิเคราะห์ปัญหา Memory Leak / Heap Snapshot ใน JS/Node.js |
| `a11y-debugging` | ตรวจสอบ Accessibility (a11y), Semantic HTML, ARIA, Focus, และ Color Contrast |
| `cookie-debugging` | ดีบัก Cookies, Session State, Headers, และ Cookie Consent |
| `troubleshooting` | แก้ปัญหาการเชื่อมต่อและการเริ่มทำงานของ DevTools Browser Server |

### 🤖 4. Automation & Workflows (2 Skills)
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `run-workflow` | รัน Autonomous Workflows และ Tasks ที่มีความซับซ้อน |
| `migrate-workflows` | แปลง Legacy Workflows เป็น Modern Skills อัตโนมัติ |

### ☁️ 5. Cloud & Google Workspace Apps (6 Skills)
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `github` | ทำงานกับ GitHub ผ่าน GitHub CLI (PR, Issues, CI Actions, Repos) |
| `gdrive` | ค้นหา จัดการ ดาวน์โหลด และอัปโหลดไฟล์ใน Google Drive |
| `gsheets` | อ่าน เขียน จัดรูปแบบ และคำนวณข้อมูลใน Google Sheets |
| `gcalendar` | จัดการนัดหมายและตารางเวลาใน Google Calendar |
| `gdocs` | อ่าน เขียน และจัดรูปแบบเอกสาร Google Docs |
| `gslides` | สร้างและตกแต่งสไลด์นำเสนอ Google Slides |

### 🛠️ 6. Management & Template (2 Skills)
| ชื่อ Skill | คำอธิบาย |
| :--- | :--- |
| `sync-agent-skills` | ซิงค์ Skills อัตโนมัติระหว่างเครื่องกับ GitHub Repository นี้ (`/sync-agent-skills`) |
| `example-custom-skill` | แม่แบบและตัวอย่างโครงสร้างสำหรับการสร้าง Custom Skill ใหม่ |

---

## 🛠️ โครงสร้างของ Repository

```text
my-agent-skills/
├── README.md               # เอกสารแนะนำและคู่มือการใช้งาน 27 Skills
├── install.sh              # สคริปต์ติดตั้งอัตโนมัติ (รองรับ Global และ Workspace)
├── sync.sh                 # สคริปต์ช่วยซิงค์ ดึง หรือส่ง Skills ขึ้น GitHub
└── skills/                 # โฟลเดอร์เก็บ Skills ทั้งหมด (27 skills)
    ├── code-reviewer/
    ├── unit-test-generator/
    ├── refactoring-clean-code/
    ├── api-architect/
    ├── database-architect/
    ├── docker-devops/
    ├── security-auditor/
    ├── technical-writer/
    ├── chrome-devtools/
    ├── web-app-development/
    ├── sync-agent-skills/
    └── ... (skills อื่นๆ)
```

---

## 🔄 วิธีเพิ่ม Custom Skill ใหม่ และซิงค์ขึ้น GitHub

### 1. วิธีเพิ่ม Skill ใหม่
สร้างโฟลเดอร์ใหม่ใน `skills/<ชื่อ-skill>/` และสร้างไฟล์ `SKILL.md` ตามรูปแบบมาตรฐาน:

```markdown
---
name: my-new-skill
description: อธิบายสั้นๆ ว่า Skill นี้ทำอะไร และควรเรียกใช้เมื่อใด
---

# My New Skill

คำสั่ง ขั้นตอน หรือ Guideline ที่ต้องการให้ Agent ปฏิบัติตามเมื่อเรียกใช้ Skill นี้...
```

### 2. สั่งซิงค์และ Push ขึ้น GitHub
รันสคริปต์ `sync.sh`:

```bash
./sync.sh push "Add my new skill"
```

สคริปต์จะตรวจหา Skills ใหม่ ทำการ Commit และ Push ขึ้น GitHub ให้ทันที

---

## 📥 วิธีอัปเดต Skills ให้เป็นเวอร์ชันล่าสุด

เมื่อมีการแก้ไขหรือเพิ่ม Skill ใหม่บน GitHub หากต้องการอัปเดตในเครื่องของคุณ สามารถรัน:

```bash
# หากอยู่ใน repo
./sync.sh pull

# หรือรันคำสั่ง 1-Line installer ซ้ำอีกครั้งได้ตลอดเวลา
curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash
```
