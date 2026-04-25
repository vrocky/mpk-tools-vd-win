namespace StickyNotesProfilePicker.Models;

public sealed class StickyNotesProfile
{
    public string Name { get; set; } = "";
    public string FullPath { get; set; } = "";
    public string Initials { get; set; } = "";
    public string AvatarColor { get; set; } = "";
    public DateTime LastModified { get; set; }
    public bool IsVirtualDesktop { get; set; }
    public int? VirtualDesktopNumber { get; set; }
    
    public string LastModifiedDisplay =>
        LastModified == DateTime.MinValue ? "" : LastModified.ToString("MMM d");
}
