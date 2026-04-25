# AntiGravityProfiles

PowerShell scripts for launching AntiGravity with a separate user data profile per Windows virtual desktop.

## What this does

- `Launch-AntiGravity.ps1` starts AntiGravity with an isolated profile directory.
- `Create-Shortcut.ps1` generates a desktop shortcut that runs the launcher.
- `antigravity_desktop.ico` is the generated shortcut icon.

Each virtual desktop gets its own profile folder under `C:\AntiGravityProfiles\virtual_desktop_[N]\`.

## Requirements

- Windows
- PowerShell 5.1 or later
- AntiGravity installed in the default location used by the scripts:
  `C:\Users\<you>\AppData\Local\Programs\AntiGravity\AntiGravity.exe`

If AntiGravity is installed somewhere else, update the executable path in both scripts.

## Launching AntiGravity

Run the launcher directly from PowerShell:

```powershell
.\Launch-AntiGravity.ps1
```

Optional parameters:

```powershell
.\Launch-AntiGravity.ps1 -Desktop 3
.\Launch-AntiGravity.ps1 -AppExePath "C:\Path\To\AntiGravity.exe"
```

### Parameters

- `-Desktop` uses a specific virtual desktop number instead of the current one.
- `-AppExePath` sets the path to `AntiGravity.exe`.

## What the launcher does

`Launch-AntiGravity.ps1`:

- Detects the current virtual desktop by reading the Windows registry.
- Builds a profile name like `virtual_desktop_1`, `virtual_desktop_2`, and so on.
- Creates a separate `data` folder for that desktop if it does not already exist.
- Starts AntiGravity with `--user-data-dir` and `--new-window`.

## Creating the desktop shortcut

Run:

```powershell
.\Create-Shortcut.ps1
```

This will:

- Extract the AntiGravity icon and save it as `antigravity_desktop.ico`.
- Create a desktop shortcut named `AntiGravity (Virtual Desktop).lnk`.
- Configure the shortcut to launch the PowerShell script hidden.

## Folder layout

```text
C:\Scripts\AntiGravityProfiles\
  Create-Shortcut.ps1
  Launch-AntiGravity.ps1
  antigravity_desktop.ico
```

Running the launcher creates profile data here:

```text
C:\AntiGravityProfiles\virtual_desktop_[N]\
  data
```

## Notes

- The scripts are intended for Windows virtual desktops.
- The launcher defaults to the current virtual desktop when `-Desktop` is not provided.
- The shortcut generator overwrites `antigravity_desktop.ico` when run.
