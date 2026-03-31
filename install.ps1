# Superpowers for GitHub Copilot CLI — Windows PowerShell Installer
# Usage: .\install.ps1
# Or:    powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Stop"

$Repo = "nguyenducviet4/superpowers"
$CopilotHome = if ($env:COPILOT_HOME) { $env:COPILOT_HOME } else { "$env:USERPROFILE\.copilot" }
$CacheDir = "$CopilotHome\state\plugin-sources\superpowers"

Write-Host "🦸 Superpowers for GitHub Copilot CLI — Windows Installer" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git is required but not installed." -ForegroundColor Red
    exit 1
}

if (-not (Get-Command copilot -ErrorAction SilentlyContinue)) {
    Write-Host "❌ GitHub Copilot CLI not found in PATH." -ForegroundColor Red
    Write-Host "   Install it first: https://docs.github.com/en/copilot/how-tos/copilot-cli"
    exit 1
}

# Clone or update the source repository
if (Test-Path "$CacheDir\.git") {
    Write-Host "📦 Updating existing source cache..."
    Push-Location $CacheDir
    try {
        git pull --quiet 2>$null
    } catch {
        Write-Host "   Update failed, removing and re-cloning..."
        Pop-Location
        Remove-Item -Recurse -Force $CacheDir
        git clone --quiet "https://github.com/$Repo.git" $CacheDir
    }
    Pop-Location
} else {
    Write-Host "📦 Cloning source repository..."
    $ParentDir = Split-Path $CacheDir -Parent
    if (-not (Test-Path $ParentDir)) {
        New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
    }
    git clone --quiet "https://github.com/$Repo.git" $CacheDir
}

$PluginDir = "$CacheDir\plugins\superpowers"

# Install plugin via native Copilot CLI plugin system
Write-Host "🔌 Installing plugin via Copilot CLI native plugin system..."
copilot plugin install $PluginDir
Write-Host "✅ Plugin installed: superpowers" -ForegroundColor Green

# ─── SDK Hooks Setup ───
$HooksInstalled = $false
if ((Get-Command node -ErrorAction SilentlyContinue) -and (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "🔧 Installing SDK dependencies for hooks..."
    Push-Location $CacheDir
    try {
        npm install --quiet 2>$null
        $HooksInstalled = $true
        Write-Host "✅ SDK hooks dependencies installed" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  SDK install failed — hooks will use fallback mode" -ForegroundColor Yellow
    }
    Pop-Location
} else {
    Write-Host "ℹ️  Node.js not found — skipping SDK hooks (instructions.md fallback active)" -ForegroundColor Yellow
}

# ─── CLI Hooks Configuration ───
$HooksDir = "$CopilotHome\hooks"
if ($HooksInstalled) {
    Write-Host "🔧 Configuring CLI lifecycle hooks..."
    if (-not (Test-Path $HooksDir)) {
        New-Item -ItemType Directory -Path $HooksDir -Force | Out-Null
    }
    $HooksConfig = "$HooksDir\hooks-copilot.json"
    if (-not (Test-Path $HooksConfig)) {
        Copy-Item "$CacheDir\hooks\hooks-copilot.json" $HooksConfig
        Write-Host "✅ CLI hooks configured: preCompact, agentStop" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  CLI hooks already configured."
    }
}

# ─── Custom Instructions (Layer 1 — Static Bootstrap) ───
$InstructionsFile = "$CopilotHome\copilot-instructions.md"
$MarkerStart = "<!-- superpowers-installed -->"
$MarkerEnd = "<!-- /superpowers-installed -->"
$SkillFile = "$PluginDir\skills\using-superpowers\SKILL.md"

# Read the full using-superpowers skill content
if (Test-Path $SkillFile) {
    $SkillContent = Get-Content $SkillFile -Raw
} else {
    $SkillContent = "Error: could not read using-superpowers skill."
}

$InstructionsBlock = @"
$MarkerStart
## Superpowers Skills

<EXTREMELY_IMPORTANT>
You have superpowers.

**Below is the full content of your 'superpowers:using-superpowers' skill - your introduction to using skills. For all other skills, use the skill system:**

$SkillContent
</EXTREMELY_IMPORTANT>

Available skills: brainstorming, test-driven-development, systematic-debugging, writing-plans,
executing-plans, subagent-driven-development, dispatching-parallel-agents, requesting-code-review,
receiving-code-review, verification-before-completion, using-git-worktrees,
finishing-a-development-branch, writing-skills, using-superpowers.

Priority order:
1. Process skills first (brainstorming, debugging) — these determine HOW to approach the task
2. Implementation skills second — these guide execution

"Let's build X" → brainstorming first, then implementation skills.
"Fix this bug" → systematic-debugging first, then domain-specific skills.
$MarkerEnd
"@

if ((Test-Path $InstructionsFile) -and (Select-String -Path $InstructionsFile -Pattern $MarkerStart -Quiet)) {
    Write-Host "🔄 Updating custom instructions with full skill content..."
    $Content = Get-Content $InstructionsFile -Raw
    $Pattern = "(?s)$([regex]::Escape($MarkerStart)).*?$([regex]::Escape($MarkerEnd))"
    $Content = $Content -replace $Pattern, $InstructionsBlock
    Set-Content -Path $InstructionsFile -Value $Content -NoNewline
    Write-Host "✅ Custom instructions updated with full using-superpowers content" -ForegroundColor Green
} else {
    if (-not (Test-Path (Split-Path $InstructionsFile -Parent))) {
        New-Item -ItemType Directory -Path (Split-Path $InstructionsFile -Parent) -Force | Out-Null
    }
    Add-Content -Path $InstructionsFile -Value "`n$InstructionsBlock"
    Write-Host "✅ Custom instructions created: $InstructionsFile" -ForegroundColor Green
}

$SkillCount = (Get-ChildItem "$PluginDir\skills" -Directory).Count

Write-Host ""
Write-Host "🎉 Superpowers installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "   Plugin:  superpowers v5.0.6-copilot.1 ($SkillCount skills + code-reviewer agent)"
if ($HooksInstalled) {
    Write-Host "   Hooks:   ✅ SDK onSessionStart + CLI preCompact/agentStop" -ForegroundColor Green
} else {
    Write-Host "   Hooks:   ⚠️  Fallback mode (copilot-instructions.md only)" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "   Next steps:"
Write-Host "   1. Start a new Copilot CLI session: copilot"
Write-Host "   2. Verify skills:  /skills list"
Write-Host "   3. Verify agent:   /agents"
Write-Host "   4. Try: 'Use the /brainstorming skill to explore an idea'"
Write-Host ""
Write-Host "   To update:    run this script again"
Write-Host "   To uninstall: copilot plugin uninstall superpowers"
Write-Host "                 and remove the $MarkerStart section from $InstructionsFile"
