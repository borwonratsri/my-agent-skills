# ==============================================================================
# Antigravity Skills & Global Rules Installer for Windows (PowerShell)
# Repository: https://github.com/borwonratsri/my-agent-skills
#
# Quick 1-Line Install (All 118 Skills + PStack Rigor + Global Rules):
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1))) -All
#
# Standard Install (58 Curated Skills + Global Rules):
#   irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1 | iex
# ==============================================================================

[CmdletBinding()]
param(
    [switch]$All = $false,
    [switch]$PStack = $false,
    [switch]$NoRules = $false,
    [switch]$Global = $true,
    [switch]$Workspace = $false,
    [string]$Target = "",
    [switch]$Help = $false
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host @"
Antigravity Skills & Global Rules Installer for Windows

Usage:
  install.ps1 [-All] [-PStack] [-NoRules] [-Global] [-Workspace] [-Target <dir>]

Options:
  -All        Install all 118 skills (Curated 58 + PStack Rigor 60) + Global Rules
  -PStack     Include the 60 isolated PStack Production Rigor skills
  -NoRules    Skip installing Global Rules (~/.gemini/config/rules)
  -Global     Install to user's global config: ~/.gemini/config (Default)
  -Workspace  Install into current project workspace (./.agents)
  -Target     Install skills to a specific custom directory path
  -Help       Show this help message

Examples:
  # Install all 118 skills + Global Rules globally (Recommended):
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1))) -All

  # Install standard 58 skills + Global Rules globally:
  irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1 | iex
"@
    exit 0
}

# Resolve Target Directories
$UserHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { [System.Environment]::GetFolderPath('UserProfile') }
$UserHomeForward = $UserHome -replace '\\', '/'
$GlobalConfigDir = Join-Path $UserHome ".gemini\config"

if ($Target -ne "") {
    $TargetDir = $Target
    $RulesTargetDir = Join-Path (Split-Path $Target -Parent) "rules"
} elseif ($Workspace) {
    $TargetDir = Join-Path (Get-Location) ".agents\skills"
    $RulesTargetDir = Join-Path (Get-Location) ".agents\rules"
} else {
    $TargetDir = Join-Path $GlobalConfigDir "skills"
    $RulesTargetDir = Join-Path $GlobalConfigDir "rules"
}

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "   🚀 Antigravity Skills & Rules Installer (Windows)" -ForegroundColor Cyan
Write-Host "   Repository: borwonratsri/my-agent-skills" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "Skills Directory: $TargetDir" -ForegroundColor Yellow
if (-not $NoRules) {
    Write-Host "Rules Directory:  $RulesTargetDir" -ForegroundColor Yellow
}

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

# Determine source location (Local file or GitHub download)
$ScriptDir = $PSScriptRoot
$TempDir = $null

if ($ScriptDir -and (Test-Path (Join-Path $ScriptDir "skills"))) {
    $RootSource = $ScriptDir
    $SkillsSource = Join-Path $ScriptDir "skills"
    $PStackSource = Join-Path $ScriptDir "pstack"
    $RulesSource = Join-Path $ScriptDir "rules"
} else {
    Write-Host "Downloading latest skill & rules library from GitHub..." -ForegroundColor Yellow
    $ZipUrl = "https://github.com/borwonratsri/my-agent-skills/archive/refs/heads/main.zip"
    $TempZip = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName() + ".zip")
    $TempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName())

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $ZipUrl -OutFile $TempZip -UseBasicParsing

    Expand-Archive -Path $TempZip -DestinationPath $TempDir -Force
    Remove-Item -Path $TempZip -Force -ErrorAction SilentlyContinue

    $ExtractedRoot = Join-Path $TempDir "my-agent-skills-main"
    $RootSource = $ExtractedRoot
    $SkillsSource = Join-Path $ExtractedRoot "skills"
    $PStackSource = Join-Path $ExtractedRoot "pstack"
    $RulesSource = Join-Path $ExtractedRoot "rules"
}

try {
    $InstallCount = 0
    $UpdatedCount = 0
    $NewCount = 0
    $RulesCount = 0

    # 1. Install Curated Standard Skills
    Write-Host "`n📦 Installing Standard Curated Skills:" -ForegroundColor Green
    $SkillDirs = Get-ChildItem -Path $SkillsSource -Directory
    foreach ($dir in $SkillDirs) {
        $destPath = Join-Path $TargetDir $dir.Name
        if (-not (Test-Path $destPath)) {
            New-Item -ItemType Directory -Path $destPath -Force | Out-Null
            $NewCount++
        } else {
            $UpdatedCount++
        }

        Copy-Item -Path (Join-Path $dir.FullName "*") -Destination $destPath -Recurse -Force
        Write-Host "  [✓] $($dir.Name)" -ForegroundColor Green
        $InstallCount++
    }

    # 2. Install PStack Rigor Suite if -All or -PStack is specified
    if ($All -or $PStack) {
        Write-Host "`n🛡️ Installing PStack Production Rigor Suite (60 Skills):" -ForegroundColor Cyan
        if (Test-Path $PStackSource) {
            $PStackDirs = Get-ChildItem -Path $PStackSource -Directory
            foreach ($dir in $PStackDirs) {
                $destPath = Join-Path $TargetDir $dir.Name
                if (-not (Test-Path $destPath)) {
                    New-Item -ItemType Directory -Path $destPath -Force | Out-Null
                    $NewCount++
                } else {
                    $UpdatedCount++
                }

                Copy-Item -Path (Join-Path $dir.FullName "*") -Destination $destPath -Recurse -Force
                Write-Host "  [✓] $($dir.Name)" -ForegroundColor Cyan
                $InstallCount++
            }
        }
    }

    # 3. Install Global Rules & AGENTS.template.md (unless -NoRules)
    if (-not $NoRules -and (Test-Path $RulesSource)) {
        Write-Host "`n🧭 Installing Global Rules & Skill Playbook Router:" -ForegroundColor Magenta
        if (-not (Test-Path $RulesTargetDir)) {
            New-Item -ItemType Directory -Path $RulesTargetDir -Force | Out-Null
        }

        $ResolvedGlobalConfig = "$UserHomeForward/.gemini/config"
        $RuleFiles = Get-ChildItem -Path $RulesSource -Filter "*.md" -File
        foreach ($ruleFile in $RuleFiles) {
            $rawContent = Get-Content -Path $ruleFile.FullName -Raw -Encoding UTF8
            $resolvedContent = $rawContent.Replace("~/.gemini/config", $ResolvedGlobalConfig)
            $destRulePath = Join-Path $RulesTargetDir $ruleFile.Name
            [System.IO.File]::WriteAllText($destRulePath, $resolvedContent, [System.Text.UTF8Encoding]::new($false))
            Write-Host "  [✓] $($ruleFile.Name) -> resolved to $ResolvedGlobalConfig" -ForegroundColor Magenta
            $RulesCount++
        }

        $TemplateSource = Join-Path $RootSource "AGENTS.template.md"
        if (Test-Path $TemplateSource) {
            if (-not (Test-Path $GlobalConfigDir)) {
                New-Item -ItemType Directory -Path $GlobalConfigDir -Force | Out-Null
            }
            $TemplateDest = Join-Path $GlobalConfigDir "AGENTS.template.md"
            Copy-Item -Path $TemplateSource -Destination $TemplateDest -Force
            Write-Host "  [✓] AGENTS.template.md -> $TemplateDest" -ForegroundColor Magenta
        }
    }

    Write-Host "`n======================================================" -ForegroundColor Green
    Write-Host "🎉 Installation & Smart Update Successful!" -ForegroundColor Green
    Write-Host "======================================================" -ForegroundColor Green
    Write-Host "Total Skills Processed: $InstallCount (New: $NewCount, Updated: $UpdatedCount)" -ForegroundColor White
    Write-Host "Total Rules Installed:  $RulesCount" -ForegroundColor Magenta
    Write-Host "Skills Directory:       $TargetDir" -ForegroundColor Cyan
    if (-not $NoRules) {
        Write-Host "Rules Directory:        $RulesTargetDir" -ForegroundColor Cyan
    }
    Write-Host "`nAll skills and global rules are now ready for Antigravity on this machine!`n" -ForegroundColor Green

} finally {
    if ($TempDir -and (Test-Path $TempDir)) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
