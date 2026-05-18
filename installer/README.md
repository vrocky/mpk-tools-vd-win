# MPK Tools Unified Installer

This folder builds a single Windows installer (`.exe`) for your MPK tools.

## What it includes

- Published WPF binaries for all `net8.0-windows` MPK desktop apps.
- PowerShell launch scripts for virtual desktop launchers.
- PowerShell shortcut scripts (`CreateShortcut.ps1` and `Create-Shortcut.ps1`) from MPK tool folders.
- Standalone updater executable at `Updater\MPKToolsUpdater.exe`.
- Start Menu shortcuts for all bundled apps and launchers.
- Optional desktop shortcuts for common launchers.

## Prerequisites

- .NET SDK 8+
- Inno Setup 6+
- `iscc` available in `PATH` (optional but recommended)

If `iscc` is not in `PATH`, the build script still prepares staging files and you can compile `MPKTools.iss` manually in Inno Setup.

## Build one installer

From repo root:

```powershell
cd .\installer
.\Build-MpkToolsInstaller.ps1 -Configuration Release -Runtime win-x64 -InstallerVersion 1.0.0
```

Installer output:

- `installer\dist\output\MPK-Tools-Setup-<version>.exe`

## Build staging only (no installer compile)

```powershell
cd .\installer
.\Build-MpkToolsInstaller.ps1 -SkipCompileInstaller
```

Staging output:

- `installer\dist\staging\Apps\...`
- `installer\dist\staging\Scripts\...`
- `installer\dist\staging\Updater\MPKToolsUpdater.exe`

## Standalone updater usage

After install, run the updater executable directly:

```powershell
"C:\Program Files\MPK Tools\Updater\MPKToolsUpdater.exe"
```

Requirements:
- GitHub CLI (`gh`) installed and authenticated.
- Installer release asset named like `MPK-Tools-Setup-<version>.exe`.

Defaults:
- Repository: `vrocky/mpk-tools-vd-win`
- Asset pattern: `MPK-Tools-Setup-*.exe`

## Notes

- The installer uses admin mode and installs to `C:\Program Files\MPK Tools`.
- Launch scripts are executed through `powershell.exe -ExecutionPolicy Bypass` via shortcuts.
- Existing profile data paths used by scripts (for example `C:\VSCodeProfiles`, `C:\ChromeProfiles`) are unchanged.
