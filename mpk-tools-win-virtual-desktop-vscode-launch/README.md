# VSCodeProfiles

PowerShell scripts for launching Visual Studio Code with a separate user data and extensions profile per Windows virtual desktop.

## What this does

- `Launch-VSCode.ps1` starts VS Code with an isolated profile directory.
- `Create-Shortcut.ps1` generates a desktop shortcut that runs the launcher.
- `vscode_desktop.ico` is the generated shortcut icon.

Each virtual desktop gets its own profile folder under `C:\VSCodeProfiles\virtual_desktop_[N]\`.

## Requirements

- Windows
- PowerShell 5.1 or later
- Visual Studio Code installed in the default location used by the scripts:
  `C:\Users\<you>\AppData\Local\Programs\Microsoft VS Code\Code.exe`

If VS Code is installed somewhere else, update the `Code.exe` path in both scripts.

## Launching VS Code

Run the launcher directly from PowerShell:

```powershell
.\Launch-VSCode.ps1
```

Optional parameters:

```powershell
.\Launch-VSCode.ps1 -Desktop 3
.\Launch-VSCode.ps1 -DevExtPath "C:\Path\To\Extension"
```

### Parameters

- `-Desktop` uses a specific virtual desktop number instead of the current one.
- `-DevExtPath` passes `--extensionDevelopmentPath` to VS Code when the path exists.

## What the launcher does

`Launch-VSCode.ps1`:

- Detects the current virtual desktop by reading the Windows registry.
- Builds a profile name like `virtual_desktop_1`, `virtual_desktop_2`, and so on.
- Creates separate `data` and `extensions` folders for that desktop if they do not already exist.
- Starts VS Code with `--user-data-dir`, `--extensions-dir`, and `--new-window`.

## Creating the desktop shortcut

Run:

```powershell
.\Create-Shortcut.ps1
```

This will:

- Extract the VS Code icon and save it as `vscode_desktop.ico`.
- Create a desktop shortcut named `VS Code (Virtual Desktop).lnk`.
- Configure the shortcut to launch the PowerShell script hidden.

## Folder layout

```text
C:\Scripts\VSCodeProfiles\
  Create-Shortcut.ps1
  Launch-VSCode.ps1
  vscode_desktop.ico
```

Running the launcher creates profile data here:

```text
C:\VSCodeProfiles\virtual_desktop_[N]\
  data
  extensions
```

## Notes

- The scripts are intended for Windows virtual desktops.
- The launcher defaults to the current virtual desktop when `-Desktop` is not provided.
- The shortcut generator overwrites `vscode_desktop.ico` when run.
