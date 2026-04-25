using System;
using System.IO;
using Microsoft.Win32;
using VsCodeProfileCommon.Models;

namespace AntigravityProfileProjectSearch.Services;

public static class AntigravitySettingsService
{
    private const string RegistryKey = @"Software\AntigravityProfileProjectSearch";

    public static AppSettings Load()
    {
        using var key = Registry.CurrentUser.CreateSubKey(RegistryKey, writable: false);

        var settings = new AppSettings();

        var exePath = key.GetValue("AntigravityExePath") as string;
        if (!string.IsNullOrWhiteSpace(exePath) && File.Exists(exePath))
        {
            settings.VsCodeExePath = exePath;
        }
        else
        {
            var localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            var defaultExe = Path.Combine(localAppData, @"Programs\AntiGravity\AntiGravity.exe");
            settings.VsCodeExePath = File.Exists(defaultExe) ? defaultExe : "";
        }

        var profileDirectoriesRaw = key.GetValue("ProfileDirectories") as string;
        if (!string.IsNullOrWhiteSpace(profileDirectoriesRaw))
        {
            settings.ProfileDirectories = profileDirectoriesRaw
                .Split(';', StringSplitOptions.RemoveEmptyEntries)
                .Select(d => d.Trim())
                .Where(d => !string.IsNullOrWhiteSpace(d))
                .ToList();
        }
        else
        {
            settings.ProfileDirectories = new List<string> { @"C:\AntiGravityProfiles" };
        }

        return settings;
    }

    public static void Save(AppSettings settings)
    {
        using var key = Registry.CurrentUser.CreateSubKey(RegistryKey, writable: true);

        key.SetValue("AntigravityExePath", settings.VsCodeExePath ?? "", RegistryValueKind.String);

        var profileDirectories = string.Join(";", settings.ProfileDirectories.Where(d => !string.IsNullOrWhiteSpace(d)));
        key.SetValue("ProfileDirectories", profileDirectories, RegistryValueKind.String);
    }
}
