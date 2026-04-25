using System.IO;
using VsCodeProfileCommon.Models;

namespace VsCodeProfileCommon.Services;

public static class ProfileScanService
{
    private static readonly HashSet<string> ReservedDirectoryNames = new(StringComparer.OrdinalIgnoreCase)
    {
        "user-data",
        "extensions",
        "data"
    };

    private static readonly string[] AvatarColors =
    [
        "#007acc", "#c586c0", "#4ec9b0", "#ce9178",
        "#569cd6", "#dcdcaa", "#6a9955", "#f44747",
        "#9cdcfe", "#d7ba7d", "#b5cea8", "#608b4e"
    ];

    public static List<VsCodeProfile> ScanAll(IEnumerable<string> directories)
    {
        var profiles = new List<VsCodeProfile>();
        var colorIndex = 0;

        foreach (var directory in directories.Where(path => !string.IsNullOrWhiteSpace(path)))
        {
            if (!Directory.Exists(directory))
            {
                continue;
            }

            var subDirectories = Directory.GetDirectories(directory)
                .OrderBy(path => Path.GetFileName(path), StringComparer.OrdinalIgnoreCase);

            foreach (var subDirectory in subDirectories)
            {
                var name = Path.GetFileName(subDirectory);
                if (ReservedDirectoryNames.Contains(name))
                {
                    continue;
                }

                var userDataPath = ResolveUserDataPath(subDirectory);
                var extensionsPath = ResolveExtensionsPath(subDirectory);

                Directory.CreateDirectory(userDataPath);
                Directory.CreateDirectory(extensionsPath);

                profiles.Add(new VsCodeProfile
                {
                    Name = name,
                    FullPath = subDirectory,
                    SourceDirectory = directory,
                    Initials = BuildInitials(name),
                    AvatarColor = AvatarColors[colorIndex % AvatarColors.Length],
                    UserDataPath = userDataPath,
                    ExtensionsPath = extensionsPath,
                    LastModified = Directory.GetLastWriteTime(subDirectory)
                });

                colorIndex += 1;
            }
        }

        return profiles;
    }

    private static string ResolveUserDataPath(string profileRoot)
    {
        var dataPath = Path.Combine(profileRoot, "data");
        if (Directory.Exists(dataPath))
        {
            return dataPath;
        }

        var userDataPath = Path.Combine(profileRoot, "user-data");
        if (Directory.Exists(userDataPath))
        {
            return userDataPath;
        }

        return userDataPath;
    }

    private static string ResolveExtensionsPath(string profileRoot)
    {
        var extensionsPath = Path.Combine(profileRoot, "extensions");
        return extensionsPath;
    }

    private static string BuildInitials(string name)
    {
        var parts = name.Split([' ', '-', '_', '.'], StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length >= 2)
        {
            return $"{char.ToUpper(parts[0][0])}{char.ToUpper(parts[1][0])}";
        }

        if (parts.Length == 1 && parts[0].Length > 0)
        {
            return parts[0].Length >= 2
                ? $"{char.ToUpper(parts[0][0])}{char.ToUpper(parts[0][1])}"
                : char.ToUpper(parts[0][0]).ToString();
        }

        return "?";
    }
}
