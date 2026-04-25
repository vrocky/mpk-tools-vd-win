using Microsoft.Win32;
using StickyNotesProfilePicker.Models;

namespace StickyNotesProfilePicker.Services;

public static class StickyNotesSettingsService
{
    private const string RegistryKey = @"Software\StickyNotesProfilePicker";

    public static StickyNotesSettings Load()
    {
        try
        {
            using var key = Registry.CurrentUser.OpenSubKey(RegistryKey);
            if (key is null)
            {
                return new StickyNotesSettings();
            }

            var dataDir = key.GetValue("DataDirectory") as string;
            var exePath = key.GetValue("StickyNotesExePath") as string;

            return new StickyNotesSettings
            {
                DataDirectory = string.IsNullOrWhiteSpace(dataDir) ? @"C:\StickyNotesProfiles" : dataDir,
                StickyNotesExePath = string.IsNullOrWhiteSpace(exePath) ? @"C:\Program Files\StickyNotesApp\StickyNotesApp.exe" : exePath
            };
        }
        catch
        {
            return new StickyNotesSettings();
        }
    }

    public static void Save(StickyNotesSettings settings)
    {
        using var key = Registry.CurrentUser.CreateSubKey(RegistryKey);
        key?.SetValue("DataDirectory", settings.DataDirectory, RegistryValueKind.String);
        key?.SetValue("StickyNotesExePath", settings.StickyNotesExePath, RegistryValueKind.String);
    }
}
