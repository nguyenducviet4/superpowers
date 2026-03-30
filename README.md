# Superpowers for GitHub Copilot CLI

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/Skills-14-blue)](plugins/superpowers/skills)
[![Source](https://img.shields.io/badge/Source-obra%2Fsuperpowers-purple)](https://github.com/obra/superpowers)

> **Until [obra/superpowers](https://github.com/obra/superpowers) ships native GitHub Copilot CLI support, this repo packages the full Superpowers skills library using Copilot CLI's native plugin and skills system. All skills are Jesse Vincent's original work — this repo only adds the Copilot CLI wiring.**

## What is Superpowers?

[Superpowers](https://github.com/obra/superpowers) by [Jesse Vincent](https://github.com/obra) is a complete software development workflow for AI coding agents. It transforms how your agent works:

- **Brainstorming** → Refines ideas through questions before writing code
- **Test-Driven Development** → Enforced RED-GREEN-REFACTOR, no exceptions
- **Systematic Debugging** → 4-phase root cause analysis, no random fixes
- **Plan Writing** → Bite-sized tasks with exact file paths and commands
- **Subagent-Driven Development** → Fresh subagent per task with two-stage review
- **Code Review** → Automated review against plan and coding standards

Superpowers already supports Claude Code, Cursor, Codex, Gemini CLI, and OpenCode. **This repo adds GitHub Copilot CLI to that list.**

## Installation

### Method 1 — One command (easiest)

```bash
curl -fsSL https://raw.githubusercontent.com/DwainTR/superpowers-copilot/main/install.sh | bash
```

### Method 2 — Native plugin marketplace

```bash
copilot plugin marketplace add DwainTR/superpowers-copilot
copilot plugin install superpowers@superpowers-copilot
```

### Verify

Start a new Copilot CLI session and run:

```
/skills list
```

You should see all 14 Superpowers skills listed.

## What's Included

### 14 Skills

| Skill | When it activates |
|-------|-------------------|
| **brainstorming** | Before any creative work — creating features, building components |
| **test-driven-development** | When implementing any feature or bugfix, before writing code |
| **systematic-debugging** | When encountering any bug, test failure, or unexpected behavior |
| **writing-plans** | When you have specs for a multi-step task, before touching code |
| **executing-plans** | When executing an implementation plan with human checkpoints |
| **subagent-driven-development** | When executing plans with independent tasks via subagents |
| **dispatching-parallel-agents** | When facing 2+ independent tasks that can be worked on in parallel |
| **requesting-code-review** | Between tasks, to review against plan |
| **receiving-code-review** | When responding to review feedback |
| **verification-before-completion** | Before declaring any fix or feature done |
| **using-git-worktrees** | After design approval, to create isolated workspace |
| **finishing-a-development-branch** | When all tasks complete, to merge/PR/cleanup |
| **writing-skills** | When creating new skills |
| **using-superpowers** | Meta-skill that ensures all other skills are used when relevant |

### 1 Custom Agent

| Agent | Description |
|-------|-------------|
| **code-reviewer** | Senior code reviewer that validates completed work against plans and coding standards |

## Usage

Skills activate automatically when Copilot detects relevance. You can also invoke them explicitly:

```
Use the /brainstorming skill to explore this feature idea
Use the /test-driven-development skill to implement this
Use the /systematic-debugging skill to find the root cause
```

### The Basic Workflow

1. **Brainstorming** → "Let's build a notification system"
2. **Writing Plans** → Agent creates detailed implementation plan
3. **Subagent-Driven Development** → Agent dispatches subagents per task
4. **Test-Driven Development** → Each task follows RED-GREEN-REFACTOR
5. **Code Review** → Automated review after each step
6. **Verification** → Confirm everything works before marking done

## How It Works

This repo follows the exact same patterns as other Copilot CLI plugins:

- **Skills** are stored in `plugins/superpowers/skills/` — each skill has a `SKILL.md` with YAML frontmatter
- **Agents** are stored in `plugins/superpowers/agents/` — Markdown files with agent configuration
- **Marketplace manifest** in `.claude-plugin/marketplace.json` — allows `copilot plugin install`
- **Install script** for one-command setup — clones, symlinks, and configures custom instructions

The install script also adds a snippet to `~/.copilot/copilot-instructions.md` that tells Copilot to check for relevant skills before every task — replicating the session-start hook that Superpowers uses in Claude Code.

## Updating

### Method 1 users

```bash
curl -fsSL https://raw.githubusercontent.com/DwainTR/superpowers-copilot/main/install.sh | bash
```

### Method 2 users

```bash
copilot plugin update superpowers@superpowers-copilot
```

## Uninstalling

```bash
rm -rf ~/.copilot/skills/superpowers
rm -f ~/.copilot/agents/code-reviewer.md
```

And remove the `<!-- superpowers-installed -->` section from `~/.copilot/copilot-instructions.md`.

## Credits

- **[Jesse Vincent](https://github.com/obra)** — Creator of [Superpowers](https://github.com/obra/superpowers). All skills are his original work under MIT License.
- **[DwainTR](https://github.com/DwainTR)** — Copilot CLI packaging and installation tooling.

## License

MIT — Same as the original [obra/superpowers](https://github.com/obra/superpowers/blob/main/LICENSE).
