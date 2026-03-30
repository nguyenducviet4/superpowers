# Superpowers for GitHub Copilot CLI

The complete [Superpowers](https://github.com/obra/superpowers) skills library by [Jesse Vincent](https://github.com/obra), packaged as a native GitHub Copilot CLI plugin.

## Installation

```bash
copilot plugin marketplace add DwainTR/superpowers-copilot
copilot plugin install superpowers@superpowers-copilot
```

## What's Included

### Skills (14)

| Skill | Description |
|-------|-------------|
| `brainstorming` | Collaborative design refinement before any code is written |
| `test-driven-development` | Enforced RED-GREEN-REFACTOR cycle |
| `systematic-debugging` | 4-phase root cause investigation process |
| `writing-plans` | Detailed implementation plans with bite-sized tasks |
| `executing-plans` | Batch execution with human checkpoints |
| `subagent-driven-development` | Fresh subagent per task with two-stage review |
| `dispatching-parallel-agents` | Concurrent subagent workflows for independent problems |
| `requesting-code-review` | Pre-review checklist before submitting changes |
| `receiving-code-review` | How to respond to review feedback |
| `verification-before-completion` | Ensure the fix actually works before declaring done |
| `using-git-worktrees` | Parallel development branches |
| `finishing-a-development-branch` | Merge/PR decision workflow |
| `writing-skills` | Create new skills following best practices |
| `using-superpowers` | Meta-skill: ensures other skills are used when relevant |

### Agents (1)

| Agent | Description |
|-------|-------------|
| `code-reviewer` | Senior code reviewer that validates work against plans and coding standards |

## Usage

Skills activate automatically when Copilot detects a relevant task. You can also invoke them manually:

```
Use the /brainstorming skill to explore this idea
Use the /test-driven-development skill for this feature
Use the /systematic-debugging skill to investigate this bug
```

## Source

All skills are from [obra/superpowers](https://github.com/obra/superpowers) (MIT License).
