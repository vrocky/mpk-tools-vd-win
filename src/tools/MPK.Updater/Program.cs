using System.Diagnostics;
using System.Text.Json;
using Microsoft.Win32;

const string AppDisplayName = "MPK Tools";
const string DefaultAssetPattern = "MPK-Tools-Setup-*.exe";
const string DefaultRepository = "vrocky/mpk-tools-vd-win";

var options = ParseArguments(args);

if (options.ShowHelp)
{
    PrintUsage();
    return 0;
}

if (!IsGhInstalled())
{
    Console.Error.WriteLine("GitHub CLI (gh) is required but was not found in PATH.");
    return 1;
}

try
{
    var release = await GetLatestReleaseAsync(options.Repository);
    var latestVersion = NormalizeVersion(release.TagName);
    var currentVersion = options.CurrentVersion ?? GetInstalledVersion() ?? "0.0.0";

    Console.WriteLine($"Installed version: {currentVersion}");
    Console.WriteLine($"Latest release:    {latestVersion} ({release.TagName})");

    if (CompareVersions(latestVersion, currentVersion) <= 0)
    {
        Console.WriteLine("No update required.");
        return 0;
    }

    if (!options.Silent)
    {
        Console.Write("Update available. Download and install now? [y/N]: ");
        var input = Console.ReadLine()?.Trim();
        if (!string.Equals(input, "y", StringComparison.OrdinalIgnoreCase) &&
            !string.Equals(input, "yes", StringComparison.OrdinalIgnoreCase))
        {
            Console.WriteLine("Update cancelled.");
            return 0;
        }
    }

    var tempDir = Path.Combine(Path.GetTempPath(), "MPKToolsUpdater", release.TagName);
    Directory.CreateDirectory(tempDir);

    DownloadInstaller(options.Repository, release.TagName, options.AssetPattern, tempDir);

    var installerPath = Directory
        .GetFiles(tempDir, options.AssetPattern, SearchOption.TopDirectoryOnly)
        .OrderByDescending(File.GetLastWriteTimeUtc)
        .FirstOrDefault();

    if (string.IsNullOrWhiteSpace(installerPath))
    {
        throw new InvalidOperationException($"No installer matching pattern '{options.AssetPattern}' was downloaded.");
    }

    Console.WriteLine($"Launching installer: {installerPath}");
    LaunchInstaller(installerPath, options.Silent);
    return 0;
}
catch (Exception ex)
{
    Console.Error.WriteLine(ex.Message);
    return 1;
}

static void PrintUsage()
{
    Console.WriteLine("MPKToolsUpdater");
    Console.WriteLine("Checks GitHub releases and runs the latest installer if newer than installed version.");
    Console.WriteLine();
    Console.WriteLine("Usage:");
    Console.WriteLine("  MPKToolsUpdater.exe [--repo <owner/repo>] [--current-version <x.y.z>] [--asset-pattern <glob>] [--silent]");
    Console.WriteLine();
    Console.WriteLine("Options:");
    Console.WriteLine($"  --repo             GitHub repository (default: {DefaultRepository}).");
    Console.WriteLine("  --current-version  Override installed version detection.");
    Console.WriteLine($"  --asset-pattern    Asset file pattern to download. Default: {DefaultAssetPattern}");
    Console.WriteLine("  --silent           Install without prompt and run installer with Inno silent flags.");
    Console.WriteLine("  -h, --help         Show this help.");
}

static UpdaterOptions ParseArguments(string[] args)
{
    var options = new UpdaterOptions
    {
        Repository = Environment.GetEnvironmentVariable("MPK_TOOLS_REPO") ?? DefaultRepository,
        AssetPattern = DefaultAssetPattern
    };

    for (var i = 0; i < args.Length; i++)
    {
        var arg = args[i];

        switch (arg)
        {
            case "--repo":
                options.Repository = ReadValue(args, ref i, "--repo");
                break;
            case "--current-version":
                options.CurrentVersion = ReadValue(args, ref i, "--current-version");
                break;
            case "--asset-pattern":
                options.AssetPattern = ReadValue(args, ref i, "--asset-pattern");
                break;
            case "--silent":
                options.Silent = true;
                break;
            case "-h":
            case "--help":
                options.ShowHelp = true;
                break;
            default:
                throw new ArgumentException($"Unknown argument: {arg}");
        }
    }

    return options;
}

static string ReadValue(string[] args, ref int index, string option)
{
    var next = index + 1;
    if (next >= args.Length)
    {
        throw new ArgumentException($"Missing value for {option}");
    }

    index = next;
    return args[next];
}

static bool IsGhInstalled()
{
    try
    {
        var result = RunProcess("gh", "--version", throwOnError: false);
        return result.ExitCode == 0;
    }
    catch
    {
        return false;
    }
}

static ReleaseInfo GetLatestRelease(string repository)
{
    var output = RunProcess(
        "gh",
        $"release view --repo \"{repository}\" --json tagName,name,isPrerelease,isDraft",
        throwOnError: true);

    var release = JsonSerializer.Deserialize<ReleaseInfo>(output.StandardOutput,
        new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

    if (release is null || string.IsNullOrWhiteSpace(release.TagName))
    {
        throw new InvalidOperationException("Unable to read release metadata from GitHub CLI output.");
    }

    if (release.IsDraft)
    {
        throw new InvalidOperationException("Latest release is a draft. Publish a non-draft release first.");
    }

    return release;
}

static async Task<ReleaseInfo> GetLatestReleaseAsync(string repository)
{
    return await Task.Run(() => GetLatestRelease(repository));
}

static void DownloadInstaller(string repository, string tagName, string assetPattern, string targetDir)
{
    var args = $"release download \"{tagName}\" --repo \"{repository}\" --pattern \"{assetPattern}\" --dir \"{targetDir}\" --clobber";
    RunProcess("gh", args, throwOnError: true);
}

static void LaunchInstaller(string installerPath, bool silent)
{
    var mode = silent ? "/VERYSILENT" : "/SILENT";
    var arguments = $"{mode} /SUPPRESSMSGBOXES /NORESTART /SP-";

    Process.Start(new ProcessStartInfo
    {
        FileName = installerPath,
        Arguments = arguments,
        UseShellExecute = true,
        Verb = "runas"
    });
}

static ProcessResult RunProcess(string fileName, string arguments, bool throwOnError)
{
    using var process = new Process
    {
        StartInfo = new ProcessStartInfo
        {
            FileName = fileName,
            Arguments = arguments,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true
        }
    };

    process.Start();
    var stdOut = process.StandardOutput.ReadToEnd();
    var stdErr = process.StandardError.ReadToEnd();
    process.WaitForExit();

    if (throwOnError && process.ExitCode != 0)
    {
        var message = string.IsNullOrWhiteSpace(stdErr) ? stdOut : stdErr;
        throw new InvalidOperationException($"Command failed: {fileName} {arguments}\n{message}".Trim());
    }

    return new ProcessResult(process.ExitCode, stdOut, stdErr);
}

static string? GetInstalledVersion()
{
    foreach (var hive in new[] { RegistryHive.LocalMachine, RegistryHive.CurrentUser })
    {
        var viewVersions = hive == RegistryHive.LocalMachine
            ? new[] { RegistryView.Registry64, RegistryView.Registry32 }
            : new[] { RegistryView.Default };

        foreach (var view in viewVersions)
        {
            using var baseKey = RegistryKey.OpenBaseKey(hive, view);
            using var uninstall = baseKey.OpenSubKey(@"Software\Microsoft\Windows\CurrentVersion\Uninstall");
            if (uninstall is null)
            {
                continue;
            }

            foreach (var subKeyName in uninstall.GetSubKeyNames())
            {
                using var sub = uninstall.OpenSubKey(subKeyName);
                var displayName = sub?.GetValue("DisplayName") as string;
                if (!string.Equals(displayName, AppDisplayName, StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                var version = sub.GetValue("DisplayVersion") as string;
                if (!string.IsNullOrWhiteSpace(version))
                {
                    return NormalizeVersion(version);
                }
            }
        }
    }

    return null;
}

static string NormalizeVersion(string value)
{
    if (string.IsNullOrWhiteSpace(value))
    {
        return "0.0.0";
    }

    var clean = value.Trim();
    if (clean.StartsWith("v", StringComparison.OrdinalIgnoreCase))
    {
        clean = clean[1..];
    }

    return clean.Split('-', 2)[0];
}

static int CompareVersions(string left, string right)
{
    var leftParts = ParseVersionParts(left);
    var rightParts = ParseVersionParts(right);
    var count = Math.Max(leftParts.Count, rightParts.Count);

    for (var i = 0; i < count; i++)
    {
        var l = i < leftParts.Count ? leftParts[i] : 0;
        var r = i < rightParts.Count ? rightParts[i] : 0;
        var comparison = l.CompareTo(r);
        if (comparison != 0)
        {
            return comparison;
        }
    }

    return 0;
}

static List<int> ParseVersionParts(string version)
{
    var parts = version.Split('.', StringSplitOptions.RemoveEmptyEntries);
    var output = new List<int>(parts.Length);

    foreach (var part in parts)
    {
        if (!int.TryParse(part, out var value))
        {
            break;
        }

        output.Add(value);
    }

    return output.Count == 0 ? new List<int> { 0 } : output;
}

internal sealed class UpdaterOptions
{
    public string Repository { get; set; } = string.Empty;
    public string AssetPattern { get; set; } = "MPK-Tools-Setup-*.exe";
    public string? CurrentVersion { get; set; }
    public bool Silent { get; set; }
    public bool ShowHelp { get; set; }
}

internal sealed class ReleaseInfo
{
    public string TagName { get; set; } = string.Empty;
    public string? Name { get; set; }
    public bool IsPrerelease { get; set; }
    public bool IsDraft { get; set; }
}

internal sealed record ProcessResult(int ExitCode, string StandardOutput, string StandardError);
