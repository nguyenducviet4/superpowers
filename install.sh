#!/usr/bin/env bash
set -euo pipefail

# Superpowers for GitHub Copilot CLI — One-line installer
# Usage: curl -fsSL https://raw.githubusercontent.com/DwainTR/superpowers-copilot/main/install.sh | bash

REPO="DwainTR/superpowers-copilot"
MARKETPLACE_NAME="superpowers-copilot"
COPILOT_HOME="${COPILOT_HOME:-$HOME/.copilot}"
CACHE_DIR="$COPILOT_HOME/marketplace-cache/dwaintr-superpowers-copilot"

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
    echo "⚠️  GitHub Copilot CLI not found in PATH."
    echo "   Install it first: https://github.com/github/copilot-cli"
    echo "   Continuing anyway (skills will be available when Copilot CLI is installed)..."
    echo ""
fi

# Clone or update the marketplace repo
if [ -d "$CACHE_DIR" ]; then
    echo "📦 Updating existing marketplace cache..."
    cd "$CACHE_DIR"
    git pull --quiet 2>/dev/null || {
        echo "   Cache update failed, removing and re-cloning..."
        rm -rf "$CACHE_DIR"
        git clone --quiet "https://github.com/$REPO.git" "$CACHE_DIR"
    }
else
    echo "📦 Cloning marketplace..."
    mkdir -p "$(dirname "$CACHE_DIR")"
    git clone --quiet "https://github.com/$REPO.git" "$CACHE_DIR"
fi

# Create skills directory and symlink
SKILLS_SRC="$CACHE_DIR/plugins/superpowers/skills"
SKILLS_DST="$COPILOT_HOME/skills/superpowers"

mkdir -p "$COPILOT_HOME/skills"
if [ -L "$SKILLS_DST" ] || [ -d "$SKILLS_DST" ]; then
    echo "🔄 Removing old skills symlink..."
    rm -rf "$SKILLS_DST"
fi
ln -s "$SKILLS_SRC" "$SKILLS_DST"
echo "✅ Skills linked: $SKILLS_DST → $SKILLS_SRC"

# Create agents directory and symlink
AGENTS_SRC="$CACHE_DIR/plugins/superpowers/agents/code-reviewer.md"
AGENTS_DIR="$COPILOT_HOME/agents"
AGENTS_DST="$AGENTS_DIR/code-reviewer.md"

mkdir -p "$AGENTS_DIR"
if [ -L "$AGENTS_DST" ] || [ -f "$AGENTS_DST" ]; then
    echo "🔄 Removing old agent symlink..."
    rm -f "$AGENTS_DST"
fi
ln -s "$AGENTS_SRC" "$AGENTS_DST"
echo "✅ Agent linked: $AGENTS_DST → $AGENTS_SRC"

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

echo ""
echo "🎉 Superpowers installed successfully!"
echo ""
echo "   Skills: $(ls "$SKILLS_DST" | wc -l | tr -d ' ') skills available"
echo "   Agent:  code-reviewer"
echo ""
echo "   Next steps:"
echo "   1. Start a new Copilot CLI session: copilot"
echo "   2. Verify: /skills list"
echo "   3. Try: 'Use the /brainstorming skill to explore an idea'"
echo ""
echo "   To update: run this script again"
echo "   To uninstall: rm -rf $SKILLS_DST $AGENTS_DST $CACHE_DIR"
echo "     and remove the superpowers section from $INSTRUCTIONS_FILE"
