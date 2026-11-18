import path from "node:path";
import { fileURLToPath } from "node:url";
import {
  CONTEXT_THRESHOLD_TOKENS,
  extractLatestTokenCount,
  getLatestPlannerStep,
  readTranscriptSteps,
} from "./context-memory-gate.mjs";
import { emitJson, readStdinJson } from "./lib.mjs";

export function formatContextMeterMarkdown(
  totalTokens,
  thresholdTokens = CONTEXT_THRESHOLD_TOKENS
) {
  const pct = Math.round((totalTokens / thresholdTokens) * 100);
  const currentK = (totalTokens / 1000).toFixed(1);
  const thresholdK = Math.round(thresholdTokens / 1000);

  if (totalTokens >= thresholdTokens) {
    return `🔴 Context: **${currentK}k / ${thresholdK}k** (${pct}%) — ถึงเกณฑ์ Auto-Handoff แนะนำเปิดแชทใหม่`;
  }
  if (pct >= 70) {
    return `⚠️ Context: **${currentK}k / ${thresholdK}k** (${pct}%) — ใกล้ถึงเกณฑ์ Auto-Handoff`;
  }
  return `📊 Context: **${currentK}k / ${thresholdK}k** (${pct}%)`;
}

/**
 * Emit a zero-model-token UI meter once per turn when the model finishes
 * responding without further tool_calls.
 */
export function evaluateContextMeter(
  steps,
  thresholdTokens = CONTEXT_THRESHOLD_TOKENS
) {
  if (!Array.isArray(steps) || steps.length === 0) return null;

  let lastUserIdx = -1;
  for (let i = steps.length - 1; i >= 0; i--) {
    if (steps[i]?.type === "USER_INPUT") {
      lastUserIdx = i;
      break;
    }
  }

  const latest = getLatestPlannerStep(steps);
  if (!latest || latest.index <= lastUserIdx) return null;

  const toolCalls = Array.isArray(latest.step.tool_calls)
    ? latest.step.tool_calls
    : [];
  if (toolCalls.length > 0) return null;

  const tokenInfo = extractLatestTokenCount([latest.step]);
  if (!tokenInfo) return null;

  return {
    injectSteps: [
      {
        systemMessage: {
          systemMessage: "",
          metadata: {
            user_markdown: formatContextMeterMarkdown(
              tokenInfo.totalTokens,
              thresholdTokens
            ),
          },
        },
      },
    ],
    terminationBehavior: "",
  };
}

function main() {
  const input = readStdinJson();
  const steps = readTranscriptSteps(input.transcriptPath);
  const output = evaluateContextMeter(steps);
  emitJson(output || {});
}

const isDirectRun =
  process.argv[1] &&
  path.resolve(process.argv[1]) === path.resolve(fileURLToPath(import.meta.url));
if (isDirectRun) {
  main();
}
