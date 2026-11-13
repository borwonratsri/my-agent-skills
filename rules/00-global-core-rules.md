---
trigger: always_on
description: Global pre-work checklist, engineering rigor principles, smart subagent delegation, runtime adapter, and communication standards.
---

# Global Core Workflow & Engineering Rules

You must follow this workflow at the start of and throughout every task across all workspaces.

## 1. Step 0: Pre-Work Context & Project Memory Check

Before modifying code or making architectural decisions in an active workspace:
1. **Check Project Memory & Rules**: Inspect the workspace root for `PROJECT_CONTEXT.md`, `.agents/memory/bridge.json`, and `AGENTS.md` (plus `GLOSSARY.md` and `docs/adr/` when present). Read any existing files first to align with project state, conventions, and pending backlog.
2. **Progressive Bootstrap**:
   - If working in a code repository that does not yet have `PROJECT_CONTEXT.md`, perform a quick structural scan (`package.json`, `pyproject.toml`, `pubspec.yaml`, directory layout) and offer to initialize or update `PROJECT_CONTEXT.md` (via `~/.gemini/config/skills/project-memory/SKILL.md`) upon completing a major milestone.
   - Only create `GLOSSARY.md`, `docs/adr/`, or `.scratch/` when starting a large feature or when running `grill-with-docs`, `domain-modeling`, `to-spec`, or `wayfinder`.

## 2. Core Engineering Rigor (`pstack` Principles)

Apply these core engineering principles on every coding and debugging task:
- **Prove It Works (`principle-prove-it-works`)**: Never declare a task complete based on assumptions or "it compiles" alone. Verify against the real artifact (run tests, typecheck, build, CLI output, or inspect the rendered UI via the `browser` subagent).
- **Fix Root Causes (`principle-fix-root-causes`)**: When debugging, establish a tight feedback loop (a reproducible failing test or command) and trace the issue to its first point of failure before writing a fix.
- **Laziness & Subtract First (`principle-laziness-protocol` / `principle-subtract-before-you-add`)**: Prefer the smallest, cleanest change that solves the root problem. Remove dead code and unnecessary wrappers before adding new abstractions.
- **Model the Domain & Boundary Discipline (`principle-model-the-domain` / `principle-boundary-discipline`)**: Define data shapes, types, and state transitions before writing business logic. Validate and parse external inputs at system boundaries; keep internal logic pure and strongly typed.
- **Guard the Context Window (`principle-guard-the-context-window`)**: Offload broad multi-file exploration, log analysis, and bulk research to subagents (`research` or `self`) so the main conversation context stays sharp.

## 3. Smart Subagent Delegation Matrix

Choose between direct execution and subagent delegation based on task scope and risk:
- **Small / Single-File Tasks**: Execute directly in the main agent for speed.
- **Broad Codebase Exploration (3+ areas or unknown architecture)**: Delegate to `research` via `invoke_subagent`.
- **Live Web App Inspection, UI Verification & E2E Flows**: Delegate to `browser` via `invoke_subagent` (use `Model: "flash"` by default unless requested otherwise).
- **Image Generation / Editing**: Delegate to `image-generator`.
- **Domain-Specific Implementation**:
  - **Cloud Firestore Rules (`firestore.rules`)**: MANDATORY delegation to `firestore-rules-author`.
  - **Vercel AI SDK / Agent Architecture / MCP**: Consult or delegate to `ai-architect`.
  - **Web Performance / Core Web Vitals / Bundle Size**: Consult or delegate to `performance-optimizer`.
  - **Vercel Deployment / CI/CD / Domains / Env Vars**: Consult or delegate to `deployment-expert`.
  - **Flutter Accessibility (a11y / WCAG)**: Delegate audits to `flutter_a11y_agent`.
- **High-Complexity Architecture & Multi-Angle Review**:
  - Use `egm-design` (scalability & risk), `egm-zoom-out` (simplicity & YAGNI), `egm-implementation-readiness` (actionable plan check), and `egm-synthesizer` for major system designs.
  - For autonomous multi-stage feature implementation with strict tool gating (Coder -> Tester -> Reviewer), read and follow `~/.gemini/config/skills/factory-droids/SKILL.md`.

## 4. Antigravity Runtime Adapter (for `pstack` & `matt-pocock-skills`)

Many skills in `~/.gemini/config/skills/` reference Cursor or Claude Code primitives. Translate them seamlessly to Antigravity native tools:
- **Subagent Dispatch**: Where a skill references `Task` or `subagent_type: "poteto-agent"`, use Antigravity's `invoke_subagent` (with `TypeName: "self"`, `"research"`, or a specialist subagent) or `swarm` for multi-worker parallel fan-out.
- **Model Selection**: Ignore hardcoded external model slugs (e.g., `grok-*`, `claude-*`) unless supported; use `Model: "inherit"` by default (or `"flash"` for `browser`), unless the user explicitly specifies another model.
- **User Questions**: Where a skill references `AskQuestion`, use Antigravity's `ask_question` tool.
- **Global Rules Path**: Where a skill references `~/.cursor/rules/`, use `~/.gemini/config/rules/`.

## 5. Safety, Verification & Communication Standards

- **Data Loss Prevention**: Strictly follow `~/.gemini/config/skills/accidental-data-loss-prevention/SKILL.md`. NEVER execute destructive operations (`DROP`, `TRUNCATE`, `DELETE` without `WHERE`, deleting production storage/resources, or overwriting critical data) without explicit prior user confirmation.
- **Language & Tone**: Communicate in **clear, concise Thai (ภาษาไทย)** while keeping technical terms, code identifiers, file paths, and CLI commands in **English**. Keep helpful, high-signal comments in code that explain *why*.
- **Clickable File Links**: Always format file references as clickable GitHub-style markdown links using `file:///` with forward slashes (e.g., `[filename.ts](file:///C:/path/to/filename.ts)`).
- **Executive Summary on Completion**: When finishing a significant feature, fix, or report, provide a structured summary covering:
  1. **What Was Accomplished (สิ่งที่ดำเนินการเสร็จสิ้น)** with clickable file links
  2. **Verification Results (ผลการตรวจสอบและทดสอบ)**
  3. **Next Actions / Recommendations (ขั้นตอนถัดไปที่แนะนำ)**
