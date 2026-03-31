@echo off
REM Superpowers for GitHub Copilot CLI — Windows CMD Installer
REM This wrapper calls install.ps1 with appropriate execution policy.
REM Usage: install.cmd

powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
