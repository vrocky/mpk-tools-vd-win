using Microsoft.Win32;
using VsCodeProfileCommon.Models;

namespace AntigravityProfilePicker.Services;

public static class AntigravitySettingsService
{
    public const string RegistryRelativeKey = @"Software\AntigravityProfilePicker";
    private const string DirectoriesValue = "ProfileDirectories";
    private const string AntigravityExePathValue = "AntigravityExePath";

    public static AppSettings Load()
    {
        try
        {
            using var key = Registry.CurrentUser.OpenSubKey(RegistryRelativeKey);
            if (key is null)
            {
                return new AppSettings
                {
                    ProfileDirectories = new List<string> { @"C:\AntiGravityProfiles" },
                    VsCodeExePath = $@"{Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData)}\Programs\AntiGravity\AntiGravity.exe"
                };
            }

            var directories = (key.GetValue(DirectoriesValue) as string[] ?? [])
                .Where(path => !string.IsNullOrWhiteSpace(path))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();

            if (directories.Count == 0)
            {
                directories.Add(@"C:\AntiGravityProfiles");
            }

            var antigravityExePath = key.GetValue(AntigravityExePathValue) as string;
            var defaultExePath = $@"{Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData)}\Programs\AntiGravity\AntiGravity.exe";

            return new AppSettings
            {
                ProfileDirectories = directories,
                VsCodeExePath = string.IsNullOrWhiteSpace(antigravityExePath) ? defaultExePath : antigravityExePath
            };
        }
        catch
        {
            return new AppSettings
            {
                ProfileDirectories = new List<string> { @"C:\AntiGravityProfiles" },
                VsCodeExePath = $@"{Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData)}\Programs\AntiGravity\AntiGravity.exe"
            };
        }
    }

    public static void Save(AppSettings settings)
    {
        using var key = Registry.CurrentUser.CreateSubKey(RegistryRelativeKey);
        key?.SetValue(DirectoriesValue, settings.ProfileDirectories.ToArray(), RegistryValueKind.MultiString);
        key?.SetValue(AntigravityExePathValue, settings.VsCodeExePath, RegistryValueKind.String);
    }
}
