#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Configuration = "Release",
    [string]$Runtime = "win-x64",
    [string]$Version,
    [switch]$SkipPublish,
    [switch]$ReusePublishedApps,
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

$shouldPublishApps    = -not ($SkipPublish -or $ReusePublishedApps)
$shouldPublishUpdater = -not $SkipPublish

if (-not $Version) {
    $versionFile = Join-Path $repoRoot "VERSION"
    $Version = if (Test-Path $versionFile) { (Get-Content $versionFile -Raw).Trim() } else { "1.5.0" }
}

Write-Host "Building MPK Tools v$Version ($Configuration)..." -ForegroundColor Cyan

function Remove-PathSafe {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path $Path)) { return }
    try { Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop }
    catch { Write-Warning "Could not fully remove '$Path'. $($_.Exception.Message)" }
}

$desktopProjects = @(
    @{ Id = "MPK.VsCode.ProfilePicker";      Project = "src\desktop\MPK.VsCode.ProfilePicker\VsCodeProfilePicker.csproj" },
    @{ Id = "MPK.StickyNotes.ProfilePicker"; Project = "src\desktop\MPK.StickyNotes.ProfilePicker\StickyNotesProfilePicker.csproj" },
    @{ Id = "MPK.AntiGravity.ProfilePicker"; Project = "src\desktop\MPK.AntiGravity.ProfilePicker\AntigravityProfilePicker.csproj" }
)

$featureProjects = @(
    @{ Id = "MPK.VsCode.ProjectSearch";      Project = "src\features\MPK.VsCode.ProjectSearch\VsCodeProfileProjectSearch.csproj" },
    @{ Id = "MPK.StickyNotes.TextSearch";    Project = "src\features\MPK.StickyNotes.TextSearch\StickyNotesProfileTextSearch.csproj" },
    @{ Id = "MPK.AntiGravity.ProjectSearch"; Project = "src\features\MPK.AntiGravity.ProjectSearch\AntigravityProfileProjectSearch.csproj" }
)

$allWpfProjects = $desktopProjects + $featureProjects

$launcherDirs = @(
    @{ Id = "chrome";       Path = "src\launchers\chrome" },
    @{ Id = "edge";         Path = "src\launchers\edge" },
    @{ Id = "vscode";       Path = "src\launchers\vscode" },
    @{ Id = "claude";       Path = "src\launchers\claude" },
    @{ Id = "sticky-notes"; Path = "src\launchers\sticky-notes" },
    @{ Id = "antigravity";  Path = "src\launchers\antigravity" }
)

if ($shouldPublishApps) {
    Remove-PathSafe -Path $distRoot
} else {
    Remove-PathSafe -Path $scriptsRoot
    Remove-PathSafe -Path $outputRoot
    if ($shouldPublishUpdater) { Remove-PathSafe -Path $updaterRoot }
}

New-Item -Path $appsRoot    -ItemType Directory -Force | Out-Null
New-Item -Path $scriptsRoot -ItemType Directory -Force | Out-Null
New-Item -Path $updaterRoot -ItemType Directory -Force | Out-Null
New-Item -Path $outputRoot  -ItemType Directory -Force | Out-Null

if ($shouldPublishApps) {
    foreach ($proj in $allWpfProjects) {
        $projPath = Join-Path $repoRoot $proj.Project
        if (-not (Test-Path $projPath)) {
            Write-Warning "Project not found, skipping: $projPath"
            continue
        }
        Write-Host "  Publishing $($proj.Id)..." -ForegroundColor Cyan
        dotnet publish $projPath -c $Configuration -r $Runtime `
            --self-contained true -p:PublishSingleFile=true `
            -p:IncludeNativeLibrariesForSelfExtract=true `
            -o (Join-Path $appsRoot $proj.Id)
        if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed for $projPath" }
    }
} elseif (-not (Get-ChildItem -Path $appsRoot -Force -ErrorAction SilentlyContinue)) {
    throw "ReusePublishedApps was set but no staged outputs found in $appsRoot"
}

if ($shouldPublishUpdater) {
    if (-not (Test-Path $updaterProj)) { throw "Updater project not found: $updaterProj" }
    Write-Host "  Publishing MPKToolsUpdater..." -ForegroundColor Cyan
    dotnet publish $updaterProj -c $Configuration -r $Runtime `
        --self-contained true -p:PublishSingleFile=true -o $updaterRoot
    if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed for $updaterProj" }
}

if (-not (Get-ChildItem -Path $updaterRoot -File -ErrorAction SilentlyContinue)) {
    throw "No updater output in $updaterRoot. Run without -SkipPublish or stage artifacts first."
}

foreach ($launcher in $launcherDirs) {
    $srcPath = Join-Path $repoRoot $launcher.Path
    if (-not (Test-Path $srcPath)) { Write-Warning "Launcher not found, skipping: $srcPath"; continue }
    $dstPath = Join-Path $scriptsRoot $launcher.Id
    New-Item -Path $dstPath -ItemType Directory -Force | Out-Null
    Get-ChildItem -Path $srcPath -File |
        Where-Object { $_.Name -like "Launch-*.ps1" -or $_.Name -eq "CreateShortcut.ps1" -or $_.Name -eq "Create-Shortcut.ps1" -or $_.Extension -eq ".ico" } |
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
