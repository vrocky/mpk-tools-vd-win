# v1.6 Updates (Agents)

**See [v1.5 docs](../v1.5) for architecture details.**

## What Changed

### Build System
- **Incremental builds** via timestamp comparison (`Should-Republish`)
- **Framework-dependent** .NET 8 (no self-contained bundles)
- New params: `-ForceRebuild`, `-Only <name>`, `-SkipCompileInstaller`
- Removed: `-SkipPublish`, `-ReusePublishedApps`, `-Runtime`

### Launchers
- **Shared module**: `src/launchers/_shared/MPKTools.Launchers.psm1`
- All 6 launchers now ~15 lines (import module, call helpers)
- `Get-VDNumber`, `Get-ProfilePath`, `New-LauncherShortcut` helpers

### Directory Layout
- `src/desktop/` + `src/features/` → `src/apps/` (unified)
- All 6 WPF apps in one location
- Update .gitmodules paths if cloning

### Profile Paths
- Old: `C:\ChromeProfiles\`, `C:\VSCodeProfiles\`, etc.
- New: `C:\MPKTools\Profiles\chrome\`, `C:\MPKTools\Profiles\vscode\`, etc.

### Installer
- Checks .NET 8 Desktop Runtime (registry)
- `scripts/Migrate-Profiles.ps1` for v1.5→v1.6 migration

## Build Command
```powershell
.\build\Build.ps1 -Configuration Release      # Incremental
.\build\Build.ps1 -ForceRebuild               # All projects
.\build\Build.ps1 -Only VsCode.ProfilePicker  # Single app
```

## Files Changed
- `build/Build.ps1` — incremental logic, new params
- `src/launchers/_shared/MPKTools.Launchers.psm1` — NEW
- `src/launchers/{chrome,edge,vscode,claude,sticky-notes,antigravity}/` — simplified
- `.gitmodules` — paths updated to `src/apps/`
- `packaging/inno/MPKTools.iss` — version 1.6.0, .NET check
- `scripts/Migrate-Profiles.ps1` — NEW migration tool

See `.agent/v1.5/` for full component inventory.
