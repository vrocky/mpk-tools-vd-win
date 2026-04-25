# StickyNotes Profile Text Search

A WPF application for searching text across all your StickyNotes profiles. Find notes by title or content, no matter which profile they're in.

## Overview

This tool allows you to:
- **Search all notes** across multiple StickyNotes profiles simultaneously
- **Find notes by title or content** with instant filtering
- **Open notes in their original profile** with one click
- **Browse all notes** sorted by most recently updated

## Key Features

- **Full-Text Search**: Search through both note titles and content
- **Multi-Profile Support**: Searches all profiles in your data directory
- **Visual Note Cards**: Browse notes with color-coded cards showing title and preview
- **Quick Launch**: Open any note in StickyNotesApp with its original profile
- **Dark Theme UI**: Modern interface matching the StickyNotes aesthetic

## Usage

### Search for Notes
Type in the search box to filter notes by title, content, profile name, or note ID. The list updates instantly as you type.

### Open a Note
Click any note card or the "Open ▶" button to launch StickyNotesApp with that note's profile. The note will be available in the opened profile.

### Settings
Click the "⚙ Settings" button to configure:
- **Data Directory**: Where profiles are stored (default: `C:\StickyNotesProfiles`)
- **StickyNotesApp Executable**: Path to StickyNotesApp.exe (default: `C:\Program Files\StickyNotesApp\StickyNotesApp.exe`)

## Configuration

Settings are stored in the Windows Registry at:
```
HKEY_CURRENT_USER\Software\StickyNotesProfileTextSearch
```

## How It Works

The application:
1. Scans all profiles in `C:\StickyNotesProfiles\profiles\`
2. Reads each profile's `notes.json` file
3. Builds a searchable index of all notes
4. Displays notes with color, title, content preview, and timestamp
5. Launches StickyNotesApp with the correct profile when you open a note

## Note Structure

Each note from `notes.json` includes:
- **id**: Unique identifier
- **title**: Note title (may be empty)
- **content**: Note text content
- **color**: Background color (e.g., #fff740)
- **createdAt**: When the note was created
- **updatedAt**: When the note was last modified

## Technical Details

- Built with .NET 8.0-windows and WPF
- Uses System.Text.Json for parsing notes.json files
- Searches across all profiles in the data directory
- Launches StickyNotesApp with `--profile` and `--data-dir` arguments

## Command Line Arguments

When opening a note, the app launches StickyNotesApp with:
```
StickyNotesApp.exe --profile "profile_name" --data-dir "C:\StickyNotesProfiles"
```

## See Also

- [StickyNotes Profile Picker](../sticky-notes-profile-picker) - Launch and manage StickyNotes profiles
- [VS Code Profile Project Search](../vscode-profile-project-search) - Similar search tool for VS Code projects
- [Antigravity Profile Project Search](../antigravity-profile-project-search) - Similar search tool for Antigravity projects
