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

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  MPK Tools Build v$Version" -ForegroundColor Cyan
Write-Host "║  Configuration: $Configuration" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Validate prerequisites
Write-Host "📋 Prerequisites:" -ForegroundColor Cyan
$dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
if (-not $dotnet) {
    Write-Host "  ✗ .NET SDK not found" -ForegroundColor Red
    Write-Error "Install from: https://dotnet.microsoft.com/download/dotnet/8.0"
    exit 1
}

$dotnetVersion = & dotnet --version
Write-Host "  ✓ .NET SDK: $dotnetVersion" -ForegroundColor Green

if ($Only) {
    Write-Host "  ✓ Build mode: Single app ($Only)" -ForegroundColor Green
} elseif ($ForceRebuild) {
    Write-Host "  ✓ Build mode: Force rebuild (all apps)" -ForegroundColor Green
} else {
    Write-Host "  ✓ Build mode: Incremental (changed only)" -ForegroundColor Green
}

Write-Host ""

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

Write-Host "🏗️  Applications:" -ForegroundColor Cyan

foreach ($app in $allApps) {
    if ($Only -and $app.Id -ne $Only) { continue }

    $projPath = Join-Path $repoRoot $app.Project
    if (-not (Test-Path $projPath)) {
        Write-Host "  ✗ $($app.Id)" -ForegroundColor Yellow
        Write-Host "    Project not found: $projPath" -ForegroundColor DarkGray
        continue
    }

    $outDir = Join-Path $appsRoot $app.Id
    if (-not (Should-Republish -ProjectPath $projPath -OutputPath $outDir -Force $ForceRebuild)) {
        Write-Host "  ⊘ $($app.Id)" -ForegroundColor DarkGray
        Write-Host "    (unchanged)" -ForegroundColor DarkGray
        $skippedCount++
        continue
    }

    Write-Host "  ⚙️  $($app.Id)..." -ForegroundColor Cyan
    dotnet publish $projPath -c $Configuration `
        -p:PublishReadyToRun=false `
        -o $outDir 2>&1 | Where-Object { $_ -match "error|warning" } | ForEach-Object { Write-Host "     $_" -ForegroundColor Yellow }

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ✗ $($app.Id) - BUILD FAILED" -ForegroundColor Red
        throw "dotnet publish failed for $projPath"
    }
    Write-Host "  ✓ $($app.Id)" -ForegroundColor Green
    $publishedCount++
}

if (-not (Test-Path $updaterProj)) {
    Write-Host "  ✗ Updater project not found" -ForegroundColor Red
    throw "File not found: $updaterProj"
}

if (Should-Republish -ProjectPath $updaterProj -OutputPath $updaterRoot -Force $ForceRebuild) {
    Write-Host "  ⚙️  MPKToolsUpdater..." -ForegroundColor Cyan
    dotnet publish $updaterProj -c $Configuration -o $updaterRoot 2>&1 | Where-Object { $_ -match "error|warning" } | ForEach-Object { Write-Host "     $_" -ForegroundColor Yellow }
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ✗ MPKToolsUpdater - BUILD FAILED" -ForegroundColor Red
        throw "dotnet publish failed for $updaterProj"
    }
    Write-Host "  ✓ MPKToolsUpdater" -ForegroundColor Green
    $publishedCount++
} else {
    Write-Host "  ⊘ MPKToolsUpdater" -ForegroundColor DarkGray
    Write-Host "    (unchanged)" -ForegroundColor DarkGray
    $skippedCount++
}

$updaterFiles = Get-ChildItem -Path $updaterRoot -File -ErrorAction SilentlyContinue
if (-not $updaterFiles) {
    Write-Host "  ✗ Updater build failed" -ForegroundColor Red
    throw "No output in $updaterRoot (expected MPKToolsUpdater.exe)"
}

Write-Host ""
Write-Host "📋 Build Summary:" -ForegroundColor Cyan
Write-Host "  ✓ Published: $publishedCount" -ForegroundColor Green
Write-Host "  ⊘ Skipped:   $skippedCount (up-to-date)" -ForegroundColor DarkGray
Write-Host ""

Write-Host "📦 Launchers:" -ForegroundColor Cyan
foreach ($launcher in $launcherDirs) {
    $srcPath = Join-Path $repoRoot $launcher.Path
    if (-not (Test-Path $srcPath)) {
        Write-Host "  ⚠️  $($launcher.Id) - source not found" -ForegroundColor Yellow
        continue
    }
    $dstPath = Join-Path $scriptsRoot $launcher.Id
    New-Item -Path $dstPath -ItemType Directory -Force | Out-Null
    Get-ChildItem -Path $srcPath -File |
        Where-Object { $_.Name -like "Launch-*.ps1" -or $_.Name -eq "Create-Shortcut.ps1" -or $_.Extension -eq ".ico" } |
        ForEach-Object { Copy-Item $_.FullName -Destination $dstPath -Force }
    Write-Host "  ✓ $($launcher.Id)" -ForegroundColor Green
}

if (-not (Test-Path $issFile)) {
    Write-Host "  ✗ Inno Setup script not found" -ForegroundColor Red
    throw "File not found: $issFile"
}

Write-Host ""
Write-Host "📦 Installer:" -ForegroundColor Cyan

if (-not $SkipCompileInstaller) {
    $iscc = Get-Command "iscc" -ErrorAction SilentlyContinue
    $isccPath = if ($iscc) { $iscc.Path } else {
        @("C:\Program Files (x86)\Inno Setup 6\ISCC.exe", "C:\Program Files\Inno Setup 6\ISCC.exe") |
            Where-Object { Test-Path $_ } | Select-Object -First 1
    }

    if (-not $isccPath) {
        Write-Host "  ⚠️  Inno Setup not found" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Staging ready at: $stageRoot" -ForegroundColor Green
        Write-Host "  To compile: Download Inno Setup 6, then run:" -ForegroundColor Cyan
        Write-Host "    iscc /DAppVersion=$Version /O$outputRoot $issFile" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Or install via: scoop install inno-setup" -ForegroundColor DarkGray
        return
    }

    Write-Host "  ⚙️  Compiling installer..." -ForegroundColor Cyan
    & $isccPath "/DAppVersion=$Version" "/O$outputRoot" $issFile | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ✗ Installer compilation failed" -ForegroundColor Red
        throw "Inno Setup returned exit code $LASTEXITCODE"
    }

    $installerPath = "$outputRoot\MPK-Tools-Setup-$Version.exe"
    if (Test-Path $installerPath) {
        $installerSize = (Get-Item $installerPath).Length / 1MB
        Write-Host "  ✓ Installer created" -ForegroundColor Green
        Write-Host ""
        Write-Host "✨ Build Complete!" -ForegroundColor Cyan
        Write-Host "   Output: $installerPath" -ForegroundColor Green
        Write-Host "   Size:   $('{0:F1}' -f $installerSize) MB" -ForegroundColor Green
    }
} else {
    Write-Host "  ⊘ Installer compilation skipped (-SkipCompileInstaller)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "✅ Staging Complete!" -ForegroundColor Cyan
    Write-Host "   Ready at: $stageRoot" -ForegroundColor Green
}
