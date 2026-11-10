---
name: skill-manager
description: "Manage, switch presets, and control the AI Skill Library directly from chat. Toggle presets like web-fullstack, mobile-app, or minimal to save context window tokens."
---

# Skill Manager Skill

Interface directly with `skill_manager.py` from the chat to toggle active presets, audit duplicates, search cataloged skills, and manage token consumption.

## When to Use This Skill
- Slash command: `/skill-manager`
- User requests: "สลับโหมดเป็น Web Full-Stack", "ประหยัด token หน่อย", "เปิด preset mobile", "Search skill in catalog", "Audit skills"

## Available Presets
- `web-fullstack`: Next.js, React, APIs, UI/UX, Testing, Chrome DevTools (reduces unrelated tokens by ~65%).
- `mobile-app`: Flutter, Android, Dart, Jetpack Compose, Firebase.
- `data-cloud`: Google Cloud, BigQuery, Bigtable, dbt, Dataform, Storage.
- `ai-engineer`: Gemini APIs, Vercel AI SDK, Agent Frameworks, Antigravity SDK.
- `design-creative`: Figma, UI/UX Pro, Shaders, Banner design.
- `pstack-rigor`: Production rigor playbooks, Arena, Swarm, TDD, Deslop.
- `minimal`: Extreme token savings (enables only core protected skills).
- `full`: Enables all skills.

## Instructions for the Agent
1. **Apply Preset**: When user asks to change preset, run:
   `python3 skill_manager.py preset apply <preset_name>`
2. **List Presets**:
   `python3 skill_manager.py preset list`
3. **Search Catalog**:
   `python3 skill_manager.py search "<keyword>"`
4. Report the resulting status and token savings clearly to the user.
