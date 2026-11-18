import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

import {
  didWriteHandoffInTurn,
  evaluateContextMemoryGate,
  extractLatestTokenCount,
} from "./context-memory-gate.mjs";

const HOOKS_DIR = path.dirname(fileURLToPath(import.meta.url));

function makePlannerStep(stepIndex, inputTokens, cacheReadTokens, outputTokens, toolCalls = []) {
  return {
    step_index: stepIndex,
    type: "PLANNER_RESPONSE",
    input_tokens: inputTokens,
    cache_read_tokens: cacheReadTokens,
    output_tokens: outputTokens,
    tool_calls: toolCalls,
  };
}

function makeTempDir(prefix) {
  return fs.mkdtempSync(path.join(os.tmpdir(), prefix));
}

test("extractLatestTokenCount sums input + cache_read + output from latest PLANNER_RESPONSE", () => {
  const steps = [
    { step_index: 0, type: "USER_INPUT" },
    makePlannerStep(1, 1000, 2000, 100),
    { step_index: 2, type: "GENERIC" },
    makePlannerStep(3, 50000, 399500, 500),
  ];
  const result = extractLatestTokenCount(steps);
  assert.deepEqual(result, {
    totalTokens: 450000,
    inputTokens: 50000,
    cacheReadTokens: 399500,
    outputTokens: 500,
    stepIndex: 3,
  });
});

test("evaluateContextMemoryGate stays silent below 450,000 tokens", () => {
  const tmpDir = makeTempDir("agy-ctx-test-");
  const statePath = path.join(tmpDir, "state.json");
  try {
    const steps = [makePlannerStep(1, 49000, 400000, 999)];
    const res = evaluateContextMemoryGate({
      input: { conversationId: "conv-1", workspacePaths: ["C:/repo"] },
      steps,
      turnSteps: steps,
      stateFilePath: statePath,
    });
    assert.equal(res.shouldContinue, false);
    assert.equal(res.tokenInfo.totalTokens, 449999);
  } finally {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
});

test("evaluateContextMemoryGate triggers at >= 450,000, enforces +50k cooldown, and re-triggers at 500,000", () => {
  const tmpDir = makeTempDir("agy-ctx-test-");
  const statePath = path.join(tmpDir, "state.json");
  try {
    // 1. Cross 450,000 -> should trigger
    const steps1 = [makePlannerStep(1, 50000, 400000, 500)];
    const res1 = evaluateContextMemoryGate({
      input: { conversationId: "conv-2", workspacePaths: ["C:/repo"] },
      steps: steps1,
      turnSteps: steps1,
      stateFilePath: statePath,
    });
    assert.equal(res1.shouldContinue, true);
    assert.match(res1.reason, /450,500 tokens >= 450,000/);
    assert.match(res1.reason, /\.agents\/memory\/handoff-latest\.md/);

    // 2. Grow to 480,000 (< 450,500 + 50,000) -> cooldown active
    const steps2 = [makePlannerStep(5, 30000, 449500, 500)];
    const res2 = evaluateContextMemoryGate({
      input: { conversationId: "conv-2", workspacePaths: ["C:/repo"] },
      steps: steps2,
      turnSteps: steps2,
      stateFilePath: statePath,
    });
    assert.equal(res2.shouldContinue, false);
    assert.equal(res2.cooldownActive, true);

    // 3. Grow to 500,500 (>= 450,500 + 50,000) -> re-triggers
    const steps3 = [makePlannerStep(9, 20000, 480000, 500)];
    const res3 = evaluateContextMemoryGate({
      input: { conversationId: "conv-2", workspacePaths: ["C:/repo"] },
      steps: steps3,
      turnSteps: steps3,
      stateFilePath: statePath,
    });
    assert.equal(res3.shouldContinue, true);
    assert.match(res3.reason, /500,500 tokens >= 450,000/);
  } finally {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
});

test("evaluateContextMemoryGate skips and records checkpoint when handoff-latest.md was written in current turn", () => {
  const tmpDir = makeTempDir("agy-ctx-test-");
  const statePath = path.join(tmpDir, "state.json");
  try {
    const turnSteps = [
      makePlannerStep(4, 10000, 450000, 200, [
        {
          name: "write_file",
          args: { Path: '"C:\\\\repo\\\\.agents\\\\memory\\\\handoff-latest.md"' },
        },
      ]),
    ];
    assert.equal(didWriteHandoffInTurn(turnSteps), true);

    const res = evaluateContextMemoryGate({
      input: { conversationId: "conv-3", workspacePaths: ["C:/repo"] },
      steps: turnSteps,
      turnSteps,
      stateFilePath: statePath,
    });
    assert.equal(res.shouldContinue, false);
    assert.equal(res.alreadySavedInTurn, true);

    // Next turn at 470,000 should respect cooldown from 460,200
    const nextSteps = [makePlannerStep(7, 10000, 459500, 500)];
    const resNext = evaluateContextMemoryGate({
      input: { conversationId: "conv-3", workspacePaths: ["C:/repo"] },
      steps: nextSteps,
      turnSteps: nextSteps,
      stateFilePath: statePath,
    });
    assert.equal(resNext.shouldContinue, false);
    assert.equal(resNext.cooldownActive, true);
  } finally {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
});

test("evaluateContextMemoryGate uses scratch fallback instructions when no workspace is open", () => {
  const tmpDir = makeTempDir("agy-ctx-test-");
  const statePath = path.join(tmpDir, "state.json");
  try {
    const steps = [makePlannerStep(2, 50000, 405000, 100)];
    const res = evaluateContextMemoryGate({
      input: { conversationId: "conv-noworkspace", workspacePaths: [] },
      steps,
      turnSteps: steps,
      stateFilePath: statePath,
    });
    assert.equal(res.shouldContinue, true);
    assert.match(res.reason, /No active workspace is open/);
    assert.match(res.reason, /scratch\/handoffs\/handoff-latest\.md/);
  } finally {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
});

test("stop-verify-gate.mjs CLI returns continue at >= 450k tokens and respects continuationActive", () => {
  const tmpDir = makeTempDir("agy-stop-cli-");
  try {
    const transcriptPath = path.join(tmpDir, "transcript.jsonl");
    const lines = [
      JSON.stringify({ step_index: 0, type: "USER_INPUT", content: "hi" }),
      JSON.stringify(makePlannerStep(1, 50000, 410000, 300)),
    ];
    fs.writeFileSync(transcriptPath, `${lines.join("\n")}\n`, "utf8");

    const convId = `test-stop-${Date.now()}`;
    const env = {
      ...process.env,
      AGY_CONTEXT_MEMORY_STATE_PATH: path.join(tmpDir, "cli-state.json"),
    };
    const run1 = spawnSync("node", [path.join(HOOKS_DIR, "stop-verify-gate.mjs")], {
      input: JSON.stringify({
        conversationId: convId,
        terminationReason: "NO_TOOL_CALL",
        continuationActive: false,
        transcriptPath,
        workspacePaths: [tmpDir],
      }),
      env,
      encoding: "utf8",
    });
    assert.equal(run1.status, 0);
    const out1 = JSON.parse(run1.stdout.trim());
    assert.equal(out1.decision, "continue");
    assert.match(out1.reason, /460,300 tokens >= 450,000/);

    // Continuation active should emit {}
    const run2 = spawnSync("node", [path.join(HOOKS_DIR, "stop-verify-gate.mjs")], {
      input: JSON.stringify({
        conversationId: convId,
        terminationReason: "NO_TOOL_CALL",
        continuationActive: true,
        transcriptPath,
        workspacePaths: [tmpDir],
      }),
      env,
      encoding: "utf8",
    });
    assert.equal(run2.status, 0);
    assert.deepEqual(JSON.parse(run2.stdout.trim()), {});
  } finally {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
});

test("session-start.mjs CLI auto-loads handoff-latest.md when inside a workspace", () => {
  const tmpDir = makeTempDir("agy-start-cli-");
  try {
    fs.writeFileSync(path.join(tmpDir, "PROJECT_CONTEXT.md"), "# Demo Project\n", "utf8");
    const memDir = path.join(tmpDir, ".agents", "memory");
    fs.mkdirSync(memDir, { recursive: true });
    fs.writeFileSync(
      path.join(memDir, "handoff-latest.md"),
      "# Session Handoff\n## Task 1: Auth Setup\nDone.",
      "utf8"
    );
    fs.writeFileSync(
      path.join(memDir, "bridge.json"),
      JSON.stringify({ nextImmediateTask: "Deploy" }),
      "utf8"
    );

    const run = spawnSync("node", [path.join(HOOKS_DIR, "session-start.mjs")], {
      input: JSON.stringify({ workspacePaths: [tmpDir] }),
      encoding: "utf8",
    });
    assert.equal(run.status, 0);
    const parsed = JSON.parse(run.stdout.trim());
    const sysMsg = parsed?.injectSteps?.[0]?.systemMessage?.systemMessage || "";
    assert.match(sysMsg, /Latest Session Handoff/);
    assert.match(sysMsg, /Task 1: Auth Setup/);
    assert.match(sysMsg, /Active Project Context/);
    assert.match(sysMsg, /Project Session Bridge/);

    // Empty workspacePaths + non-project cwd should NOT inject project memory
    const plainDir = makeTempDir("agy-plain-cwd-");
    try {
      const runPlain = spawnSync("node", [path.join(HOOKS_DIR, "session-start.mjs")], {
        input: JSON.stringify({ workspacePaths: [], cwd: plainDir }),
        encoding: "utf8",
      });
      assert.equal(runPlain.status, 0);
      const parsedPlain = JSON.parse(runPlain.stdout.trim());
      const plainMsg = parsedPlain?.injectSteps?.[0]?.systemMessage?.systemMessage || "";
      assert.doesNotMatch(plainMsg, /Latest Session Handoff/);
    } finally {
      fs.rmSync(plainDir, { recursive: true, force: true });
    }
  } finally {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
});
