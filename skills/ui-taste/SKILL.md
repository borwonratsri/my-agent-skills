---
name: ui-taste
description: Give your coding agent better UI taste. Build and polish web and iOS interfaces with Uizze's anti-ui-slop playbooks, design tokens, responsive layouts, and visual hierarchy standards.
---

# UI Taste: Stop AI Coding Agents From Shipping Generic UI

Give coding agents real design sensibility, crisp visual hierarchy, refined typography, and intentional spacing instead of boilerplate, generic "AI-slop" interfaces.

## When to Use This Skill
- Slash command: `/ui-taste`
- User requests: "Make this UI look better", "ยกระดับ UI ให้ดูเป็นมืออาชีพ", "Polish frontend styling", "Prevent AI UI slop"
- Building new web pages, landing pages, dashboards, or mobile components from scratch.

## Anti-UI-Slop Principles

1. **Hierarchy over Uniformity**:
   - Never give every card, border, and button equal visual weight.
   - Establish 1 clear focal point per viewport: Hero metric, Primary CTA, or Main data table.
   - Contrast text size with weight: Big titles should often be tighter and slightly muted (`text-4xl font-bold tracking-tight text-neutral-900 dark:text-neutral-50`).

2. **Intentional Color Palettes**:
   - Avoid default raw primaries (e.g. pure `#0000ff` or bright purple gradients).
   - Use high-quality neutral scales (zinc, slate, or stone) for 90% of surfaces.
   - Use accent colors sparingly: 1 primary brand color for action buttons, links, and active badges.
   - Dark mode must have depth: Never use pure black `#000000` for all cards; use layered elevated surfaces (`bg-neutral-900`, `bg-neutral-800/60`, subtle borders `border-neutral-800`).

3. **Spacious, Consistent Rhythm**:
   - Generous whitespace breathes quality: Use 4px/8px scale (`p-4`, `p-6`, `p-8`, `gap-6`).
   - Align elements rigorously: Labels above inputs, consistent border-radius (`rounded-xl` or `rounded-2xl` matching across all cards and buttons).

4. **Complete State Coverage**:
   - Always implement: Default, Hover, Active/Focus-visible, Loading (skeletons/spinners), Empty state, and Error state.
   - Smooth transitions: `transition-all duration-150 ease-in-out` on interactive controls.

## Instructions for the Agent
1. Inspect existing design tokens and tailwind configuration before writing styles.
2. Replace generic boilerplate styling with clean, modern, product-grade UI patterns.
3. Verify visual hierarchy and responsive mobile/desktop layouts.
