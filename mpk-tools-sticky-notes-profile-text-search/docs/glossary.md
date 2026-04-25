# Glossary

## Data Directory
The root directory where all StickyNotes profiles are stored.

Example: `C:\StickyNotesProfiles`

This directory contains a `profiles` subdirectory with individual profile folders.

## Profile
An isolated StickyNotes environment containing a `notes.json` file with all notes for that profile.

Example: `C:\StickyNotesProfiles\profiles\virtual_desktop_1\`

## Note
A single sticky note entry with:
- `id` - Unique identifier (e.g., "note_1714069200_abc123")
- `title` - Note title text (optional)
- `content` - Note body text
- `color` - Background color hex code (e.g., "#fff740")
- `createdAt` - Creation timestamp
- `updatedAt` - Last modification timestamp

## notes.json
The JSON file in each profile containing all notes:
```json
{
  "notes": [
    {
      "id": "note_...",
      "title": "My Note",
      "content": "Note content...",
      "color": "#fff740",
      "createdAt": "2026-04-25T...",
      "updatedAt": "2026-04-25T..."
    }
  ],
  "updatedAt": "2026-04-25T..."
}
```

## Note Index
The searchable collection of all notes built by scanning all profiles. Updated each time you click "Refresh" or change settings.

## Full-Text Search
Search functionality that looks for matches in:
- Note title
- Note content
- Profile name
- Note ID

Results update instantly as you type.

## Content Preview
Truncated view of note content (first 150 characters) displayed in note cards. Newlines are replaced with spaces for compact display.

## Timeline Label
Human-readable time since last update (e.g., "5m ago", "3h ago", "2d ago").

## Launch Arguments
The command line arguments passed to StickyNotesApp when opening a note:
- `--profile` - The profile name
- `--data-dir` - The data directory path

Example: `StickyNotesApp.exe --profile "virtual_desktop_1" --data-dir "C:\StickyNotesProfiles"`

## Registry Settings Key
`HKEY_CURRENT_USER\\Software\\StickyNotesProfileTextSearch`

Stores:
- `DataDirectory` - Path to the data directory
- `StickyNotesExePath` - Path to StickyNotesApp.exe

## Virtual Desktop Profile
A profile automatically named `virtual_desktop_N` where N is the virtual desktop number. These profiles are displayed as "Virtual Desktop N" in the UI.
