---
name: sync-agent-skills
description: Synchronize skills with the personal GitHub repository (push local changes or pull updates).
---

# Sync Agent Skills

Use this skill to push newly created or modified skills to GitHub (`borwonratsri/my-agent-skills`), or pull updates from GitHub into the current environment.

## Trigger
- User asks to sync skills: "ซิงค์ skill ให้หน่อย", "sync skills to github", "update skills from github"
- User runs slash command: `/sync-agent-skills`

## Instructions for the Agent

### 1. Identify Action
- **Push**: Export newly created custom skills from `~/.gemini/config/skills/` or `<workspace>/.agents/skills/` to the repo, commit, and push.
- **Pull / Install**: Update installed skills from the latest GitHub repository commits.

### 2. Execution Steps
- To pull updates: Run `curl -sSL https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.sh | bash`
- To push updates:
  1. Clone or check the repo at `/home/antigravity/my-agent-skills`
  2. Copy modified/new skill folders into `skills/`
  3. Git add, commit, and push to main branch
  4. Confirm the list of updated skills to the user
