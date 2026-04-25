# Glossary

## Data Directory
The root directory where all StickyNotes profiles are stored.

Example: `C:\StickyNotesProfiles`

This directory contains a `profiles` subdirectory with individual profile folders.

## Profile
An isolated StickyNotes environment containing:
- `config.json` - Profile configuration
- `notes.json` - Sticky notes data
- `.lock` - Profile lock file

Example: `C:\StickyNotesProfiles\profiles\virtual_desktop_1\`

## Virtual Desktop
A Windows virtual desktop workspace. Each virtual desktop can have its own StickyNotes profile.

Virtual desktop numbers start at 1 and are detected via Windows Registry.

## Virtual Desktop Profile
A profile automatically named `virtual_desktop_N` where N is the virtual desktop number.

These profiles are created automatically when launching StickyNotes for a specific virtual desktop.

## Profile Name
The name of the profile directory. For virtual desktop profiles, this is derived from the folder name (e.g., `virtual_desktop_8` becomes "Virtual Desktop 8").

## Launch Arguments
The command line arguments passed to StickyNotesApp:
- `--profile` - The profile name
- `--data-dir` - The data directory path

Example: `StickyNotesApp.exe --profile "virtual_desktop_1" --data-dir "C:\StickyNotesProfiles"`

## Registry Settings Key
`HKEY_CURRENT_USER\\Software\\StickyNotesProfilePicker`

Stores:
- `DataDirectory` - Path to the data directory
- `StickyNotesExePath` - Path to StickyNotesApp.exe

## Profile Lock
The `.lock` file in each profile directory prevents multiple instances of StickyNotesApp from running with the same profile simultaneously.
