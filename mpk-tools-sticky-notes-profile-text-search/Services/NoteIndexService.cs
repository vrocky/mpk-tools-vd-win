using System.IO;
using System.Text.Json;
using StickyNotesProfileTextSearch.Models;

namespace StickyNotesProfileTextSearch.Services;

/// <summary>
/// Builds an index of all notes across all StickyNotes profiles
/// </summary>
public static class NoteIndexService
{
    public static List<NoteSearchItem> BuildIndex(StickyNotesSettings settings, bool includeMissing)
    {
        var results = new List<NoteSearchItem>();

        try
        {
            var profilesDir = Path.Combine(settings.DataDirectory, "profiles");
            
            if (!Directory.Exists(profilesDir))
            {
                LoggingService.Info($"Profiles directory not found: {profilesDir}");
                return results;
            }

            var profileDirs = Directory.GetDirectories(profilesDir);
            LoggingService.Info($"Found {profileDirs.Length} profile directories");

            foreach (var profileDir in profileDirs)
            {
                try
                {
                    var profileName = Path.GetFileName(profileDir);
                    var notesFile = Path.Combine(profileDir, "notes.json");

                    if (!File.Exists(notesFile))
                    {
                        LoggingService.Info($"No notes.json in profile: {profileName}");
                        continue;
                    }

                    var notes = ReadNotesFile(notesFile);
                    LoggingService.Info($"Profile '{profileName}': {notes.Count} notes");

                    foreach (var note in notes)
                    {
                        var item = new NoteSearchItem
                        {
                            ProfileName = FormatProfileName(profileName),
                            ProfilePath = profileDir,
                            DataDirectory = settings.DataDirectory,
                            NoteId = note.Id,
                            Title = note.Title ?? string.Empty,
                            Content = note.Content ?? string.Empty,
                            Color = note.Color ?? "#fff740",
                            CreatedAt = note.CreatedAt,
                            UpdatedAt = note.UpdatedAt,
                            ProfileExists = true
                        };

                        results.Add(item);
                    }
                }
                catch (Exception ex)
                {
                    LoggingService.Error($"Error processing profile directory: {profileDir}", ex);
                }
            }

            // Sort by most recently updated first
            results = results.OrderByDescending(n => n.UpdatedAt).ToList();
            LoggingService.Info($"Index complete: {results.Count} total notes");
        }
        catch (Exception ex)
        {
            LoggingService.Error("BuildIndex failed", ex);
        }

        return results;
    }

    private static List<Note> ReadNotesFile(string notesFilePath)
    {
        try
        {
            var json = File.ReadAllText(notesFilePath);
            var options = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            };
            var notesData = JsonSerializer.Deserialize<NotesData>(json, options);
            return notesData?.Notes ?? new List<Note>();
        }
        catch (Exception ex)
        {
            LoggingService.Error($"Error reading notes file: {notesFilePath}", ex);
            return new List<Note>();
        }
    }

    private static string FormatProfileName(string profileName)
    {
        // Convert "virtual_desktop_8" to "Virtual Desktop 8"
        if (profileName.StartsWith("virtual_desktop_", StringComparison.OrdinalIgnoreCase))
        {
            var parts = profileName.Split('_');
            if (parts.Length >= 3 && int.TryParse(parts[2], out var number))
            {
                return $"Virtual Desktop {number}";
            }
        }

        // Otherwise just title case
        return System.Globalization.CultureInfo.CurrentCulture.TextInfo.ToTitleCase(profileName.Replace("_", " "));
    }

    // JSON deserialization models
    private class NotesData
    {
        public List<Note> Notes { get; set; } = new();
        public string? UpdatedAt { get; set; }
    }

    private class Note
    {
        public string Id { get; set; } = string.Empty;
        public string? Title { get; set; }
        public string? Content { get; set; }
        public string? Color { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}
