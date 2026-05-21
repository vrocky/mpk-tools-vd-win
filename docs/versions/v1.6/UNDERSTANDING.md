# v1.6 Quick Start for Understanding

## How It Works (Simple)

### 1. Virtual Desktop Detection
Every launcher script reads Windows Registry to find: "Which desktop am I on?" (1, 2, 3, etc.)

```powershell
# Inside Launch-Chrome.ps1
Get-VDNumber  # Returns 1, 2, or 3 (current desktop)
```

### 2. Profile Isolation
Each app gets its own folder per desktop. Launched with flags pointing to that folder.

```
Desktop 1: C:\MPKTools\Profiles\chrome\virtual_desktop_1\
Desktop 2: C:\MPKTools\Profiles\chrome\virtual_desktop_2\
Desktop 3: C:\MPKTools\Profiles\chrome\virtual_desktop_3\
```

Chrome on Desktop 1 uses different bookmarks, history, and accounts than Chrome on Desktop 2.

### 3. Shortcuts
Shortcuts run `Launch-Chrome.ps1` silently (hidden window) → opens Chrome in the right profile.

---

## Files & What They Do

| File | What | Why |
|------|------|-----|
| `src/launchers/_shared/MPKTools.Launchers.psm1` | Shared functions (VD detection, profile paths, shortcuts) | Eliminates code duplication |
| `src/launchers/chrome/Launch-Chrome.ps1` | Opens Chrome with VD-isolated profile | ~15 lines, uses shared helpers |
| `src/launchers/chrome/Create-Shortcut.ps1` | Creates desktop shortcut for launcher | Runs post-install |
| `build/Build.ps1` | Compiles apps, stages files, builds installer | Incremental (only rebuilds if changed) |
| `scripts/Migrate-Profiles.ps1` | Moves profiles from v1.5 old locations to new unified root | One-time v1.5→v1.6 migration |
| `packaging/inno/MPKTools.iss` | Installer config | Checks .NET 8, runs Create-Shortcut scripts |

---

## The Flow

```
1. .\build\Build.ps1
   ├─ Checks: dotnet SDK installed?
   ├─ Publishes: 6 WPF apps (only changed ones rebuild)
   ├─ Publishes: Updater exe
   ├─ Copies: Launcher scripts to staging/Scripts/
   └─ Compiles: Installer .exe

2. Run installer.exe
   ├─ Checks: .NET 8 Desktop Runtime installed?
   ├─ Extracts: Apps, launchers, updater to C:\Program Files\MPK Tools\
   └─ Runs: Create-Shortcut.ps1 (creates desktop shortcuts)

3. User clicks shortcut
   ├─ Runs: Launch-Chrome.ps1 (hidden PowerShell window)
   ├─ Gets: Current desktop number from Registry
   ├─ Opens: Chrome with --user-data-dir=C:\MPKTools\Profiles\chrome\virtual_desktop_N\
   └─ Result: Chrome on this desktop uses this profile
```

---

## Error Messages

**"Chrome not found at: ..."**  
→ App not installed. Install it to default location, or launcher can''t find it.

**"Virtual desktop detection failed"**  
→ Registry missing or corrupted. Launcher falls back to Desktop 1.

**".NET SDK not found"**  
→ Build requires .NET SDK 8. Download from https://dotnet.microsoft.com/download/dotnet/8.0

**"No updater output"**  
→ Updater build failed. Check dotnet publish output for errors.

---

## Adding a New Launcher

1. **Create script**: `src/launchers/[name]/Launch-[Name].ps1`
   ```powershell
   Import-Module "..\_shared\MPKTools.Launchers.psm1" -Force -ErrorAction Stop
   $profilePath = Get-ProfilePath -AppName "[name]" -Desktop $Desktop
   Start-Process "[path/to/exe]" -ArgumentList "--user-data-dir=$profilePath"
   ```

2. **Create shortcut script**: `src/launchers/[name]/Create-Shortcut.ps1`
   ```powershell
   Import-Module "..\_shared\MPKTools.Launchers.psm1" -Force
   New-LauncherShortcut @{ Name = "[Name] (VD)"; ScriptPath = "..."; IconPath = "..." }
   ```

3. **Update Build.ps1**: Add to `$launcherDirs` array
   ```powershell
   @{ Id = "[name]"; Path = "src/launchers/[name]" }
   ```

4. **Rebuild**: `.\build\Build.ps1` — installer picks it up automatically

---

## Incremental Builds (Why They''re Fast)

Build.ps1 compares file timestamps:
- If source hasn''t changed since last build → skip rebuild
- If source has changed → rebuild only that app
- Result: Second build 40× faster

**Force rebuild**: `.\build\Build.ps1 -ForceRebuild`  
**Single app**: `.\build\Build.ps1 -Only MPK.VsCode.ProfilePicker`

