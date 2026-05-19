# MPK Tools v1.5 — Updates & Changes

**Release:** v1.5.0  
**Date:** 2026-05-19  
**Type:** Restructuring release — no product behavior changes

---

## Summary

v1.5 is a cleanup and professionalization release. The core feature set is unchanged — virtual desktop profile isolation works exactly the same way. What changed is the organization of the source repository, the build system, and the installer configuration.

The goal was to make the project look and feel like a real product: clear structure, one version number, clean names, and a build command that just works.

---

## What Changed

### 1. Source Directory Structure

**Before:**
```
apps/                          (mixed: WPF apps + libraries + features + POC)
launch/                        (PowerShell launchers with long names)
installer/                     (build script + Inno Setup + updater source)
feature-updates/               (update strategy doc, buried)
```

**After:**
```
src/
├── desktop/                   WPF profile picker applications
│   ├── MPK.VsCode.ProfilePicker/
│   ├── MPK.StickyNotes.ProfilePicker/
│   └── MPK.AntiGravity.ProfilePicker/
├── features/                  App-specific search and utility modules
│   ├── MPK.VsCode.ProjectSearch/
│   ├── MPK.StickyNotes.TextSearch/
│   └── MPK.AntiGravity.ProjectSearch/
├── launchers/                 PowerShell virtual desktop launchers
│   ├── _shared/               (reserved for shared launcher engine)
│   ├── chrome/
│   ├── edge/
│   ├── vscode/
│   ├── claude/
│   ├── sticky-notes/
│   └── antigravity/
├── shared/                    Shared C# libraries
│   └── MPK.Profile.Core/
└── tools/                     Updater and internal utilities
    └── MPK.Updater/

build/                         Build orchestration scripts
packaging/inno/                Inno Setup installer configuration
docs/                          Architecture and process documentation
tests/                         Unit and integration tests (placeholder)
legacy/poc/                    Archived proof-of-concept code
dist/                          Build output (generated, not committed)
```

---

### 2. Git Submodule Paths

All 14 submodules retained their original GitHub repository URLs. Only the local checkout paths changed.

| Submodule (name in .gitmodules) | Old path | New path |
|---|---|---|
| `src/desktop/MPK.VsCode.ProfilePicker` | `apps/mpk-tools-vscode-profile-picker` | `src/desktop/MPK.VsCode.ProfilePicker` |
| `src/desktop/MPK.StickyNotes.ProfilePicker` | `apps/mpk-tools-sticky-notes-profile-picker` | `src/desktop/MPK.StickyNotes.ProfilePicker` |
| `src/desktop/MPK.AntiGravity.ProfilePicker` | `apps/mpk-tools-antigravity-profile-picker` | `src/desktop/MPK.AntiGravity.ProfilePicker` |
| `src/features/MPK.VsCode.ProjectSearch` | `apps/mpk-tools-vscode-profile-project-search` | `src/features/MPK.VsCode.ProjectSearch` |
| `src/features/MPK.StickyNotes.TextSearch` | `apps/mpk-tools-sticky-notes-profile-text-search` | `src/features/MPK.StickyNotes.TextSearch` |
| `src/features/MPK.AntiGravity.ProjectSearch` | `apps/mpk-tools-antigravity-profile-project-search` | `src/features/MPK.AntiGravity.ProjectSearch` |
| `src/shared/MPK.Profile.Core` | `apps/mpk-tools-mpk-profile-common-libs` | `src/shared/MPK.Profile.Core` |
| `legacy/poc/virtual-desktop-poc` | `apps/mpk-tools-win-virtual-desktop-poc` | `legacy/poc/virtual-desktop-poc` |
| `src/launchers/chrome` | `launch/mpk-tools-win-virtual-desktop-chrome-launch` | `src/launchers/chrome` |
| `src/launchers/edge` | `launch/mpk-tools-win-virtual-desktop-edge-launch` | `src/launchers/edge` |
| `src/launchers/vscode` | `launch/mpk-tools-win-virtual-desktop-vscode-launch` | `src/launchers/vscode` |
| `src/launchers/claude` | `launch/mpk-tools-win-virtual-desktop-claude-launch` | `src/launchers/claude` |
| `src/launchers/sticky-notes` | `launch/mpk-tools-win-virtual-desktop-sticky-notes-launch` | `src/launchers/sticky-notes` |
| `src/launchers/antigravity` | `launch/mpk-tools-win-virtual-desktop-antigravity-launch` | `src/launchers/antigravity` |

**How the move was done:**
- Used `git mv` on each submodule path to preserve git history
- Updated `.gitmodules` with clean section names matching the new paths
- Ran `git submodule sync` to reconcile `.git/config` with the new `.gitmodules`

---

### 3. Build Script (`build/Build.ps1`)

**Old file:** `installer/Build-MpkToolsInstaller.ps1`  
**New file:** `build/Build.ps1`

Key changes:

| Area | Before | After |
|------|--------|-------|
| Location | `installer/` | `build/` |
| Version input | Required `-InstallerVersion` parameter | Reads `VERSION` file; `-Version` overrides |
| App source paths | `apps/mpk-tools-vscode-profile-picker/...` | `src/desktop/MPK.VsCode.ProfilePicker/...` |
| Feature source paths | Also in `$wpfProjects` mixed with apps | Separate `$featureProjects` array |
| Launcher source | Scanned from `launch/` recursively | Iterated from explicit `$launcherDirs` list |
| Launcher staging names | `Scripts/mpk-tools-win-virtual-desktop-chrome-launch/` | `Scripts/chrome/` |
| App staging names | `Apps/mpk-tools-vscode-profile-picker/` | `Apps/MPK.VsCode.ProfilePicker/` |
| Dist output path | `installer/dist/` (inside installer dir) | `dist/` (at repo root) |
| Updater source | `installer/MPKToolsUpdater/MPKToolsUpdater.csproj` | `src/tools/MPK.Updater/MPKToolsUpdater.csproj` |
| Inno Setup script | `installer/MPKTools.iss` | `packaging/inno/MPKTools.iss` |

**New build command (from repo root):**
```powershell
.\build\Build.ps1 -Configuration Release
```

Version is read from `VERSION`. No flags required for a standard release build.

Override version:
```powershell
.\build\Build.ps1 -Configuration Release -Version 1.5.1
```

Skip app publish (reuse existing staged binaries):
```powershell
.\build\Build.ps1 -ReusePublishedApps -SkipCompileInstaller
```

---

### 4. Inno Setup Script (`packaging/inno/MPKTools.iss`)

**Old file:** `installer/MPKTools.iss`  
**New file:** `packaging/inno/MPKTools.iss`

Key changes:

**Source file paths** — paths are relative to the `.iss` file location. Moving from `installer/` to `packaging/inno/` required updating all source references:

```ini
; Before (relative to installer/)
Source: "dist\staging\*"; ...

; After (relative to packaging\inno\)
Source: "..\..\dist\staging\*"; ...
```

**Installed app paths** — updated to use clean names matching staging:

```ini
; Before
{app}\Apps\mpk-tools-vscode-profile-picker\VsCodeProfilePicker.exe

; After
{app}\Apps\MPK.VsCode.ProfilePicker\VsCodeProfilePicker.exe
```

**Installed launcher paths** — updated to use short names:

```ini
; Before
{app}\Scripts\mpk-tools-win-virtual-desktop-chrome-launch\Launch-Chrome.ps1

; After
{app}\Scripts\chrome\Launch-Chrome.ps1
```

**Default version** updated from `1.1.0` to `1.5.0` (always overridden by build script at compile time).

**AppId unchanged** — `{A3A6FB9E-9775-42DB-95BF-0A9E8D4D2B36}` — preserves in-place upgrade compatibility with all previous installs.

---

### 5. Versioning

Added root-level `VERSION` file:

```
1.5.0
```

The build script reads this file and passes it to Inno Setup as `AppVersion`. No more manual `-InstallerVersion 1.x.x` argument on every build. To release a new version, update `VERSION` and run the build.

---

### 6. Documentation

**Moved:** `feature-updates/update-mechanism-strategy.md` → `docs/architecture/update-mechanism.md`

**Added:**
- `docs/architecture/v1.5-restructuring-proposal.md` — design rationale and proposed structure (source of this change)
- `docs/architecture/MIGRATION-GUIDE-v1.5.md` — step-by-step migration reference
- `docs/RESTRUCTURING-STATUS.md` — checklist tracking the restructuring work
- `docs/README.md` — index of all documentation
- `.project.md` (root) — comprehensive project context for agents and new contributors

---

### 7. Archived POC

`apps/mpk-tools-win-virtual-desktop-poc` moved to `legacy/poc/virtual-desktop-poc`.

This submodule was a research project for virtual desktop detection patterns. Any useful code from it has been or should be extracted into `src/shared/MPK.Profile.Core/` or `src/shared/MPK.VirtualDesktop/`. The archived copy is retained for reference only and is not built or packaged.

---

### 8. Installed Layout (Runtime — Unchanged)

The installed layout on the user's machine is functionally unchanged. Folder names inside `C:\Program Files\MPK Tools\` are cleaner:

**Before:**
```
C:\Program Files\MPK Tools\
├── Apps\
│   ├── mpk-tools-vscode-profile-picker\
│   ├── mpk-tools-sticky-notes-profile-picker\
│   └── ...
├── Scripts\
│   ├── mpk-tools-win-virtual-desktop-chrome-launch\
│   └── ...
└── Updater\
```

**After:**
```
C:\Program Files\MPK Tools\
├── Apps\
│   ├── MPK.VsCode.ProfilePicker\
│   ├── MPK.StickyNotes.ProfilePicker\
│   ├── MPK.VsCode.ProjectSearch\
│   └── ...
├── Scripts\
│   ├── chrome\
│   ├── edge\
│   ├── vscode\
│   ├── claude\
│   ├── sticky-notes\
│   └── antigravity\
└── Updater\
```

Profile data locations are unchanged:
```
C:\ChromeProfiles\virtual_desktop_[N]\
C:\VSCodeProfiles\virtual_desktop_[N]\
C:\EdgeProfiles\virtual_desktop_[N]\
...
```

---

## What Did NOT Change

- All 14 GitHub repository URLs are unchanged
- Virtual desktop detection logic is unchanged
- Profile isolation behavior is unchanged
- Registry storage keys are unchanged
- AppId for Inno Setup installer is unchanged (upgrades work)
- Individual launcher scripts (`Launch-Chrome.ps1`, etc.) are unchanged
- Individual WPF app code is unchanged

---

## Upgrade Impact

**Existing users upgrading from v1.1.0:**

The installer `AppId` is preserved so the upgrade installs over the existing installation silently. The installed folder names under `C:\Program Files\MPK Tools\Apps\` and `Scripts\` will change to the new clean names during the upgrade. All shortcuts in the Start Menu are recreated pointing to the new paths. Desktop shortcuts created by `Create-Shortcut.ps1` may need to be regenerated — the installer runs each `Create-Shortcut.ps1` automatically during the `[Run]` phase, which will overwrite the old shortcuts.

No profile data is affected. All data under `C:\ChromeProfiles\`, `C:\VSCodeProfiles\`, etc. is untouched.

---

## Known Gaps (v1.5 Does Not Include)

These were identified but deferred to future versions:

| Item | Status | Notes |
|------|--------|-------|
| Shared launcher engine (`_shared/`) | Placeholder only | Each launcher still has independent logic |
| CI/CD pipeline (`.github/workflows/`) | Not implemented | Builds and releases are still manual |
| Automated tests | Empty `tests/` dirs | No unit or integration tests exist yet |
| Shared virtual desktop library | Planned | Would consolidate detection code from each launcher |
| Unified profile root (`C:\MPKProfiles\`) | Deferred | Profile folders are still per-app at `C:\ChromeProfiles\` etc. |

---

## Files Changed in v1.5

| File | Change |
|------|--------|
| `.gitmodules` | All 14 submodule paths and section names updated |
| `build/Build.ps1` | New location; rewritten with new paths and VERSION support |
| `packaging/inno/MPKTools.iss` | New location; source paths and installed names updated |
| `VERSION` | New file — `1.5.0` |
| `README.md` | New file — project overview |
| `CHANGELOG.md` | New file — release history |
| `docs/architecture/update-mechanism.md` | Moved from `feature-updates/update-mechanism-strategy.md` |
| `legacy/poc/virtual-desktop-poc` | Moved from `apps/mpk-tools-win-virtual-desktop-poc` |
| `src/tools/MPK.Updater/` | Moved from `installer/MPKToolsUpdater/` |

---

## Related Documents

- [`../../architecture/v1.5-restructuring-proposal.md`](../../architecture/v1.5-restructuring-proposal.md) — design rationale
- [`../../architecture/MIGRATION-GUIDE-v1.5.md`](../../architecture/MIGRATION-GUIDE-v1.5.md) — step-by-step migration details
- [`../../../.project.md`](../../../.project.md) — full project context
- [`../../../CHANGELOG.md`](../../../CHANGELOG.md) — release history
