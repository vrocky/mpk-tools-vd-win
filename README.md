# MPK Tools

**Version:** 1.5.0 — Windows 11

A suite of tools that gives each Windows virtual desktop its own isolated application environment. Switch virtual desktops and your browser, editor, notes, and AI workspace all change with you — different accounts, different projects, different sessions, completely independent.

---

## The Problem It Solves

Windows virtual desktops let you organize running applications into separate workspaces, but every application still shares the same profile. Chrome on Desktop 1 and Chrome on Desktop 2 have the same bookmarks, the same history, the same logged-in accounts. VS Code opens in the same workspace with the same extensions regardless of which desktop you are on.

MPK Tools breaks that coupling. Each virtual desktop gets its own profile directory for every supported application. Switch desktops, and the application that opens is in a completely different context.

---

## How It Works

### Virtual Desktop Detection

Every launcher reads the current virtual desktop from the Windows registry:

```
HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
  CurrentVirtualDesktop  REG_BINARY  (16-byte GUID of the active desktop)
  VirtualDesktopIDs      REG_BINARY  (concatenated GUIDs of all desktops)
```

The GUID of the current desktop is matched against the ordered list to determine its position (Desktop 1, Desktop 2, etc.). That number becomes the profile folder name: `virtual_desktop_1`, `virtual_desktop_2`, and so on.

No third-party libraries or Windows internals are involved — only the public registry and the stable COM interface `IVirtualDesktopManager`.

### Profile Isolation

Each application is launched with flags that point it at a desktop-specific data folder:

| Application | Isolation Mechanism |
|-------------|-------------------|
| Chrome | `--user-data-dir "C:\ChromeProfiles\virtual_desktop_[N]\"` |
| Edge | `--user-data-dir "C:\EdgeProfiles\virtual_desktop_[N]\"` |
| VS Code | `--user-data-dir` + `--extensions-dir` in `C:\VSCodeProfiles\virtual_desktop_[N]\` |
| AntiGravity | `--user-data-dir "C:\AntiGravityProfiles\virtual_desktop_[N]\data"` |
| Sticky Notes | `--profile` + `--data-dir` in `C:\StickyNotesProfiles\profiles\virtual_desktop_[N]\` |
| Claude Code | Working directory `C:\claude-ws\vd-profiles\vd-[N]\` in Windows Terminal |

Profile folders are created automatically on first launch if they do not exist.

---

## What Is Included

MPK Tools has two kinds of components that serve different use cases.

### Virtual Desktop Launchers

PowerShell scripts that auto-detect the current desktop and open the application in the matching profile. No UI — just a shortcut that does the right thing.

| Launcher | What It Opens | Profile per Desktop |
|----------|--------------|-------------------|
| **Chrome** | Google Chrome | `C:\ChromeProfiles\virtual_desktop_[N]\` |
| **Edge** | Microsoft Edge | `C:\EdgeProfiles\virtual_desktop_[N]\` |
| **VS Code** | Visual Studio Code | `C:\VSCodeProfiles\virtual_desktop_[N]\data` + `extensions` |
| **Sticky Notes** | StickyNotesApp | `C:\StickyNotesProfiles\profiles\virtual_desktop_[N]\` |
| **AntiGravity** | AntiGravity browser | `C:\AntiGravityProfiles\virtual_desktop_[N]\data` |
| **Claude Code** | Claude Code CLI in Windows Terminal | `C:\claude-ws\vd-profiles\vd-[N]\` |

Each launcher includes a `Create-Shortcut.ps1` that creates a desktop shortcut (hidden PowerShell window, correct icon) for easy access.

**Example — Chrome launcher parameters:**
```powershell
.\Launch-Chrome.ps1              # uses current virtual desktop
.\Launch-Chrome.ps1 -Desktop 3  # force a specific desktop number
.\Launch-Chrome.ps1 -Url "https://example.com"
```

**Claude Code is different from the others:** it opens Windows Terminal in a per-desktop working directory rather than using a `--user-data-dir` flag, because Claude Code sessions are workspace-scoped. Supports `-Resume` to continue a previous session.

```powershell
.\Launch-Claude.ps1          # new session on current desktop
.\Launch-Claude.ps1 -Resume  # resume session on current desktop
```

---

### Profile Picker Applications (WPF)

GUI applications for managing named profiles — useful when you want more than just numbered desktop slots. Browse, search, and launch named profiles like `Work`, `Personal`, `Python`, `Client-A`.

#### VS Code Profile Picker

A dark-themed WPF application (`#1e1e1e` background matching VS Code) that manages multiple named VS Code environments.

**Features:**
- Searchable profile card grid — filter by name in real time
- Per-profile avatar with auto-generated initials and color derived from the profile name
- Last-modified timestamp on each card
- Settings window to add or remove profile root directories using the native Windows folder picker
- Auto-creates `user-data\` and `extensions\` subdirectories on first scan
- Launches VS Code with both `--user-data-dir` and `--extensions-dir` for complete isolation
- Registry-backed settings — no config files, no environment variables

**Profile folder structure:**
```
C:\VSCodeProfiles\
├── Work\
│   ├── user-data\    (--user-data-dir)
│   └── extensions\   (--extensions-dir)
├── Personal\
│   ├── user-data\
│   └── extensions\
└── Python\
    ├── user-data\
    └── extensions\
```

**Registry key:** `HKCU:\Software\VsCodeProfilePicker`

#### Sticky Notes Profile Picker

Same pattern as VS Code Profile Picker but for StickyNotesApp — browse named note collections and launch into a specific one.

#### AntiGravity Profile Picker

Same pattern for the AntiGravity browser — manage named profiles and launch with a selected one.

---

### Feature Modules

Companion utilities that extend the profile pickers:

| Module | Purpose |
|--------|---------|
| VS Code Project Search | Search recent projects across all VS Code profiles and open directly in the right profile |
| Sticky Notes Text Search | Full-text search across notes in all Sticky Notes profiles |
| AntiGravity Project Search | Search recent projects across AntiGravity profiles |

---

## Requirements

| Component | Requirement |
|-----------|------------|
| OS | Windows 10 or Windows 11 |
| WPF apps | .NET 8 runtime (bundled in installer — no separate install needed) |
| Launchers | PowerShell 5.1 or later |
| Chrome launcher | Chrome installed at default path |
| Edge launcher | Edge installed (pre-installed on Windows 11) |
| VS Code launcher / picker | `code` command in PATH, or path configured in Settings |
| AntiGravity launcher | AntiGravity installed at default path |
| Sticky Notes launcher | StickyNotesApp installed at `C:\Program Files\StickyNotesApp\` |
| Claude launcher | `claudew` on PATH (`npm install -g @anthropic-ai/claude-code`), Windows Terminal (`wt`) |
| Updater | [GitHub CLI](https://cli.github.com/) (`gh`) authenticated |

---

## Install

Download the installer from [Releases](https://github.com/vrocky/mpk-tools-vd-win/releases):

```
MPK-Tools-Setup-1.5.0.exe
```

- Installs to `C:\Program Files\MPK Tools\`
- Creates Start Menu shortcuts for all apps and launchers
- Runs each `Create-Shortcut.ps1` automatically to create desktop shortcuts
- Optional: desktop shortcuts via installer checkbox

After install, set up a launcher shortcut for each application you use. Each shortcut runs silently in the background and opens the app in the right profile automatically.

---

## Update

Run the updater to check for and install new versions:

```
C:\Program Files\MPK Tools\Updater\MPKToolsUpdater.exe
```

The updater queries the latest GitHub release, downloads the installer, and runs it silently. Requires `gh` CLI installed and authenticated. Existing profile data is never touched during upgrades.

---

## Build from Source

**Requirements:** .NET SDK 8+, Inno Setup 6+, PowerShell 5.1+

```powershell
git clone --recursive https://github.com/vrocky/mpk-tools-vd-win.git
cd mpk-tools-vd-win
.\build\Build.ps1 -Configuration Release
```

Output: `dist\output\MPK-Tools-Setup-1.5.0.exe`

Version is read from the `VERSION` file at the repo root. Override:

```powershell
.\build\Build.ps1 -Configuration Release -Version 1.5.1
```

Stage files without compiling the installer:

```powershell
.\build\Build.ps1 -SkipCompileInstaller
# Output at dist\staging\
```

---

## Repository Structure

This repo is a monorepo containing 14 git submodules — one per component.

```
src/
├── desktop/                   WPF profile picker applications
│   ├── MPK.VsCode.ProfilePicker/
│   ├── MPK.StickyNotes.ProfilePicker/
│   └── MPK.AntiGravity.ProfilePicker/
├── features/                  App-specific search utilities
│   ├── MPK.VsCode.ProjectSearch/
│   ├── MPK.StickyNotes.TextSearch/
│   └── MPK.AntiGravity.ProjectSearch/
├── launchers/                 PowerShell virtual desktop launchers
│   ├── chrome/
│   ├── edge/
│   ├── vscode/
│   ├── claude/
│   ├── sticky-notes/
│   └── antigravity/
├── shared/
│   └── MPK.Profile.Core/      Shared registry, profile scan, virtual desktop code
└── tools/
    └── MPK.Updater/           Standalone updater executable

build/                         Build scripts
packaging/inno/                Inno Setup installer configuration
docs/                          Architecture and process documentation
legacy/poc/                    Archived virtual desktop detection POC
dist/                          Build output (not committed)
```

Clone with all submodules:

```bash
git clone --recursive https://github.com/vrocky/mpk-tools-vd-win.git
```

---

## Profile Data Locations

All profile data is stored outside `Program Files` and is never modified by the installer or updater.

| Application | Profile Root |
|-------------|-------------|
| Chrome | `C:\ChromeProfiles\` |
| Edge | `C:\EdgeProfiles\` |
| VS Code (launcher) | `C:\VSCodeProfiles\` |
| VS Code (picker) | Configurable — any directory you register |
| Sticky Notes | `C:\StickyNotesProfiles\` |
| AntiGravity | `C:\AntiGravityProfiles\` |
| Claude Code | `C:\claude-ws\vd-profiles\` |

---

## Documentation

- [`docs/architecture/`](docs/architecture/) — design decisions, v1.5 restructuring rationale, migration guide
- [`CHANGELOG.md`](CHANGELOG.md) — release history
- [`docs/versions/v1.5/updates.md`](docs/versions/v1.5/updates.md) — detailed v1.5 change log
