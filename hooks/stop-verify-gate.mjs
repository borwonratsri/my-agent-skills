import fs from "node:fs";
import path from "node:path";
import { emitJson, readStdinJson } from "./lib.mjs";

const CODE_EXTS = new Set([
  ".ts",
  ".tsx",
  ".js",
  ".jsx",
  ".mjs",
  ".cjs",
  ".py",
  ".dart",
  ".go",
  ".rs",
  ".java",
  ".cs",
  ".vue",
  ".svelte",
]);

const VERIFY_CMD_PATTERN =
  /\b(test|tsc|typecheck|lint|build|pytest|vitest|jest|mocha|playwright|cypress|flutter|dart\s+analyze|cargo\s+(test|check)|go\s+test|uv\s+run|npm\s+run|pnpm\s+|yarn\s+|bun\s+|node\s+|python\s+)/i;

function cleanArgString(val) {
  if (typeof val !== "string") return "";
  const trimmed = val.trim();
  if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
    try {
      const parsed = JSON.parse(trimmed);
      if (typeof parsed === "string") return parsed;
    } catch {
      return trimmed.slice(1, -1);
    }
  }
  return trimmed;
}

function isCodePath(filePath) {
  if (!filePath) return false;
  const normalized = cleanArgString(filePath).replace(/\\/g, "/");
  // Exclude global hooks/skills edits from triggering app test gates.
  if (normalized.includes("/.gemini/config/")) return false;
  return CODE_EXTS.has(path.extname(normalized).toLowerCase());
}

function main() {
  const input = readStdinJson();

  if (input.continuationActive === true) {
    emitJson({});
    return;
  }

  if (input.terminationReason && input.terminationReason !== "NO_TOOL_CALL") {
    emitJson({});
    return;
  }

  const transcriptPath = input.transcriptPath;
  if (!transcriptPath || !fs.existsSync(transcriptPath)) {
    emitJson({});
    return;
  }

  let lines;
  try {
    const raw = fs.readFileSync(transcriptPath, "utf8");
    lines = raw.split(/\r?\n/).filter(Boolean);
  } catch {
    emitJson({});
    return;
  }

  const steps = [];
  for (const line of lines) {
    try {
      steps.push(JSON.parse(line));
    } catch {
      // Ignore malformed lines.
    }
  }

  let lastUserIdx = -1;
  for (let i = steps.length - 1; i >= 0; i--) {
    if (steps[i]?.type === "USER_INPUT") {
      lastUserIdx = i;
      break;
    }
  }

  const turnSteps = lastUserIdx >= 0 ? steps.slice(lastUserIdx + 1) : steps;
  let callCounter = 0;
  let lastCodeEditIdx = -1;
  let lastVerifyIdx = -1;

  for (const step of turnSteps) {
    const toolCalls = Array.isArray(step?.tool_calls) ? step.tool_calls : [];
    for (const tc of toolCalls) {
      callCounter++;
      const name = tc?.name || "";
      const args = tc?.args || {};

      if (name === "write_file" || name === "edit_file") {
        const target = args.Path || args.path || args.TargetFile || "";
        if (isCodePath(target)) {
          lastCodeEditIdx = callCounter;
        }
      } else if (name === "run_command") {
        const cmd = cleanArgString(args.CommandLine || args.command || "");
        if (VERIFY_CMD_PATTERN.test(cmd)) {
          lastVerifyIdx = callCounter;
        }
      } else if (name === "invoke_subagent") {
        const typeName = cleanArgString(args.TypeName || "");
        if (typeName === "browser") {
          lastVerifyIdx = callCounter;
        }
      }
    }
  }

  if (lastCodeEditIdx !== -1 && lastVerifyIdx < lastCodeEditIdx) {
    emitJson({
      decision: "continue",
      reason:
        "Verification Gate (Prove It Works): You modified source code files in this turn without running a test, typecheck, build, or browser verification afterward. Run the relevant verification check before concluding.",
    });
    return;
  }

  emitJson({});
}

main();
