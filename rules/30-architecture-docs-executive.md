---
trigger: model_decision
description: Apply when designing large-scale system architecture, writing technical specifications/ADRs/READMEs, creating PowerPoint presentations (.pptx), or generating executive summaries.
---

# System Architecture, Technical Documentation & Executive Reporting Rules

When planning complex systems, authoring documentation, building presentations, or writing executive summaries:

1. **Multi-Perspective Architecture & Plan Review (EGM Swarm)**:
   - For major system architecture proposals, greenfield designs, or high-risk implementation plans, invoke the appropriate EGM specialist subagents:
     - `egm-design`: Audit system scalability, failure modes, infrastructure economics, and unmitigated risks.
     - `egm-zoom-out`: Challenge unnecessary complexity (YAGNI) and identify codebase reuse opportunities.
     - `egm-implementation-readiness`: Verify that implementation plans are concrete and unambiguous.
     - `egm-codebase-details` / `egm-comprehension` / `egm-structural` / `egm-style`: Use when auditing comprehensive technical documentation or bootstrapping repository READMEs via `egm-bootstrap-orchestrator` and `egm-synthesizer`.

2. **Technical Writing & Agent Documentation**:
   - For ADRs, runbooks, API docs, and READMEs, read `~/.gemini/config/skills/technical-writer/SKILL.md` or `~/.gemini/config/skills/technical-writing/SKILL.md`.
   - When creating or editing `AGENTS.md`, `SKILL.md`, or agent rules, follow `~/.gemini/config/skills/writing-for-agents/SKILL.md`.

3. **PowerPoint Presentations (`.pptx` / `.potx`)**:
   - Whenever creating, reading, or updating slide decks or `.pptx` files, read both `~/.gemini/config/skills/pptx/SKILL.md` and `~/.gemini/config/skills/elite-powerpoint-designer/SKILL.md`.

4. **Executive Formal Summaries**:
   - When summarizing long documents, meeting notes, or project reports for management, follow `~/.gemini/config/skills/summary-text/SKILL.md` (structured with Key Highlights, Core Substance, and Action Items).
