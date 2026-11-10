# 🚀 My Agent Skills

คลังรวบรวม **Antigravity Skills** แบบพกพา (ทั้งหมด 19 Skills) พร้อมชุดสคริปต์ติดตั้งอัตโนมัติด้วยคำสั่งเดียว (`1-Line Installer`) และระบบซิงค์ข้อมูลกับ GitHub สามารถนำไปติดตั้งใช้งานได้ทันทีในทุกเครื่อง, ทุก Environment หรือทุก Workspace ใหม่

---

## ⚡ วิธีติดตั้งด่วน (Quick Install)

เพียงรันคำสั่งด้านล่างนี้ใน Terminal ของเครื่องหรือ Environment ใดก็ได้ที่ใช้ Antigravity:

### 1. ติดตั้งระดับ Global (แนะนำ - ใช้ได้กับทุกโปรเจกต์)
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

## 📦 รายชื่อ Skills ทั้งหมดที่มีในคลัง (19 รายการ)

| หมวดหมู่ | ชื่อ Skill | คำอธิบาย |
| :--- | :--- | :--- |
| **Development** | `web-app-development` | สร้างและปรับปรุง Web App, UI, React, Vite, Next.js, HTML/CSS/JS |
| **Development** | `generative_ui` | แสดงผล Rich UI Widgets, แผนภูมิข้อมูล, แดชบอร์ดแบบ Interactive |
| **Chrome DevTools** | `chrome-devtools` | ออโตเมชันเบราว์เซอร์และ Debug เว็บไซต์ผ่าน Chrome DevTools MCP |
| **Chrome DevTools** | `chrome-devtools-cli` | สคริปต์ CLI สำหรับควบคุมและทดสอบเบราว์เซอร์ผ่าน DevTools |
| **Chrome DevTools** | `debug-optimize-lcp` | วิเคราะห์และปรับแต่งความเร็ว Core Web Vitals (Largest Contentful Paint) |
| **Chrome DevTools** | `memory-leak-debugging` | ตรวจสอบและแก้ไขปัญหา Memory Leak / Heap Snapshot ใน JS/Node.js |
| **Chrome DevTools** | `a11y-debugging` | ตรวจสอบ Accessibility (a11y), Semantic HTML, ARIA, และ Contrast |
| **Chrome DevTools** | `cookie-debugging` | ดีบัก Cookies, Session State, Headers, และ Cookie Consent |
| **Chrome DevTools** | `troubleshooting` | แก้ปัญหาการเชื่อมต่อและการเริ่มทำงานของ DevTools Browser Server |
| **Automation** | `run-workflow` | รัน Autonomous Workflows และ Tasks ที่มีความซับซ้อน |
| **Automation** | `migrate-workflows` | แปลง Legacy Workflows เป็น Modern Skills อัตโนมัติ |
| **Cloud & Tools** | `github` | ทำงานกับ GitHub ผ่าน GitHub CLI (PR, Issues, CI Actions, Repos) |
| **Google Apps** | `gdrive` | ค้นหา จัดการ ดาวน์โหลด และอัปโหลดไฟล์ใน Google Drive |
| **Google Apps** | `gsheets` | อ่าน เขียน จัดรูปแบบ และคำนวณข้อมูลใน Google Sheets |
| **Google Apps** | `gcalendar` | จัดการนัดหมายและตารางเวลาใน Google Calendar |
| **Google Apps** | `gdocs` | อ่าน เขียน และจัดรูปแบบเอกสาร Google Docs |
| **Google Apps** | `gslides` | สร้างและตกแต่งสไลด์นำเสนอ Google Slides |
| **Management** | `sync-agent-skills` | ซิงค์ Skills อัตโนมัติระหว่างเครื่องกับ GitHub Repository นี้ |
| **Template** | `example-custom-skill` | แม่แบบและตัวอย่างโครงสร้างสำหรับการสร้าง Custom Skill ใหม่ |

---

## 🛠️ โครงสร้างของ Repository

```text
my-agent-skills/
├── README.md               # เอกสารแนะนำและคู่มือการใช้งาน
├── install.sh              # สคริปต์ติดตั้งอัตโนมัติ (รองรับ Global และ Workspace)
├── sync.sh                 # สคริปต์ช่วยซิงค์ ดึง หรือส่ง Skills ขึ้น GitHub
└── skills/                 # โฟลเดอร์เก็บ Skills ทั้งหมด (19 skills)
    ├── chrome-devtools/
    ├── debug-optimize-lcp/
    ├── generative_ui/
    ├── web-app-development/
    ├── sync-agent-skills/
    ├── example-custom-skill/
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
