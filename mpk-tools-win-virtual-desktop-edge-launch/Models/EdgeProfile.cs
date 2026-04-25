namespace EdgeProfilePicker.Models;

public class EdgeProfile
{
    public string Folder { get; set; } = "";
    public string Name { get; set; } = "";
    public string Email { get; set; } = "";
    public string Initials { get; set; } = "";
    public string AvatarColor { get; set; } = "#0f3460";
    public string? PicturePath { get; set; }
    public bool HasPicture => !string.IsNullOrEmpty(PicturePath);
}
