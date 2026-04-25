using Microsoft.Win32;
using VsCodeProfileCommon.Models;

namespace VsCodeProfileCommon.Services;

public static class SettingsService
{
    public const string RegistryRelativeKey = @"Software\VsCodeProfilePicker";
    private const string DirectoriesValue = "ProfileDirectories";
    private const string VsCodeExePathValue = "VsCodeExePath";

    public static AppSettings Load()
    {
        try
        {
            using var key = Registry.CurrentUser.OpenSubKey(RegistryRelativeKey);
            if (key is null)
            {
                return new AppSettings();
            }

            var directories = (key.GetValue(DirectoriesValue) as string[] ?? [])
                .Where(path => !string.IsNullOrWhiteSpace(path))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();

            var vscodeExePath = key.GetValue(VsCodeExePathValue) as string;

            return new AppSettings
            {
                ProfileDirectories = directories,
                VsCodeExePath = string.IsNullOrWhiteSpace(vscodeExePath) ? "code" : vscodeExePath
            };
        }
        catch
        {
            return new AppSettings();
        }
    }

    public static void Save(AppSettings settings)
    {
        using var key = Registry.CurrentUser.CreateSubKey(RegistryRelativeKey);
        key?.SetValue(DirectoriesValue, settings.ProfileDirectories.ToArray(), RegistryValueKind.MultiString);
        key?.SetValue(VsCodeExePathValue, settings.VsCodeExePath, RegistryValueKind.String);
    }
}
