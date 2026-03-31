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

# ─── SDK Hooks Setup ───
# Try to install @github/copilot-sdk for onSessionStart hook support
HOOKS_INSTALLED=false
if command -v node &> /dev/null && command -v npm &> /dev/null; then
    echo "🔧 Installing SDK dependencies for hooks..."
    cd "$CACHE_DIR"
    if npm install --quiet 2>/dev/null; then
        HOOKS_INSTALLED=true
        echo "✅ SDK hooks dependencies installed"
    else
        echo "⚠️  SDK install failed — hooks will use fallback mode"
    fi
    cd - > /dev/null
else
    echo "ℹ️  Node.js not found — skipping SDK hooks (instructions.md fallback active)"
fi

# ─── CLI Hooks Configuration ───
HOOKS_DIR="$COPILOT_HOME/hooks"
if [ "$HOOKS_INSTALLED" = true ]; then
    echo "🔧 Configuring CLI lifecycle hooks..."
    mkdir -p "$HOOKS_DIR"
    # Copy hooks config if not already present
    if [ ! -f "$HOOKS_DIR/hooks-copilot.json" ]; then
        cp "$CACHE_DIR/hooks/hooks-copilot.json" "$HOOKS_DIR/hooks-copilot.json"
        echo "✅ CLI hooks configured: preCompact, agentStop"
    else
        echo "ℹ️  CLI hooks already configured."
    fi
fi

# ─── Custom Instructions (Layer 1 — Static Bootstrap) ───
# Inject FULL using-superpowers content (not just a summary)
INSTRUCTIONS_FILE="$COPILOT_HOME/copilot-instructions.md"
MARKER_START="<!-- superpowers-installed -->"
MARKER_END="<!-- /superpowers-installed -->"
SKILL_FILE="$PLUGIN_DIR/skills/using-superpowers/SKILL.md"

# Read the full using-superpowers skill content
if [ -f "$SKILL_FILE" ]; then
    SKILL_CONTENT=$(cat "$SKILL_FILE")
else
    SKILL_CONTENT="Error: could not read using-superpowers skill."
fi

# Build the full instructions block
INSTRUCTIONS_BLOCK="$MARKER_START
## Superpowers Skills

<EXTREMELY_IMPORTANT>
You have superpowers.

**Below is the full content of your 'superpowers:using-superpowers' skill - your introduction to using skills. For all other skills, use the skill system:**

$SKILL_CONTENT
</EXTREMELY_IMPORTANT>

Available skills: brainstorming, test-driven-development, systematic-debugging, writing-plans,
executing-plans, subagent-driven-development, dispatching-parallel-agents, requesting-code-review,
receiving-code-review, verification-before-completion, using-git-worktrees,
finishing-a-development-branch, writing-skills, using-superpowers.

Priority order:
1. Process skills first (brainstorming, debugging) — these determine HOW to approach the task
2. Implementation skills second — these guide execution

\"Let's build X\" → brainstorming first, then implementation skills.
\"Fix this bug\" → systematic-debugging first, then domain-specific skills.
$MARKER_END"

if [ -f "$INSTRUCTIONS_FILE" ] && grep -q "$MARKER_START" "$INSTRUCTIONS_FILE" 2>/dev/null; then
    # Replace existing block between markers
    echo "🔄 Updating custom instructions with full skill content..."
    # Use sed to replace content between markers
    TEMP_FILE=$(mktemp)
    awk -v start="$MARKER_START" -v end="$MARKER_END" -v block="$INSTRUCTIONS_BLOCK" '
        $0 == start { print block; skip=1; next }
        $0 == end { skip=0; next }
        !skip { print }
    ' "$INSTRUCTIONS_FILE" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$INSTRUCTIONS_FILE"
    echo "✅ Custom instructions updated with full using-superpowers content"
else
    echo "" >> "$INSTRUCTIONS_FILE"
    echo "$INSTRUCTIONS_BLOCK" >> "$INSTRUCTIONS_FILE"
    echo "✅ Custom instructions created: $INSTRUCTIONS_FILE"
fi

SKILL_COUNT=$(ls "$PLUGIN_DIR/skills" | wc -l | tr -d ' ')

echo ""
echo "🎉 Superpowers installed successfully!"
echo ""
echo "   Plugin:  superpowers v5.0.6-copilot.1 ($SKILL_COUNT skills + code-reviewer agent)"
if [ "$HOOKS_INSTALLED" = true ]; then
    echo "   Hooks:   ✅ SDK onSessionStart + CLI preCompact/agentStop"
else
    echo "   Hooks:   ⚠️  Fallback mode (copilot-instructions.md only)"
fi
echo ""
echo "   Next steps:"
echo "   1. Start a new Copilot CLI session: copilot"
echo "   2. Verify skills:  /skills list"
echo "   3. Verify agent:   /agents"
echo "   4. Try: 'Use the /brainstorming skill to explore an idea'"
echo ""
echo "   To update:    run this script again"
echo "   To uninstall: copilot plugin uninstall superpowers"
echo "                 and remove the $MARKER_START section from $INSTRUCTIONS_FILE"
