# MPK Tools v1.5 Agent Context

**Project:** Windows 11 virtual desktop profile isolation suite  
**Version:** 1.5.0  
**Status:** Restructuring complete, all 14 submodules reorganized  
**Last Commit:** b79745e (2026-05-19)

## Quick Facts

| Fact | Value |
|------|-------|
| **Language** | C#/PowerShell |
| **Framework** | .NET 8 (WPF + Console) |
| **Components** | 3 WPF apps + 6 PS launchers + 3 features + 1 shared lib + 1 updater + 1 POC |
| **Submodules** | 14 (all at origin/main, no drift) |
| **Build** | `.\build\Build.ps1 -Configuration Release` |
| **Installer** | Inno Setup 6+, AppId preserved for upgrades |
| **Profile Data** | Registry-backed (HKCU:\Software\*) |
| **VD Detection** | Windows Registry + COM IVirtualDesktopManager |

## v1.5 Accomplishments

- ✅ Moved 14 submodules from flat `apps/launch/` to semantic `src/` structure
- ✅ Renamed submodules to clean names (e.g., `mpk-tools-vscode-profile-picker` → `src/desktop/MPK.VsCode.ProfilePicker`)
- ✅ Rewrote build script to read VERSION file, clean staging names, split desktop/feature projects
- ✅ Updated Inno Setup paths and installed shortcut names
- ✅ Added comprehensive README, CHANGELOG, VERSION, project context docs
- ✅ Archived POC to `legacy/poc/`
- ✅ Created migration guide and restructuring documentation

## v1.5 Known Gaps (for v1.6)

- ❌ No CI/CD pipeline (builds/releases still manual)
- ❌ No automated tests (tests/ directories empty)
- ❌ Shared launcher engine not implemented (each launcher has independent logic)
- ❌ No unified profile root (still `C:\ChromeProfiles\`, `C:\VSCodeProfiles\`, etc.)
- ❌ No package.json/nuget.json at root for dependency tracking
- ❌ No release automation (manual GitHub release creation)

## Directory Tree

```
src/
├── desktop/              (3 WPF profile picker apps)
├── features/             (3 app-specific search modules)
├── launchers/            (6 PS vd launchers + _shared placeholder)
├── shared/               (1 shared C# library)
└── tools/                (1 updater .NET app)

build/                    (build orchestration)
packaging/inno/           (Inno Setup config)
docs/                     (architecture + release docs)
docs/versions/v1.5/docs/  (v1.5 detailed component docs)
legacy/poc/               (archived research POC)
tests/                    (placeholder structure only)
```

## Build Command

```powershell
# Standard release build (reads VERSION file automatically)
.\build\Build.ps1 -Configuration Release

# Override version
.\build\Build.ps1 -Configuration Release -Version 1.5.1

# Skip installer compilation
.\build\Build.ps1 -SkipCompileInstaller

# Reuse existing published apps
.\build\Build.ps1 -ReusePublishedApps
```

**Output:** `dist\output\MPK-Tools-Setup-<version>.exe`

## Key Paths & Edits

| Change | File | What |
|--------|------|------|
| Version number | `VERSION` | Single source of truth (1.5.0) |
| Release notes | `CHANGELOG.md` | Semver entries |
| Build logic | `build/Build.ps1` | Staging, publishing, version handling |
| Installer | `packaging/inno/MPKTools.iss` | Silent install flags, shortcuts |
| App paths | `.gitmodules` | Submodule → local path mappings |
| README | `README.md` | User-facing feature overview |

## Submodule Pinning

All 14 submodules pinned at origin/main HEAD. No local changes. No prefix marks in `git submodule status`.

```
4e725daa9e src/launchers/vscode (heads/main)
36ffd5d09 src/desktop/MPK.VsCode.ProfilePicker (heads/master) ← check main branch
... (12 more)
```

**Action for v1.6:** All VS Code picker submodules should be on `main`, not `master`.
