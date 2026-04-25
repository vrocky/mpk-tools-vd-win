namespace VsCodeProfileCommon.Models;

public sealed class VsCodeProfile
{
    public string Name { get; set; } = "";
    public string FullPath { get; set; } = "";
    public string SourceDirectory { get; set; } = "";
    public string Initials { get; set; } = "";
    public string AvatarColor { get; set; } = "#007acc";
    public string UserDataPath { get; set; } = "";
    public string ExtensionsPath { get; set; } = "";
    public DateTime LastModified { get; set; }
    public string LastModifiedDisplay => LastModified == default
        ? "" : LastModified.ToString("MMM d, yyyy");
}
