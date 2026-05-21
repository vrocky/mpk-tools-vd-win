# v1.5 Components Reference

Detailed specification of all 14 submodules in MPK Tools.

---

## Desktop Applications (WPF Profile Pickers)

### 1. VS Code Profile Picker

**Path:** `src/desktop/MPK.VsCode.ProfilePicker/`  
**GitHub:** vrocky/mpk-tools-vscode-profile-picker  
**Type:** WPF Desktop Application  
**Language:** C#  
**Framework:** .NET 8 (net8.0-windows, self-contained)  
**Output:** `VsCodeProfilePicker.exe`  
**Installs To:** `C:\Program Files\MPK Tools\Apps\MPK.VsCode.ProfilePicker\`  
**Status:** ✅ Mature

**Purpose:** Browse, search, and launch named VS Code profiles from a dark-themed grid UI.

**Features:**
- Searchable profile card grid (real-time filtering by profile name)
- Per-profile avatar with auto-generated initials + color derived from name
- Last-modified timestamp on each card
- Dark theme (#1e1e1e background matching VS Code)
- Settings window to add/remove profile root directories (native Windows folder picker)
- Auto-creates `user-data/` and `extensions/` subdirectories on first scan
- Launches VS Code with both `--user-data-dir` and `--extensions-dir` for complete isolation
- Registry-backed settings (HKCU:\Software\VsCodeProfilePicker)

**Profile Structure:**
```
C:\VSCodeProfiles\
├── Work\
│   ├── user-data\
│   └── extensions\
├── Personal\
│   ├── user-data\
│   └── extensions\
└── Python\
    ├── user-data\
    └── extensions\
```

**Key Files:**
- `MainWindow.xaml` — Grid UI, search box, profile cards
- `Views/SettingsWindow.xaml` — Folder picker dialog
- `VsCodeProfilePicker.csproj` — Project file (references VsCodeProfileCommon)
- `CreateShortcut.ps1` — Desktop shortcut generator
- `app.ico` — Application icon

**Dependency:** `src/shared/MPK.Profile.Core` (VsCodeProfileCommon namespace)

---

### 2. Sticky Notes Profile Picker

**Path:** `src/desktop/MPK.StickyNotes.ProfilePicker/`  
**GitHub:** vrocky/mpk-tools-sticky-notes-profile-picker  
**Type:** WPF Desktop Application  
**Language:** C#  
**Framework:** .NET 8 (net8.0-windows, self-contained)  
**Output:** `StickyNotesProfilePicker.exe`  
**Installs To:** `C:\Program Files\MPK Tools\Apps\MPK.StickyNotes.ProfilePicker\`  
**Status:** 🔶 In Progress

**Purpose:** Browse named note collections and launch Sticky Notes into a specific profile.

**Features:** Same pattern as VS Code Profile Picker but tailored for Sticky Notes app.

**Profile Root:** `C:\StickyNotesProfiles\profiles\`

**Key Difference from VS Code:**
- Uses `--profile` and `--data-dir` flags (Sticky Notes API differs from VS Code)
- Profile structure: `C:\StickyNotesProfiles\profiles\[ProfileName]\`

---

### 3. AntiGravity Profile Picker

**Path:** `src/desktop/MPK.AntiGravity.ProfilePicker/`  
**GitHub:** vrocky/mpk-tools-antigravity-profile-picker  
**Type:** WPF Desktop Application  
**Language:** C#  
**Framework:** .NET 8 (net8.0-windows, self-contained)  
**Output:** `AntigravityProfilePicker.exe`  
**Installs To:** `C:\Program Files\MPK Tools\Apps\MPK.AntiGravity.ProfilePicker\`  
**Status:** 🔶 Early/Future

**Purpose:** Browse named profiles and launch AntiGravity browser in isolated environment.

**Profile Root:** `C:\AntiGravityProfiles\`

---

## Feature Modules (WPF Search/Utilities)

### 4. VS Code Project Search

**Path:** `src/features/MPK.VsCode.ProjectSearch/`  
**GitHub:** vrocky/mpk-tools-vscode-profile-project-search  
**Type:** WPF Feature Application  
**Language:** C#  
**Framework:** .NET 8 (net8.0-windows, self-contained)  
**Output:** `VsCodeProfileProjectSearch.exe`  
**Installs To:** `C:\Program Files\MPK Tools\Apps\MPK.VsCode.ProjectSearch\`  
**Status:** ✅ Active

**Purpose:** Search recent projects across all VS Code profiles and launch directly in the correct profile.

**Features:**
- Indexes recent projects from all configured profiles
- Full-text search across project names and paths
- One-click launch opens VS Code in the right profile with that project

**Dependency:** `src/shared/MPK.Profile.Core` (RecentProjectsService)

---

### 5. Sticky Notes Text Search

**Path:** `src/features/MPK.StickyNotes.TextSearch/`  
**GitHub:** vrocky/mpk-tools-sticky-notes-profile-text-search  
**Type:** WPF Feature Application  
**Language:** C#  
**Framework:** .NET 8 (net8.0-windows, self-contained)  
**Output:** `StickyNotesProfileTextSearch.exe`  
**Status:** 🔶 Planned

**Purpose:** Full-text search across all Sticky Notes profiles.

---

### 6. AntiGravity Project Search

**Path:** `src/features/MPK.AntiGravity.ProjectSearch/`  
**GitHub:** vrocky/mpk-tools-antigravity-profile-project-search  
**Type:** WPF Feature Application  
**Language:** C#  
**Framework:** .NET 8  
**Purpose:** Search recent projects across AntiGravity profiles.  
**Status:** 🔶 Early/Future

---

## Virtual Desktop Launchers (PowerShell)

All launchers follow the same pattern:
1. Detect current virtual desktop from Windows Registry
2. Calculate desktop number (1, 2, 3, etc.)
3. Create profile folder if it doesn't exist
4. Launch application with `--user-data-dir` pointing to desktop-specific profile
5. Optional: Create desktop shortcut via `Create-Shortcut.ps1`

### 7. Chrome Launcher

**Path:** `src/launchers/chrome/`  
**GitHub:** vrocky/mpk-tools-win-virtual-desktop-chrome-launch  
**Script:** `Launch-Chrome.ps1` (~50 lines)  
**Profile Root:** `C:\ChromeProfiles\virtual_desktop_[N]\`  
**App Launched:** Google Chrome  
**Status:** ✅ Mature

**Usage:**
```powershell
.\Launch-Chrome.ps1                    # Current desktop
.\Launch-Chrome.ps1 -Desktop 2         # Force Desktop 2
.\Launch-Chrome.ps1 -Url "https://..."  # With URL
```

**Key Files:**
- `Launch-Chrome.ps1` — VD detection + launch logic
- `Create-Shortcut.ps1` — Desktop shortcut generator
- `chrome_desktop.ico` — Icon
- `README.md` — Documentation

---

### 8. Edge Launcher

**Path:** `src/launchers/edge/`  
**GitHub:** vrocky/mpk-tools-win-virtual-desktop-edge-launch  
**Script:** `Launch-Edge.ps1`  
**Profile Root:** `C:\EdgeProfiles\virtual_desktop_[N]\`  
**App Launched:** Microsoft Edge  
**Status:** ✅ Mature

---

### 9. VS Code Launcher

**Path:** `src/launchers/vscode/`  
**GitHub:** vrocky/mpk-tools-win-virtual-desktop-vscode-launch  
**Script:** `Launch-VSCode.ps1`  
**Profile Root:** `C:\VSCodeProfiles\virtual_desktop_[N]\`  
**App Launched:** VS Code  
**Status:** ✅ Mature

**Special Feature:** Sets both `--user-data-dir` and `--extensions-dir` for complete isolation.

---

### 10. Claude Launcher

**Path:** `src/launchers/claude/`  
**GitHub:** vrocky/mpk-tools-win-virtual-desktop-claude-launch  
**Script:** `Launch-Claude.ps1`  
**Profile Root:** `C:\claude-ws\vd-profiles\vd-[N]\`  
**App Launched:** Claude Code CLI in Windows Terminal  
**Status:** ✅ Mature

**Unique Design:**
- Opens Windows Terminal in per-desktop working directory (NOT `--user-data-dir`)
- Claude Code sessions are workspace-scoped, so each desktop gets a different working directory
- Supports `-Resume` flag to continue previous session

**Usage:**
```powershell
.\Launch-Claude.ps1           # New session on current desktop
.\Launch-Claude.ps1 -Resume   # Resume session on current desktop
.\Launch-Claude.ps1 -Desktop 2  # Different desktop
```

---

### 11. Sticky Notes Launcher

**Path:** `src/launchers/sticky-notes/`  
**GitHub:** vrocky/mpk-tools-win-virtual-desktop-sticky-notes-launch  
**Script:** `Launch-StickyNotes.ps1`  
**Profile Root:** `C:\StickyNotesProfiles\profiles\virtual_desktop_[N]\`  
**App Launched:** StickyNotesApp  
**Status:** ✅ Mature

---

### 12. AntiGravity Launcher

**Path:** `src/launchers/antigravity/`  
**GitHub:** vrocky/mpk-tools-win-virtual-desktop-antigravity-launch  
**Script:** `Launch-AntiGravity.ps1`  
**Profile Root:** `C:\AntiGravityProfiles\virtual_desktop_[N]\data`  
**App Launched:** AntiGravity Browser  
**Status:** ✅ Mature

---

## Shared Library

### 13. MPK.Profile.Core

**Path:** `src/shared/MPK.Profile.Core/`  
**GitHub:** vrocky/mpk-tools-mpk-profile-common-libs  
**Type:** C# Class Library  
**Language:** C#  
**Framework:** .NET 8 (net8.0-windows)  
**Namespace:** `VsCodeProfileCommon`  
**Status:** ✅ Active

**Used By:**
- MPK.VsCode.ProfilePicker
- MPK.VsCode.ProjectSearch
- Future: Sticky Notes and AntiGravity pickers

**Contents:**

**Models/**
- `VsCodeProfile.cs` — Profile metadata (name, path, lastModified)
- `AppSettings.cs` — User settings (registry-backed)
- `ProjectSearchItem.cs` — Recent project entry
- `VsCodeRecentProject.cs` — Parsed recent project object
- `RecentProjectsService.cs` — Service for querying recent projects

**Services/**
- `SettingsService.cs` — Registry read/write (HKCU:\Software\VsCodeProfilePicker)
- `ProfileScanService.cs` — Enumerate profile folders, detect structure
- `RecentProjectsService.cs` — Parse recent projects from VS Code JSON storage
- `ProjectIndexService.cs` — Index and search projects across profiles
- `LoggingService.cs` — Debug logging to file or console

**Converters/**
- `StringToColorBrushConverter.cs` — Hex string → WPF SolidColorBrush (for profile avatars)

**Registry Key:**
```
HKCU:\Software\VsCodeProfilePicker
  ProfileRoot (REG_SZ) — Root directory to scan for profiles
  AutoCreateDirectories (REG_DWORD) — 0 or 1
  CacheTTL (REG_DWORD) — Cache expiry in minutes
```

---

## Tools

### 14. MPK.Updater

**Path:** `src/tools/MPK.Updater/`  
**GitHub:** N/A (part of main repo)  
**Type:** Console Application  
**Language:** C#  
**Framework:** .NET 8 (net8.0, self-contained)  
**Output:** `MPKToolsUpdater.exe`  
**Installs To:** `C:\Program Files\MPK Tools\Updater\`  
**Status:** ✅ Active

**Purpose:** Check for and install new versions of MPK Tools from GitHub Releases.

**Functionality:**
1. Reads installed version from Windows Registry (UninstallString DisplayVersion)
2. Queries GitHub Releases via `gh release view --repo "vrocky/mpk-tools-vd-win"`
3. Compares versions (semantic versioning)
4. Prompts user to update (or `--silent` mode)
5. Downloads installer: `gh release download <tagName> --pattern "MPK-Tools-Setup-*.exe"`
6. Launches installer with silent flags: `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-`
7. Verifies installation and cleans up download

**Executable Flags:**
```powershell
MPKToolsUpdater.exe --silent              # No user prompts
MPKToolsUpdater.exe --repo "owner/repo"   # Custom GitHub repo
MPKToolsUpdater.exe --current-version 1.4.0  # Override detected version
MPKToolsUpdater.exe --asset-pattern "*.exe"  # Custom asset pattern
```

**Code Location:** `src/tools/MPK.Updater/Program.cs` (~400 lines)

**Dependencies:**
- GitHub CLI (`gh` command in PATH) — must be authenticated
- Windows Registry access — for version detection

---

## Archived Components

### legacy/poc/virtual-desktop-poc

**Path:** `legacy/poc/virtual-desktop-poc/`  
**GitHub:** vrocky/mpk-tools-win-virtual-desktop-poc  
**Type:** Research / Proof of Concept  
**Language:** PowerShell  
**Status:** 📦 Archived (not built/packaged)

**Purpose:** Virtual desktop detection mechanism experiments (registry GUID parsing + COM IVirtualDesktopManager).

**Useful For:** Reference when implementing VD detection changes. Code may be extracted into `src/shared/` if needed.

---

## Summary Table

| Component | Type | Language | Status | Purpose |
|-----------|------|----------|--------|---------|
| VS Code Profile Picker | WPF | C# | ✅ Mature | Browse/launch named profiles |
| Sticky Notes Picker | WPF | C# | 🔶 In Progress | Browse/launch note collections |
| AntiGravity Picker | WPF | C# | 🔶 Early | Browse/launch browser profiles |
| VS Code Project Search | WPF | C# | ✅ Active | Cross-profile project search |
| Sticky Notes Text Search | WPF | C# | 🔶 Planned | Cross-profile note search |
| AntiGravity Project Search | WPF | C# | 🔶 Early | Cross-profile project search |
| Chrome Launcher | PowerShell | PS | ✅ Mature | VD-aware Chrome launch |
| Edge Launcher | PowerShell | PS | ✅ Mature | VD-aware Edge launch |
| VS Code Launcher | PowerShell | PS | ✅ Mature | VD-aware VS Code launch |
| Claude Launcher | PowerShell | PS | ✅ Mature | VD-aware CLI launch |
| Sticky Notes Launcher | PowerShell | PS | ✅ Mature | VD-aware Sticky Notes launch |
| AntiGravity Launcher | PowerShell | PS | ✅ Mature | VD-aware browser launch |
| MPK.Profile.Core | Library | C# | ✅ Active | Shared registry/profile code |
| MPK.Updater | Console | C# | ✅ Active | Update checker/installer |
