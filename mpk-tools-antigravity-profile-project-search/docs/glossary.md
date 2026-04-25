# Glossary

## Profile Container Directory
The parent directory that contains multiple Antigravity profile directories.

Example: `C:\AntiGravityProfiles`

This is the directory stored in registry value `ProfileDirectories`.

## Antigravity Profile Directory
A single child folder under the profile container directory representing one Antigravity profile.

Example: `C:\AntiGravityProfiles\Work`

Each profile directory includes a `data` folder (Antigravity style) or `user-data` and `extensions` (VS Code style for compatibility).

## Antigravity Profile
A profile folder containing isolated Antigravity data:
- `data` (Antigravity style - single directory)
- Or `user-data` and `extensions` (VS Code compatibility)

## User Data Directory
The path passed to Antigravity with `--user-data-dir`. It stores settings, UI state, and global storage.

For Antigravity profiles, this is typically the `data` folder within the profile directory.

## Extensions Directory
In Antigravity, extensions are managed within the user data directory. The `--extensions-dir` flag is not used.

## Recent Projects
Antigravity recently opened folder/workspace entries, read from `storage.json` or `state.vscdb`.

## Workspace Project
A `.code-workspace` file entry from recent projects.

## Folder Project
A folder URI entry from recent projects.

## Profile-Scoped Open
Opening a project with `--user-data-dir` set to a specific profile and `--new-window` to open in a new window.

Antigravity uses: `antigravity --user-data-dir "<profile>\data" --new-window "<projectPath>"`

