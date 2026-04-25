# StickyNotesProfiles

PowerShell scripts for launching StickyNotesApp with a separate user data profile per Windows virtual desktop.

## What this does

- `Launch-StickyNotes.ps1` starts StickyNotesApp with an isolated profile directory.
- `Create-Shortcut.ps1` generates a desktop shortcut that runs the launcher.
- `stickynotes_desktop.ico` is the generated shortcut icon.

Each virtual desktop gets its own profile folder under `C:\StickyNotesProfiles\profiles\virtual_desktop_[N]\`.

## Requirements

- Windows
- PowerShell 5.1 or later
- StickyNotesApp installed at:
  `C:\Program Files\StickyNotesApp\StickyNotesApp.exe`

If StickyNotesApp is installed somewhere else, update the path in both scripts.

## Launching StickyNotesApp

Run the launcher directly from PowerShell:

```powershell
.\Launch-StickyNotes.ps1
```

Optional parameters:

```powershell
.\Launch-StickyNotes.ps1 -Desktop 3
```

### Parameters

- `-Desktop` uses a specific virtual desktop number instead of the current one.

## What the launcher does

`Launch-StickyNotes.ps1`:

- Detects the current virtual desktop by reading the Windows registry.
- Builds a profile name like `virtual_desktop_1`, `virtual_desktop_2`, and so on.
- Starts StickyNotesApp with `--profile` and `--data-dir` arguments for complete data isolation.

## Creating the desktop shortcut

Run:

```powershell
.\Create-Shortcut.ps1
```

This will:

- Extract the StickyNotesApp icon and save it as `stickynotes_desktop.ico`.
- Create a desktop shortcut named `StickyNotes (Virtual Desktop).lnk`.
- Configure the shortcut to launch the PowerShell script hidden.

## Folder layout

```text
C:\Scripts\StickyNotesProfiles\
  Create-Shortcut.ps1
  Launch-StickyNotes.ps1
  stickynotes_desktop.ico
```

Running the launcher creates profile data here:

```text
C:\StickyNotesProfiles\profiles\virtual_desktop_[N]\
```

## Notes

- The scripts are intended for Windows virtual desktops.
- The launcher defaults to the current virtual desktop when `-Desktop` is not provided.
- The shortcut generator overwrites `stickynotes_desktop.ico` when run.
- Each profile maintains separate sticky notes data (notes.json, config.json) per virtual desktop.
- Profile locking prevents running the same profile twice simultaneously.
