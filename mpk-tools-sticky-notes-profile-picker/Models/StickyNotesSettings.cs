namespace StickyNotesProfilePicker.Models;

public sealed class StickyNotesSettings
{
    public string DataDirectory { get; set; } = @"C:\StickyNotesProfiles";
    public string StickyNotesExePath { get; set; } = @"C:\Program Files\StickyNotesApp\StickyNotesApp.exe";
}
