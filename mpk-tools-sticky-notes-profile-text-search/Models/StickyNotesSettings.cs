namespace StickyNotesProfileTextSearch.Models;

/// <summary>
/// Application settings for StickyNotes text search
/// </summary>
public class StickyNotesSettings
{
    public string DataDirectory { get; set; } = @"C:\StickyNotesProfiles";
    public string StickyNotesExePath { get; set; } = @"C:\Program Files\StickyNotesApp\StickyNotesApp.exe";
}
