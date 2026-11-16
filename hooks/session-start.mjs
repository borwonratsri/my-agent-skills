import path from "node:path";
import { emitJson, getConfigDir, readStdinJson, safeReadText } from "./lib.mjs";

function main() {
  const input = readStdinJson();
  const configDir = getConfigDir();

  const sections = [];

  const userMemoryPath = path.join(configDir, "USER_MEMORY.md");
  const userMemory = safeReadText(userMemoryPath, 3000);
  if (userMemory) {
    sections.push(`## Global Saved Info (${userMemoryPath})\n${userMemory}`);
  }

  const knowledgeIndexPath = path.join(configDir, "knowledge", "INDEX.md");
  const knowledgeIndex = safeReadText(knowledgeIndexPath, 1500);
  if (knowledgeIndex) {
    sections.push(`## Global Knowledge Vault Index (${knowledgeIndexPath})\n${knowledgeIndex}`);
  }

  const workspaceRoot =
    (Array.isArray(input.workspacePaths) && input.workspacePaths[0]) ||
    input.cwd ||
    "";

  if (workspaceRoot) {
    const projectContextPath = path.join(workspaceRoot, "PROJECT_CONTEXT.md");
    const projectContext = safeReadText(projectContextPath, 1800);
    if (projectContext) {
      sections.push(`## Active Project Context (${projectContextPath})\n${projectContext}`);
    }

    const bridgePath = path.join(workspaceRoot, ".agents", "memory", "bridge.json");
    const bridge = safeReadText(bridgePath, 1000);
    if (bridge) {
      sections.push(`## Project Session Bridge (${bridgePath})\n${bridge}`);
    }
  }

  if (sections.length === 0) {
    emitJson({});
    return;
  }

  const message =
    `[4-Pillar SessionStart Context]\n\n${sections.join("\n\n---\n\n")}`;

  emitJson({
    injectSteps: [
      {
        systemMessage: {
          systemMessage: message,
        },
      },
    ],
  });
}

main();
