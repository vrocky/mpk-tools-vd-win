# Glossary

## Profile Container Directory
The container directory that holds many VS Code profile directories.

Example: `C:\VSCodeProfiles`

This root path is what gets registered in `ProfileDirectories` (registry).

## VS Code Profile Directory
A single profile folder inside the profile container directory.

Example: `C:\VSCodeProfiles\Work`

Each profile directory contains its own `user-data` and `extensions` folders.

## VS Code Profile
A folder that isolates a VS Code environment through:
- `user-data` (settings/state)
- `extensions` (installed extensions)

## Registry Settings Key
`HKEY_CURRENT_USER\\Software\\VsCodeProfilePicker`, used by both picker and project-search apps.

## User Data Path
The path supplied to VS Code via `--user-data-dir`.

## Extensions Path
The path supplied to VS Code via `--extensions-dir`.

## Recent Projects Index
Aggregated folder/workspace entries parsed from profile-local VS Code storage (`storage.json` or `state.vscdb`).

## Profile-Scoped Launch
Opening VS Code with both profile isolation flags so the selected project opens in the intended profile context.
