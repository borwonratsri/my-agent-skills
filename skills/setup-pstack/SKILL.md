---
name: setup-pstack
description: Configure model assignments and reasoning budgets for the pstack production engineering rigor suite. Supports both Cursor (MDC rules) and Antigravity/Gemini (subagent tiers pro/flash/inherit). Use for /setup-pstack, "configure pstack", "pstack budget", or setting up production-grade engineering workflows.
---

# Setup pstack (Production Engineering Rigor)

Configure model allocations and reasoning budgets for the **pstack** production engineering framework created by Lauren Tan (@poteto).

pstack enforces extreme engineering rigor across four core pillars:
1. **Architectural Exploration** (`architect`, `how`, `why`): Design twice, explore epistemic truth before coding.
2. **Multi-Agent Competition** (`arena`, `swarm`): Multi-arm races and independent cross-judging.
3. **Verification & Proofs** (`create-verification-skill`, `create-formal-verification-skill`, `statechart`): Model-checked proofs and behavioral verifications.
4. **Deslop & Quality Gates** (`unslop`, `no-comments`, `blast-radius`, `benchmark-checklist`, 24 Principles).

---

## Steps

### 1. Detect Environment & Available Models

Detect the host IDE/agent platform:
- **Antigravity / Gemini Code Assist**: Uses subagent tiers (`pro`, `flash`, `inherit`).
- **Cursor IDE**: Uses model slugs with reasoning effort levels (e.g. `claude-opus-5-5-xhigh`, `grok-4.7-xhigh-fast`).
- **Claude Code / Generic Agent**: Uses model flags or system guidelines.

### 2. Choose Reasoning Budget

Prompt the user to select their desired reasoning budget:

| Budget Level | Target Effort | Description | Recommended Usage |
|---|---|---|---|
| `unlimited` | `max` | Maximum depth and full reasoning steps | Critical infrastructure, mission-critical security |
| `large` *(Default)* | `xhigh` | Heavy reasoning, deep verification | Production architectures, complex refactoring |
| `medium` | `high` | Balanced speed, intelligence, and token cost | Standard feature work, daily development |
| `small` | `medium` | Fast turnaround, lower token consumption | Quick fixes, documentation, prototypes |

### 3. Role-to-Model Mapping

#### Universal Model Mapping Matrix

| pstack Role | Antigravity Tier (Standard / Pro Available) | Antigravity Tier (When Pro Unavailable / Recommended) | Cursor Slug (Large Budget) | Description |
|---|---|---|---|---|
| `judgment and prose` | `pro` | **`inherit`** *(Parent Model)* | `claude-opus-5-5-xhigh` | Deep evaluations, architecture synthesis |
| `hardest tasks` | `pro` | **`inherit`** *(Parent Model)* | `claude-opus-5-5-xhigh` | Complex algorithms, state machines |
| `architect runners` | `pro` (multi-arm) | **`inherit`** *(Parent Model)* | `claude-opus-5-5-xhigh`, `grok-4.7-xhigh-fast` | Independent solution architects |
| `arena cross-judge pool`| `pro` (independent) | **`inherit`** *(Parent Model)* | `claude-opus-5-5-xhigh` | Neutral judge scoring competing arms |
| `how explainer` | `pro` | **`inherit`** *(Parent Model)* | `claude-opus-5-5-xhigh` | High-level architectural explanations |
| `why synthesizer` | `pro` | **`inherit`** *(Parent Model)* | `claude-opus-5-5-xhigh` | Deep epistemic investigation synthesis |
| `feature, refactoring` | `flash` | `flash` (or `inherit`) | `grok-4.7-xhigh-fast` | High-speed coding and implementation |
| `bug-fix`, `perf-issue` | `flash` | `flash` (or `inherit`) | `grok-4.7-xhigh-fast` | Targeted defect resolution |
| `swarm workers` | `flash` (fan-out) | `flash` (fan-out) | `grok-4.7-xhigh-fast` | Parallelized worker subagents |
| `how explorer` | `flash` | `flash` | `grok-4.7-xhigh-fast` | Codebase traversal and mapping |
| `why investigators` | `flash` | `flash` | `grok-4.7-xhigh-fast` | Telemetry & archaeology gathering |
| `reflect tooling` | `flash` | `flash` | `grok-4.7-xhigh-fast` | Linting, test execution, tooling |

> [!TIP]
> **กรณีที่ Antigravity ไม่มีโมเดล `pro` หรือติดข้อจำกัด Quota:**
> - ให้ใช้ค่า **`inherit`** แทน `pro` สำหรับบทบาทการคิดวิเคราะห์ทั้งหมด (Judgment, Architect, Cross-Judge, Synthesizer)
> - เมื่อกำหนดเป็น `inherit` ตัว Subagent จะดึงโมเดลหลักในห้องแชต (เช่น Claude 3.7 Sonnet หรือโมเดลตัวท็อปที่คุณเลือกไว้ในหน้าแชต) มาทำงานแทนทันที ทำให้ได้ความสามารถระดับสูงสุดโดยไม่ต้องพึ่งพา `pro` tier
> - ส่วนงานที่เป็นคนงานย่อย (Swarm Workers, File Searching, Tooling) ยังคงใช้ **`flash`** เพื่อประหยัดเวลาและทำงานแบบขนานได้รวดเร็ว หรือจะเลือกใช้ `inherit` ทั้งหมด (All-Inherit Mode) ก็ได้เช่นกัน

---

### 4. Write Configuration Rule

Write the appropriate configuration file based on the environment:

#### For Cursor: `~/.cursor/rules/pstack-models.mdc`
```yaml
---
description: pstack per-role model choices (overrides skill defaults)
alwaysApply: true
---
# pstack model configuration. One line per role.
# budget: large (xhigh)
feature, refactoring: grok-4.7-xhigh-fast
bug-fix: grok-4.7-xhigh-fast
perf-issue: grok-4.7-xhigh-fast
hillclimb: grok-4.7-xhigh-fast
judgment and prose: claude-opus-5-5-xhigh
hardest tasks: claude-opus-5-5-xhigh
how explorer: grok-4.7-xhigh-fast
how explainer: claude-opus-5-5-xhigh
why investigators: grok-4.7-xhigh-fast
why synthesizer: claude-opus-5-5-xhigh
reflect tooling: grok-4.7-xhigh-fast
reflect judgment, divergent, synthesizer: claude-opus-5-5-xhigh
arena runners: claude-opus-5-5-xhigh, grok-4.7-xhigh-fast
arena cross-judge pool: claude-opus-5-5-xhigh, grok-4.7-xhigh-fast
swarm workers: grok-4.7-xhigh-fast
architect runners: claude-opus-5-5-xhigh, grok-4.7-xhigh-fast
interrogate reviewers: claude-opus-5-5-xhigh, grok-4.7-xhigh-fast
```

#### For Antigravity / Gemini: `.agents/rules/pstack-models.md`
```markdown
# PStack Model Allocation Rule
- Pro Tier (`Model: pro`): Judgment, Hardest Tasks, Architect Runners, Arena Cross-Judge, Why Synthesizer
- Flash Tier (`Model: flash`): Features, Bug Fixes, Swarm Workers, How Explorers, Telemetry Collectors
- Inherit (`Model: inherit`): Fallback to parent agent session model
```

---

### 5. Offer Verification Skills

Inquire if the target codebase requires automated verification:
1. **Behavioral App Verification (`create-verification-skill`)**:
   - Generates project-local Playwright/CLI verification skills to drive the application like a real human.
2. **Formal Model Verification (`create-formal-verification-skill`)**:
   - Generates TLA+ / statechart model checking to mathematically prove invariants hold under all reachable states.

---

### 6. Managing PStack Isolation

To activate or toggle the isolated pstack suite within this library:
```bash
# Apply pstack rigor preset (enables all 60 pstack skills):
python skill_manager.py preset apply pstack-rigor

# Revert to standard lightweight skills:
python skill_manager.py preset apply minimal
```
