# Superpowers for GitHub Copilot CLI — Hooks & Feature Parity Design

**Date:** 2026-03-30
**Status:** Implemented
**Author:** nguyenducviet4
**Scope:** Bring superpowers-me to full feature parity with obra/superpowers for GitHub Copilot CLI

See full spec in session workspace: `files/2026-03-30-copilot-cli-hooks-parity-design.md`

## Summary

- 3-layer context protection: copilot-instructions.md + hooks-copilot.json + copilot-plugin.js
- Skills synced with obra v5.0.6
- Version: 5.0.6-copilot.1
- Cross-platform installers: install.sh + install.ps1 + install.cmd
- SDK onSessionStart hook via @github/copilot-sdk
