# v1.5 Build System

Complete reference for building and packaging MPK Tools.

---

## Build Pipeline Overview

```
Developer
    ↓
VERSION file (1.5.0)
    ↓
.\build\Build.ps1 -Configuration Release
    ├─ Validate environment (.NET SDK 8, Inno Setup)
    ├─ Read version from VERSION file
    ├─ Clean dist/staging, dist/output
    ├─ Publish 3 desktop WPF apps (self-contained)
    ├─ Publish 3 feature WPF apps (self-contained)
    ├─ Copy 6 launcher PowerShell scripts
    ├─ Publish MPK.Updater console app (self-contained)
    ↓
dist/staging/
    ├─ Apps/ (9 folders, each with exe + dlls + .NET 8 runtime)
    ├─ Scripts/ (6 folders, each with ps1 + icon)
    └─ Updater/ (MPKToolsUpdater.exe)
    ↓
packaging/inno/MPKTools.iss (with version from build script)
    ↓
iscc.exe MPKTools.iss
    ↓
dist/output/MPK-Tools-Setup-1.5.0.exe
    ↓
Upload to GitHub Releases (manual or CI/CD)
```

---

## Entry Point: build/Build.ps1

**Location:** `build/Build.ps1`  
**Language:** PowerShell 5.1+  
**Purpose:** Orchestrate entire build and packaging process

**Command:**
```powershell
.\build\Build.ps1 -Configuration Release
.\build\Build.ps1 -Configuration Release -Version 1.5.1
.\build\Build.ps1 -SkipCompileInstaller
.\build\Build.ps1 -ReusePublishedApps
```

### Phase 1: Initialization

```powershell
# Read version from VERSION file (single source of truth)
$versionFile = Join-Path $rootPath "VERSION"
$version = (Get-Content $versionFile -Raw).Trim()
# Result: "1.5.0"

# Define output paths
$stagingPath = Join-Path $rootPath "dist/staging"
$outputPath = Join-Path $rootPath "dist/output"
```

### Phase 2: Environment Validation

```powershell
# Check .NET SDK available
dotnet --version  # Must be 8.0+

# Check Inno Setup available
iscc.exe --version  # Must be 6.0+

# Create directories
New-Item -ItemType Directory -Force $stagingPath
```

### Phase 3: Project Publishing

**Desktop Applications:**
```powershell
$desktopProjects = @(
    "src/desktop/MPK.VsCode.ProfilePicker/VsCodeProfilePicker.csproj",
    "src/desktop/MPK.StickyNotes.ProfilePicker/StickyNotesProfilePicker.csproj",
    "src/desktop/MPK.AntiGravity.ProfilePicker/AntigravityProfilePicker.csproj"
)

foreach ($project in $desktopProjects) {
    $projectName = Split-Path -Leaf $project
    $projectName = $projectName -replace '\.csproj$', ''
    
    dotnet publish $project `
        -c $Configuration `
        -f net8.0-windows `
        -o "$stagingPath/Apps/$projectName" `
        --self-contained `
        --runtime win-x64
}
```

**Why `--self-contained --runtime win-x64`?**
- User doesn't need .NET 8 runtime installed
- Each app contains its own copy of .NET 8 runtime (larger installer, but zero dependencies on target machine)

**Feature Applications:**
```powershell
$featureProjects = @(
    "src/features/MPK.VsCode.ProjectSearch/VsCodeProfileProjectSearch.csproj",
    "src/features/MPK.StickyNotes.TextSearch/StickyNotesProfileTextSearch.csproj",
    "src/features/MPK.AntiGravity.ProjectSearch/AntigravityProfileProjectSearch.csproj"
)

# Same publish pattern as desktop apps
foreach ($project in $featureProjects) {
    dotnet publish $project -c $Configuration -f net8.0-windows -o "$stagingPath/Apps/$projectName" --self-contained
}
```

**Updater:**
```powershell
$updaterProject = "src/tools/MPK.Updater/MPKToolsUpdater.csproj"

dotnet publish $updaterProject `
    -c $Configuration `
    -f net8.0 `
    -o "$stagingPath/Updater" `
    --self-contained
```

### Phase 4: Launcher Staging

```powershell
$launchers = @("chrome", "edge", "vscode", "claude", "sticky-notes", "antigravity")

foreach ($launcher in $launchers) {
    $srcDir = Join-Path $rootPath "src/launchers/$launcher"
    $dstDir = Join-Path $stagingPath "Scripts/$launcher"
    
    # Copy entire launcher directory
    Copy-Item -Path $srcDir -Destination $dstDir -Recurse -Force
}
```

**What gets copied:**
- `Launch-[App].ps1` — Main launcher script (~50 lines)
- `Create-Shortcut.ps1` — Desktop shortcut generator
- `*.ico` — Application icon
- `README.md` — Documentation

### Phase 5: Installer Compilation

```powershell
if (-not $SkipCompileInstaller) {
    # Update .iss file with current version
    $issFile = Join-Path $rootPath "packaging/inno/MPKTools.iss"
    
    # Inno Setup compiler
    $isccPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    
    & $isccPath /Dversion=$version $issFile
    
    # Output: dist/output/MPK-Tools-Setup-1.5.0.exe
}
```

---

## Installer Configuration: packaging/inno/MPKTools.iss

**Location:** `packaging/inno/MPKTools.iss`  
**Language:** Inno Setup Installer Script  
**Format:** INI-like with sections

### Key Sections

#### [Setup]
```ini
AppId={{A3A6FB9E-9775-42DB-95BF-0A9E8D4D2B36}
; AppId is fixed for in-place upgrades (Windows recognizes same app)

AppName=MPK Tools
AppVersion=1.5.0
; Version is injected by build script: /Dversion=1.5.0

DefaultDirName={pf}\MPK Tools
; {pf} = C:\Program Files\

DefaultGroupName=MPK Tools
; Start Menu folder name

OutputDir=..\..\..\dist\output
OutputBaseFilename=MPK-Tools-Setup-{#version}.exe
; Result: MPK-Tools-Setup-1.5.0.exe

Compression=lzma2
SolidCompression=yes
```

#### [Files]
```ini
; Source paths are relative to .iss location
; Source is ..\..\dist\staging\* because .iss is in packaging/inno/

Source: "..\..\dist\staging\Apps\*"; DestDir: "{app}\Apps"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\dist\staging\Scripts\*"; DestDir: "{app}\Scripts"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\dist\staging\Updater\*"; DestDir: "{app}\Updater"; Flags: ignoreversion recursesubdirs
```

**Variables:**
- `{app}` = `C:\Program Files\MPK Tools\`
- `{pf}` = `C:\Program Files\`
- `{userdesktop}` = User's Desktop folder
- `{userstartmenu}` = User's Start Menu folder

#### [Dirs]
```ini
; Pre-create these directories (rarely needed, usually implicit in [Files])
Name: "{app}\Apps"
Name: "{app}\Scripts"
Name: "{app}\Updater"
```

#### [Icons]
```ini
; Start Menu shortcuts
Name: "{group}\VS Code Profile Picker"; Filename: "{app}\Apps\MPK.VsCode.ProfilePicker\VsCodeProfilePicker.exe"; IconFilename: "{app}\Apps\MPK.VsCode.ProfilePicker\app.ico"
Name: "{group}\Chrome Launcher"; Filename: "{app}\Scripts\chrome\Launch-Chrome.ps1"; IconFilename: "{app}\Scripts\chrome\chrome_desktop.ico"
; ... (more shortcuts)
```

#### [Run]
```ini
; Post-install actions (run Create-Shortcut.ps1 for each launcher)
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\Scripts\chrome\Create-Shortcut.ps1"""; Flags: skipifdoesntexist runascurrentuser

; Repeat for each launcher: edge, vscode, claude, sticky-notes, antigravity
```

**Purpose:** Each launcher can create a desktop shortcut without user intervention.

#### [UninstallRun]
```ini
; Clean up desktop shortcuts on uninstall (optional)
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\Scripts\chrome\Remove-Shortcut.ps1"""; Flags: skipifdoesntexist runascurrentuser
```

---

## Version Management

**Single Source of Truth:**
```
VERSION file
    ↓
read by build\Build.ps1
    ↓
injected into packaging\inno\MPKTools.iss
    ↓
passed to iscc.exe /Dversion=1.5.0
    ↓
embedded in .exe installer
```

**No Manual Parameter Needed:**
```powershell
# Old way (v1.4):
.\build\Build.ps1 -Configuration Release -InstallerVersion 1.5.0

# New way (v1.5):
.\build\Build.ps1 -Configuration Release
# Reads VERSION file automatically
```

**To release v1.5.1:**
1. Edit VERSION file: `1.5.0` → `1.5.1`
2. Commit and tag: `git tag v1.5.1`
3. Run build: `.\build\Build.ps1 -Configuration Release`
4. Upload: `dist/output/MPK-Tools-Setup-1.5.1.exe`

---

## Self-Contained Publishing

**Why `--self-contained`?**

Without:
```
MyApp.exe (100 KB)
  + requires .NET 8 runtime installed (100+ MB)
```

With `--self-contained --runtime win-x64`:
```
MyApp.exe (100 KB)
  + MyApp.dll
  + MyApp.runtimeconfig.json
  + (all of .NET 8 runtime, ~150 MB)
  ───────────────────────────────
  = ~150 MB total in staging/Apps/MyApp/
```

**Trade-off:** Larger installer (150 MB per app × 9 apps = 1.35 GB before compression), but zero runtime dependencies on target machine.

**Optimization:** Inno Setup `Compression=lzma2` + `SolidCompression=yes` reduces final .exe to ~200–300 MB (lots of duplicate .NET 8 runtime code shared across apps).

---

## Build Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `dotnet: not found` | .NET SDK not in PATH | Install .NET SDK 8.0+, restart terminal |
| `iscc.exe: not found` | Inno Setup not in PATH | Install Inno Setup 6.0+, add to PATH |
| `Build.ps1 cannot be loaded` | Execution policy | `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| Files already exist in dist/staging | Stale build | `build\Build.ps1` auto-cleans dist/staging first |
| Submodule not found | Didn't clone recursively | `git clone --recursive ...` or `git submodule update --init --recursive` |

---

## Staging Directory Structure

**After successful build:**

```
dist/staging/
├── Apps/
│   ├── MPK.VsCode.ProfilePicker/
│   │   ├── VsCodeProfilePicker.exe
│   │   ├── VsCodeProfileCommon.dll
│   │   ├── System.*.dll (many, from .NET 8 runtime)
│   │   └── (150 MB total)
│   ├── MPK.StickyNotes.ProfilePicker/
│   ├── MPK.AntiGravity.ProfilePicker/
│   ├── MPK.VsCode.ProjectSearch/
│   ├── MPK.StickyNotes.TextSearch/
│   └── MPK.AntiGravity.ProjectSearch/
│
├── Scripts/
│   ├── chrome/
│   │   ├── Launch-Chrome.ps1
│   │   ├── Create-Shortcut.ps1
│   │   └── chrome_desktop.ico
│   ├── edge/
│   ├── vscode/
│   ├── claude/
│   ├── sticky-notes/
│   └── antigravity/
│
└── Updater/
    └── MPKToolsUpdater.exe
```

**Total size:** ~1.5 GB (before Inno Setup compression)

**Inno Setup compresses to:** ~200–300 MB .exe file

---

## CI/CD Integration (Future)

**For GitHub Actions:**

```yaml
name: Build Release
on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: recursive
      
      - uses: actions/setup-dotnet@v3
        with:
          dotnet-version: 8.0.x
      
      - name: Install Inno Setup
        run: choco install inno-setup -y
      
      - name: Build
        run: .\build\Build.ps1 -Configuration Release
      
      - name: Upload Release Asset
        uses: softprops/action-gh-release@v1
        with:
          files: dist/output/MPK-Tools-Setup-*.exe
```

---

## Build Parameters Reference

```powershell
.\build\Build.ps1 `
    -Configuration Release|Debug          # Debug includes symbols
    -Version 1.5.1                        # Override VERSION file
    -SkipCompileInstaller                 # Stop after staging, don't run iscc
    -ReusePublishedApps                   # Skip dotnet publish, use existing apps/
```

**Default behavior:**
```powershell
.\build\Build.ps1 -Configuration Release
# Reads VERSION file
# Publishes all apps
# Compiles Inno Setup installer
# Output: dist/output/MPK-Tools-Setup-1.5.0.exe
```

---

Return to [README.md](README.md)
