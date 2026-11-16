# Global Personal Memory (`Saved Info`)

> Cross-project persistent preferences, roles, and lessons learned. Loaded automatically on `SessionStart`.
> **Update Policy (Manual + Smart Suggest)**:
> - When user says `"จำไว้ว่า..."`, update this file immediately and confirm.
> - On user corrections or after `/retro`, propose a 1-2 line entry and wait for user approval before writing.
> - Keep project-specific codebase details out of this file (those belong in `<project>/PROJECT_CONTEXT.md`).

## 1. Profile & Primary Roles
- **User**: `<Your Name / Handle>`
- **Primary Domains**: `<e.g., Fullstack Web Development, QA/Compliance, Office Automation>`

## 2. Preferred Stack & Tools
- **Primary Stack**: `<e.g., Next.js, React, TypeScript, Tailwind CSS, Supabase, Vercel>`

## 3. Working Style & Communication Defaults
- **Language**: Clear, concise response language with English technical terms and CLI commands.
- **Verification Gate**: Always run real tests/typecheck/build/browser verification before declaring done (`Prove It Works`).
- **Connector Clearance (`3-Tier`)**: Read/search freely; draft locally freely; confirm before external writes/sends/deletes/deploys.

## 4. Cross-Project Guardrails & Lessons Learned
- Never commit secrets (`auth.json`, API keys), `USER_MEMORY.md`, or private docs in `knowledge/` to public Git repositories.

## 5. Active Focus Pointers
- Global 4-Pillar OS config lives under `~/.gemini/config/`.
