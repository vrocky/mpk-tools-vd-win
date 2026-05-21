# v1.6 What''s New

See [v1.5 docs](../v1.5/) for full details. This is what changed.

## Smaller Installer

- **15 MB** (was 300 MB)
- Framework-dependent .NET 8 instead of bundled runtimes
- Requires .NET 8 Desktop Runtime (installer checks for it)
- Much faster downloads and installs

## Simpler Launchers

All 6 virtual desktop launchers simplified:

```powershell
# Before: 50+ lines with VD detection logic
# After: 15 lines
param([int]$Desktop = 0, [string]$Url = "")
Import-Module "..\_shared\MPKTools.Launchers.psm1" -Force
$profilePath = Get-ProfilePath -AppName "chrome" -Desktop $Desktop
Start-Process "chrome.exe" -ArgumentList @("--user-data-dir", $profilePath) + @($Url)
```

Shared helpers: `Get-VDNumber`, `Get-ProfilePath`, `New-LauncherShortcut`

## Unified Profile Location

All profiles now in **`C:\MPKTools\Profiles\`**:

```
C:\MPKTools\Profiles\
├── chrome\virtual_desktop_1\
├── edge\virtual_desktop_1\
├── vscode\virtual_desktop_1\
├── sticky-notes\virtual_desktop_1\
├── antigravity\virtual_desktop_1\
└── claude\vd-1\
```

**Migrate from v1.5:**
```powershell
.\scripts\Migrate-Profiles.ps1
```

See [PROFILE_MIGRATION.md](PROFILE_MIGRATION.md) for details.

## Faster Builds

`build/Build.ps1` now skips unchanged projects.

```powershell
.\build\Build.ps1                          # Only builds changed apps
.\build\Build.ps1 -ForceRebuild            # Rebuild all
.\build\Build.ps1 -Only VsCode.ProfilePicker  # Single app
```

40× faster when nothing changed.

## Directory Cleanup

- `src/desktop/` + `src/features/` → **`src/apps/`**
- All 6 WPF apps in one place
- Cleaner, more intuitive

## From v1.5

Full architecture, design decisions, and component details: [v1.5 docs](../v1.5/)
