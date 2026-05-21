# v1.5 Repository Structure Map

## Root Level Files

```
VERSION                 ← Suite version (1.5.0) — read by build script
README.md               ← User-facing overview
CHANGELOG.md            ← Release history (v1.5.0, v1.1.0)
.gitmodules             ← Submodule path mappings (14 submodules)
.gitignore              ← Excludes dist/, bin/, obj/, *.nupkg, etc.
```

## src/ — Source Code (14 submodules + placeholders)

```
src/
├── desktop/                   ← WPF Profile Picker Applications (3)
│   ├── MPK.VsCode.ProfilePicker/              [submodule]
│   │   ├── MainWindow.xaml                    (grid UI, search, profile cards)
│   │   ├── Views/SettingsWindow.xaml          (directory picker)
│   │   ├── VsCodeProfilePicker.csproj         (.NET 8 WPF, references VsCodeProfileCommon)
│   │   ├── CreateShortcut.ps1                 (generates desktop shortcut)
│   │   ├── app.ico
│   │   ├── docs/glossary.md                   (profile terminology)
│   │   └── README.md
│   │
│   ├── MPK.StickyNotes.ProfilePicker/         [submodule]
│   │   └── Similar structure
│   │
│   └── MPK.AntiGravity.ProfilePicker/         [submodule]
│       └── Similar structure
│
├── features/                  ← App-Specific Feature Modules (3)
│   ├── MPK.VsCode.ProjectSearch/              [submodule]
│   │   ├── MainWindow.xaml                    (project search UI)
│   │   ├── Views/SettingsWindow.xaml
│   │   ├── VsCodeProfileProjectSearch.csproj  (.NET 8 WPF, references VsCodeProfileCommon)
│   │   ├── CreateShortcut.ps1
│   │   ├── app.ico
│   │   └── README.md
│   │
│   ├── MPK.StickyNotes.TextSearch/            [submodule]
│   │   └── Similar structure
│   │
│   └── MPK.AntiGravity.ProjectSearch/         [submodule]
│       └── Similar structure
│
├── launchers/                 ← PowerShell Virtual Desktop Launchers (6 + placeholder)
│   ├── _shared/                               ← Placeholder for shared launcher modules (v1.6 future)
│   │   └── .gitkeep
│   │
│   ├── chrome/                                [submodule]
│   │   ├── Launch-Chrome.ps1                  (~50 lines, detects VD, launches with --user-data-dir)
│   │   ├── Create-Shortcut.ps1                (generates desktop shortcut)
│   │   ├── chrome_desktop.ico
│   │   └── README.md
│   │
│   ├── edge/                                  [submodule]
│   │   └── Similar structure (Launch-Edge.ps1, etc.)
│   │
│   ├── vscode/                                [submodule]
│   │   ├── Launch-VSCode.ps1                  (--user-data-dir + --extensions-dir)
│   │   └── ...
│   │
│   ├── claude/                                [submodule]
│   │   ├── Launch-Claude.ps1                  (opens Windows Terminal in VD-specific dir)
│   │   └── ...
│   │
│   ├── sticky-notes/                          [submodule]
│   │   ├── Launch-StickyNotes.ps1
│   │   └── ...
│   │
│   └── antigravity/                           [submodule]
│       ├── Launch-AntiGravity.ps1
│       └── ...
│
├── shared/                    ← Shared C# Libraries (1)
│   └── MPK.Profile.Core/                      [submodule, namespace: VsCodeProfileCommon]
│       ├── VsCodeProfileCommon/
│       │   ├── Models/
│       │   │   ├── VsCodeProfile.cs
│       │   │   ├── AppSettings.cs
│       │   │   ├── ProjectSearchItem.cs
│       │   │   ├── VsCodeRecentProject.cs
│       │   │   └── RecentProjectsService.cs
│       │   │
│       │   ├── Services/
│       │   │   ├── SettingsService.cs         (registry read/write)
│       │   │   ├── ProfileScanService.cs      (enumerate profile folders)
│       │   │   ├── RecentProjectsService.cs   (parse recent projects from VS Code storage)
│       │   │   ├── ProjectIndexService.cs
│       │   │   └── LoggingService.cs
│       │   │
│       │   ├── Converters/
│       │   │   └── StringToColorBrushConverter.cs  (hex string → WPF SolidColorBrush)
│       │   │
│       │   └── VsCodeProfileCommon.csproj     (.NET 8 class library)
│       │
│       └── README.md
│
└── tools/                     ← Build/Utility Tools (1)
    └── MPK.Updater/                           [submodule]
        ├── Program.cs                         (~400 lines)
        │   ├── GitHub release lookup (gh CLI)
        │   ├── Version comparison logic
        │   ├── Installer download (gh release download)
        │   ├── Silent installer launch (/VERYSILENT /SUPPRESSMSGBOXES /NORESTART)
        │   ├── Registry version detection
        │   └── CLI argument parsing (--repo, --current-version, --silent, etc.)
        │
        └── MPKToolsUpdater.csproj             (.NET 8 console app, no external dependencies)
```

## build/ — Build Orchestration

```
build/
├── Build.ps1                    ← Main build entry point
│   ├── Reads VERSION file
│   ├── Publishes .NET 8 WPF apps as self-contained
│   ├── Stages PowerShell launchers with short names
│   ├── Publishes updater
│   ├── Calls Inno Setup compiler
│   └── Output: dist/output/MPK-Tools-Setup-<version>.exe
│
├── Publish-DesktopApps.ps1      ← (referenced in Build.ps1, could be external script)
├── Publish-Launchers.ps1        ← (referenced in Build.ps1, could be external script)
├── Stage-Installer.ps1          ← (referenced in Build.ps1, could be external script)
└── New-Release.ps1              ← (referenced in Build.ps1, for CI/CD, not yet implemented)
```

**Note:** Currently all build logic is in `Build.ps1`. Helper scripts are suggested in v1.5 proposal but not yet implemented.

## packaging/ — Installer Configuration

```
packaging/
├── inno/
│   ├── MPKTools.iss                 ← Inno Setup script
│   │   ├── Version definition: {#AppVersion}
│   │   ├── Source files: ..\..\dist\staging\*  (relative path fixed for new location)
│   │   ├── Install destination: C:\Program Files\MPK Tools\
│   │   ├── AppId (preserved): {A3A6FB9E-9775-42DB-95BF-0A9E8D4D2B36}
│   │   ├── Start Menu shortcuts (all apps + launchers)
│   │   ├── Desktop shortcuts (optional, unchecked by default)
│   │   ├── Post-install [Run] section: runs each launcher's Create-Shortcut.ps1
│   │   └── Silent install flags: /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
│   │
│   └── assets/                      ← (placeholder for installer assets)
│
└── README.md                    ← Packaging docs (moved from installer/)
```

## docs/ — Documentation

```
docs/
├── README.md                    ← Documentation index
│
├── architecture/                ← v1.5 Restructuring Docs
│   ├── v1.5-restructuring-proposal.md     (design rationale, before/after)
│   ├── MIGRATION-GUIDE-v1.5.md            (step-by-step migration procedure)
│   ├── update-mechanism.md                (moved from feature-updates/)
│   └── (future: architecture diagrams, design decisions)
│
├── guides/                      ← Developer Guides (placeholder)
│   └── .gitkeep
│
├── process/                     ← Operational Docs (placeholder)
│   └── .gitkeep
│
└── versions/
    └── v1.5/
        ├── updates.md               (detailed v1.5 changelog)
        └── docs/                    (v1.5 component documentation - to be populated)
```

## tests/ — Test Suites (Placeholder)

```
tests/
├── desktop/                     ← WPF app tests
│   └── .gitkeep
├── launchers/                   ← Launcher script tests
│   └── .gitkeep
└── shared/                      ← Shared library tests
    └── .gitkeep
```

**Status:** No tests implemented yet. v1.6 priority.

## legacy/ — Archived Code

```
legacy/
└── poc/
    └── virtual-desktop-poc/     [submodule, archived]
        ├── Get-VirtualDesktop.ps1      (registry + COM GUID parsing)
        ├── README.md
        └── (reference only, not built)
```

## dist/ — Build Output (Generated, .gitignore'd)

```
dist/
├── staging/                     ← Intermediate staging directory
│   ├── Apps/
│   │   ├── MPK.VsCode.ProfilePicker/    (self-contained .exe, dlls, runtime)
│   │   ├── MPK.StickyNotes.ProfilePicker/
│   │   ├── MPK.AntiGravity.ProfilePicker/
│   │   ├── MPK.VsCode.ProjectSearch/
│   │   ├── MPK.StickyNotes.TextSearch/
│   │   └── MPK.AntiGravity.ProjectSearch/
│   │
│   ├── Scripts/                 ← Launchers in short-name folders
│   │   ├── chrome/              (Launch-Chrome.ps1, Create-Shortcut.ps1, chrome_desktop.ico)
│   │   ├── edge/
│   │   ├── vscode/
│   │   ├── claude/
│   │   ├── sticky-notes/
│   │   └── antigravity/
│   │
│   └── Updater/
│       └── MPKToolsUpdater.exe  (self-contained)
│
└── output/
    └── MPK-Tools-Setup-1.5.0.exe    ← Final installer
```

---

## Key Design Decisions in v1.5 Layout

1. **Flat submodule roots inside `src/`**
   - Desktop pickers in `src/desktop/` (clear visual grouping)
   - Launchers in `src/launchers/` (natural domain)
   - Shared lib in `src/shared/` (easy to reference)
   - Updater in `src/tools/` (utility tool, not core product)

2. **Clean staging names**
   - Launchers stage to `Scripts/chrome/` not `Scripts/mpk-tools-win-virtual-desktop-chrome-launch/`
   - Apps stage to `Apps/MPK.VsCode.ProfilePicker/` not `Apps/mpk-tools-vscode-profile-picker/`
   - Keeps installer payloads cleaner

3. **Build script reads VERSION**
   - No `-InstallerVersion` parameter required
   - Single source of truth for version number
   - CI/CD can just modify VERSION file

4. **Archive vs Delete**
   - POC archived to `legacy/poc/` (not deleted, can be reference)
   - `tests/` directories kept empty with `.gitkeep` (ready for v1.6)
   - `src/launchers/_shared/` placeholder (reserved for shared engine, v1.6)

5. **Documentation in versions/**
   - `docs/versions/v1.5/` contains v1.5-specific docs
   - Allows versioned history of architecture decisions
   - Future: v1.6 docs go in `docs/versions/v1.6/`
