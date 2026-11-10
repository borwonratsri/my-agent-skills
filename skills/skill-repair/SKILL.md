---
name: skill-repair
description: Use this to fix and re-install agent skills that have failed installation. This skill provides diagnostics, YAML syntax fixing, permission repair, and cache re-indexing.
---

# Skill Repair & Diagnostics Tool

Diagnose, troubleshoot, repair, and re-install broken or non-functioning agent skills across Global (`~/.gemini/config/skills/`) and Workspace (`.agents/skills/`) scopes.

## Trigger Scenarios
- Slash command: `/skill-repair`
- User requests: "Skill ใช้ไม่ได้", "ซ่อม skill ให้หน่อย", "Fix failed skills", "Repair missing slash command"

## Common Skill Failure Modes & Repair Procedures

1. **YAML Frontmatter Formatting Errors**:
   - Issue: Missing opening/closing `---`, invalid YAML syntax, missing `name:` or `description:`.
   - Repair: Parse and rewrite frontmatter ensuring valid YAML compliance and proper single-line string formatting.

2. **File Permissions & Executable Bits**:
   - Issue: Scripts in `<skill>/scripts/` lack execution permissions (`chmod +x`).
   - Repair: Run `chmod -R u+rwX <skill_dir>` and `chmod +x <skill_dir>/scripts/* 2>/dev/null`.

3. **Directory Layout & File Naming**:
   - Issue: File is named something other than `SKILL.md` (e.g. `skill.md` or `README.md`), or placed in nested invalid folders.
   - Repair: Move and rename file to exact `<skill-name>/SKILL.md`.

4. **Cache & Agent Discovery Sync**:
   - Issue: Agent hasn't picked up newly added skill.
   - Repair: Re-run `install.sh` or verify path in `~/.gemini/config/skills/<name>/SKILL.md`.

## Instructions for the Agent
1. Scan both `~/.gemini/config/skills/` and `./.agents/skills/`.
2. Inspect every `SKILL.md` for YAML validity and directory structure.
3. Automatically repair syntax, permissions, and paths.
4. Report repaired skills and confirm discovery status.
