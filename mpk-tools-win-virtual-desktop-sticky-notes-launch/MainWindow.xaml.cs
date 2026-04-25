using System.Diagnostics;
using System.Windows;
using System.Windows.Controls;
using StickyNotesProfilePicker.Models;
using StickyNotesProfilePicker.Services;
using StickyNotesProfilePicker.Views;

namespace StickyNotesProfilePicker;

public partial class MainWindow : Window
{
    private StickyNotesSettings _settings = new();
    private List<StickyNotesProfile> _allProfiles = [];
    private int _currentDesktop;

    public MainWindow()
    {
        InitializeComponent();
        Loaded += MainWindow_Loaded;
    }

    private void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        _settings = StickyNotesSettingsService.Load();
        _currentDesktop = VirtualDesktopService.GetCurrentDesktopNumber();
        Refresh();
        SearchBox.Focus();
    }

    private void Refresh()
    {
        _allProfiles = StickyNotesProfileScanService.ScanProfiles(_settings.DataDirectory);
        
        var currentDesktopProfile = _allProfiles.FirstOrDefault(p => 
            p.IsVirtualDesktop && p.VirtualDesktopNumber == _currentDesktop);

        SubtitleText.Text = _allProfiles.Count == 0
            ? "No profiles found — they will be created when you launch StickyNotes"
            : currentDesktopProfile != null
                ? $"{_allProfiles.Count} profile{(_allProfiles.Count == 1 ? "" : "s")} • Current: {currentDesktopProfile.Name}"
                : $"{_allProfiles.Count} profile{(_allProfiles.Count == 1 ? "" : "s")} • Current: Virtual Desktop {_currentDesktop}";

        RenderProfiles(_allProfiles);
    }

    private void RenderProfiles(List<StickyNotesProfile> profiles)
    {
        ProfileListBox.ItemsSource = null;
        ProfileListBox.ItemsSource = profiles;

        EmptyState.Visibility = profiles.Count == 0 ? Visibility.Visible : Visibility.Collapsed;

        StatusText.Text = profiles.Count == 0
            ? ""
            : "Click a profile to open StickyNotes.";
    }

    private void SearchBox_TextChanged(object sender, TextChangedEventArgs e)
    {
        var query = SearchBox.Text.Trim();
        var filtered = string.IsNullOrEmpty(query)
            ? _allProfiles
            : _allProfiles.Where(p =>
                p.Name.Contains(query, StringComparison.OrdinalIgnoreCase) ||
                p.FullPath.Contains(query, StringComparison.OrdinalIgnoreCase)
            ).ToList();

        RenderProfiles(filtered);
    }

    private void ProfileCard_Click(object sender, RoutedEventArgs e)
    {
        if (sender is Button btn && btn.Tag is StickyNotesProfile profile)
        {
            StatusText.Text = $"Opening {profile.Name}...";
            LaunchProfile(profile);
        }
    }

    private void LaunchCurrentDesktop_Click(object sender, RoutedEventArgs e)
    {
        StatusText.Text = $"Opening Virtual Desktop {_currentDesktop}...";
        var profileName = $"virtual_desktop_{_currentDesktop}";
        
        // Create a profile object for current desktop (may not exist yet)
        var profile = _allProfiles.FirstOrDefault(p => p.IsVirtualDesktop && p.VirtualDesktopNumber == _currentDesktop);
        if (profile == null)
        {
            profile = new StickyNotesProfile
            {
                Name = $"Virtual Desktop {_currentDesktop}",
                FullPath = System.IO.Path.Combine(_settings.DataDirectory, "profiles", profileName),
                IsVirtualDesktop = true,
                VirtualDesktopNumber = _currentDesktop
            };
        }
        
        LaunchProfile(profile);
    }

    private void LaunchProfile(StickyNotesProfile profile)
    {
        try
        {
            var profileName = profile.IsVirtualDesktop && profile.VirtualDesktopNumber.HasValue
                ? $"virtual_desktop_{profile.VirtualDesktopNumber.Value}"
                : System.IO.Path.GetFileName(profile.FullPath);

            var args = $"--profile \"{profileName}\" --data-dir \"{_settings.DataDirectory}\"";
            
            Process.Start(new ProcessStartInfo
            {
                FileName = _settings.StickyNotesExePath,
                Arguments = args,
                UseShellExecute = true
            });
            Application.Current.Shutdown();
        }
        catch (Exception ex)
        {
            StatusText.Text = $"Error: {ex.Message}";
        }
    }

    private void Settings_Click(object sender, RoutedEventArgs e)
    {
        var win = new SettingsWindow(_settings) { Owner = this };
        win.ShowDialog();
        if (win.Saved)
        {
            _settings = StickyNotesSettingsService.Load();
            SearchBox.Clear();
            Refresh();
        }
    }

    private void Refresh_Click(object sender, RoutedEventArgs e)
    {
        _currentDesktop = VirtualDesktopService.GetCurrentDesktopNumber();
        Refresh();
    }
}
