---
trigger: glob
globs: "**/*.{tsx,jsx,ts,js,mjs,cjs,css,scss,html},**/next.config.*,**/vite.config.*,**/vercel.json,**/netlify.toml"
description: Web and Fullstack development rules for React, Next.js, Vite, Tailwind, Vercel, Netlify, and UI/UX design.
---

# Web & Fullstack Development Rules

When creating, modifying, or reviewing web frontend and fullstack files:

1. **UI/UX Quality & Anti-Slop Design**:
   - Before building or restyling UI components, landing pages, or dashboards, consult `~/.gemini/config/skills/ui-taste/SKILL.md` and `~/.gemini/config/skills/website-design/SKILL.md`.
   - When recreating a UI from a screenshot or Figma mockup, follow `~/.gemini/config/skills/image-to-ui/SKILL.md`.
   - Enforce mobile-first responsive breakpoints, semantic HTML, keyboard accessibility, and cohesive typography/color tokens.

2. **React, Next.js & TypeScript Performance**:
   - Apply `~/.gemini/config/skills/typescript-best-practices/SKILL.md` for strict type safety (avoid `any`, model states as discriminated unions, parse external payloads at boundaries).
   - For React and Next.js pages, data fetching, caching, and bundle optimization, follow `~/.gemini/config/plugins/vercel-plugin/skills/react-best-practices/SKILL.md` and consult the `performance-optimizer` subagent when investigating slow routes or Core Web Vitals.

3. **Platform & AI Integrations (Vercel / Netlify)**:
   - **AI Features & Agents**: When integrating LLMs, AI SDK, streaming, or MCP servers, consult the `ai-architect` subagent.
   - **Deployments & Config**: When editing `vercel.json`, `netlify.toml`, CI/CD workflows, or environment variables, consult `deployment-expert` or the relevant platform skill (`vercel-cli`, `vercel-functions`, `netlify-config`, `netlify-deploy`).

4. **End-to-End Browser Verification**:
   - After modifying visible UI or interactive flows, verify the rendered page and console/network state using the `browser` subagent (or `~/.gemini/config/plugins/chrome-devtools-plugin/skills/chrome-devtools/SKILL.md` when debugging performance/lcp/cookies).
