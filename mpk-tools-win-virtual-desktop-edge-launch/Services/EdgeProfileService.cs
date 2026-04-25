using System.IO;
using System.Text.Json;
using EdgeProfilePicker.Models;

namespace EdgeProfilePicker.Services;

public static class EdgeProfileService
{
    private static readonly string[] AvatarColors =
    [
        "#e94560", "#0f3460", "#533483", "#2b9348",
        "#e76f51", "#457b9d", "#6d6875", "#e9c46a"
    ];

    public static string EdgeExePath =>
        @"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe";

    public static List<EdgeProfile> LoadProfiles()
    {
        var userDataPath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "Microsoft", "Edge", "User Data");

        if (!Directory.Exists(userDataPath))
            return [];

        var folders = Directory.GetDirectories(userDataPath)
            .Select(Path.GetFileName)
            .Where(n => n == "Default" || (n!.StartsWith("Profile ") && int.TryParse(n[8..], out _)))
            .OrderBy(n => n == "Default" ? 0 : int.Parse(n![8..]))
            .ToList();

        var profiles = new List<EdgeProfile>();
        int colorIndex = 0;

        foreach (var folder in folders)
        {
            var prefsFile = Path.Combine(userDataPath, folder!, "Preferences");
            if (!File.Exists(prefsFile)) continue;

            try
            {
                using var doc = JsonDocument.Parse(File.ReadAllText(prefsFile));
                var profileNode = doc.RootElement.GetProperty("profile");

                var name = profileNode.TryGetProperty("name", out var nameProp)
                    ? nameProp.GetString() ?? folder!
                    : folder!;

                var email = profileNode.TryGetProperty("user_name", out var emailProp)
                    ? emailProp.GetString() ?? ""
                    : "";

                var icoPath = Path.Combine(userDataPath, folder!, "Edge Profile.ico");

                profiles.Add(new EdgeProfile
                {
                    Folder = folder!,
                    Name = name,
                    Email = string.IsNullOrEmpty(email) ? "No account signed in" : email,
                    Initials = GetInitials(name),
                    AvatarColor = AvatarColors[colorIndex % AvatarColors.Length],
                    PicturePath = File.Exists(icoPath) ? icoPath : null
                });

                colorIndex++;
            }
            catch { /* skip unreadable profiles */ }
        }

        return profiles;
    }

    private static string GetInitials(string name)
    {
        var parts = name.Split([' ', ':', '_', '-'], StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length >= 2)
            return $"{char.ToUpper(parts[0][0])}{char.ToUpper(parts[1][0])}";
        if (parts.Length == 1 && parts[0].Length > 0)
            return char.ToUpper(parts[0][0]).ToString();
        return "?";
    }
}
