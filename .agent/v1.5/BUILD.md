# v1.5 Build System

## Quick Build

```powershell
cd C:\Users\globql-local\Documents\projects\mpk-tools-vd-win
.\build\Build.ps1 -Configuration Release
```

**Output:** `dist\output\MPK-Tools-Setup-1.5.0.exe`

## Build Script: build/Build.ps1

**Reads:** VERSION file (1.5.0) — single source of truth  
**Publishes:** 9 .NET 8 WPF apps (self-contained)  
**Stages:** 6 PowerShell launchers with icon files  
**Builds:** Inno Setup installer  
**Output:** Signed .exe at `dist\output\`

## Build Phases

| Phase | Action | Output |
|-------|--------|--------|
| **1. Clean** | Remove dist/staging, dist/output | Fresh staging area |
| **2. Publish Desktop Apps** | `dotnet publish` on 3 desktop pickers (.NET 8-windows) | `dist/staging/Apps/` |
| **3. Publish Feature Apps** | `dotnet publish` on 3 feature modules (.NET 8-windows) | `dist/staging/Apps/` |
| **4. Stage Launchers** | Copy 6 launcher dirs (chrome, edge, vscode, claude, sticky-notes, antigravity) | `dist/staging/Scripts/` |
| **5. Publish Updater** | `dotnet publish` MPK.Updater (.NET 8 console) | `dist/staging/Updater/` |
| **6. Compile Installer** | Call Inno Setup: `iscc MPKTools.iss` | `dist/output/MPK-Tools-Setup-1.5.0.exe` |

## Project Paths

**Desktop Apps (Published as self-contained):**
- `src/desktop/MPK.VsCode.ProfilePicker/VsCodeProfilePicker.csproj` → `dist/staging/Apps/MPK.VsCode.ProfilePicker/`
- `src/desktop/MPK.StickyNotes.ProfilePicker/StickyNotesProfilePicker.csproj` → `dist/staging/Apps/MPK.StickyNotes.ProfilePicker/`
- `src/desktop/MPK.AntiGravity.ProfilePicker/AntigravityProfilePicker.csproj` → `dist/staging/Apps/MPK.AntiGravity.ProfilePicker/`

**Feature Apps:**
- `src/features/MPK.VsCode.ProjectSearch/VsCodeProfileProjectSearch.csproj` → `dist/staging/Apps/MPK.VsCode.ProjectSearch/`
- `src/features/MPK.StickyNotes.TextSearch/StickyNotesProfileTextSearch.csproj` → `dist/staging/Apps/MPK.StickyNotes.TextSearch/`
- `src/features/MPK.AntiGravity.ProjectSearch/AntigravityProfileProjectSearch.csproj` → `dist/staging/Apps/MPK.AntiGravity.ProjectSearch/`

**Launchers (Copied verbatim with shortname dirs):**
- `src/launchers/chrome/` → `dist/staging/Scripts/chrome/`
- `src/launchers/edge/` → `dist/staging/Scripts/edge/`
- `src/launchers/vscode/` → `dist/staging/Scripts/vscode/`
- `src/launchers/claude/` → `dist/staging/Scripts/claude/`
- `src/launchers/sticky-notes/` → `dist/staging/Scripts/sticky-notes/`
- `src/launchers/antigravity/` → `dist/staging/Scripts/antigravity/`

**Updater:**
- `src/tools/MPK.Updater/MPKToolsUpdater.csproj` → `dist/staging/Updater/`

## Installer: packaging/inno/MPKTools.iss

**Key Settings:**
- AppId: `{A3A6FB9E-9775-42DB-95BF-0A9E8D4D2B36}` (preserved for in-place upgrades)
- Install Path: `C:\Program Files\MPK Tools\`
- Source Files: `..\..\dist\staging\*`
- Version: Read from build script (always overrides default 1.5.0)

**Installs:**
- `C:\Program Files\MPK Tools\Apps\` — All WPF applications
- `C:\Program Files\MPK Tools\Scripts\` — All launchers
- `C:\Program Files\MPK Tools\Updater\` — Standalone updater
- Start Menu: All shortcut entries
- Desktop: Optional (unchecked by default)

**Post-Install:**
- Runs `Create-Shortcut.ps1` from each launcher (chrome, edge, vscode, etc.)
- Creates desktop shortcuts with proper icons and hidden PowerShell window

## Build Parameters

```powershell
# Standard release (reads VERSION file)
.\build\Build.ps1 -Configuration Release

# Override version (ignores VERSION file)
.\build\Build.ps1 -Configuration Release -Version 1.5.1

# Skip installer, just stage files
.\build\Build.ps1 -SkipCompileInstaller

# Reuse previously published apps (faster iteration)
.\build\Build.ps1 -ReusePublishedApps
```

## Dependencies

- `.NET SDK 8.0+` — Publish WPF and console apps
- `Inno Setup 6.0+` — Compile installer (iscc.exe must be in PATH)
- `PowerShell 5.1+` — Build script language

## Shared Library Build

**MPK.Profile.Core** (src/shared/) is referenced by all desktop and feature apps:
- Auto-built as transitive dependency during `dotnet publish`
- Not published separately — only as DLL inside each app's output folder

## Key Code in build/Build.ps1

```powershell
# Read version from VERSION file
$version = (Get-Content $versionFile -Raw).Trim()

# Array of desktop app projects (published separately)
$desktopProjects = @(
    "src/desktop/MPK.VsCode.ProfilePicker/VsCodeProfilePicker.csproj",
    ...
)

# Array of feature app projects
$featureProjects = @(
    "src/features/MPK.VsCode.ProjectSearch/VsCodeProfileProjectSearch.csproj",
    ...
)

# Loop and publish each with -SelfContained flag
foreach ($project in $desktopProjects) {
    dotnet publish $project -c $configuration -o "dist/staging/Apps/..." --self-contained
}
```

## Known Issues

- Inno Setup must be in system PATH
- If `.NET 8 runtime` not on target machine, apps fail (but .NET 8 is bundled by build script via `--self-contained`)
- Each launcher's Create-Shortcut.ps1 must be individually executable (PowerShell execution policy)
