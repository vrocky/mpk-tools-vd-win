namespace VsCodeProfileCommon.Models;

public sealed class VsCodeRecentProject
{
    public int Index { get; set; }
    public string Kind { get; set; } = "unknown";
    public string Uri { get; set; } = "";
    public string Path { get; set; } = "";
    public bool Exists { get; set; }
    public string Source { get; set; } = "none";
    public DateTime? LastAccessedUtc { get; set; }
}
