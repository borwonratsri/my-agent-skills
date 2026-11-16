import { emitJson, readStdinJson } from "./lib.mjs";

const DESTRUCTIVE_CHECKS = [
  {
    label: "Destructive SQL (DROP / TRUNCATE / unqualified DELETE)",
    pattern:
      /\b(DROP\s+(TABLE|DATABASE|SCHEMA|VIEW|INDEX)|TRUNCATE\s+(TABLE\s+)?\w+|DELETE\s+FROM\s+[\w."`[\]]+\s*(;|WHERE\s+1\s*=\s*1|$))/i,
    skipPrefixes: [/^\s*git\s+(add|commit|status|log|diff|branch|fetch)\b/i],
  },
  {
    label: "Git Force-Push to Main/Master or Hard Reset",
    pattern:
      /(\bgit\s+push\b[^\n]*(\s--force\b|\s-f\b)[^\n]*\b(main|master)\b|\bgit\s+reset\s+--hard\b)/i,
  },
  {
    label: "Cloud / Database Reset or Resource Deletion",
    pattern:
      /\b(gcloud\s+projects\s+delete|gsutil\s+(?:-m\s+)?rm\b|gcloud\s+storage\s+rm\b|supabase\s+db\s+reset|prisma\s+migrate\s+reset)\b/i,
  },
  {
    label: "Root / Home Recursive Deletion or Volume Format",
    pattern:
      /(\brm\s+-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*\s+([/~]|C:\\|"C:\\|\$HOME|\$env:USERPROFILE)(\s|$|\/\*|\*)|\bRemove-Item\b[^\n]*-Recurse[^\n]*\s+(C:\\|~|\$HOME|\$env:USERPROFILE)(\s|$|\\\*)|\bFormat-Volume\b)/i,
  },
];

function main() {
  const input = readStdinJson();
  const toolName = input?.toolCall?.name || "";

  if (toolName !== "run_command") {
    emitJson({ decision: "allow" });
    return;
  }

  const args = input?.toolCall?.args || {};
  const cmd = String(args.CommandLine || args.command || "");

  for (const check of DESTRUCTIVE_CHECKS) {
    if (check.skipPrefixes && check.skipPrefixes.some((rx) => rx.test(cmd))) {
      continue;
    }
    if (check.pattern.test(cmd)) {
      emitJson({
        decision: "force_ask",
        reason: `Global Safety Guard: Detected potentially destructive operation (${check.label}). Please confirm explicitly before running.`,
      });
      return;
    }
  }

  emitJson({ decision: "allow" });
}

main();
