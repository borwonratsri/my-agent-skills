---
name: recall
description: >-
  Reconstruct recent working context from Antigravity chat transcripts, live git
  state, and project memory, then hand back a tight current-state brief. Use for
  'recall my work on X', 'catch me up', 'what have I been working on', or
  'where did I leave off' before starting or resuming work.
disable-model-invocation: true
---

# Recall (Antigravity Cross-Session Context Reconstruction)

**Before you start or resume work, rebuild the user's recent working context and hand back a tight capsule of where things stand now and what to do next.**

Keep it tight and on-topic. Read only what the in-scope threads need, then stop.

## Where Transcripts Live

1. **Antigravity (Primary)**:
   - Compact transcripts: `~/.gemini/antigravity/brain/<conversation-id>/.system_generated/logs/transcript.jsonl`
   - Full untruncated lines (only read matching line numbers when `truncated_fields` is present): `transcript_full.jsonl` in the same folder.
   - Workspace project metadata (optional context): `~/.gemini/config/projects/*.json`
   - Never rely on UUID alphabetical order; always sort conversation folders by `transcript.jsonl` modification time descending (`LastWriteTime` on Windows, `ls -t` / `stat` on Unix).
   - Skip the active conversation ID and subagent logs unless debugging a specific subagent run.
2. **Cursor (Legacy Fallback)**: `~/.cursor/projects/<slug>/agent-transcripts/<uuid>/<uuid>.jsonl` (only if Antigravity logs contain no matches or user explicitly asks for Cursor history).

## Process

1. **Classify & Lock Scope**: Pin the time window (default: last 7 days), topic keyword (if named), and workspace (default: active workspace). State the scope back cleanly. If the user already gave a complete capsule (paths, branch, change), skip transcript mining and verify live state directly.
2. **Locate Candidate Chats**: Scan recent `transcript.jsonl` files within the time window ordered by modification time descending. Grep for the topic/project keywords first rather than reading whole files.
3. **Fan Out When Corpus Is Large**:
   - For 1-2 matching chats, read only the matching `USER_INPUT` and final `PLANNER_RESPONSE` regions directly.
   - For 3+ matching chats, dispatch parallel `research` (or `self`) subagents via `invoke_subagent` (`Model: "flash"` or `"inherit"`), each inspecting a slice and returning per chat: `conversation_id`, user goal, decisions made, open threads, corrections/struggles, and artifacts (files/commits/branches/PRs). Keep raw transcripts inside subagents so the main thread stays clean.
4. **Cross-Check Shared Record & Live State**:
   - Check `PROJECT_CONTEXT.md`, `.agents/memory/bridge.json`, `git status`, `git log -n 10`, open branches, and `gh` PR/issue state (if `gh` CLI is installed) to verify whether planned work actually landed or remains uncommitted/reverted.
   - When the topic names a bug or recurring issue, consult the `why` skill (`~/.gemini/config/skills/why/SKILL.md`) across git history and docs.
5. **Write the Brief to the Output Contract**.

## Output Contract

Lead with the capsule, then thread status, problems, and next move:

- **Capsule**: At most 5 bullets — what this work is and where it stands overall.
- **Threads**: One line each, prefixed with a status tag: `[committed/pushed]`, `[open PR #N]`, `[in flight <branch>]`, `[verified, uncommitted]`, `[reverted]`, or `[planned, not started]`, citing the conversation ID link (`[label](conversation://<id>)`) or commit hash.
- **Problems**: At most 5 recurring blockers, symptoms, or corrections made by the user.
- **Next move**: The single most useful concrete next action.
