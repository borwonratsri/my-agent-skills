---
name: sync-agent-skills
description: Synchronize skills, rules, USER_MEMORY.md, knowledge/, and hooks with the personal GitHub repositories (my-agent-private and my-agent-skills).
---

# Sync Agent Skills & Private Config

Use this skill to synchronize both layers cleanly across Windows machines:
1. **Private Personal Layer (`borwonratsri/my-agent-private`)** — `rules/`, `USER_MEMORY.md`, `AGENTS.template.md`, `knowledge/`, `qa-docs`, `gem-*`, `recall`, `sync-agent-skills`.
2. **Public Base & Hooks Layer (`borwonratsri/my-agent-skills`)** — curated `skills/`, `pstack/`, `hooks/` + `hooks.json`, `plugins/` (24 plugins, excluding `auth.json`), and base templates.

## Trigger
- User asks to sync skills or private rules: "ซิงค์ skill ให้หน่อย", "ซิงก์กฎขึ้น github", "sync private rules", "sync skills to github", "update from github", "check agent config health"
- User runs slash command: `/sync-agent-skills`

## Auto-Detect Repo Locations (Windows)
Locate each repo in order (first match wins):
- `my-agent-private`: `~/my-agent-private` -> `~/.gemini/antigravity/scratch/my-agent-private`
- `my-agent-skills`: `~/my-agent-skills` -> `~/.gemini/antigravity/scratch/my-agent-skills`

## Instructions for the Agent

### 1. Private Personal Config (`my-agent-private` — Default for Rules, Memory, Knowledge, `qa-docs`, `gem-*`, `recall`)
- **Check diff**: `& "<private-repo>\sync.ps1" status`
- **Health check (`doctor`)**: `& "<private-repo>\sync.ps1" doctor`
- **Push local updates (with path normalization & Secret Guard)**:
  `& "<private-repo>\sync.ps1" push "<commit message>"`
- **Pull / restore onto this or another Windows machine (uses `uv` automatically for `qa-docs`)**:
  `& "<private-repo>\sync.ps1" pull [-SetupVenv]`

### 2. Public Base, Hooks & Plugins (`my-agent-skills` — Only when user explicitly updates public base)
- **Strict Privacy Gate**: Never copy `USER_MEMORY.md`, `knowledge/`, `plugins/**/auth.json`, or confidential files into `my-agent-skills`.
- Use `<public-repo>` (`install.ps1 -All` / `sync.sh` / git) for public skills, `hooks/`, and plugin updates.
