# ==============================================================================
# Antigravity Skills Installer for Windows (PowerShell)
# Repository: https://github.com/borwonratsri/my-agent-skills
#
# Quick 1-Line Install (All 118 Skills - Standard + PStack Rigor):
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1))) -All
#
# Standard Install (58 Curated Skills):
#   irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1 | iex
# ==============================================================================

[CmdletBinding()]
param(
    [switch]$All = $false,
    [switch]$PStack = $false,
    [switch]$Global = $true,
    [switch]$Workspace = $false,
    [string]$Target = "",
    [switch]$Help = $false
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host @"
Antigravity Skills Installer for Windows

Usage:
  install.ps1 [-All] [-PStack] [-Global] [-Workspace] [-Target <dir>]

Options:
  -All        Install all 118 skills (Curated 58 + PStack Rigor 60)
  -PStack     Include the 60 isolated PStack Production Rigor skills
  -Global     Install to user's global config: ~/.gemini/config/skills (Default)
  -Workspace  Install into current project workspace (./.agents/skills)
  -Target     Install to a specific custom directory path
  -Help       Show this help message

Examples:
  # Install all 118 skills globally (Recommended):
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1))) -All

  # Install standard 58 skills globally:
  irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1 | iex
"@
    exit 0
}

# Resolve Target Directory
$UserHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { [System.Environment]::GetFolderPath('UserProfile') }

if ($Target -ne "") {
    $TargetDir = $Target
} elseif ($Workspace) {
    $TargetDir = Join-Path (Get-Location) ".agents\skills"
} else {
    $TargetDir = Join-Path $UserHome ".gemini\config\skills"
}

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "   🚀 Antigravity Skills Installer for Windows" -ForegroundColor Cyan
Write-Host "   Repository: borwonratsri/my-agent-skills" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "Target Directory: $TargetDir" -ForegroundColor Yellow

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

# Determine source location (Local file or GitHub download)
$ScriptDir = $PSScriptRoot
$TempDir = $null

if ($ScriptDir -and (Test-Path (Join-Path $ScriptDir "skills"))) {
    $SkillsSource = Join-Path $ScriptDir "skills"
    $PStackSource = Join-Path $ScriptDir "pstack"
} else {
    Write-Host "Downloading latest skill library from GitHub..." -ForegroundColor Yellow
    $ZipUrl = "https://github.com/borwonratsri/my-agent-skills/archive/refs/heads/main.zip"
    $TempZip = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName() + ".zip")
    $TempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName())

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $ZipUrl -OutFile $TempZip -UseBasicParsing

    Expand-Archive -Path $TempZip -DestinationPath $TempDir -Force
    Remove-Item -Path $TempZip -Force -ErrorAction SilentlyContinue

    $ExtractedRoot = Join-Path $TempDir "my-agent-skills-main"
    $SkillsSource = Join-Path $ExtractedRoot "skills"
    $PStackSource = Join-Path $ExtractedRoot "pstack"
}

try {
    $InstallCount = 0
    $UpdatedCount = 0
    $NewCount = 0

    # 1. Install Curated Standard Skills
    Write-Host "`n📦 Installing Standard Curated Skills (58 Skills):" -ForegroundColor Green
    $SkillDirs = Get-ChildItem -Path $SkillsSource -Directory
    foreach ($dir in $SkillDirs) {
        $destPath = Join-Path $TargetDir $dir.Name
        $isExisting = Test-Path $destPath

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
                $isExisting = Test-Path $destPath

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

    Write-Host "`n======================================================" -ForegroundColor Green
    Write-Host "🎉 Installation & Smart Update Successful!" -ForegroundColor Green
    Write-Host "======================================================" -ForegroundColor Green
    Write-Host "Total Skills Processed: $InstallCount" -ForegroundColor White
    Write-Host "  - Newly Installed:    $NewCount" -ForegroundColor Green
    Write-Host "  - Updated to Latest:  $UpdatedCount" -ForegroundColor Yellow
    Write-Host "Target Directory:       $TargetDir" -ForegroundColor Cyan
    Write-Host "`nExisting Custom Skills in the folder were kept intact." -ForegroundColor Gray
    Write-Host "All skills are now ready to be used by Antigravity in this machine!`n" -ForegroundColor Green

} finally {
    if ($TempDir -and (Test-Path $TempDir)) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
