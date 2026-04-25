# EdgeProfiles

PowerShell scripts for launching Microsoft Edge with a separate user data profile per Windows virtual desktop.

## What this does

- `Launch-Edge.ps1` starts Edge with an isolated profile directory.
- `Create-Shortcut.ps1` generates a desktop shortcut that runs the launcher.
- `edge_desktop.ico` is the generated shortcut icon.

Each virtual desktop gets its own profile folder under `C:\EdgeProfiles\virtual_desktop_[N]\`.

## Requirements

- Windows
- PowerShell 5.1 or later
- Microsoft Edge installed in the default location:
  `C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe`

If Edge is installed somewhere else, update the `msedge.exe` path in both scripts.

## Launching Edge

Run the launcher directly from PowerShell:

```powershell
.\Launch-Edge.ps1
```

Optional parameters:

```powershell
.\Launch-Edge.ps1 -Desktop 3
.\Launch-Edge.ps1 -Url "https://example.com"
```

### Parameters

- `-Desktop` uses a specific virtual desktop number instead of the current one.
- `-Url` opens Edge with a specific URL.

## What the launcher does

`Launch-Edge.ps1`:

- Detects the current virtual desktop by reading the Windows registry.
- Builds a profile name like `virtual_desktop_1`, `virtual_desktop_2`, and so on.
- Creates a separate user data folder for that desktop if it does not already exist.
- Starts Edge with `--user-data-dir` and `--new-window`.

## Creating the desktop shortcut

Run:

```powershell
.\Create-Shortcut.ps1
```

This will:

- Extract the Edge icon and save it as `edge_desktop.ico`.
- Create a desktop shortcut named `Edge (Virtual Desktop).lnk`.
- Configure the shortcut to launch the PowerShell script hidden.

## Folder layout

```text
C:\Scripts\EdgeProfiles\
  Create-Shortcut.ps1
  Launch-Edge.ps1
  edge_desktop.ico
```

Running the launcher creates profile data here:

```text
C:\EdgeProfiles\virtual_desktop_[N]\
```

## Notes

- The scripts are intended for Windows virtual desktops.
- The launcher defaults to the current virtual desktop when `-Desktop` is not provided.
- The shortcut generator overwrites `edge_desktop.ico` when run.
- Each profile maintains separate bookmarks, extensions, history, and settings.
