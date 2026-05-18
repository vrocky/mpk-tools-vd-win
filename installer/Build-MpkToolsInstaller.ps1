#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Configuration = "Release",
    [string]$Runtime = "win-x64",
    [string]$InstallerVersion = "1.1.0",
    [switch]$SkipPublish,
    [switch]$ReusePublishedApps,
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
$updaterRoot = Join-Path $stageRoot "Updater"
$outputRoot = Join-Path $distRoot "output"
$shouldPublishApps = -not ($SkipPublish -or $ReusePublishedApps)
$shouldPublishUpdater = -not $SkipPublish
$updaterProjectPath = Join-Path $scriptRoot "MPKToolsUpdater/MPKToolsUpdater.csproj"

function Remove-PathSafe {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        return
    }

    try {
        Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
    }
    catch {
        Write-Warning "Could not fully remove '$Path'. Continuing build with existing contents. $($_.Exception.Message)"
    }
}

$wpfProjects = @(
    @{ Id = "mpk-tools-antigravity-profile-picker"; Project = "apps/mpk-tools-antigravity-profile-picker/AntigravityProfilePicker.csproj" },
    @{ Id = "mpk-tools-antigravity-profile-project-search"; Project = "apps/mpk-tools-antigravity-profile-project-search/AntigravityProfileProjectSearch.csproj" },
    @{ Id = "mpk-tools-sticky-notes-profile-picker"; Project = "apps/mpk-tools-sticky-notes-profile-picker/StickyNotesProfilePicker.csproj" },
    @{ Id = "mpk-tools-sticky-notes-profile-text-search"; Project = "apps/mpk-tools-sticky-notes-profile-text-search/StickyNotesProfileTextSearch.csproj" },
    @{ Id = "mpk-tools-vscode-profile-picker"; Project = "apps/mpk-tools-vscode-profile-picker/VsCodeProfilePicker.csproj" },
    @{ Id = "mpk-tools-vscode-profile-project-search"; Project = "apps/mpk-tools-vscode-profile-project-search/VsCodeProfileProjectSearch.csproj" }
)

$scriptSourceRoots = @($launchSourceRoot) | Where-Object { Test-Path $_ }
if (@($scriptSourceRoots).Count -eq 0) {
    throw "No launch script source root found. Expected directory: $launchSourceRoot"
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

$scriptAssetFiles = $scriptSourceRoots |
ForEach-Object {
    Get-ChildItem -Path $_ -Recurse -File -Filter "*.ico"
} |
Sort-Object FullName

if (-not $scriptFiles -or $scriptFiles.Count -eq 0) {
    throw "No launcher or shortcut scripts were found to package."
}

if ($shouldPublishApps) {
    Remove-PathSafe -Path $distRoot
}
else {
    Remove-PathSafe -Path $scriptsRoot
    Remove-PathSafe -Path $outputRoot

    if ($shouldPublishUpdater) {
        Remove-PathSafe -Path $updaterRoot
    }
}

New-Item -Path $appsRoot -ItemType Directory -Force | Out-Null
New-Item -Path $scriptsRoot -ItemType Directory -Force | Out-Null
New-Item -Path $updaterRoot -ItemType Directory -Force | Out-Null
New-Item -Path $outputRoot -ItemType Directory -Force | Out-Null

if ($shouldPublishApps) {
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
elseif (-not (Get-ChildItem -Path $appsRoot -Force -ErrorAction SilentlyContinue)) {
    throw "ReusePublishedApps was requested but no staged app outputs were found in $appsRoot"
}

if ($shouldPublishUpdater) {
    if (-not (Test-Path $updaterProjectPath)) {
        throw "Updater project not found: $updaterProjectPath"
    }

    Write-Host "Publishing MPKToolsUpdater..." -ForegroundColor Cyan
    dotnet publish $updaterProjectPath `
        -c $Configuration `
        -r $Runtime `
        --self-contained true `
        -p:PublishSingleFile=true `
        -o $updaterRoot

    if ($LASTEXITCODE -ne 0) {
        throw "dotnet publish failed for $updaterProjectPath"
    }
}

if (-not (Get-ChildItem -Path $updaterRoot -File -ErrorAction SilentlyContinue)) {
    throw "No updater output found in $updaterRoot. Run without -SkipPublish or stage updater artifacts first."
}

foreach ($scriptFile in @($scriptFiles) + @($scriptAssetFiles)) {
    $scriptRelPath = $scriptFile.FullName.Substring($repoRoot.Length + 1)
    $pathSegments = $scriptRelPath -split "[\\/]"
    if ($pathSegments.Length -ge 2 -and $pathSegments[0] -eq "launch") {
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
