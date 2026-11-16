import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

export function getConfigDir() {
  const thisDir = path.dirname(fileURLToPath(import.meta.url));
  return path.resolve(thisDir, "..");
}

export function readStdinJson() {
  try {
    const raw = fs.readFileSync(0, "utf8").trim();
    if (!raw) return {};
    return JSON.parse(raw);
  } catch {
    return {};
  }
}

export function safeReadText(filePath, maxChars = 2500) {
  try {
    if (!filePath || !fs.existsSync(filePath)) return "";
    const content = fs.readFileSync(filePath, "utf8").trim();
    if (!content) return "";
    if (content.length <= maxChars) return content;
    const sliced = content.slice(0, maxChars);
    const lastNewline = sliced.lastIndexOf("\n");
    const cut = lastNewline > maxChars * 0.5 ? sliced.slice(0, lastNewline) : sliced;
    return `${cut}\n... [truncated; read ${filePath} for full content]`;
  } catch {
    return "";
  }
}

export function emitJson(obj) {
  process.stdout.write(`${JSON.stringify(obj)}\n`);
}
