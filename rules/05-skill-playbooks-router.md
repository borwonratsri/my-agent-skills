---
trigger: always_on
description: Context pointer routing map for matt-pocock-skills, pstack playbooks, and custom skills across all task phases.
---

# Global Skill & Playbook Routing Map (Best-of-Both Synergy)

Several high-leverage skills in `~/.gemini/config/skills/` have `disable-model-invocation: true` to save context tokens. Use the context pointers below to read the relevant `SKILL.md` file via `read_file` whenever a task enters that branch.

## Phase 1: Clarify, Scope & Plan (`matt-pocock-skills`)

When requirements are ambiguous, domain terms are unsettled, or a feature spans multiple steps/sessions:
- **Interactive Interview (No Repo / Stateless)**: Read `~/.gemini/config/skills/grilling/SKILL.md` (and `grill-me/SKILL.md`) to walk down the decision tree one question at a time.
- **Repo-Backed Interview + Glossary/ADR**: Read `~/.gemini/config/skills/grill-with-docs/SKILL.md` and `~/.gemini/config/skills/domain-modeling/SKILL.md` to sharpen requirements while maintaining `GLOSSARY.md` and `docs/adr/`.
- **Deep Module & Interface Design**: Read `~/.gemini/config/skills/codebase-design/SKILL.md` when designing module boundaries, seams, and testability.
- **Large / Multi-Session Foggy Efforts**: Read `~/.gemini/config/skills/wayfinder/SKILL.md` to chart a decision map before building.
- **Spec & Tracer-Bullet Tickets**:
  - Turn settled decisions into a buildable spec: `~/.gemini/config/skills/to-spec/SKILL.md`
  - Break a spec into ordered, vertical tracer-bullet tickets: `~/.gemini/config/skills/to-tickets/SKILL.md`
  - Configure repo issue tracker (GitHub / GitLab / `.scratch/`): `~/.gemini/config/skills/setup-matt-pocock-skills/SKILL.md`

## Phase 2: Deep Codebase Analysis & Architecture (`pstack`)

When investigating existing behavior, evaluating design alternatives, or assessing change impact:
- **How Code Works & Where New Code Belongs**: Read `~/.gemini/config/skills/how/SKILL.md`
- **Why Code or Metrics Are Shaped This Way (Git Archaeology & Root Rationale)**: Read `~/.gemini/config/skills/why/SKILL.md`
- **Cross-Boundary Type & Module Architecture**: Read `~/.gemini/config/skills/architect/SKILL.md` when changes cross function or module boundaries.
- **Impact & Breakage Analysis Outside the Diff**: Read `~/.gemini/config/skills/blast-radius/SKILL.md`
- **Throwaway Empirical Prototype**: Read `~/.gemini/config/skills/prototype/SKILL.md` when a UI or state question is faster to settle by sketching runnable code.
- **Competing Implementations Bakeoff**: Read `~/.gemini/config/skills/arena/SKILL.md`
- **Bespoke Playbook for Cross-Cutting Migrations**: Read `~/.gemini/config/skills/figure-it-out/SKILL.md`

## Phase 3: Implementation, Debugging & Testing (`matt-pocock` + `pstack` + Custom)

When writing production code, fixing bugs, or refactoring:
- **Test-Driven Vertical Slices**: Read `~/.gemini/config/skills/tdd/SKILL.md`
- **Ticket / Spec Execution**:
  - Single ticket implementation (`tdd` + `code-review`): `~/.gemini/config/skills/implement/SKILL.md`
  - Parallel multi-ticket orchestration: `~/.gemini/config/skills/implement-spec/SKILL.md`
- **Hard Bugs & Performance Regressions**: Read `~/.gemini/config/skills/diagnosing-bugs/SKILL.md` (and `~/.gemini/config/skills/benchmark-checklist/SKILL.md` before reporting performance numbers).
- **Code Quality & Type Discipline**:
  - TypeScript `.ts` / `.tsx` work: `~/.gemini/config/skills/typescript-best-practices/SKILL.md`
  - Clean modular refactoring: `~/.gemini/config/skills/refactoring-clean-code/SKILL.md`
  - Comprehensive test suite generation: `~/.gemini/config/skills/unit-test-generator/SKILL.md`
- **Autonomous Coder -> Tester -> Reviewer Pipeline**: Read `~/.gemini/config/skills/factory-droids/SKILL.md`

## Phase 4: Review, Security Audit, Retro & Memory

Before shipping, opening a PR, or closing out a session:
- **Two-Axis Code Review (Standards + Spec)**: Read `~/.gemini/config/skills/code-review/SKILL.md` and `~/.gemini/config/skills/code-reviewer/SKILL.md`
- **Adversarial Diff Interrogation**: Read `~/.gemini/config/skills/interrogate/SKILL.md`
- **OWASP & Security Vulnerability Audit**: Read `~/.gemini/config/skills/security-auditor/SKILL.md`
- **Pull Request Formatting**: Read `~/.gemini/config/skills/pr/SKILL.md`
- **Post-Task Retrospective & Environment Improvement**: Read `~/.gemini/config/skills/retro/SKILL.md` or `~/.gemini/config/skills/reflect/SKILL.md`
- **Persistent Project Context & Session Handoff**:
  - Save/update `PROJECT_CONTEXT.md` and `.agents/memory/bridge.json`: `~/.gemini/config/skills/project-memory/SKILL.md`
  - Portable session handoff document: `~/.gemini/config/skills/handoff/SKILL.md`
  - Manage active skill presets to optimize tokens: `~/.gemini/config/skills/skill-manager/SKILL.md`
