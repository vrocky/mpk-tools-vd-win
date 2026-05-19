# MPK Tools v1.5 Migration Guide

## Overview

This guide outlines the step-by-step process to migrate from the current structure to the professional v1.5 layout described in `v1.5-restructuring-proposal.md`.

**Current State:** Monorepo with 14 git submodules in `apps/` and `launch/` folders  
**Target State:** Professionally organized `src/`, `build/`, `packaging/`, `docs/` structure

---

## Why v1.5?

1. **Clarity** — Desktop apps, launchers, libraries, and tools are visually separated
2. **Maintainability** — Build scripts are split and more manageable
3. **Scalability** — Easier to add new apps or launchers without confusion
4. **Professionalism** — Clear top-level README, versioning, changelog
5. **DX** — Developers immediately understand what goes where

---

## Migration Steps

### Phase 1: Prepare (No Destructive Changes)

#### 1.1 Create New Directory Structure

```powershell
mkdir -Force src/desktop, src/features, src/launchers/_shared, src/shared, src/tools
mkdir -Force build, packaging/inno, docs/architecture, docs/guides, docs/process
mkdir -Force tests/desktop, tests/launchers, tests/shared
mkdir -Force legacy/poc, dist/staging, dist/output
```

#### 1.2 Create Root-Level Files

**`VERSION`** (at root):
```
1.5.0-rc1
```

**`CHANGELOG.md`** (at root):
```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [1.5.0-rc1] - 2026-05-19

### Changed
- Restructured project layout for clarity and maintainability
- Desktop apps, launchers, and libraries now in separate `src/` subdirectories
- Moved build scripts to dedicated `build/` directory
- Moved installer config to `packaging/inno/`
- Introduced shared launcher module pattern

### Added
- Suite-level versioning (single VERSION file)
- Migration guide for v1.5

## [1.0.0] - (Legacy)
...
```

**`README.md`** (at root):
```markdown
# MPK Tools — Virtual Desktop Profile Manager

A Windows productivity suite that isolates application profiles per virtual desktop.

## Quick Start

### Installation
Download the latest installer from [Releases](https://github.com/vrocky/mpk-tools-vd-win/releases).

### Building from Source
```powershell
cd mpk-tools-vd-win
.\build\Build.ps1 -Configuration Release
```

Output: `dist/output/MPK-Tools-Setup-<version>.exe`

## What's Included

- **Desktop Apps:** VS Code Profile Picker, Sticky Notes Profile Picker
- **Launchers:** Virtual desktop-aware launchers for Chrome, Edge, VS Code, Claude, Sticky Notes, AntiGravity
- **Shared Library:** Virtual desktop detection, profile management, registry integration
- **Updater:** Automatic update mechanism via GitHub Releases

## Architecture

See [`docs/architecture/`](docs/architecture/) for detailed architecture documentation.

## Development

See [`docs/guides/`](docs/guides/) for contribution and development guides.

## License

[Your License Here]
```

---

### Phase 2: Reorganize Submodules

#### 2.1 Plan Submodule Moves

Current → Target mapping:

```
apps/mpk-tools-vscode-profile-picker 
  → src/desktop/MPK.VsCode.ProfilePicker

apps/mpk-tools-sticky-notes-profile-picker 
  → src/desktop/MPK.StickyNotes.ProfilePicker

apps/mpk-tools-antigravity-profile-picker 
  → src/desktop/MPK.AntiGravity.ProfilePicker

apps/mpk-tools-vscode-profile-project-search 
  → src/features/MPK.VsCode.ProjectSearch

apps/mpk-tools-sticky-notes-profile-text-search 
  → src/features/MPK.StickyNotes.TextSearch

apps/mpk-tools-antigravity-profile-project-search 
  → src/features/MPK.AntiGravity.ProjectSearch

launch/mpk-tools-win-virtual-desktop-chrome-launch 
  → src/launchers/chrome

launch/mpk-tools-win-virtual-desktop-edge-launch 
  → src/launchers/edge

launch/mpk-tools-win-virtual-desktop-vscode-launch 
  → src/launchers/vscode

launch/mpk-tools-win-virtual-desktop-claude-launch 
  → src/launchers/claude

launch/mpk-tools-win-virtual-desktop-sticky-notes-launch 
  → src/launchers/sticky-notes

launch/mpk-tools-win-virtual-desktop-antigravity-launch 
  → src/launchers/antigravity

apps/mpk-tools-mpk-profile-common-libs 
  → src/shared/MPK.Profile.Core

installer/MPKToolsUpdater → src/tools/MPK.Updater

apps/mpk-tools-win-virtual-desktop-poc 
  → legacy/poc/virtual-desktop-poc
```

#### 2.2 Update .gitmodules

**IMPORTANT:** Back up the current `.gitmodules` before proceeding.

```powershell
Copy-Item .gitmodules .gitmodules.backup
```

Then use the provided `.gitmodules.v1.5` or manually update `.gitmodules`:

```bash
git config --file=.gitmodules --rename-section submodule."mpk-tools-vscode-profile-picker" submodule."src/desktop/MPK.VsCode.ProfilePicker"
git config --file=.gitmodules --rename-section submodule."..." submodule."..." 
# (repeat for all submodules)
```

**Alternatively:** Replace `.gitmodules` wholesale:

```powershell
Copy-Item .gitmodules.v1.5 .gitmodules
git add .gitmodules
```

#### 2.3 Move Submodule Directories

For each submodule, use `git mv` to preserve history:

```bash
# Example: Move VS Code Profile Picker
git mv apps/mpk-tools-vscode-profile-picker src/desktop/MPK.VsCode.ProfilePicker
git add src/desktop/MPK.VsCode.ProfilePicker

# Repeat for all submodules...
```

#### 2.4 Reinitialize Submodules

After moving all paths in `.gitmodules` and running `git mv`:

```bash
git submodule sync
git submodule update --init --recursive
```

---

### Phase 3: Move Build & Installer Files

#### 3.1 Move Installer Files

```powershell
# Move build script
Move-Item installer/Build-MpkToolsInstaller.ps1 build/Build.ps1

# Move installer config
Move-Item installer/MPKTools.iss packaging/inno/MPKTools.iss

# Move updater source
Move-Item installer/MPKToolsUpdater src/tools/MPK.Updater

# Remove old installer directory (after verification)
Remove-Item installer/ -Recurse -Force
```

#### 3.2 Create Helper Build Scripts

Create `build/Publish-DesktopApps.ps1`:
```powershell
param([string]$Configuration = "Release", [string]$OutputPath = "dist/staging/Apps")

# Publish all WPF desktop apps
$desktopApps = @(
    "src/desktop/MPK.VsCode.ProfilePicker",
    "src/desktop/MPK.StickyNotes.ProfilePicker",
    "src/desktop/MPK.AntiGravity.ProfilePicker"
)

foreach ($app in $desktopApps) {
    if (Test-Path $app) {
        Write-Host "Publishing $app..."
        dotnet publish "$app/*.csproj" -c $Configuration -r win-x64 --self-contained `
            -o "$OutputPath/$(Split-Path $app -Leaf)"
    }
}
```

Create `build/Publish-Launchers.ps1`:
```powershell
param([string]$OutputPath = "dist/staging/Launchers")

# Copy PowerShell launchers
$launcherDirs = @(
    "src/launchers/chrome",
    "src/launchers/edge",
    "src/launchers/vscode",
    "src/launchers/claude",
    "src/launchers/sticky-notes",
    "src/launchers/antigravity"
)

foreach ($launcher in $launcherDirs) {
    if (Test-Path $launcher) {
        $name = Split-Path $launcher -Leaf
        Copy-Item $launcher -Destination "$OutputPath/$name" -Recurse -Force
        Write-Host "Copied $name launcher"
    }
}
```

Create `build/Stage-Installer.ps1`:
```powershell
param([string]$StagingPath = "dist/staging")

Write-Host "Staging files for installer..."

# (Copy logic from current Build-MpkToolsInstaller.ps1)
# This script prepares all files before Inno Setup packaging
```

#### 3.3 Update Main Build Script

Create `build/Build.ps1` that orchestrates the entire process:

```powershell
param(
    [string]$Configuration = "Release",
    [string]$Version,
    [switch]$SkipCompileInstaller
)

$ErrorActionPreference = "Stop"

# Read version from VERSION file if not provided
if (-not $Version) {
    $Version = Get-Content "VERSION" -Raw | ForEach-Object { $_.Trim() }
}

Write-Host "Building MPK Tools v$Version..."

# Run sub-scripts
& "$PSScriptRoot/Publish-DesktopApps.ps1" -Configuration $Configuration
& "$PSScriptRoot/Publish-Launchers.ps1"
& "$PSScriptRoot/Stage-Installer.ps1"

if (-not $SkipCompileInstaller) {
    Write-Host "Compiling installer..."
    $issPath = "packaging/inno/MPKTools.iss"
    
    # Call iscc.exe with version and staging path
    # (Details depend on your Inno Setup configuration)
}

Write-Host "Build complete. Output: dist/output/"
```

---

### Phase 4: Verify & Test

#### 4.1 Verify Directory Structure

```powershell
# Should see this structure:
Get-ChildItem -Directory | Select-Object Name | Sort-Object Name

# Expected:
# .git
# .github (if needed)
# build
# docs
# legacy
# packaging
# src
# tests
# dist
```

#### 4.2 Test Submodule Initialization

```bash
git submodule sync
git submodule update --init --recursive
ls src/desktop/MPK.VsCode.ProfilePicker  # Should not be empty
```

#### 4.3 Test Build Process

```powershell
cd build
.\Build.ps1 -Configuration Release -Version 1.5.0-rc1
# Check: dist/output/MPK-Tools-Setup-1.5.0-rc1.exe exists
```

#### 4.4 Test Installer

On a clean Windows VM:
```powershell
.\MPK-Tools-Setup-1.5.0-rc1.exe
# Verify installation to C:\Program Files\MPK Tools\
# Verify shortcuts created
# Test launching VS Code Profile Picker
```

---

### Phase 5: Create Git Commit

Once everything is verified:

```bash
git add -A
git commit -m "Restructure project to v1.5 layout

- Move desktop apps to src/desktop/
- Move launchers to src/launchers/
- Move shared libraries to src/shared/
- Move build scripts to build/
- Move installer config to packaging/inno/
- Add VERSION and CHANGELOG.md
- Archive POC to legacy/poc/
- Update .gitmodules with new paths

This restructuring improves maintainability without changing product behavior."
```

---

## Rollback Plan

If something goes wrong during migration:

```bash
# Restore backup
git checkout HEAD -- .gitmodules
cp .gitmodules.backup .gitmodules

# Reset submodules
git submodule deinit -a -f
git reset --hard HEAD~1
git submodule update --init --recursive

# Verify old structure is back
ls apps/ launch/
```

---

## Common Issues & Solutions

### Issue 1: Submodule Sync Fails
**Cause:** `git submodule sync` can't find the new paths  
**Solution:**
```bash
git rm -r --cached src/
git submodule sync
git submodule update --init --recursive
```

### Issue 2: Build Script Errors
**Cause:** Hardcoded paths in old build script don't match new layout  
**Solution:** Update all path references in `build/Build.ps1`:
```powershell
# Old:
$apps = Get-ChildItem "apps/" -Directory

# New:
$apps = Get-ChildItem "src/desktop/" -Directory
```

### Issue 3: Installer References Old Paths
**Cause:** `MPKTools.iss` still points to `installer/` paths  
**Solution:** Update paths in Inno Setup script:
```ini
; Old:
Source: "..\installer\MPKToolsUpdater.exe"; ...

; New:
Source: "..\dist\staging\Updater\MPKToolsUpdater.exe"; ...
```

---

## Post-Migration Checklist

- [ ] All directories created
- [ ] VERSION and CHANGELOG.md files added
- [ ] README.md created at root
- [ ] .gitmodules updated and verified
- [ ] All submodules moved with `git mv`
- [ ] Build scripts moved and updated
- [ ] Installer config moved and paths fixed
- [ ] `git submodule sync` and `git submodule update` successful
- [ ] Build runs without errors
- [ ] Installer creates and deploys correctly
- [ ] Test on clean VM passed
- [ ] Git commit created
- [ ] Old backup files cleaned up

---

## Next Steps After v1.5 Migration

1. **Add CI/CD Pipeline**
   - Create `.github/workflows/build.yml` for automated builds
   - Create `.github/workflows/release.yml` for automated releases

2. **Add Tests**
   - Unit tests in `tests/` directories
   - Integration tests for launcher behavior

3. **Implement Shared Launcher Pattern**
   - Create `src/launchers/_shared/` PowerShell modules
   - Refactor each launcher to use common functions

4. **Set Up Semantic Versioning**
   - Automate version bumping based on commits
   - Use tags for releases

5. **Add Documentation**
   - Architecture guide in `docs/architecture/`
   - Developer guide in `docs/guides/`
   - Contributing guidelines

---

## Questions & Support

For issues during migration, refer to:
- `.project.md` — Overall context and architecture
- `v1.5-restructuring-proposal.md` — Detailed design rationale
- Git submodule docs: `git help submodule`
