#!/usr/bin/env bash
set -euo pipefail

# Superpowers for GitHub Copilot CLI — One-line installer
# Usage: curl -fsSL https://raw.githubusercontent.com/nguyenducviet4/superpowers/main/install.sh | bash

REPO="nguyenducviet4/superpowers"
COPILOT_HOME="${COPILOT_HOME:-$HOME/.copilot}"
CACHE_DIR="$COPILOT_HOME/state/plugin-sources/superpowers"

echo "🦸 Superpowers for GitHub Copilot CLI — Installer"
echo "=================================================="
echo ""

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ Git is required but not installed."
    exit 1
fi

# Check if copilot CLI is installed
if ! command -v copilot &> /dev/null; then
    echo "❌ GitHub Copilot CLI not found in PATH."
    echo "   Install it first: https://docs.github.com/en/copilot/how-tos/copilot-cli"
    exit 1
fi

# Clone or update the source repository
if [ -d "$CACHE_DIR/.git" ]; then
    echo "📦 Updating existing source cache..."
    cd "$CACHE_DIR"
    git pull --quiet 2>/dev/null || {
        echo "   Update failed, removing and re-cloning..."
        rm -rf "$CACHE_DIR"
        git clone --quiet "https://github.com/$REPO.git" "$CACHE_DIR"
    }
    cd - > /dev/null
else
    echo "📦 Cloning source repository..."
    mkdir -p "$(dirname "$CACHE_DIR")"
    git clone --quiet "https://github.com/$REPO.git" "$CACHE_DIR"
fi

PLUGIN_DIR="$CACHE_DIR/plugins/superpowers"

# Install (or reinstall/update) the plugin using the native Copilot CLI plugin system
echo "🔌 Installing plugin via Copilot CLI native plugin system..."
copilot plugin install "$PLUGIN_DIR"
echo "✅ Plugin installed: superpowers"

# Add custom instructions snippet if not already present
INSTRUCTIONS_FILE="$COPILOT_HOME/copilot-instructions.md"
MARKER="<!-- superpowers-installed -->"

if [ -f "$INSTRUCTIONS_FILE" ] && grep -q "$MARKER" "$INSTRUCTIONS_FILE" 2>/dev/null; then
    echo "ℹ️  Custom instructions already configured."
else
    echo "" >> "$INSTRUCTIONS_FILE"
    cat >> "$INSTRUCTIONS_FILE" << 'INSTRUCTIONS'

<!-- superpowers-installed -->
## Superpowers Skills

You have Superpowers skills installed. Before any task, check if a relevant skill applies.
If there is even a 1% chance a skill might be relevant, invoke it.

Available skills: brainstorming, test-driven-development, systematic-debugging, writing-plans,
executing-plans, subagent-driven-development, dispatching-parallel-agents, requesting-code-review,
receiving-code-review, verification-before-completion, using-git-worktrees,
finishing-a-development-branch, writing-skills, using-superpowers.

Priority order:
1. Process skills first (brainstorming, debugging) — these determine HOW to approach the task
2. Implementation skills second — these guide execution

"Let's build X" → brainstorming first, then implementation skills.
"Fix this bug" → systematic-debugging first, then domain-specific skills.
INSTRUCTIONS
    echo "✅ Custom instructions updated: $INSTRUCTIONS_FILE"
fi

SKILL_COUNT=$(ls "$PLUGIN_DIR/skills" | wc -l | tr -d ' ')

echo ""
echo "🎉 Superpowers installed successfully!"
echo ""
echo "   Plugin:  superpowers ($SKILL_COUNT skills + code-reviewer agent)"
echo ""
echo "   Next steps:"
echo "   1. Start a new Copilot CLI session: copilot"
echo "   2. Verify skills:  /skills list"
echo "   3. Verify agent:   /agents"
echo "   4. Try: 'Use the /brainstorming skill to explore an idea'"
echo ""
echo "   To update:    run this script again"
echo "   To uninstall: copilot plugin uninstall superpowers"
echo "                 and remove the <!-- superpowers-installed --> section from $INSTRUCTIONS_FILE"
