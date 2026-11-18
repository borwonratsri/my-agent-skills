import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { getConfigDir } from "./lib.mjs";

export const CONTEXT_THRESHOLD_TOKENS = 450_000;
export const CONTEXT_STEP_TOKENS = 50_000;
const STATE_MAX_ENTRIES = 50;
const STATE_TTL_MS = 7 * 24 * 60 * 60 * 1000;

export function getDefaultStatePath() {
  return (
    process.env.AGY_CONTEXT_MEMORY_STATE_PATH ||
    path.join(os.tmpdir(), "agy-context-memory-state.json")
  );
}

function toFiniteNumber(value) {
  const num = Number(value);
  return Number.isFinite(num) && num >= 0 ? num : 0;
}

/**
 * Parse a JSONL transcript file into an array of step objects.
 */
export function readTranscriptSteps(transcriptPath) {
  if (!transcriptPath || !fs.existsSync(transcriptPath)) return [];
  let raw;
  try {
    raw = fs.readFileSync(transcriptPath, "utf8");
  } catch {
    return [];
  }

  const steps = [];
  for (const line of raw.split(/\r?\n/)) {
    if (!line) continue;
    try {
      steps.push(JSON.parse(line));
    } catch {
      // Ignore malformed lines.
    }
  }
  return steps;
}

/**
 * Find the most recent PLANNER_RESPONSE step carrying token metadata.
 */
export function getLatestPlannerStep(steps) {
  if (!Array.isArray(steps)) return null;

  for (let i = steps.length - 1; i >= 0; i--) {
    const step = steps[i];
    if (step?.type !== "PLANNER_RESPONSE") continue;

    const hasTokenField =
      step.input_tokens !== undefined ||
      step.cache_read_tokens !== undefined ||
      step.output_tokens !== undefined;
    if (!hasTokenField) continue;

    const totalTokens =
      toFiniteNumber(step.input_tokens) +
      toFiniteNumber(step.cache_read_tokens) +
      toFiniteNumber(step.output_tokens);

    if (totalTokens > 0) {
      return { step, index: i };
    }
  }

  return null;
}

/**
 * Extract the latest token usage snapshot from transcript steps.
 * Sums input_tokens + cache_read_tokens + output_tokens from the most recent
 * PLANNER_RESPONSE step that carries token metadata.
 */
export function extractLatestTokenCount(steps) {
  const latest = getLatestPlannerStep(steps);
  if (!latest) return null;

  const { step, index } = latest;
  const inputTokens = toFiniteNumber(step.input_tokens);
  const cacheReadTokens = toFiniteNumber(step.cache_read_tokens);
  const outputTokens = toFiniteNumber(step.output_tokens);

  return {
    totalTokens: inputTokens + cacheReadTokens + outputTokens,
    inputTokens,
    cacheReadTokens,
    outputTokens,
    stepIndex: step.step_index ?? index,
  };
}

function cleanTargetPath(rawPath) {
  if (typeof rawPath !== "string") return "";
  let trimmed = rawPath.trim();
  if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
    try {
      const parsed = JSON.parse(trimmed);
      if (typeof parsed === "string") trimmed = parsed;
    } catch {
      trimmed = trimmed.slice(1, -1);
    }
  }
  return trimmed.replace(/\\/g, "/");
}

/**
 * Detect whether the agent already wrote or updated handoff-latest.md in this turn.
 */
export function didWriteHandoffInTurn(turnSteps) {
  if (!Array.isArray(turnSteps)) return false;

  for (const step of turnSteps) {
    const toolCalls = Array.isArray(step?.tool_calls) ? step.tool_calls : [];
    for (const tc of toolCalls) {
      const name = tc?.name || "";
      if (name !== "write_file" && name !== "edit_file") continue;
      const args = tc?.args || {};
      const target = cleanTargetPath(
        args.Path || args.path || args.TargetFile || ""
      ).toLowerCase();
      if (
        target === "handoff-latest.md" ||
        target.endsWith("/handoff-latest.md")
      ) {
        return true;
      }
    }
  }

  return false;
}

function loadState(stateFilePath) {
  try {
    if (!stateFilePath || !fs.existsSync(stateFilePath)) return {};
    const parsed = JSON.parse(fs.readFileSync(stateFilePath, "utf8"));
    return parsed && typeof parsed === "object" && !Array.isArray(parsed)
      ? parsed
      : {};
  } catch {
    return {};
  }
}

function pruneState(state, nowMs) {
  const entries = Object.entries(state).filter(([, val]) => {
    if (!val || typeof val !== "object") return false;
    const ts = Date.parse(val.updatedAt || "");
    if (!Number.isFinite(ts)) return true;
    return nowMs - ts <= STATE_TTL_MS;
  });

  entries.sort((a, b) => {
    const ta = Date.parse(a[1]?.updatedAt || "") || 0;
    const tb = Date.parse(b[1]?.updatedAt || "") || 0;
    return tb - ta;
  });

  return Object.fromEntries(entries.slice(0, STATE_MAX_ENTRIES));
}

function saveState(stateFilePath, state, nowMs = Date.now()) {
  if (!stateFilePath) return;
  try {
    const dir = path.dirname(stateFilePath);
    fs.mkdirSync(dir, { recursive: true });
    const pruned = pruneState(state, nowMs);
    fs.writeFileSync(stateFilePath, `${JSON.stringify(pruned, null, 2)}\n`, "utf8");
  } catch {
    // Best-effort state persistence; never crash the Stop hook.
  }
}

function hasActiveWorkspace(input) {
  return (
    Array.isArray(input?.workspacePaths) &&
    input.workspacePaths.some((p) => typeof p === "string" && p.trim().length > 0)
  );
}

function buildHandoffReason(totalTokens, hasWorkspace) {
  const formatted = totalTokens.toLocaleString("en-US");
  const skillPath = path
    .join(getConfigDir(), "skills", "project-memory", "SKILL.md")
    .replace(/\\/g, "/");
  const scratchHandoffPath = path
    .join(os.homedir(), ".gemini", "antigravity", "scratch", "handoffs", "handoff-latest.md")
    .replace(/\\/g, "/");

  const locationHint = hasWorkspace
    ? "Archive any existing .agents/memory/handoff-latest.md to .agents/memory/archive/, write the full per-task handoff summary into .agents/memory/handoff-latest.md, update PROJECT_CONTEXT.md and .agents/memory/bridge.json, and ensure .agents/memory/ is in .gitignore if appropriate."
    : `No active workspace is open: archive any existing ${scratchHandoffPath} to .../archive/, save the full per-task handoff summary there, and include a ready-to-copy handoff summary + file link in your response.`;

  return (
    `Context Memory Handoff Gate (${formatted} tokens >= 450,000): ` +
    `Execute the project-memory skill (${skillPath}) ` +
    `to summarize each task completed in this session with full details so the user can open a new chat and continue seamlessly. ` +
    `${locationHint} ` +
    `Inform the user of the current token usage (~${formatted}) and recommend starting a new chat (or running /compact).`
  );
}

/**
 * Evaluate whether the Stop hook should force a project-memory handoff summary.
 */
export function evaluateContextMemoryGate({
  input,
  steps,
  turnSteps,
  stateFilePath = getDefaultStatePath(),
  thresholdTokens = CONTEXT_THRESHOLD_TOKENS,
  stepTokens = CONTEXT_STEP_TOKENS,
  nowMs = Date.now(),
}) {
  const tokenInfo = extractLatestTokenCount(steps);
  if (!tokenInfo || tokenInfo.totalTokens < thresholdTokens) {
    return { shouldContinue: false, tokenInfo };
  }

  const conversationId =
    (typeof input?.conversationId === "string" && input.conversationId.trim()) ||
    "default";
  const state = loadState(stateFilePath);

  if (didWriteHandoffInTurn(turnSteps)) {
    state[conversationId] = {
      lastTriggeredTokens: tokenInfo.totalTokens,
      updatedAt: new Date(nowMs).toISOString(),
    };
    saveState(stateFilePath, state, nowMs);
    return { shouldContinue: false, tokenInfo, alreadySavedInTurn: true };
  }

  const prevTokens = toFiniteNumber(state[conversationId]?.lastTriggeredTokens);
  if (prevTokens >= thresholdTokens && tokenInfo.totalTokens < prevTokens + stepTokens) {
    return { shouldContinue: false, tokenInfo, cooldownActive: true, prevTokens };
  }

  state[conversationId] = {
    lastTriggeredTokens: tokenInfo.totalTokens,
    updatedAt: new Date(nowMs).toISOString(),
  };
  saveState(stateFilePath, state, nowMs);

  return {
    shouldContinue: true,
    tokenInfo,
    reason: buildHandoffReason(tokenInfo.totalTokens, hasActiveWorkspace(input)),
  };
}
