# Antigravity Profile Project Search

A WPF application that searches for recently accessed projects across all Antigravity profile containers and allows you to quickly open them in their original profile.

## Overview

This tool scans your Antigravity profile container directories (e.g., `C:\AntiGravityProfiles`), reads each profile's recent project history, and presents a unified search interface where you can:

- **Search** for projects by path or profile name
- **Launch** projects directly in their original Antigravity profile
- **Include or exclude missing projects** from the results

## Key Features

- **Cross-profile search**: Finds projects from all profiles in one place
- **Recent activity sorting**: Shows most recently accessed projects first
- **Profile awareness**: Launches projects with the correct profile settings
- **Missing project detection**: Optionally shows or hides projects that no longer exist
- **Dark theme UI**: Modern dark interface matching Antigravity's aesthetic

## Usage

1. Launch the application
2. Type in the search box to filter projects
3. Click any existing project to open it in Antigravity with its original profile
4. Use the Settings button to configure profile container directories and Antigravity executable path
5. Use the Refresh button to rescan profiles
6. Toggle "Include missing" to show/hide projects that no longer exist on disk

## Configuration

Settings are stored in the Windows Registry at:
```
HKEY_CURRENT_USER\Software\AntigravityProfileProjectSearch
```

Default settings:
- **Profile Directory**: `C:\AntiGravityProfiles`
- **Antigravity Executable**: `%LOCALAPPDATA%\Programs\AntiGravity\AntiGravity.exe`

## Profile Structure

The application expects profile directories with either structure:
- **Antigravity style**: `data\` folder (single directory for user data)
- **VS Code style**: `user-data\` and `extensions\` folders (for compatibility)

Antigravity uses a simplified single-directory profile structure with only the `--user-data-dir` flag.

## Technical Details

- Built with .NET 8.0-windows and WPF
- Uses shared library `VsCodeProfileCommon` for profile scanning and project history reading
- Reads project history from `storage.json` and `state.vscdb` in each profile's storage directory
- Launches Antigravity with `--user-data-dir` and `--new-window` flags

## Logs

Application logs are stored at:
```
%LOCALAPPDATA%\AntigravityProfileProjectSearch\logs\
```

## See Also

- [Antigravity Profile Picker](../antigravity-profile-picker) - Choose and launch Antigravity profiles
- [VS Code Profile Project Search](../vscode-profile-project-search) - VS Code version of this tool


## Build and run

```powershell
cd C:\Users\ws-user\Documents\project-8\vscode-profile-project-search
dotnet build
dotnet run
```

## Shared library

This app depends on the shared library at:

- `..\\mpk-profile-common-libs\\VsCodeProfileCommon`

The shared library contains settings loading, profile scanning, and recent-project parsing so behavior stays consistent across both apps.

## Glossary

See `docs/glossary.md`.
