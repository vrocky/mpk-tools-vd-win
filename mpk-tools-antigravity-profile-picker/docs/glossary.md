# Glossary

## Profile Container Directory
The container directory that holds many Antigravity profile directories.

Example: `C:\AntiGravityProfiles`

This root path is what gets registered in `ProfileDirectories` (registry).

## Antigravity Profile Directory
A single profile folder inside the profile container directory.

Example: `C:\AntiGravityProfiles\Work`

Each profile directory contains its own `data` folder.

## Antigravity Profile
A folder that isolates an Antigravity environment through:
- `data` (settings/state/extensions)

## Registry Settings Key
`HKEY_CURRENT_USER\\Software\\AntigravityProfilePicker`, used by the Antigravity profile picker app.

## User Data Path
The path supplied to Antigravity via `--user-data-dir`.

## Recent Projects Index
Aggregated folder/workspace entries parsed from profile-local Antigravity storage (`storage.json` or `state.vscdb`).

## Profile-Scoped Launch
Opening Antigravity with the profile isolation flag so the selected project opens in the intended profile context.
