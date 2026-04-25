using System.IO;
using System.Text.RegularExpressions;
using StickyNotesProfilePicker.Models;

namespace StickyNotesProfilePicker.Services;

public static class StickyNotesProfileScanService
{
    public static List<StickyNotesProfile> ScanProfiles(string dataDirectory)
    {
        var profiles = new List<StickyNotesProfile>();

        if (string.IsNullOrWhiteSpace(dataDirectory) || !Directory.Exists(dataDirectory))
        {
            return profiles;
        }

        var profilesDir = Path.Combine(dataDirectory, "profiles");
        if (!Directory.Exists(profilesDir))
        {
            Directory.CreateDirectory(profilesDir);
            return profiles;
        }

        var subdirs = Directory.GetDirectories(profilesDir);

        foreach (var dir in subdirs)
        {
            var dirName = Path.GetFileName(dir);
            var profile = new StickyNotesProfile
            {
                Name = FormatProfileName(dirName),
                FullPath = dir,
                LastModified = Directory.GetLastWriteTime(dir),
                Initials = GenerateInitials(dirName),
                AvatarColor = GenerateColor(dirName)
            };

            // Check if it's a virtual desktop profile
            var vdMatch = Regex.Match(dirName, @"^virtual_desktop_(\d+)$", RegexOptions.IgnoreCase);
            if (vdMatch.Success)
            {
                profile.IsVirtualDesktop = true;
                profile.VirtualDesktopNumber = int.Parse(vdMatch.Groups[1].Value);
            }

            profiles.Add(profile);
        }

        return profiles
            .OrderBy(p => !p.IsVirtualDesktop) // Virtual desktop profiles first
            .ThenBy(p => p.VirtualDesktopNumber ?? int.MaxValue)
            .ThenBy(p => p.Name, StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    private static string FormatProfileName(string dirName)
    {
        // Convert "virtual_desktop_8" -> "Virtual Desktop 8"
        var vdMatch = Regex.Match(dirName, @"^virtual_desktop_(\d+)$", RegexOptions.IgnoreCase);
        if (vdMatch.Success)
        {
            return $"Virtual Desktop {vdMatch.Groups[1].Value}";
        }

        // Otherwise use the directory name with underscores replaced
        return dirName.Replace('_', ' ');
    }

    private static string GenerateInitials(string name)
    {
        var vdMatch = Regex.Match(name, @"^virtual_desktop_(\d+)$", RegexOptions.IgnoreCase);
        if (vdMatch.Success)
        {
            return $"VD{vdMatch.Groups[1].Value}";
        }

        var words = name.Split(new[] { ' ', '_', '-' }, StringSplitOptions.RemoveEmptyEntries);
        if (words.Length == 0) return "SN";
        if (words.Length == 1) return words[0].Substring(0, Math.Min(2, words[0].Length)).ToUpper();
        return (words[0][0].ToString() + words[1][0].ToString()).ToUpper();
    }

    private static string GenerateColor(string name)
    {
        // Generate a color based on the name hash
        var hash = name.GetHashCode();
        var colors = new[]
        {
            "#007acc", "#68217a", "#ff6347", "#32cd32", "#ffa500",
            "#9370db", "#20b2aa", "#ff69b4", "#4682b4", "#dc143c"
        };
        return colors[Math.Abs(hash) % colors.Length];
    }
}
