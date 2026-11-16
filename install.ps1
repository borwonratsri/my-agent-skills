# ==============================================================================
# Antigravity Skills, Global Rules & Plugins Installer for Windows (PowerShell)
# Repository: https://github.com/borwonratsri/my-agent-skills
#
# Quick 1-Line Install (All Skills + PStack Rigor + Global Rules + 24 Plugins):
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1))) -All
#
# Standard Install (Curated Skills + Global Rules + 24 Plugins):
#   irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1 | iex
# ==============================================================================

[CmdletBinding()]
param(
    [switch]$All = $false,
    [switch]$PStack = $false,
    [switch]$NoRules = $false,
    [switch]$NoPlugins = $false,
    [switch]$NoHooks = $false,
    [switch]$Global = $true,
    [switch]$Workspace = $false,
    [string]$Target = "",
    [switch]$Help = $false
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host @"
Antigravity Skills, Global Rules & Plugins Installer for Windows

Usage:
  install.ps1 [-All] [-PStack] [-NoRules] [-NoPlugins] [-NoHooks] [-Global] [-Workspace] [-Target <dir>]

Options:
  -All        Install all skills (Curated + PStack Rigor) + Global Rules + Hooks + 24 Plugins
  -PStack     Include the 60 isolated PStack Production Rigor skills
  -NoRules    Skip installing Global Rules (~/.gemini/config/rules)
  -NoPlugins  Skip installing Plugins (~/.gemini/config/plugins & config.json registration)
  -NoHooks    Skip installing Global Hooks (~/.gemini/config/hooks.json) & 4-Pillar templates
  -Global     Install to user's global config: ~/.gemini/config (Default)
  -Workspace  Install into current project workspace (./.agents)
  -Target     Install skills to a specific custom directory path
  -Help       Show this help message

Examples:
  # Install everything globally (Recommended):
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1))) -All

  # Install standard skills + Global Rules + Plugins globally:
  irm https://raw.githubusercontent.com/borwonratsri/my-agent-skills/main/install.ps1 | iex
"@
    exit 0
}

# Resolve Target Directories
$UserHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { [System.Environment]::GetFolderPath('UserProfile') }
$UserHomeForward = $UserHome -replace '\\', '/'
$GlobalConfigDir = Join-Path $UserHome ".gemini\config"
$PluginsTargetDir = Join-Path $GlobalConfigDir "plugins"
$GlobalConfigJsonPath = Join-Path $GlobalConfigDir "config.json"

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
Write-Host "   Antigravity Full Setup Installer (Windows)" -ForegroundColor Cyan
Write-Host "   Repository: borwonratsri/my-agent-skills" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "Skills Directory:  $TargetDir" -ForegroundColor Yellow
if (-not $NoRules) {
    Write-Host "Rules Directory:   $RulesTargetDir" -ForegroundColor Yellow
}
if (-not $NoPlugins -and -not $Workspace) {
    Write-Host "Plugins Directory: $PluginsTargetDir" -ForegroundColor Yellow
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
    $PluginsSource = Join-Path $ScriptDir "plugins"
    $PluginsManifestSource = Join-Path $ScriptDir "config\plugins-manifest.json"
} else {
    Write-Host "Downloading latest skill, rules & plugins library from GitHub..." -ForegroundColor Yellow
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
    $PluginsSource = Join-Path $ExtractedRoot "plugins"
    $PluginsManifestSource = Join-Path $ExtractedRoot "config\plugins-manifest.json"
}

try {
    $InstallCount = 0
    $UpdatedCount = 0
    $NewCount = 0
    $RulesCount = 0
    $PluginsCount = 0

    # 1. Install Curated Standard Skills
    Write-Host "`nInstalling Standard Curated Skills:" -ForegroundColor Green
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
        Write-Host "  [OK] $($dir.Name)" -ForegroundColor Green
        $InstallCount++
    }

    # 2. Install PStack Rigor Suite if -All or -PStack is specified
    if ($All -or $PStack) {
        Write-Host "`nInstalling PStack Production Rigor Suite (60 Skills):" -ForegroundColor Cyan
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
                Write-Host "  [OK] $($dir.Name)" -ForegroundColor Cyan
                $InstallCount++
            }
        }
    }

    # 3. Install Global Rules & AGENTS.template.md (unless -NoRules)
    if (-not $NoRules -and (Test-Path $RulesSource)) {
        Write-Host "`nInstalling Global Rules & Skill Playbook Router:" -ForegroundColor Magenta
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
            Write-Host "  [OK] $($ruleFile.Name) -> resolved to $ResolvedGlobalConfig" -ForegroundColor Magenta
            $RulesCount++
        }

        $TemplateSource = Join-Path $RootSource "AGENTS.template.md"
        if (Test-Path $TemplateSource) {
            if (-not (Test-Path $GlobalConfigDir)) {
                New-Item -ItemType Directory -Path $GlobalConfigDir -Force | Out-Null
            }
            $TemplateDest = Join-Path $GlobalConfigDir "AGENTS.template.md"
            Copy-Item -Path $TemplateSource -Destination $TemplateDest -Force
            Write-Host "  [OK] AGENTS.template.md -> $TemplateDest" -ForegroundColor Magenta
        }
    }

    # 4. Install Plugins & Merge into ~/.gemini/config/config.json (unless -NoPlugins or -Workspace)
    if (-not $NoPlugins -and -not $Workspace -and (Test-Path $PluginsSource)) {
        Write-Host "`nInstalling & Registering Antigravity Plugins (24 Plugins):" -ForegroundColor Yellow
        if (-not (Test-Path $PluginsTargetDir)) {
            New-Item -ItemType Directory -Path $PluginsTargetDir -Force | Out-Null
        }

        $PluginDirs = Get-ChildItem -Path $PluginsSource -Directory
        foreach ($pDir in $PluginDirs) {
            $destPluginPath = Join-Path $PluginsTargetDir $pDir.Name
            if (-not (Test-Path $destPluginPath)) {
                New-Item -ItemType Directory -Path $destPluginPath -Force | Out-Null
            }
            Copy-Item -Path (Join-Path $pDir.FullName "*") -Destination $destPluginPath -Recurse -Force
            Write-Host "  [OK] $($pDir.Name)" -ForegroundColor Yellow
            $PluginsCount++
        }

        if (Test-Path $PluginsManifestSource) {
            $manifestData = Get-Content -Path $PluginsManifestSource -Raw -Encoding UTF8 | ConvertFrom-Json
            if (Test-Path $GlobalConfigJsonPath) {
                $existingConfig = Get-Content -Path $GlobalConfigJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
            } else {
                $existingConfig = [PSCustomObject]@{}
            }

            if (-not ($existingConfig.PSObject.Properties.Name -contains "plugins") -or $null -eq $existingConfig.plugins) {
                $existingConfig | Add-Member -MemberType NoteProperty -Name "plugins" -Value ([PSCustomObject]@{}) -Force
            }

            foreach ($prop in $manifestData.plugins.PSObject.Properties) {
                $existingConfig.plugins | Add-Member -MemberType NoteProperty -Name $prop.Name -Value $prop.Value -Force
            }

            $updatedConfigJson = $existingConfig | ConvertTo-Json -Depth 10
            [System.IO.File]::WriteAllText($GlobalConfigJsonPath, $updatedConfigJson, [System.Text.UTF8Encoding]::new($false))
            Write-Host "  [OK] Registered $PluginsCount plugins in $GlobalConfigJsonPath" -ForegroundColor Green
        }
    }

    # 5. Install Global Hooks & Bootstrap 4-Pillar Templates (unless -NoHooks or -Workspace)
    if (-not $NoHooks -and -not $Workspace) {
        $HooksJsonSource = Join-Path $RootSource "hooks.json"
        $HooksDirSource = Join-Path $RootSource "hooks"
        if ((Test-Path $HooksJsonSource) -and (Test-Path $HooksDirSource)) {
            Write-Host "`nInstalling Global Lifecycle Hooks & 4-Pillar Templates:" -ForegroundColor Cyan
            $HooksTargetDir = Join-Path $GlobalConfigDir "hooks"
            if (-not (Test-Path $HooksTargetDir)) {
                New-Item -ItemType Directory -Path $HooksTargetDir -Force | Out-Null
            }
            Copy-Item -Path (Join-Path $HooksDirSource "*.mjs") -Destination $HooksTargetDir -Force
            Copy-Item -Path $HooksJsonSource -Destination (Join-Path $GlobalConfigDir "hooks.json") -Force
            Write-Host "  [OK] hooks.json & hooks/*.mjs -> $GlobalConfigDir" -ForegroundColor Cyan
        }

        # Initialize USER_MEMORY.md only if missing (never overwrite user's live memory)
        $MemoryDest = Join-Path $GlobalConfigDir "USER_MEMORY.md"
        $MemoryTpl = Join-Path $RootSource "config\USER_MEMORY.template.md"
        if (-not (Test-Path $MemoryDest) -and (Test-Path $MemoryTpl)) {
            Copy-Item -Path $MemoryTpl -Destination $MemoryDest -Force
            Write-Host "  [OK] Initialized USER_MEMORY.md from template" -ForegroundColor Cyan
        } elseif (Test-Path $MemoryDest) {
            Write-Host "  [KEEP] Kept existing USER_MEMORY.md intact" -ForegroundColor Gray
        }

        # Initialize knowledge/ drawers + INDEX.md only if missing
        $KnowledgeDir = Join-Path $GlobalConfigDir "knowledge"
        $KnowledgeIndexDest = Join-Path $KnowledgeDir "INDEX.md"
        $KnowledgeIndexTpl = Join-Path $RootSource "config\knowledge-INDEX.template.md"
        foreach ($drawer in @("qa-gmp", "exec-templates", "tech-standards", "prompt-frameworks")) {
            $drawerPath = Join-Path $KnowledgeDir $drawer
            if (-not (Test-Path $drawerPath)) {
                New-Item -ItemType Directory -Path $drawerPath -Force | Out-Null
            }
        }
        if (-not (Test-Path $KnowledgeIndexDest) -and (Test-Path $KnowledgeIndexTpl)) {
            Copy-Item -Path $KnowledgeIndexTpl -Destination $KnowledgeIndexDest -Force
            Write-Host "  [OK] Initialized knowledge/INDEX.md and 4 drawers" -ForegroundColor Cyan
        } elseif (Test-Path $KnowledgeIndexDest) {
            Write-Host "  [KEEP] Kept existing knowledge/INDEX.md intact" -ForegroundColor Gray
        }

        # Merge missing MCP servers from config/mcp_config.template.json into ~/.gemini/config/mcp_config.json
        $McpTpl = Join-Path $RootSource "config\mcp_config.template.json"
        $McpDest = Join-Path $GlobalConfigDir "mcp_config.json"
        if (Test-Path $McpTpl) {
            $tplObj = Get-Content -Path $McpTpl -Raw -Encoding UTF8 | ConvertFrom-Json
            if (Test-Path $McpDest) {
                $destObj = Get-Content -Path $McpDest -Raw -Encoding UTF8 | ConvertFrom-Json
            } else {
                $destObj = [PSCustomObject]@{ mcpServers = [PSCustomObject]@{} }
            }
            if (-not ($destObj.PSObject.Properties.Name -contains "mcpServers") -or $null -eq $destObj.mcpServers) {
                $destObj | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value ([PSCustomObject]@{}) -Force
            }
            foreach ($srv in $tplObj.mcpServers.PSObject.Properties) {
                if (-not ($destObj.mcpServers.PSObject.Properties.Name -contains $srv.Name)) {
                    $destObj.mcpServers | Add-Member -MemberType NoteProperty -Name $srv.Name -Value $srv.Value -Force
                    Write-Host "  [OK] Added MCP server '$($srv.Name)' to mcp_config.json" -ForegroundColor Cyan
                }
            }
            $updatedMcpJson = $destObj | ConvertTo-Json -Depth 10
            [System.IO.File]::WriteAllText($McpDest, $updatedMcpJson, [System.Text.UTF8Encoding]::new($false))
        }
    }

    Write-Host "`n======================================================" -ForegroundColor Green
    Write-Host "Installation & Smart Update Successful!" -ForegroundColor Green
    Write-Host "======================================================" -ForegroundColor Green
    Write-Host "Total Skills Processed: $InstallCount (New: $NewCount, Updated: $UpdatedCount)" -ForegroundColor White
    Write-Host "Total Rules Installed:  $RulesCount" -ForegroundColor Magenta
    Write-Host "Total Plugins Synced:   $PluginsCount" -ForegroundColor Yellow
    Write-Host "Skills Directory:       $TargetDir" -ForegroundColor Cyan
    if (-not $NoRules) {
        Write-Host "Rules Directory:        $RulesTargetDir" -ForegroundColor Cyan
    }
    if (-not $NoPlugins -and -not $Workspace) {
        Write-Host "Plugins Directory:      $PluginsTargetDir" -ForegroundColor Cyan
    }
    Write-Host "`nAll skills, global rules, and plugins are now ready for Antigravity on this machine!`n" -ForegroundColor Green

} finally {
    if ($TempDir -and (Test-Path $TempDir)) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
