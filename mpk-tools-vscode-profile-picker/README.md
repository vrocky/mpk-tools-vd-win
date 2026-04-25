# VS Code Profile Picker

A WPF desktop application for Windows that lets you manage and launch multiple isolated Visual Studio Code profiles from a single, searchable UI. Each profile maintains its own extensions and user data, eliminating conflicts between project-specific tooling setups.

---

## Overview

VS Code Profile Picker scans one or more registered directories for profile folders. Each subfolder found in those directories is treated as a distinct VS Code profile. The application launches VS Code with the `--user-data-dir` and `--extensions-dir` flags pointed at subdirectories inside the selected profile, keeping settings, themes, keybindings, and extensions completely isolated from every other profile.

Profile directories are stored in the Windows Registry under `HKEY_CURRENT_USER\Software\VsCodeProfilePicker`, so no configuration files are written to disk and no environment variables need to be set.

---

## Features

- Dark theme UI matching the VS Code color scheme (`#1e1e1e` background)
- Searchable profile card grid — filter profiles by name in real time
- Automatic `user-data\` and `extensions\` subdirectory creation when a profile is first scanned
- Per-profile avatar with auto-generated initials and color derived from the profile name
- Last-modified timestamp displayed on each profile card
- Settings window to add or remove profile directories using the native Windows folder picker
- Gear button in the main window opens Settings without blocking the main window
- Registry-backed persistence — no INI files, no JSON, no XML
- Shared core library (`Shared/VsCodeProfileCommon`) for registry, profile scan, and recent-project parsing logic
- Desktop shortcut creation via `CreateShortcut.ps1`

---

## Project Structure

```
vscode-profile-picker/
├── Converters/
│   └── StringToColorBrushConverter.cs  # Hex string → WPF SolidColorBrush
├── Views/
│   ├── SettingsWindow.xaml     # Settings UI (XAML)
│   └── SettingsWindow.xaml.cs  # Settings code-behind
├── MainWindow.xaml             # Main UI (XAML)
├── MainWindow.xaml.cs          # Main code-behind
├── app.ico                     # Application icon (VS Code's code.ico)
├── CreateShortcut.ps1          # PowerShell script to create desktop shortcut
├── docs/
│   └── glossary.md             # Shared terminology for profile tooling
└── README.md                   # This file

Shared library:
../mpk-profile-common-libs/
└── VsCodeProfileCommon/        # Shared library used by multiple apps
    ├── Models/
    └── Services/
```

---

## Prerequisites

| Requirement | Notes |
|---|---|
| Windows 10 or 11 | WPF requires Windows |
| .NET 8 or later | Targets `net8.0-windows` |
| Visual Studio 2022+ or `dotnet` CLI | For building |
| Visual Studio Code | Must be accessible via the `code` command in PATH, or the full path must be configured in Settings |

Verify VS Code is in your PATH:

```powershell
code --version
```

If the `code` command is not found, either add the VS Code installation directory to `PATH` or set the full path to `code.exe` through the application's Settings window after first launch.

---

## How to Build

### Using Visual Studio

1. Open `vscode-profile-picker.sln` in Visual Studio 2022 or later.
2. Select the **Release** configuration.
3. Press **Ctrl+Shift+B** to build.

### Using the .NET CLI

```powershell
cd C:\Users\ws-user\Documents\project-8\vscode-profile-picker
dotnet build -c Release
```

---

## How to Run

### From Visual Studio

Press **F5** (Debug) or **Ctrl+F5** (Run without debugging).

### From the .NET CLI

```powershell
dotnet run --project vscode-profile-picker.csproj
```

### From the built binary

```powershell
.\bin\Release\net6.0-windows\vscode-profile-picker.exe
```

---

## How to Publish (self-contained executable)

The following command produces a single `.exe` that does not require the .NET runtime to be installed on the target machine:

```powershell
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o .\publish
```

The output executable will be at `.\publish\vscode-profile-picker.exe`.

---

## Adding a Profile Directory

1. Launch the application.
2. Click the gear icon ( Settings ) in the top-right corner of the main window.
3. In the Settings window, click **Add Directory**.
4. Use the native folder picker to select a directory that contains (or will contain) profile subfolders.
5. Click **Save**. The main window will rescan and display any profiles found in the new directory.

To remove a directory, select it in the list and click **Remove**, then **Save**.

---

## Profile Folder Structure

Each subdirectory inside a registered profile directory is treated as one VS Code profile. The scanner automatically creates the required subdirectories on first scan if they do not already exist:

```
<ProfileDirectory>/
└── MyProfile/                  # Profile name shown in the UI
    ├── user-data\              # --user-data-dir value passed to VS Code
    └── extensions\             # --extensions-dir value passed to VS Code
```

Example with multiple profiles:

```
C:\VSCodeProfiles\
├── Work\
│   ├── user-data\
│   └── extensions\
├── Personal\
│   ├── user-data\
│   └── extensions\
└── Python\
    ├── user-data\
    └── extensions\
```

Each profile stores its own:
- VS Code settings (`settings.json`)
- Keybindings
- Installed extensions
- Theme and UI state

---

## Registry Storage

All persistent settings are stored in the Windows Registry. No files are written outside the application directory.

**Registry path:** `HKEY_CURRENT_USER\Software\VsCodeProfilePicker`

| Value name | Type | Description |
|---|---|---|
| `ProfileDirectories` | `REG_MULTI_SZ` | List of directory paths to scan for profiles |
| `VsCodeExePath` | `REG_SZ` | Path or command used to launch VS Code (default: `code`) |

You can inspect or modify these values directly with `regedit.exe` or PowerShell:

```powershell
# View current settings
Get-Item "HKCU:\Software\VsCodeProfilePicker"

# Add a profile directory manually
$key = "HKCU:\Software\VsCodeProfilePicker"
$existing = (Get-ItemProperty $key).ProfileDirectories
Set-ItemProperty $key -Name ProfileDirectories -Value ($existing + "C:\MyProfiles") -Type MultiString
```

---

## Desktop Shortcut Creation

A PowerShell script is included to create a desktop shortcut pointing to the published executable:

```powershell
.\CreateShortcut.ps1
```

Edit the script to adjust the target path if you published to a non-default location.

---

## VS Code Launch Command

When a profile is launched, the application runs:

```
code --user-data-dir "<profile>\user-data" --extensions-dir "<profile>\extensions"
```

where `<profile>` is the full path to the profile subfolder (e.g., `C:\VSCodeProfiles\Work`).

Both flags must always be supplied together. Supplying only one will cause VS Code to use the default location for the other, defeating the isolation purpose.
