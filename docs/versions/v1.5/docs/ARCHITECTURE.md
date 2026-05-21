# v1.5 Architecture

How MPK Tools components fit together and interact.

---

## Monorepo Design

**Why a monorepo?**
- All 14 components work together as one product
- Shared library (MPK.Profile.Core) reduces code duplication
- Single installer distributes everything
- Coordinated releases (version bump in one file affects all)
- Easier refactoring across boundaries

**Why submodules instead of full merge?**
- Each component has its own GitHub repo (independent development)
- Developers working on specific launcher/app can clone just that repo
- Changes to one submodule don't trigger full rebuild of others
- Loose coupling: changes to Chrome launcher don't affect VS Code

**Trade-off:** `.gitmodules` adds complexity, requires `git clone --recursive`

---

## Component Organization

```
src/
├── desktop/          (3 WPF profile picker apps)
│   ├── MPK.VsCode.ProfilePicker
│   ├── MPK.StickyNotes.ProfilePicker
│   └── MPK.AntiGravity.ProfilePicker
│
├── features/         (3 search/utility apps)
│   ├── MPK.VsCode.ProjectSearch
│   ├── MPK.StickyNotes.TextSearch
│   └── MPK.AntiGravity.ProjectSearch
│
├── launchers/        (6 PowerShell VD launchers)
│   ├── chrome/
│   ├── edge/
│   ├── vscode/
│   ├── claude/
│   ├── sticky-notes/
│   ├── antigravity/
│   └── _shared/      (placeholder for v1.6 shared engine)
│
├── shared/           (1 shared C# library)
│   └── MPK.Profile.Core/
│
└── tools/            (1 updater utility)
    └── MPK.Updater/
```

**Rationale:**
- `desktop/` groups profile pickers (similar UI, similar function)
- `features/` groups search utilities that extend pickers
- `launchers/` groups VD detection scripts (similar logic, PowerShell)
- `shared/` centralizes common code (registry, VD detection, profile scanning)
- `tools/` separates utilities from core product

---

## Dependency Graph

```
┌─────────────────────────────────────────────────┐
│ Inno Setup Installer                            │
│ ├─ WPF Apps (9 total, self-contained)           │
│ │  ├─ Profile Pickers (3)                       │
│ │  │  └─ depend on: MPK.Profile.Core            │
│ │  └─ Feature Search Apps (3)                   │
│ │     └─ depend on: MPK.Profile.Core            │
│ ├─ Launchers (6, PowerShell scripts)            │
│ │  └─ detect VD registry directly               │
│ └─ Updater (console app, self-contained)        │
│    └─ no internal dependencies                  │
└─────────────────────────────────────────────────┘

MPK.Profile.Core
├─ Used by: Profile Picker WPF apps (3)
├─ Used by: Feature search apps (3)
└─ Contains: Models, Services, Converters
   ├─ SettingsService → Registry (HKCU:\Software\*)
   ├─ ProfileScanService → File system
   └─ RecentProjectsService → VS Code JSON storage
```

**Key Point:** Launchers do NOT depend on shared library. Each launcher implements VD detection independently (code duplication, but loose coupling).

---

## Data Flow Diagrams

### Launch Path (PowerShell Launcher)

```
User clicks shortcut
    ↓
Launch-Chrome.ps1 (or other launcher)
    ↓
Query Registry: HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
    ↓
Get current desktop GUID (16-byte binary)
    ↓
Lookup GUID in VirtualDesktopIDs (get position: 1, 2, 3, etc.)
    ↓
Create folder: C:\ChromeProfiles\virtual_desktop_[N]\
    ↓
Launch: chrome --user-data-dir "C:\ChromeProfiles\virtual_desktop_[N]\"
    ↓
Chrome reads its user data from isolated folder
```

### Profile Picker Path (WPF App)

```
User opens VS Code Profile Picker (WPF app)
    ↓
MainWindow.xaml initializes
    ↓
ProfileScanService.ScanDirectory("C:\VSCodeProfiles\")
    ↓
For each folder, auto-create user-data\ and extensions\
    ↓
Load profile metadata into VsCodeProfile model
    ↓
Bind to GridView (XAML data binding)
    ↓
Render profile cards with avatars, colors, timestamps
    ↓
User types in search box
    ↓
StringToColorBrushConverter updates UI in real-time
    ↓
User clicks profile card
    ↓
Launch: code --user-data-dir "C:\VSCodeProfiles\[Name]\user-data" --extensions-dir "C:\VSCodeProfiles\[Name]\extensions"
```

### Project Search Path (WPF Feature App)

```
User opens VS Code Project Search
    ↓
ProjectIndexService scans all profiles
    ↓
RecentProjectsService reads recent projects from:
    C:\VSCodeProfiles\[Profile]\user-data\storage.json
    (VS Code's internal recent project cache)
    ↓
Index all projects by name and path
    ↓
User types search query
    ↓
Filter indexed projects in real-time
    ↓
User clicks project
    ↓
Launch: code --user-data-dir "C:\VSCodeProfiles\[CorrectProfile]\user-data" "C:\path\to\project"
```

### Updater Path (Console App)

```
User runs MPKToolsUpdater.exe
    ↓
Read installed version from Registry
    (HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\MPKTools)
    ↓
Call: gh release view --repo "vrocky/mpk-tools-vd-win" --json tagName,body
    ↓
Compare latest version vs installed version
    ↓
If update available, prompt user (or --silent skip prompt)
    ↓
Call: gh release download <tagName> --pattern "MPK-Tools-Setup-*.exe"
    ↓
Run: MPK-Tools-Setup-1.5.1.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
    ↓
Installer runs (Inno Setup)
    ↓
All .NET 8 apps and launchers reinstalled/upgraded
    ↓
Profile data left untouched (stored in C:\*Profiles\, not Program Files)
```

---

## Registry Structure

**Virtual Desktop Detection (all launchers use):**
```
HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
  CurrentVirtualDesktop (REG_BINARY, 16 bytes) — GUID of active desktop
  VirtualDesktopIDs (REG_BINARY, variable) — Concatenated GUIDs of all desktops
```

**VS Code Profile Picker Settings:**
```
HKCU:\Software\VsCodeProfilePicker
  ProfileRoot (REG_SZ) — Root directory to scan (default: "C:\VSCodeProfiles\")
  AutoCreateDirectories (REG_DWORD) — 0 or 1
  CacheTTL (REG_DWORD) — Cache expiry in minutes
  LastScanTime (REG_QWORD) — Timestamp of last profile scan
```

**Application Uninstall Info:**
```
HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\MPKTools
  DisplayVersion (REG_SZ) — Installed version (read by updater)
  DisplayName (REG_SZ) — "MPK Tools"
  UninstallString (REG_SZ) — Path to uninstaller
```

---

## Build & Distribution Pipeline

```
VERSION file (1.5.0)
    ↓
build\Build.ps1 -Configuration Release
    ↓
├─ Publish desktop apps (3) → dist\staging\Apps\
├─ Publish feature apps (3) → dist\staging\Apps\
├─ Copy launchers (6) → dist\staging\Scripts\
├─ Publish updater → dist\staging\Updater\
    ↓
packaging\inno\MPKTools.iss (Inno Setup script)
    ↓
iscc MPKTools.iss
    ↓
dist\output\MPK-Tools-Setup-1.5.0.exe
    ↓
Upload to GitHub Releases (manual or CI/CD)
    ↓
User downloads and runs installer
    ↓
Installs to: C:\Program Files\MPK Tools\
```

**Key:** Build script reads VERSION file once. No manual parameter needed. CI/CD updates VERSION file → automatic version propagation to installer.

---

## Communication Patterns

**WPF App → Registry (Settings Service)**
- Write user preferences: ProfileRoot, CacheTTL
- Read preferences on startup
- Example: User changes profile root in Settings window

**WPF App → File System (Profile Scan Service)**
- Enumerate folders in profile root
- Detect subdirectory structure (user-data/, extensions/)
- Read folder modification times
- Example: Detect new profiles added since last scan

**WPF App → VS Code JSON (Recent Projects Service)**
- Read `storage.json` from VS Code user-data folder
- Parse recent projects list
- Cache in memory (with TTL from registry)
- Example: Project Search app indexes all profiles' recent projects

**Launcher → Registry (Direct)**
- Read VirtualDesktops GUIDs
- Calculate desktop number
- No abstraction layer (inline PowerShell code)
- Example: Launch-Chrome.ps1 reads GUID, launches with correct profile

**Updater → GitHub API (gh CLI)**
- Query latest release
- Download installer asset
- No SDK used (just subprocess calls to `gh`)
- Example: MPKToolsUpdater.exe checks for new version

**Updater → Windows Installer (Inno Setup)**
- Launch installer as subprocess with `/VERYSILENT` flag
- No success/failure feedback (fire-and-forget pattern)
- Example: Silent auto-update during off-hours

---

## Extension Points (v1.6 Opportunities)

**Add a new launcher:**
1. Create new PowerShell script in `src/launchers/[app-name]/`
2. Implement VD detection (copy from existing launcher)
3. Add to `build\Build.ps1` copy step
4. Add entry to `packaging\inno\MPKTools.iss` [Files] and [Run] sections
5. Done (no code changes elsewhere)

**Add a new profile picker app:**
1. Create new WPF project in `src/desktop/[app-name]/`
2. Reference `MPK.Profile.Core`
3. Copy MainWindow.xaml/code-behind from VS Code picker (same pattern)
4. Add to `build\Build.ps1` publish step
5. Add to `.gitmodules` as submodule
6. Add entry to installer

**Extend shared library:**
1. Add new Service to `src/shared/MPK.Profile.Core/Services/`
2. Recompile: `dotnet build`
3. All apps automatically use new version next build

---

## Loosely Coupled Boundaries

**Why launchers don't use shared library:**
- PowerShell lacks C# interop (can't call .NET dll from PS)
- VD detection must be fast (subprocess overhead would be noticeable)
- Each launcher can be modified independently (no rebuild cycle)

**Why desktop apps do use shared library:**
- DLL import is native in C#
- Registry/file I/O is complex enough to centralize
- Consistent behavior across all profile pickers

---

## Design Decisions & Trade-offs

| Decision | Benefit | Trade-off |
|----------|---------|-----------|
| Submodules instead of monolith | Independent repos, loose coupling | git submodule complexity |
| PowerShell launchers instead of .NET | Easier to distribute, no runtime needed | Code duplication across launchers |
| Registry-backed settings | No config files, survives uninstall | Windows-specific, can't migrate to Linux |
| Self-contained .NET apps | No runtime install needed | Larger installer (includes .NET 8 runtime per app) |
| Inno Setup installer | Standard Windows installer, upgrades work | Limited to Windows |
| MCP-style agent docs | Token-efficient, easy to search | Less narrative, more reference-style |

---

Return to [README.md](README.md)
