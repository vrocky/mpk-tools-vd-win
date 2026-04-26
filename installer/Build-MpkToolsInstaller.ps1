#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Configuration = "Release",
    [string]$Runtime = "win-x64",
    [string]$InstallerVersion = "1.0.0",
    [switch]$SkipPublish,
    [switch]$SkipCompileInstaller
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$appsSourceRoot = Join-Path $repoRoot "apps"
$launchSourceRoot = Join-Path $repoRoot "launch"
$distRoot = Join-Path $scriptRoot "dist"
$stageRoot = Join-Path $distRoot "staging"
$appsRoot = Join-Path $stageRoot "Apps"
$scriptsRoot = Join-Path $stageRoot "Scripts"
$outputRoot = Join-Path $distRoot "output"

$wpfProjects = @(
    @{ Id = "mpk-tools-antigravity-profile-picker"; Project = "apps/mpk-tools-antigravity-profile-picker/AntigravityProfilePicker.csproj" },
    @{ Id = "mpk-tools-antigravity-profile-project-search"; Project = "apps/mpk-tools-antigravity-profile-project-search/AntigravityProfileProjectSearch.csproj" },
    @{ Id = "mpk-tools-sticky-notes-profile-picker"; Project = "apps/mpk-tools-sticky-notes-profile-picker/StickyNotesProfilePicker.csproj" },
    @{ Id = "mpk-tools-sticky-notes-profile-text-search"; Project = "apps/mpk-tools-sticky-notes-profile-text-search/StickyNotesProfileTextSearch.csproj" },
    @{ Id = "mpk-tools-vscode-profile-picker"; Project = "apps/mpk-tools-vscode-profile-picker/VsCodeProfilePicker.csproj" },
    @{ Id = "mpk-tools-vscode-profile-project-search"; Project = "apps/mpk-tools-vscode-profile-project-search/VsCodeProfileProjectSearch.csproj" },
    @{ Id = "mpk-tools-win-virtual-desktop-antigravity-launch"; Project = "launch/mpk-tools-win-virtual-desktop-antigravity-launch/AntigravityProfilePicker.csproj" },
    @{ Id = "mpk-tools-win-virtual-desktop-edge-launch"; Project = "launch/mpk-tools-win-virtual-desktop-edge-launch/EdgeProfilePicker.csproj" },
    @{ Id = "mpk-tools-win-virtual-desktop-sticky-notes-launch"; Project = "apps/mpk-tools-win-virtual-desktop-sticky-notes-launch/StickyNotesProfilePicker.csproj" }
)

$scriptSourceRoots = @($appsSourceRoot, $launchSourceRoot) | Where-Object { Test-Path $_ }
if (-not $scriptSourceRoots -or $scriptSourceRoots.Count -eq 0) {
    throw "No script source roots found. Expected directories: $appsSourceRoot and/or $launchSourceRoot"
}

$scriptFiles = $scriptSourceRoots |
ForEach-Object {
    Get-ChildItem -Path $_ -Recurse -File -Filter "*.ps1"
} |
Where-Object {
    $_.Name -like "Launch-*.ps1" -or
    $_.Name -eq "CreateShortcut.ps1" -or
    $_.Name -eq "Create-Shortcut.ps1"
} |
Sort-Object FullName

if (-not $scriptFiles -or $scriptFiles.Count -eq 0) {
    throw "No launcher or shortcut scripts were found to package."
}

if (Test-Path $distRoot) {
    Remove-Item -Path $distRoot -Recurse -Force
}

New-Item -Path $appsRoot -ItemType Directory -Force | Out-Null
New-Item -Path $scriptsRoot -ItemType Directory -Force | Out-Null
New-Item -Path $outputRoot -ItemType Directory -Force | Out-Null

if (-not $SkipPublish) {
    foreach ($projectInfo in $wpfProjects) {
        $projectPath = Join-Path $repoRoot $projectInfo.Project
        if (-not (Test-Path $projectPath)) {
            throw "Project not found: $projectPath"
        }

        $publishOut = Join-Path $appsRoot $projectInfo.Id

        Write-Host "Publishing $($projectInfo.Id)..." -ForegroundColor Cyan
        dotnet publish $projectPath `
            -c $Configuration `
            -r $Runtime `
            --self-contained true `
            -p:PublishSingleFile=true `
            -p:IncludeNativeLibrariesForSelfExtract=true `
            -o $publishOut

        if ($LASTEXITCODE -ne 0) {
            throw "dotnet publish failed for $projectPath"
        }
    }
}

foreach ($scriptFile in $scriptFiles) {
    $scriptRelPath = $scriptFile.FullName.Substring($repoRoot.Length + 1)
    $pathSegments = $scriptRelPath -split "[\\/]"
    if ($pathSegments.Length -ge 2 -and ($pathSegments[0] -eq "apps" -or $pathSegments[0] -eq "launch")) {
        $targetDir = Join-Path $scriptsRoot $pathSegments[1]
    }
    else {
        $targetDir = Join-Path $scriptsRoot (Split-Path $scriptRelPath -Parent)
    }
    New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
    Copy-Item -Path $scriptFile.FullName -Destination $targetDir -Force
}

$issFile = Join-Path $scriptRoot "MPKTools.iss"
if (-not (Test-Path $issFile)) {
    throw "Inno Setup script not found: $issFile"
}

if (-not $SkipCompileInstaller) {
    $iscc = Get-Command "iscc" -ErrorAction SilentlyContinue
    $isccPath = $null

    if ($iscc) {
        $isccPath = $iscc.Path
    }
    else {
        $candidates = @(
            "C:/Program Files (x86)/Inno Setup 6/ISCC.exe",
            "C:/Program Files/Inno Setup 6/ISCC.exe"
        )

        foreach ($candidate in $candidates) {
            if (Test-Path $candidate) {
                $isccPath = $candidate
                break
            }
        }
    }

    if (-not $isccPath) {
        Write-Warning "Inno Setup compiler (iscc) was not found in PATH."
        Write-Warning "Staging is ready at: $stageRoot"
        Write-Warning "Compile manually in Inno Setup using: $issFile"
        return
    }

    Write-Host "Compiling installer..." -ForegroundColor Cyan
    & $isccPath "/DAppVersion=$InstallerVersion" "/O$outputRoot" $issFile

    if ($LASTEXITCODE -ne 0) {
        throw "Inno Setup compilation failed."
    }

    Write-Host "Installer created in: $outputRoot" -ForegroundColor Green
}
else {
    Write-Host "Staging complete at: $stageRoot" -ForegroundColor Green
}
