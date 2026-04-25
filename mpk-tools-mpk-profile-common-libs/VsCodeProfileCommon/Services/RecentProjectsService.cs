using System.Data;
using System.IO;
using System.Linq;
using System.Text.Json;
using Microsoft.Data.Sqlite;
using VsCodeProfileCommon.Models;

namespace VsCodeProfileCommon.Services;

public static class RecentProjectsService
{
    private static readonly string[] StateDbKeys =
    [
        "history.recentlyOpenedPathsList",
        "recentlyOpenedPathsList",
        "openedPathsList"
    ];

    public static List<VsCodeRecentProject> ReadFromProfile(string profileUserDataDirectory, bool includeMissing = false)
    {
        if (string.IsNullOrWhiteSpace(profileUserDataDirectory))
        {
            return [];
        }

        foreach (var globalStorageDirectory in ResolveGlobalStorageDirectories(profileUserDataDirectory))
        {
            var storageJsonPath = Path.Combine(globalStorageDirectory, "storage.json");
            var stateDbPath = Path.Combine(globalStorageDirectory, "state.vscdb");

            var fromStorage = ReadFromStorageJson(storageJsonPath);
            if (fromStorage.Count > 0)
            {
                return includeMissing ? fromStorage : fromStorage.Where(project => project.Exists).ToList();
            }

            var fromStateDb = ReadFromStateDb(stateDbPath);
            if (fromStateDb.Count > 0)
            {
                return includeMissing ? fromStateDb : fromStateDb.Where(project => project.Exists).ToList();
            }
        }

        return [];
    }

    private static IEnumerable<string> ResolveGlobalStorageDirectories(string profileUserDataDirectory)
    {
        var candidates = new[]
        {
            Path.Combine(profileUserDataDirectory, "User", "globalStorage"),
            Path.Combine(profileUserDataDirectory, "globalStorage")
        };

        return candidates.Distinct(StringComparer.OrdinalIgnoreCase);
    }

    public static List<VsCodeRecentProject> ReadFromStorageJson(string storageJsonPath)
    {
        if (!File.Exists(storageJsonPath))
        {
            return [];
        }

        try
        {
            using var stream = File.OpenRead(storageJsonPath);
            using var json = JsonDocument.Parse(stream);

            if (!json.RootElement.TryGetProperty("recentlyOpenedPathsList", out var listNode) ||
                !listNode.TryGetProperty("entries", out var entriesNode) ||
                entriesNode.ValueKind != JsonValueKind.Array)
            {
                return ExtractBackupWorkspaceProjects(json.RootElement);
            }

            return ExtractProjects(entriesNode, "storage.json");
        }
        catch
        {
            return [];
        }
    }

    private static List<VsCodeRecentProject> ExtractBackupWorkspaceProjects(JsonElement root)
    {
        if (!root.TryGetProperty("backupWorkspaces", out var backupNode) ||
            backupNode.ValueKind != JsonValueKind.Object)
        {
            return [];
        }

        var projects = new List<VsCodeRecentProject>();
        var index = 0;

        if (backupNode.TryGetProperty("folders", out var foldersNode) && foldersNode.ValueKind == JsonValueKind.Array)
        {
            foreach (var folder in foldersNode.EnumerateArray())
            {
                if (!folder.TryGetProperty("folderUri", out var folderUriNode) || folderUriNode.ValueKind != JsonValueKind.String)
                {
                    continue;
                }

                var uri = folderUriNode.GetString();
                if (string.IsNullOrWhiteSpace(uri))
                {
                    continue;
                }

                var normalizedPath = NormalizeFileUri(uri);
                if (string.IsNullOrWhiteSpace(normalizedPath))
                {
                    continue;
                }

                projects.Add(new VsCodeRecentProject
                {
                    Index = index,
                    Kind = "folder",
                    Uri = uri,
                    Path = normalizedPath,
                    Exists = File.Exists(normalizedPath) || Directory.Exists(normalizedPath),
                    Source = "storage.json.backupWorkspaces",
                    LastAccessedUtc = TryGetTimestampUtc(folder, out var timestampUtc) ? timestampUtc : null
                });

                index += 1;
            }
        }

        if (backupNode.TryGetProperty("workspaces", out var workspacesNode) && workspacesNode.ValueKind == JsonValueKind.Array)
        {
            foreach (var workspace in workspacesNode.EnumerateArray())
            {
                if (!workspace.TryGetProperty("configURIPath", out var configUriNode) || configUriNode.ValueKind != JsonValueKind.String)
                {
                    continue;
                }

                var uri = configUriNode.GetString();
                if (string.IsNullOrWhiteSpace(uri))
                {
                    continue;
                }

                var normalizedPath = NormalizeFileUri(uri);
                if (string.IsNullOrWhiteSpace(normalizedPath))
                {
                    continue;
                }

                projects.Add(new VsCodeRecentProject
                {
                    Index = index,
                    Kind = "workspace",
                    Uri = uri,
                    Path = normalizedPath,
                    Exists = File.Exists(normalizedPath) || Directory.Exists(normalizedPath),
                    Source = "storage.json.backupWorkspaces",
                    LastAccessedUtc = TryGetTimestampUtc(workspace, out var timestampUtc) ? timestampUtc : null
                });

                index += 1;
            }
        }

        return projects;
    }

    public static List<VsCodeRecentProject> ReadFromStateDb(string stateDbPath)
    {
        if (!File.Exists(stateDbPath))
        {
            return [];
        }

        var projects = new List<VsCodeRecentProject>();

        try
        {
            var builder = new SqliteConnectionStringBuilder
            {
                DataSource = stateDbPath,
                Mode = SqliteOpenMode.ReadOnly,
                Pooling = false
            };

            using var connection = new SqliteConnection(builder.ToString());
            connection.Open();

            using var command = connection.CreateCommand();
            command.CommandText = @"
SELECT [key], value
FROM ItemTable
WHERE [key] IN ('history.recentlyOpenedPathsList', 'recentlyOpenedPathsList', 'openedPathsList');";

            using var reader = command.ExecuteReader();

            while (reader.Read())
            {
                if (reader.GetFieldType(1) != typeof(string))
                {
                    continue;
                }

                var rawJson = reader.GetString(1);
                if (string.IsNullOrWhiteSpace(rawJson))
                {
                    continue;
                }

                var parsed = ExtractFromStatePayload(rawJson);
                if (parsed.Count > 0)
                {
                    projects.AddRange(parsed);
                    break;
                }
            }
        }
        catch
        {
            return [];
        }

        return projects;
    }

    private static List<VsCodeRecentProject> ExtractFromStatePayload(string rawJson)
    {
        try
        {
            using var json = JsonDocument.Parse(rawJson);
            var root = json.RootElement;

            if (root.TryGetProperty("recentlyOpenedPathsList", out var nestedList) &&
                nestedList.TryGetProperty("entries", out var nestedEntries) &&
                nestedEntries.ValueKind == JsonValueKind.Array)
            {
                return ExtractProjects(nestedEntries, "state.vscdb");
            }

            if (root.TryGetProperty("entries", out var entriesNode) && entriesNode.ValueKind == JsonValueKind.Array)
            {
                return ExtractProjects(entriesNode, "state.vscdb");
            }

            return [];
        }
        catch
        {
            return [];
        }
    }

    private static List<VsCodeRecentProject> ExtractProjects(JsonElement entriesNode, string source)
    {
        var projects = new List<VsCodeRecentProject>();
        var index = 0;

        foreach (var entry in entriesNode.EnumerateArray())
        {
            var hasFolder = entry.TryGetProperty("folderUri", out var folderUriNode) && folderUriNode.ValueKind == JsonValueKind.String;
            var hasWorkspace = entry.TryGetProperty("workspaceUri", out var workspaceUriNode) && workspaceUriNode.ValueKind == JsonValueKind.String;

            var uri = hasFolder
                ? folderUriNode.GetString()
                : hasWorkspace
                    ? workspaceUriNode.GetString()
                    : null;

            if (string.IsNullOrWhiteSpace(uri))
            {
                index += 1;
                continue;
            }

            var normalizedPath = NormalizeFileUri(uri);
            if (string.IsNullOrWhiteSpace(normalizedPath))
            {
                index += 1;
                continue;
            }

            var kind = hasFolder ? "folder" : hasWorkspace ? "workspace" : "unknown";

            projects.Add(new VsCodeRecentProject
            {
                Index = index,
                Kind = kind,
                Uri = uri,
                Path = normalizedPath,
                Exists = File.Exists(normalizedPath) || Directory.Exists(normalizedPath),
                Source = source,
                LastAccessedUtc = TryGetTimestampUtc(entry, out var timestampUtc) ? timestampUtc : null
            });

            index += 1;
        }

        return projects;
    }

    private static string NormalizeFileUri(string uri)
    {
        if (!uri.StartsWith("file:///", StringComparison.OrdinalIgnoreCase))
        {
            return uri;
        }

        var decoded = Uri.UnescapeDataString(uri.Substring("file:///".Length));

        return OperatingSystem.IsWindows()
            ? decoded.Replace('/', '\\')
            : $"/{decoded}";
    }

    private static bool TryGetTimestampUtc(JsonElement entry, out DateTime timestampUtc)
    {
        timestampUtc = default;

        if (!entry.TryGetProperty("timestamp", out var node))
        {
            return false;
        }

        long unixValue;

        if (node.ValueKind == JsonValueKind.Number && node.TryGetInt64(out unixValue))
        {
            // Heuristic: values >= 10^12 are milliseconds; otherwise seconds.
            timestampUtc = unixValue >= 1_000_000_000_000
                ? DateTimeOffset.FromUnixTimeMilliseconds(unixValue).UtcDateTime
                : DateTimeOffset.FromUnixTimeSeconds(unixValue).UtcDateTime;
            return true;
        }

        if (node.ValueKind == JsonValueKind.String && long.TryParse(node.GetString(), out unixValue))
        {
            timestampUtc = unixValue >= 1_000_000_000_000
                ? DateTimeOffset.FromUnixTimeMilliseconds(unixValue).UtcDateTime
                : DateTimeOffset.FromUnixTimeSeconds(unixValue).UtcDateTime;
            return true;
        }

        return false;
    }
}
