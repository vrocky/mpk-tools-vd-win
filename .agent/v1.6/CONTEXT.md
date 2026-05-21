# v1.6 Context (Agents)

MPK Tools v1.6 — simplified build, launchers, and profiles.

## Quick Facts
- **Build**: Framework-dependent .NET 8 (15 MB installer, was 300 MB)
- **Launchers**: 6 simplified scripts + shared module
- **Profiles**: Unified under `C:\MPKTools\Profiles\`
- **Incremental**: Changed projects only rebuild
- **Apps**: All WPF apps in `src/apps/` (was split across desktop/features)

## Key Files
- `build/Build.ps1` — incremental, framework-dependent publish
- `src/launchers/_shared/MPKTools.Launchers.psm1` — VD detection, path helpers
- `src/launchers/{chrome,edge,vscode,claude,sticky-notes,antigravity}/` — simplified launchers
- `src/apps/` — 6 WPF profile pickers + search utilities
- `scripts/Migrate-Profiles.ps1` — v1.5→v1.6 migration

## Build
```powershell
.\build\Build.ps1 -Configuration Release
```

## To Add a Launcher
1. Create `src/launchers/[name]/` submodule
2. Add `Launch-[Name].ps1` (imports `_shared\MPKTools.Launchers.psm1`)
3. Call `Get-ProfilePath -AppName "name"`
4. Add to `$launcherDirs` array in `Build.ps1`
5. Installer picks up from staging automatically

**See [v1.5 CONTEXT](../.agent/v1.5/CONTEXT.md) for full architecture.**
