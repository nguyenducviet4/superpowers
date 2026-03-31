// hooks/copilot-plugin.js
// Copilot CLI plugin hooks — registers onSessionStart to inject using-superpowers context
//
// Dual-mode module:
// 1. SDK Plugin: exports `hooks` object with onSessionStart handler
// 2. CLI Hook Command: when run with argument (pre-compact, agent-stop),
//    outputs JSON to stdout for Copilot CLI hooks system
//
// Mirrors obra's hooks/session-start behavior but in Node.js for cross-platform support.

import { readFileSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const PLUGIN_ROOT = join(__dirname, "..");
const SKILL_PATH = join(
  PLUGIN_ROOT,
  "plugins",
  "superpowers",
  "skills",
  "using-superpowers",
  "SKILL.md"
);

function readSkillContent() {
  try {
    return readFileSync(SKILL_PATH, "utf-8");
  } catch (err) {
    return `Error reading using-superpowers skill: ${err.message}`;
  }
}

function buildSessionContext(skillContent) {
  return [
    "<EXTREMELY_IMPORTANT>",
    "You have superpowers.",
    "",
    "**Below is the full content of your 'superpowers:using-superpowers' skill - your introduction to using skills. For all other skills, use the skill system:**",
    "",
    skillContent,
    "</EXTREMELY_IMPORTANT>",
  ].join("\n");
}

// === SDK Plugin Hooks (exported for Copilot SDK plugin system) ===
export const hooks = {
  onSessionStart: async (_input, _invocation) => {
    const content = readSkillContent();
    return { additionalContext: buildSessionContext(content) };
  },

  onPreToolUse: async (_input, _invocation) => {
    // Allow all tools — no permission filtering
    return { permissionDecision: "allow" };
  },
};

// === CLI Hook Commands (invoked via hooks-copilot.json) ===
const action = process.argv[2];

if (action === "pre-compact") {
  // Before context compaction: output superpowers context to preserve awareness
  const content = readSkillContent();
  const context = buildSessionContext(content);
  process.stdout.write(
    JSON.stringify({ additionalContext: context }) + "\n"
  );
} else if (action === "agent-stop") {
  // Agent stopping — placeholder for future cleanup
  process.exit(0);
}
