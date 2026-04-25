using Microsoft.Win32;
using StickyNotesProfileTextSearch.Models;

namespace StickyNotesProfileTextSearch.Services;

/// <summary>
/// Manages application settings via Windows Registry
/// </summary>
public static class StickyNotesSettingsService
{
    private const string RegistryKeyPath = @"Software\StickyNotesProfileTextSearch";

    public static StickyNotesSettings Load()
    {
        try
        {
            using var key = Registry.CurrentUser.OpenSubKey(RegistryKeyPath, false);
            if (key == null)
            {
                // Return defaults if no settings exist
                return new StickyNotesSettings();
            }

            return new StickyNotesSettings
            {
                DataDirectory = key.GetValue("DataDirectory")?.ToString() 
                    ?? @"C:\StickyNotesProfiles",
                StickyNotesExePath = key.GetValue("StickyNotesExePath")?.ToString() 
                    ?? @"C:\Program Files\StickyNotesApp\StickyNotesApp.exe"
            };
        }
        catch
        {
            return new StickyNotesSettings();
        }
    }

    public static void Save(StickyNotesSettings settings)
    {
        try
        {
            using var key = Registry.CurrentUser.CreateSubKey(RegistryKeyPath);
            key.SetValue("DataDirectory", settings.DataDirectory);
            key.SetValue("StickyNotesExePath", settings.StickyNotesExePath);
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException("Failed to save settings to registry.", ex);
        }
    }
}
