#Requires -Version 5.1
<#
.SYNOPSIS
    Build and package MPK Tools with framework-dependent publishing and incremental builds.

.PARAMETER Configuration
    Build configuration: Release or Debug. Default: Release

.PARAMETER Version
    Override version from VERSION file. Default: read from VERSION file

.PARAMETER ForceRebuild
    Force rebuild of all apps, skipping incremental build optimization

.PARAMETER Only
    Build only a specific app by ID (e.g., "MPK.VsCode.ProfilePicker")

.PARAMETER SkipCompileInstaller
    Build apps and stage files, but skip Inno Setup compilation

.EXAMPLE
    .\build\Build.ps1                    # Full build with incremental optimization
    .\build\Build.ps1 -ForceRebuild      # Force rebuild all apps
    .\build\Build.ps1 -Only MPK.VsCode.ProfilePicker -ForceRebuild  # Rebuild one app
    .\build\Build.ps1 -SkipCompileInstaller  # Stage files without installer
#>
[CmdletBinding()]
param(
    [string]$Configuration = "Release",
    [string]$Version,
    [switch]$ForceRebuild,
    [string]$Only,
    [switch]$SkipCompileInstaller
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$buildRoot   = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot    = Split-Path -Parent $buildRoot
$distRoot    = Join-Path $repoRoot "dist"
$stageRoot   = Join-Path $distRoot "staging"
$appsRoot    = Join-Path $stageRoot "Apps"
$scriptsRoot = Join-Path $stageRoot "Scripts"
$updaterRoot = Join-Path $stageRoot "Updater"
$outputRoot  = Join-Path $distRoot "output"
$issFile     = Join-Path $repoRoot "packaging\inno\MPKTools.iss"
$updaterProj = Join-Path $repoRoot "src\tools\MPK.Updater\MPKToolsUpdater.csproj"

if (-not $Version) {
    $versionFile = Join-Path $repoRoot "VERSION"
    $Version = if (Test-Path $versionFile) { (Get-Content $versionFile -Raw).Trim() } else { "1.6.0" }
}

Write-Host "Building MPK Tools v$Version ($Configuration)..." -ForegroundColor Cyan
Write-Host ""

# Validate prerequisites
$dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
if (-not $dotnet) {
    Write-Error ".NET SDK not found. Install from https://dotnet.microsoft.com/download/dotnet/8.0"
    exit 1
}

Write-Host "Using: $(dotnet --version)" -ForegroundColor DarkGray

function Remove-PathSafe {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path $Path)) { return }
    try { Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop }
    catch { Write-Warning "Could not fully remove '$Path'. $($_.Exception.Message)" }
}

function Should-Republish {
    param(
        [Parameter(Mandatory)][string]$ProjectPath,
        [Parameter(Mandatory)][string]$OutputPath,
        [bool]$Force = $false
    )
    if ($Force) { return $true }
    if (-not (Test-Path $OutputPath)) { return $true }

    $sourceNewest = Get-ChildItem -Path (Split-Path $ProjectPath) -Include "*.cs","*.xaml","*.csproj" -Recurse -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $outputNewest = Get-ChildItem -Path $OutputPath -Recurse -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1

    return ($null -eq $sourceNewest -or $null -eq $outputNewest -or $sourceNewest.LastWriteTime -gt $outputNewest.LastWriteTime)
}

$allApps = @(
    @{ Id = "MPK.VsCode.ProfilePicker";      Project = "src\apps\MPK.VsCode.ProfilePicker\VsCodeProfilePicker.csproj" },
    @{ Id = "MPK.StickyNotes.ProfilePicker"; Project = "src\apps\MPK.StickyNotes.ProfilePicker\StickyNotesProfilePicker.csproj" },
    @{ Id = "MPK.AntiGravity.ProfilePicker"; Project = "src\apps\MPK.AntiGravity.ProfilePicker\AntigravityProfilePicker.csproj" },
    @{ Id = "MPK.VsCode.ProjectSearch";      Project = "src\apps\MPK.VsCode.ProjectSearch\VsCodeProfileProjectSearch.csproj" },
    @{ Id = "MPK.StickyNotes.TextSearch";    Project = "src\apps\MPK.StickyNotes.TextSearch\StickyNotesProfileTextSearch.csproj" },
    @{ Id = "MPK.AntiGravity.ProjectSearch"; Project = "src\apps\MPK.AntiGravity.ProjectSearch\AntigravityProfileProjectSearch.csproj" }
)

$launcherDirs = @(
    @{ Id = "chrome";       Path = "src\launchers\chrome" },
    @{ Id = "edge";         Path = "src\launchers\edge" },
    @{ Id = "vscode";       Path = "src\launchers\vscode" },
    @{ Id = "claude";       Path = "src\launchers\claude" },
    @{ Id = "sticky-notes"; Path = "src\launchers\sticky-notes" },
    @{ Id = "antigravity";  Path = "src\launchers\antigravity" }
)

Remove-PathSafe -Path $outputRoot
New-Item -Path $appsRoot    -ItemType Directory -Force | Out-Null
New-Item -Path $scriptsRoot -ItemType Directory -Force | Out-Null
New-Item -Path $updaterRoot -ItemType Directory -Force | Out-Null
New-Item -Path $outputRoot  -ItemType Directory -Force | Out-Null

$publishedCount = 0
$skippedCount = 0

foreach ($app in $allApps) {
    if ($Only -and $app.Id -ne $Only) { continue }

    $projPath = Join-Path $repoRoot $app.Project
    if (-not (Test-Path $projPath)) {
        Write-Warning "Project not found, skipping: $projPath"
        continue
    }

    $outDir = Join-Path $appsRoot $app.Id
    if (-not (Should-Republish -ProjectPath $projPath -OutputPath $outDir -Force $ForceRebuild)) {
        Write-Host "  [$($app.Id)] Up-to-date, skipping" -ForegroundColor DarkGray
        $skippedCount++
        continue
    }

    Write-Host "  Publishing $($app.Id)..." -ForegroundColor Cyan
    dotnet publish $projPath -c $Configuration `
        -p:PublishReadyToRun=false `
        -o $outDir
    if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed for $projPath" }
    $publishedCount++
}

if (-not (Test-Path $updaterProj)) { throw "Updater project not found: $updaterProj" }
if (Should-Republish -ProjectPath $updaterProj -OutputPath $updaterRoot -Force $ForceRebuild) {
    Write-Host "  Publishing MPKToolsUpdater..." -ForegroundColor Cyan
    dotnet publish $updaterProj -c $Configuration -o $updaterRoot
    if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed for $updaterProj" }
    $publishedCount++
} else {
    Write-Host "  [MPKToolsUpdater] Up-to-date, skipping" -ForegroundColor DarkGray
    $skippedCount++
}

if ($publishedCount -gt 0) {
    Write-Host "  Published: $publishedCount apps" -ForegroundColor Green
}
if ($skippedCount -gt 0) {
    Write-Host "  Skipped: $skippedCount apps (up-to-date)" -ForegroundColor DarkGray
}

$updaterFiles = Get-ChildItem -Path $updaterRoot -File -ErrorAction SilentlyContinue
if (-not $updaterFiles) {
    throw "Updater build failed: no output in $updaterRoot (expected MPKToolsUpdater.exe)"
}

foreach ($launcher in $launcherDirs) {
    $srcPath = Join-Path $repoRoot $launcher.Path
    if (-not (Test-Path $srcPath)) { Write-Warning "Launcher not found, skipping: $srcPath"; continue }
    $dstPath = Join-Path $scriptsRoot $launcher.Id
    New-Item -Path $dstPath -ItemType Directory -Force | Out-Null
    Get-ChildItem -Path $srcPath -File |
        Where-Object { $_.Name -like "Launch-*.ps1" -or $_.Name -eq "Create-Shortcut.ps1" -or $_.Extension -eq ".ico" } |
        ForEach-Object { Copy-Item $_.FullName -Destination $dstPath -Force }
}

if (-not (Test-Path $issFile)) { throw "Inno Setup script not found: $issFile" }

if (-not $SkipCompileInstaller) {
    $iscc = Get-Command "iscc" -ErrorAction SilentlyContinue
    $isccPath = if ($iscc) { $iscc.Path } else {
        @("C:\Program Files (x86)\Inno Setup 6\ISCC.exe", "C:\Program Files\Inno Setup 6\ISCC.exe") |
            Where-Object { Test-Path $_ } | Select-Object -First 1
    }

    if (-not $isccPath) {
        Write-Warning "iscc not found. Staging ready at: $stageRoot"
        Write-Warning "Compile manually: $issFile"
        return
    }

    Write-Host "  Compiling installer..." -ForegroundColor Cyan
    & $isccPath "/DAppVersion=$Version" "/O$outputRoot" $issFile
    if ($LASTEXITCODE -ne 0) { throw "Inno Setup compilation failed." }

    Write-Host "Installer: $outputRoot\MPK-Tools-Setup-$Version.exe" -ForegroundColor Green
} else {
    Write-Host "Staging complete: $stageRoot" -ForegroundColor Green
}
