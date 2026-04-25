namespace StickyNotesProfileTextSearch.Models;

/// <summary>
/// Represents a sticky note from a profile for text search
/// </summary>
public class NoteSearchItem
{
    public string ProfileName { get; set; } = string.Empty;
    public string ProfilePath { get; set; } = string.Empty;
    public string DataDirectory { get; set; } = string.Empty;
    
    public string NoteId { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string Color { get; set; } = "#fff740";
    
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    public bool ProfileExists { get; set; }
    
    // Display properties
    public string DisplayTitle => string.IsNullOrWhiteSpace(Title) ? "(Untitled Note)" : Title;
    public string ContentPreview
    {
        get
        {
            if (string.IsNullOrWhiteSpace(Content))
                return "(Empty note)";
            
            var preview = Content.Length > 150 
                ? Content.Substring(0, 150) + "..." 
                : Content;
            
            // Replace newlines with spaces for display
            return preview.Replace("\r\n", " ").Replace("\n", " ").Replace("\r", " ");
        }
    }
    
    public string TimelineLabel
    {
        get
        {
            var span = DateTime.Now - UpdatedAt;
            if (span.TotalMinutes < 60)
                return $"{(int)span.TotalMinutes}m ago";
            if (span.TotalHours < 24)
                return $"{(int)span.TotalHours}h ago";
            if (span.TotalDays < 7)
                return $"{(int)span.TotalDays}d ago";
            if (span.TotalDays < 30)
                return $"{(int)(span.TotalDays / 7)}w ago";
            if (span.TotalDays < 365)
                return $"{(int)(span.TotalDays / 30)}mo ago";
            return $"{(int)(span.TotalDays / 365)}y ago";
        }
    }
    
    public string ExistsLabel => ProfileExists ? "✓ exists" : "✗ missing";
}
