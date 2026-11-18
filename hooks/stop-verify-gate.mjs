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

const OFFICE_DELIVERABLE_EXT_PATTERN = /\.(docx|xlsx|pptx|pdf)\b/i;
const OFFICE_READONLY_CMD_PATTERN =
  /^\s*(Get-ChildItem|Get-Item|Get-Content|dir|ls|Test-Path|Select-String)\b/i;
const QA_DOCS_CMD_PATTERN = /\bqa_docs\.py\b/i;

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

function isOfficeDeliverableScript(filePath) {
  if (!filePath) return false;
  const normalized = cleanArgString(filePath).replace(/\\/g, "/");
  if (normalized.includes("/.gemini/config/")) return false;
  if (normalized.includes("/_qa_report/")) return false;
  return OFFICE_DELIVERABLE_EXT_PATTERN.test(normalized);
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
  let lastOfficeBuildIdx = -1;
  let lastQaDocsIdx = -1;

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
        if (isOfficeDeliverableScript(target)) {
          lastOfficeBuildIdx = callCounter;
        }
      } else if (name === "run_command") {
        const cmd = cleanArgString(args.CommandLine || args.command || "");
        if (QA_DOCS_CMD_PATTERN.test(cmd)) {
          lastQaDocsIdx = callCounter;
          lastVerifyIdx = callCounter;
          continue;
        }
        if (VERIFY_CMD_PATTERN.test(cmd)) {
          lastVerifyIdx = callCounter;
        }
        if (
          OFFICE_DELIVERABLE_EXT_PATTERN.test(cmd) &&
          !OFFICE_READONLY_CMD_PATTERN.test(cmd) &&
          !/\.rendered\.pdf\b/i.test(cmd) &&
          !cmd.includes("/_qa_report/") &&
          !cmd.includes("\\_qa_report\\")
        ) {
          lastOfficeBuildIdx = callCounter;
        }
      } else if (name === "invoke_subagent") {
        const typeName = cleanArgString(args.TypeName || "");
        if (typeName === "browser") {
          lastVerifyIdx = callCounter;
        }
      }
    }
  }

  const reasons = [];
  if (lastCodeEditIdx !== -1 && lastVerifyIdx < lastCodeEditIdx) {
    reasons.push(
      "Code Verification Gate (Prove It Works): Source code files were modified in this turn without a subsequent test, typecheck, build, or browser verification."
    );
  }
  if (lastOfficeBuildIdx !== -1 && lastQaDocsIdx < lastOfficeBuildIdx) {
    reasons.push(
      "Office QA Gate (qa-docs): If a final .docx/.xlsx/.pptx/.pdf deliverable was generated in this turn (skipping quick intermediate drafts), run qa-docs before concluding."
    );
  }

  if (reasons.length > 0) {
    emitJson({
      decision: "continue",
      reason: reasons.join(" | "),
    });
    return;
  }

  emitJson({});
}

main();
