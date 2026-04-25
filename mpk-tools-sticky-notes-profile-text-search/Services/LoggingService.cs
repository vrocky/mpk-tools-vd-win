using System.IO;

namespace StickyNotesProfileTextSearch.Services;

/// <summary>
/// Simple file-based logging service
/// </summary>
public static class LoggingService
{
    private static string? _logFilePath;

    public static void Initialize()
    {
        try
        {
            var appDataDir = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "StickyNotesProfileTextSearch"
            );
            
            Directory.CreateDirectory(appDataDir);
            _logFilePath = Path.Combine(appDataDir, "log.txt");
            
            File.AppendAllText(_logFilePath, 
                $"\n=== Session started at {DateTime.Now:yyyy-MM-dd HH:mm:ss} ===\n");
        }
        catch
        {
            // Ignore initialization errors
        }
    }

    public static void Info(string message)
    {
        Log("INFO", message);
    }

    public static void Error(string message, Exception? ex = null)
    {
        var fullMessage = ex == null ? message : $"{message}\n{ex}";
        Log("ERROR", fullMessage);
    }

    private static void Log(string level, string message)
    {
        if (_logFilePath == null) return;

        try
        {
            var timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            File.AppendAllText(_logFilePath, $"[{timestamp}] [{level}] {message}\n");
        }
        catch
        {
            // Ignore logging errors
        }
    }
}
