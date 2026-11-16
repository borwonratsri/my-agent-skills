import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { emitJson, readStdinJson } from "./lib.mjs";

const PRETTIER_EXTS = new Set([
  ".ts",
  ".tsx",
  ".js",
  ".jsx",
  ".mjs",
  ".cjs",
  ".css",
  ".scss",
  ".json",
]);

function findUpward(startDir, relPaths, stopDir) {
  let current = path.resolve(startDir);
  const homeDir = path.resolve(os.homedir());
  const normalizedStop = stopDir ? path.resolve(stopDir) : "";

  for (let depth = 0; depth < 8; depth++) {
    for (const rel of relPaths) {
      const candidate = path.join(current, rel);
      if (fs.existsSync(candidate)) {
        return { projectDir: current, binPath: candidate };
      }
    }
    if (current === normalizedStop || current === homeDir) break;
    const parent = path.dirname(current);
    if (parent === current) break;
    current = parent;
  }
  return null;
}

function main() {
  const input = readStdinJson();
  const toolName = input?.toolCall?.name || "";

  if (toolName !== "write_file" && toolName !== "edit_file") {
    emitJson({});
    return;
  }

  const args = input?.toolCall?.args || {};
  const targetPath = String(args.Path || args.path || args.TargetFile || "");
  if (!targetPath || !fs.existsSync(targetPath)) {
    emitJson({});
    return;
  }

  const ext = path.extname(targetPath).toLowerCase();
  const workspaceRoot =
    (Array.isArray(input.workspacePaths) && input.workspacePaths[0]) ||
    input.cwd ||
    "";
  const fileDir = path.dirname(targetPath);

  try {
    if (PRETTIER_EXTS.has(ext)) {
      const found = findUpward(
        fileDir,
        [path.join("node_modules", "prettier", "bin", "prettier.cjs")],
        workspaceRoot
      );
      if (found) {
        execFileSync(
          process.execPath,
          [found.binPath, "--write", targetPath],
          { cwd: found.projectDir, timeout: 4000, stdio: "ignore" }
        );
      }
    } else if (ext === ".py") {
      const ruffCandidates =
        process.platform === "win32"
          ? [
              path.join(".venv", "Scripts", "ruff.exe"),
              path.join("venv", "Scripts", "ruff.exe"),
            ]
          : [path.join(".venv", "bin", "ruff"), path.join("venv", "bin", "ruff")];
      const found = findUpward(fileDir, ruffCandidates, workspaceRoot);
      if (found) {
        execFileSync(found.binPath, ["format", targetPath], {
          cwd: found.projectDir,
          timeout: 4000,
          stdio: "ignore",
        });
      }
    }
  } catch {
    // Formatting is best-effort and must never block the tool loop.
  }

  emitJson({});
}

main();
