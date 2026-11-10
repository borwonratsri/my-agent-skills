---
name: ui-taste
description: "Give your coding agent better UI taste. Combines Uizze's Anti-UI-Slop playbooks, design tokens, visual hierarchy, responsive layouts, and UI finish gates into one unified master design skill."
---

# UI Taste: Professional UI/UX & Anti-UI-Slop Master Skill

Give coding agents refined design sensibility, crisp visual hierarchy, intentional typography, and production-grade polish instead of generic, robotic "AI-slop" interfaces.

## When to Use This Skill
- Slash command: `/ui-taste`
- User requests: "Make this UI look better", "ยกระดับ UI ให้ดูเป็นมืออาชีพ", "Polish frontend styling", "Prevent AI UI slop", "Redesign this interface", "Run UI review"
- Whenever building web pages, mobile apps, landing pages, dashboards, or interface components.

---

## 🛑 The Core Anti-UI-Slop Rules

1. **Stop Making Every Element Equal Weight**:
   - Never give every card, border, and badge identical visual prominence.
   - Establish exactly **1 primary focal point** per viewport (e.g. Hero value, Main CTA button, Primary Data Chart).
   - Balance large text with lighter weight and tighter tracking: `text-3xl md:text-4xl font-bold tracking-tight text-neutral-900 dark:text-neutral-50`.

2. **Refined Color Systems (Kill Raw Primary Gradients)**:
   - Use high-quality neutral scales (`slate`, `zinc`, or `stone`) for 90% of surfaces and backgrounds.
   - Restrict accent brand colors to interactive elements: Primary buttons, active tabs, focus rings.
   - **Dark Mode with Real Depth**: Never use flat pure black `#000000` for all cards. Use layered surfaces (`bg-neutral-900`, `bg-neutral-800/60`, subtle borders `border-neutral-800`).

3. **Consistent Spacing & Border Radius Rhythm**:
   - Follow strict 4px/8px scale (`p-4`, `p-6`, `p-8`, `gap-4`, `gap-6`).
   - Match radii across the page: If cards use `rounded-2xl`, inputs and buttons should use harmonious `rounded-xl`.

4. **100% State Coverage (The Finish Gate)**:
   - Every interactive component must handle: Default, Hover, Active/Focus-visible, Disabled.
   - Every data container must handle: Loading (skeletons), Empty state with illustration/helpful CTA, and Error state.
   - Micro-interactions: `transition-all duration-150 ease-in-out` on buttons, cards, and links.

5. **Typography & Readability**:
   - Clean, modern typefaces: Inter, Plus Jakarta Sans, Geist, or Prompt (for Thai).
   - Maintain readable line lengths (max 65–75 characters for prose).

---

## 🛠️ Instructions for the Agent

1. **Audit Existing Tokens**: Inspect Tailwind config or CSS variables before writing styles to ensure brand continuity.
2. **Design from Real User Needs**: Favor clean, purpose-driven layouts over flashy, empty decorations.
3. **Execute Clean Markup**: Write semantic HTML (`<main>`, `<nav>`, `<article>`, `<button>`) with accessible ARIA labels.
4. **Self-Review**: Run the finish gate checklist before presenting UI to the user.
