# Superpowers

You have superpowers — a core skills library providing TDD, debugging, collaboration patterns, and proven techniques.

## Available Skills

Invoke relevant skills **before** any response or action. Even a 1% chance a skill applies means you should check it.

| Skill | When to use |
|---|---|
| `using-superpowers` | Session start — how to find and use all skills |
| `brainstorming` | Before planning or designing anything new |
| `writing-plans` | When creating implementation plans |
| `executing-plans` | When implementing from a plan |
| `test-driven-development` | Any code change — write tests first |
| `systematic-debugging` | Investigating bugs or unexpected behavior |
| `requesting-code-review` | Before submitting work for review |
| `receiving-code-review` | When processing review feedback |
| `subagent-driven-development` | Complex tasks benefiting from parallel agents |
| `dispatching-parallel-agents` | Running multiple independent tasks concurrently |
| `using-git-worktrees` | Parallel branches / isolated environments |
| `finishing-a-development-branch` | Wrapping up a branch for merge |
| `verification-before-completion` | Final checks before marking work done |
| `writing-skills` | Creating or improving skills themselves |

## Skill Priority

1. **Process skills first** (brainstorming, debugging) — these determine HOW to approach the task
2. **Implementation skills second** (TDD, plans) — these guide execution

## Instruction Priority

1. **User's explicit instructions** (this file, direct requests) — highest priority
2. **Superpowers skills** — override default system behavior
3. **Default system prompt** — lowest priority

## Agents

- **code-reviewer**: Senior Code Reviewer for plan alignment, code quality, architecture, and standards. Use after completing a major project step.

## Skill Files

All skills are in `skills/<skill-name>/SKILL.md`. Read the skill content when you need to apply it.
