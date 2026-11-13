# Project Agent Rules (`AGENTS.md`)

> Copy this template to the root of a project as `AGENTS.md` to customize project-specific context on top of the Global Rules in `~/.gemini/config/rules/`.

## 1. Project Overview & Tech Stack
- **Project Name**: `<ชื่อโปรเจกต์>`
- **Primary Stack**: `<เช่น Next.js 15 / TypeScript / Tailwind CSS / Supabase / Vercel>`
- **Memory & Context File**: Read `[PROJECT_CONTEXT.md](./PROJECT_CONTEXT.md)` and `.agents/memory/bridge.json` before starting any task.

## 2. Project-Specific Commands
- **Install**: `npm install`
- **Dev Server**: `npm run dev`
- **Typecheck / Lint**: `npm run lint && npx tsc --noEmit`
- **Test**: `npm test`
- **Build**: `npm run build`

## 3. Agent skills (Matt Pocock & pstack Integration)

### Issue tracker
Issues and specs live as local markdown under `.scratch/<feature>/` by default (or run `/setup-matt-pocock-skills` to bind to GitHub Issues).

### Domain docs
Single-context layout: read `GLOSSARY.md` and `docs/adr/` when present for domain terminology and architectural decisions.

## 4. Project-Specific Subagent & Skill Overrides
- **UI & Frontend**: Follow `ui-taste` and `website-design`; verify UI changes with the `browser` subagent.
- **Database & Auth**: Follow `supabase-postgres-best-practices` (or `firestore-rules-author` for `firestore.rules`).
- **Verification Gate**: Always run typecheck and tests before marking a task complete (`principle-prove-it-works`).
