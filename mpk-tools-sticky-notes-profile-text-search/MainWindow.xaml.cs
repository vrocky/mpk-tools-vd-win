using System.Diagnostics;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using StickyNotesProfileTextSearch.Models;
using StickyNotesProfileTextSearch.Services;
using StickyNotesProfileTextSearch.Views;

namespace StickyNotesProfileTextSearch;

public partial class MainWindow : Window
{
    private StickyNotesSettings _settings = new();
    private List<NoteSearchItem> _allNotes = new();

    public MainWindow()
    {
        InitializeComponent();
        Loaded += MainWindow_Loaded;
    }

    private async void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        await RefreshIndexAsync();
        SearchBox.Focus();
    }

    private async Task RefreshIndexAsync()
    {
        try
        {
            StatusText.Text = "Scanning profiles for notes...";
            LoggingService.Info("Refreshing note index.");

            var includeMissing = IncludeMissingCheck.IsChecked == true;

            var result = await Task.Run(() =>
            {
                var settings = StickyNotesSettingsService.Load();
                var notes = NoteIndexService.BuildIndex(settings, includeMissing);
                return (settings, notes);
            });

            _settings = result.settings;
            _allNotes = result.notes;

            var profilesDir = Path.Combine(_settings.DataDirectory, "profiles");
            var profileCount = Directory.Exists(profilesDir) 
                ? Directory.GetDirectories(profilesDir).Length 
                : 0;

            SubtitleText.Text = profileCount == 0
                ? "No profiles found. Configure data directory in Settings."
                : $"{_allNotes.Count} note{(_allNotes.Count == 1 ? "" : "s")} across {profileCount} profile{(profileCount == 1 ? "" : "s")}";

            Render(_allNotes);
            LoggingService.Info($"Index refresh complete. Notes={_allNotes.Count}, Profiles={profileCount}.");
        }
        catch (Exception ex)
        {
            LoggingService.Error("RefreshIndexAsync failed.", ex);
            StatusText.Text = "Error while scanning. See log file in %LocalAppData%\\StickyNotesProfileTextSearch\\log.txt";
        }
    }

    private void Render(List<NoteSearchItem> notes)
    {
        NotesList.ItemsSource = null;
        NotesList.ItemsSource = notes;

        StatusText.Text = notes.Count == 0
            ? "No notes found."
            : $"{notes.Count} note{(notes.Count == 1 ? "" : "s")} displayed. Click to open in StickyNotes.";
    }

    private void SearchBox_TextChanged(object sender, TextChangedEventArgs e)
    {
        var query = SearchBox.Text.Trim();
        
        if (string.IsNullOrWhiteSpace(query))
        {
            Render(_allNotes);
            return;
        }

        var filtered = _allNotes.Where(note =>
            note.Title.Contains(query, StringComparison.OrdinalIgnoreCase) ||
            note.Content.Contains(query, StringComparison.OrdinalIgnoreCase) ||
            note.ProfileName.Contains(query, StringComparison.OrdinalIgnoreCase) ||
            note.NoteId.Contains(query, StringComparison.OrdinalIgnoreCase)
        ).ToList();

        Render(filtered);
    }

    private void OpenNote_Click(object sender, RoutedEventArgs e)
    {
        if (sender is not Button { Tag: NoteSearchItem item })
        {
            return;
        }

        OpenNoteInProfile(item);
    }

    private void NoteCard_Click(object sender, MouseButtonEventArgs e)
    {
        if (sender is not Border { Tag: NoteSearchItem item })
        {
            return;
        }

        OpenNoteInProfile(item);
    }

    private void OpenNoteInProfile(NoteSearchItem item)
    {
        if (!item.ProfileExists)
        {
            StatusText.Text = "Cannot open: profile no longer exists.";
            return;
        }

        try
        {
            if (!File.Exists(_settings.StickyNotesExePath))
            {
                StatusText.Text = $"StickyNotesApp not found at: {_settings.StickyNotesExePath}. Check Settings.";
                return;
            }

            var profileName = Path.GetFileName(item.ProfilePath);
            var args = $"--profile \"{profileName}\" --data-dir \"{_settings.DataDirectory}\"";

            var startInfo = new ProcessStartInfo
            {
                FileName = _settings.StickyNotesExePath,
                Arguments = args,
                UseShellExecute = false
            };

            Process.Start(startInfo);
            StatusText.Text = $"Opened profile: {item.ProfileName}";
            LoggingService.Info($"Launched note '{item.DisplayTitle}' in profile '{profileName}'");
        }
        catch (Exception ex)
        {
            StatusText.Text = $"Failed to open: {ex.Message}";
            LoggingService.Error("Failed to launch StickyNotes", ex);
        }
    }

    private async void Refresh_Click(object sender, RoutedEventArgs e)
    {
        await RefreshIndexAsync();
    }

    private async void IncludeMissing_Changed(object sender, RoutedEventArgs e)
    {
        await RefreshIndexAsync();
    }

    private void Settings_Click(object sender, RoutedEventArgs e)
    {
        var settingsWindow = new SettingsWindow(_settings);
        if (settingsWindow.ShowDialog() == true)
        {
            _ = RefreshIndexAsync();
        }
    }
}
