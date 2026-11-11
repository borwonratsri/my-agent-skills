# 🧠 PROJECT CONTEXT & PERSISTENT MEMORY
> **Repository**: [borwonratsri/my-agent-skills](https://github.com/borwonratsri/my-agent-skills)  
> **Last Updated**: 2026-11-11  
> **Status**: Active & Production-Ready  
> **Branch**: `main` (Synced with GitHub)

---

## 1. Project Overview (ภาพรวมโครงการ)

**my-agent-skills** เป็นคลังทักษะ AI แบบพกพา (Universal AI Skills & Factory Droids Library) ที่รวมระบบวิศวกรรมระดับโลกไว้ในที่เดียว ออกแบบมาเพื่อทำงานร่วมกับ **Google Deepmind Antigravity**, **Gemini Code Assist**, **Cursor IDE**, และ **Claude Code**:

1. **Factory AI Architecture**: ระบบ Dark Factory แบบ 3 เอเจนต์ย่อยอิสระ (Coder ➔ Tester ➔ Reviewer) พร้อม Tool Gating ป้องกัน Bias
2. **Context Window Token Presets**: ระบบจัดการ Token ด้วย `skill_manager.py` สลับกลุ่มทักษะตามสายงาน (Web, Mobile, Data, PStack, Minimal) ประหยัด Token สูงถึง 65%
3. **Curated 58 Standard Skills**: รวมสุดยอดทักษะด้าน Software Engineering, UI/UX, Spec & Implementation, TDD, และ DevOps
4. **PStack Production Rigor Subsystem (Isolated 60 Skills)**: ระบบความถูกต้องระดับ Principal Engineer ของ Lauren Tan (@poteto) แยกเก็บใน `pstack/` ไม่ให้ปะปนกับทักษะทั่วไป
5. **Cross-Platform Native Installers**: ตัวติดตั้งคำสั่งเดียวทั้ง Windows PowerShell (`install.ps1` พร้อม Smart Update) และ Linux/macOS/WSL (`install.sh`)

---

## 2. Tech Stack & Toolchain (เทคโนโลยีและเครื่องมือ)

- **Languages & Runtimes**:
  - Python 3.10+ (CLI Engine: `skill_manager.py`, Scanner, Catalog Builder, Presets)
  - PowerShell 5.1 / 7+ (Windows Native Installer: `install.ps1`)
  - Bash (Linux/macOS Installer: `install.sh`, Sync script: `sync.sh`)
  - TypeScript, Node.js 24 LTS, Bun (PStack Scripts, Statechart TLA+ Checker, Watch-PR)
- **AI Agent Frameworks**:
  - Antigravity / Gemini Code Assist (`pro`, `flash`, `inherit` tiers)
  - Cursor IDE (`.cursor/rules/pstack-models.mdc`)
  - Model Context Protocol (MCP) Servers: `chrome-devtools`, `postgres`, `sqlite`
- **VCS & Delivery**:
  - Git & GitHub CLI (`gh`)
  - GitHub Remote: `https://github.com/borwonratsri/my-agent-skills.git`

---

## 3. Architecture & Directory Map (แผนผังโครงสร้างระบบ)

```
my-agent-skills/
├── skills/                     # 🌟 Curated Standard Skills (58 รายการ สำหรับงานทั่วไป)
│   ├── setup-pstack/           # Universal Entrypoint Skill (/setup-pstack)
│   ├── factory-droids/         # Dark Factory Pipeline (/factory-droids)
│   ├── skill-manager/          # Presets & Token Selector (/skill-manager)
│   ├── grill-me/               # Deep requirements interview protocol
│   ├── tdd/                    # Test-Driven Development workflow
│   ├── code-reviewer/          # Deep multi-dimensional code auditor
│   ├── database-architect/     # DB Schema & migration planner
│   ├── api-architect/          # RESTful / GraphQL API designer
│   ├── ui-taste/               # Unified Anti-UI-Slop & design system
│   ├── project-memory/         # Persistent memory & PROJECT_CONTEXT.md generator
│   └── ...
│
├── pstack/                     # 🛡️ PStack Isolated Ecosystem (60 Skills เฉพาะทาง)
│   ├── setup-pstack/           # Model budgeting & rule generator
│   ├── poteto-mode/            # Full production orchestrator (23 playbooks)
│   ├── architect/              # Design twice system (Proposal A vs Proposal B)
│   ├── arena/                  # Multi-agent racing & neutral cross-judging
│   ├── swarm/                  # Parallel worker fan-out
│   ├── interrogate/            # Adversarial code reviewer (Red Teaming)
│   ├── statechart/             # TLA+ model checker & statechart compiler
│   ├── create-verification-skill/        # Real-app behavioral test driver
│   ├── create-formal-verification-skill/ # TLA+ formal invariant verifier
│   ├── unslop/                 # AI Slop remover
│   └── principle-*/            # คลัง 24 Fundamental Engineering Principles
│
├── core/                       # Python Backend Engine
│   ├── auditor.py              # Skill auditing & duplicate checker
│   ├── catalog_builder.py      # Markdown & JSON catalog generator
│   ├── droid_manager.py        # Factory Droids definitions
│   ├── preset_manager.py       # Preset switcher & filter logic
│   ├── recommender.py          # Skill recommender by task
│   └── scanner.py              # Multi-root file scanner
│
├── config/                     # System & Presets Configuration
│   ├── config.json             # Scan roots and catalog output paths
│   └── presets.json            # 7 Presets definitions (inc. pstack-rigor)
│
├── install.ps1                 # 🪟 Windows PowerShell 1-Liner Installer (Smart Update)
├── install.sh                  # 🐧 Linux/macOS/Git Bash Installer (--pstack support)
├── sync.sh                     # Sync script between local and GitHub
├── skill_manager.py            # Central CLI entrypoint
├── PSTACK_WORKFLOW.md          # 📖 Comprehensive PStack Workflow Guide
├── CATALOG.md & catalog.json   # Generated Skill Catalog (116 Skills)
├── PROJECT_CONTEXT.md          # 🧠 File นี้ (Persistent Memory)
└── README.md                   # Complete Documentation & Usage Guides
```

---

## 4. Key Conventions & Engineering Rules (กฎและแบบแผนปฏิบัติ)

1. **Strict PStack Isolation**:
   - ห้ามนำสกิลใน `pstack/` มารวมปนใน `skills/` โดยตรง เพื่อไม่ให้ Context Window บวมในเซสชันปกติ
   - ใช้งาน PStack ผ่าน `/setup-pstack` หรือสลับโหมดผ่าน `python skill_manager.py preset apply pstack-rigor`
2. **Model Fallback Discipline (When Pro Unavailable)**:
   - ใน Antigravity หากไม่มีโมเดล `pro` ให้แมปบทบาท High-Reasoning (Judgment, Architect, Cross-Judge, Synthesizer) ไปใช้ **`inherit`** เพื่อดึงโมเดลหลักในห้องแชต (เช่น Claude 3.7 Sonnet) มาใช้แทน
   - บทบาทคนงานย่อย (Swarm Workers, Tooling, Explorers) ให้ใช้ **`flash`** เพื่อสปีดสูงสุด
3. **Smart Update Protocol**:
   - ตัวติดตั้ง `install.ps1` จะอัปเดตทับเฉพาะสกิลที่ชื่อซ้ำกันให้เป็นเวอร์ชันล่าสุดจาก GitHub
   - **ห้ามลบ** Custom Skills ที่ผู้ใช้สร้างไว้เองในเครื่องเด็ดขาด

---

## 5. Current Status & Milestones (สถานะและสิ่งที่สำเร็จแล้ว)

| Milestone | สถานะ | รายละเอียด |
|---|:---:|---|
| **Curated 57 Skills** | ✅ เสร็จสมบูรณ์ | รวบรวม ปรับจูน ล้าง Slop และจัดหมวดหมู่ชัดเจน |
| **Factory AI Droids** | ✅ เสร็จสมบูรณ์ | เพิ่ม `factory-droids`, `coder-droid`, `tester-droid`, `reviewer-droid` |
| **Presets Manager** | ✅ เสร็จสมบูรณ์ | CLI `skill_manager.py` สลับ 7 Presets คัดกรอง Token |
| **PStack Rigor Integration** | ✅ เสร็จสมบูรณ์ | คัดลอก 60 ทักษะ (Bit-for-bit exact copy) ไว้ใน `pstack/` |
| **Universal Setup-PStack** | ✅ เสร็จสมบูรณ์ | สร้าง `skills/setup-pstack/SKILL.md` และ `PSTACK_WORKFLOW.md` |
| **Inherit Model Fallback** | ✅ เสร็จสมบูรณ์ | ปรับตารางแมปปิ้งรองรับกรณีไม่มี `pro` ใน Antigravity |
| **Native Windows Installer** | ✅ เสร็จสมบูรณ์ | สร้าง `install.ps1` รองรับ `-All` และ Smart Update |
| **Cloud Registry Activation** | ✅ เสร็จสมบูรณ์ | ลงทะเบียนทักษะทั้งหมดใน Antigravity Active Skill Registry |
| **Project Memory System** | ✅ เสร็จสมบูรณ์ | สร้าง `PROJECT_CONTEXT.md` และ `.agents/memory/bridge.json` |

---

## 6. Next Actions & Backlog (งานที่ต้องทำต่อในเซสชันหน้า)

- [ ] **Local Windows Installation**:
  - ผู้ใช้รันคำสั่ง `& ([scriptblock]::Create((irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1))) -All` ในเครื่องคอมพิวเตอร์ส่วนตัว
- [ ] **First Rigor Run**:
  - ทดสอบรัน `/setup-pstack` และลองใช้ `/architect` หรือ `/arena` ในการพัฒนาฟีเจอร์ใหม่
- [ ] **Custom Project Verifications**:
  - พิจารณาใช้ `/create-verification-skill` สำหรับโปรเจกต์งานจริงเพื่อสร้าง automated browser test driver
