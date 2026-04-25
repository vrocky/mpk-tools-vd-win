namespace VsCodeProfileCommon.Models;

public sealed class AppSettings
{
    public List<string> ProfileDirectories { get; set; } = [];
    public string VsCodeExePath { get; set; } = "code";
}
