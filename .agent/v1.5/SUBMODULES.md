# v1.5 Submodule Inventory

## Summary
- **Total:** 14 submodules
- **Languages:** C# (7), PowerShell (6)
- **Status:** All pinned to origin/main, no drift, fully synced

## Desktop Applications (WPF, .NET 8)

### 1. src/desktop/MPK.VsCode.ProfilePicker
| Property | Value |
|----------|-------|
| **GitHub** | vrocky/mpk-tools-vscode-profile-picker |
| **Type** | WPF Application |
| **Language** | C# |
| **Framework** | .NET 8 (`net8.0-windows`) |
| **Dependencies** | MPK.Profile.Core (shared lib) |
| **Output** | `VsCodeProfilePicker.exe` (self-contained) |
| **Purpose** | GUI to browse, search, launch named VS Code profiles |
| **Features** | Dark theme (#1e1e1e), searchable grid, profile avatars, registry-backed settings |
| **Installs To** | `C:\Program Files\MPK Tools\Apps\MPK.VsCode.ProfilePicker\` |
| **Status** | ✅ Mature |

### 2. src/desktop/MPK.StickyNotes.ProfilePicker
| Property | Value |
|----------|-------|
| **GitHub** | vrocky/mpk-tools-sticky-notes-profile-picker |
| **Type** | WPF Application |
| **Language** | C# |
| **Framework** | .NET 8 (`net8.0-windows`) |
| **Dependencies** | MPK.Profile.Core |
| **Output** | `StickyNotesProfilePicker.exe` |
| **Purpose** | GUI to launch Sticky Notes with named profile isolation |
| **Installs To** | `C:\Program Files\MPK Tools\Apps\MPK.StickyNotes.ProfilePicker\` |
| **Status** | ✅ In progress |

### 3. src/desktop/MPK.AntiGravity.ProfilePicker
| Property | Value |
|----------|-------|
| **GitHub** | vrocky/mpk-tools-antigravity-profile-picker |
| **Type** | WPF Application |
| **Language** | C# |
| **Framework** | .NET 8 |
| **Dependencies** | MPK.Profile.Core |
| **Output** | `AntigravityProfilePicker.exe` |
| **Purpose** | GUI to launch AntiGravity with named profile isolation |
| **Installs To** | `C:\Program Files\MPK Tools\Apps\MPK.AntiGravity.ProfilePicker\` |
| **Status** | 🔶 Early/Future |

## Feature Modules (WPF, .NET 8)

### 4. src/features/MPK.VsCode.ProjectSearch
| Property | Value |
|----------|-------|
| **GitHub** | vrocky/mpk-tools-vscode-profile-project-search |
| **Type** | WPF Feature App |
| **Language** | C# |
| **Framework** | .NET 8 |
| **Dependencies** | MPK.Profile.Core |
| **Output** | `VsCodeProfileProjectSearch.exe` |
| **Purpose** | Search recent projects across all VS Code profiles, launch in correct profile |
| **Installs To** | `C:\Program Files\MPK Tools\Apps\MPK.VsCode.ProjectSearch\` |
| **Status** | ✅ Active |

### 5. src/features/MPK.StickyNotes.TextSearch
| Property | Value |
|----------|-------|
| **GitHub** | vrocky/mpk-tools-sticky-notes-profile-text-search |
| **Type** | WPF Feature App |
| **Language** | C# |
| **Framework** | .NET 8 |
| **Dependencies** | MPK.Profile.Core |
| **Output** | `StickyNotesProfileTextSearch.exe` |
| **Purpose** | Full-text search across all Sticky Notes profiles |
| **Status** | 🔶 Planned |

### 6. src/features/MPK.AntiGravity.ProjectSearch
| Property | Value |
|----------|-------|
| **GitHub** | vrocky/mpk-tools-antigravity-profile-project-search |
| **Type** | WPF Feature App |
| **Framework** | .NET 8 |
| **Purpose** | Search recent projects across AntiGravity profiles |
| **Status** | 🔶 Early/Future |

## Virtual Desktop Launchers (PowerShell)

### 7-12. src/launchers/* (6 total)

| Launcher | GitHub Repo | Launch Script | Profile Root | App Launched | Status |
|----------|------------|---------------|-------------|--------------|--------|
| **chrome** | mpk-tools-win-virtual-desktop-chrome-launch | Launch-Chrome.ps1 | `C:\ChromeProfiles\` | Chrome | ✅ Mature |
| **edge** | mpk-tools-win-virtual-desktop-edge-launch | Launch-Edge.ps1 | `C:\EdgeProfiles\` | Edge | ✅ Mature |
| **vscode** | mpk-tools-win-virtual-desktop-vscode-launch | Launch-VSCode.ps1 | `C:\VSCodeProfiles\` | VS Code | ✅ Mature |
| **claude** | mpk-tools-win-virtual-desktop-claude-launch | Launch-Claude.ps1 | `C:\claude-ws\vd-profiles\` | Claude Code (CLI) | ✅ Mature |
| **sticky-notes** | mpk-tools-win-virtual-desktop-sticky-notes-launch | Launch-StickyNotes.ps1 | `C:\StickyNotesProfiles\` | Sticky Notes | ✅ Mature |
| **antigravity** | mpk-tools-win-virtual-desktop-antigravity-launch | Launch-AntiGravity.ps1 | `C:\AntiGravityProfiles\` | AntiGravity | ✅ Mature |

**Each launcher includes:**
- `Launch-*.ps1` — VD-aware launcher script
- `Create-Shortcut.ps1` — Creates desktop shortcut
- `.ico` — Icon file
- `README.md` — Usage docs

**Claude launcher is different:**
- Opens Windows Terminal in per-desktop working directory (not a `--user-data-dir`)
- Supports `-Resume` flag to continue previous session
- Uses `claudew` CLI, not a browser or GUI app

## Shared Library

### 13. src/shared/MPK.Profile.Core
| Property | Value |
|----------|-------|
| **GitHub** | vrocky/mpk-tools-mpk-profile-common-libs |
| **Type** | C# Class Library |
| **Language** | C# |
| **Framework** | .NET 8 (`net8.0-windows`) |
| **Namespace** | `VsCodeProfileCommon` |
| **Status** | ✅ Active |

**Contains:**
- `Models/` — VsCodeProfile, AppSettings, ProjectSearchItem, RecentProject
- `Services/` — ProfileScanService, SettingsService, RecentProjectsService, ProjectIndexService, LoggingService
- `Converters/` — StringToColorBrushConverter

**Used by:**
- MPK.VsCode.ProfilePicker (WPF)
- MPK.VsCode.ProjectSearch (WPF)
- Future Sticky Notes and AntiGravity pickers

**Key capability:** Registry-backed persistence (`HKCU:\Software\VsCodeProfilePicker`)

## Tools

### 14. src/tools/MPK.Updater
| Property | Value |
|----------|-------|
| **Type** | Console Application |
| **Language** | C# |
| **Framework** | .NET 8 (`net8.0`) |
| **Output** | `MPKToolsUpdater.exe` (self-contained) |
| **Installs To** | `C:\Program Files\MPK Tools\Updater\` |
| **Dependencies** | GitHub CLI (`gh` in PATH) |
| **Status** | ✅ Active |

**Functionality:**
1. Reads installed version from Windows Registry (UninstallString DisplayVersion)
2. Queries GitHub Releases via `gh release view`
3. Downloads installer asset via `gh release download`
4. Runs installer with `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-`
5. Supports `--silent` mode (no user prompt)
6. Supports custom `--repo`, `--asset-pattern`, `--current-version` flags

**Code location:** `src/tools/MPK.Updater/Program.cs` (~400 lines)

## Archived

### Archive: legacy/poc/virtual-desktop-poc
| Property | Value |
|----------|-------|
| **GitHub** | vrocky/mpk-tools-win-virtual-desktop-poc |
| **Type** | Research / POC |
| **Language** | PowerShell |
| **Purpose** | Virtual desktop detection mechanism experiments (registry + COM) |
| **Status** | 📦 Archived (not built/packaged) |

**Useful for:** Reference when implementing VD detection changes. Code may be extracted into `src/shared/` if needed.

---

## Submodule Sync Status

```
 4e725daa9e556494b7f7346266c984d1757a4120 legacy/poc/virtual-desktop-poc (heads/main)
 36ffd5d09934caf0a07dcb5da760992064e5062e src/desktop/MPK.AntiGravity.ProfilePicker (heads/main)
 2211f89af9385e19983602a3401c96bb0a1b31ba src/desktop/MPK.StickyNotes.ProfilePicker (heads/main)
 63beb14696fccf0c6fb92b61ff063d88f9fd101d src/desktop/MPK.VsCode.ProfilePicker (heads/master) ← ISSUE
 4746a7e7b264502615f02b2a1c5af1bec5abadc3 src/features/MPK.AntiGravity.ProjectSearch (heads/main)
 2b8bd334b9f22823c5ec1f80ccdb4df224acc348 src/features/MPK.StickyNotes.TextSearch (heads/main)
 660e28e2d3beab13a4099f2edd58ad2ea426724f src/features/MPK.VsCode.ProjectSearch (heads/main)
 7fd14dd30defd1931bf3e2096a0211d1d247184d src/launchers/antigravity (heads/main)
 b831dd67c80380a633fea21eb841ca0aadd33e47 src/launchers/chrome (heads/main)
 919a68deae02b871d9bfb63765370dd82518fc0c src/launchers/claude (heads/main)
 6417f8b75d404469e5333f1aa2c87a97347a357b src/launchers/edge (heads/main)
 3acf7323aef08af93c805e62230ffc629e269bbe src/launchers/sticky-notes (heads/main)
 d75dc205550e5d09a76f9a4a4ef1e7e24bd9e860 src/launchers/vscode (heads/main)
 b980b56776a1fe3785888ac00985e23f7c0057a4 src/shared/MPK.Profile.Core (heads/main)
```

**Note:** `src/desktop/MPK.VsCode.ProfilePicker` is on `heads/master`, not `heads/main`. This should be fixed in v1.6.
