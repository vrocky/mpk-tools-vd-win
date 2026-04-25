using System.Diagnostics;
using System.Windows;
using System.Windows.Controls;
using VsCodeProfileCommon.Models;
using VsCodeProfileCommon.Services;
using VsCodeProfilePicker.Views;

namespace VsCodeProfilePicker;

public partial class MainWindow : Window
{
    private AppSettings _settings = new();
    private List<VsCodeProfile> _allProfiles = [];

    public MainWindow()
    {
        InitializeComponent();
        Loaded += MainWindow_Loaded;
    }

    private void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        _settings = SettingsService.Load();
        Refresh();
        SearchBox.Focus();
    }

    private void Refresh()
    {
        _allProfiles = ProfileScanService.ScanAll(_settings.ProfileDirectories);
        SubtitleText.Text = _allProfiles.Count == 0
            ? "No profiles — add a directory in Settings ⚙"
            : $"{_allProfiles.Count} profile{(_allProfiles.Count == 1 ? "" : "s")} across {_settings.ProfileDirectories.Count} director{(_settings.ProfileDirectories.Count == 1 ? "y" : "ies")}";

        RenderProfiles(_allProfiles);
    }

    private void RenderProfiles(List<VsCodeProfile> profiles)
    {
        ProfileListBox.ItemsSource = null;
        ProfileListBox.ItemsSource = profiles;

        EmptyState.Visibility = profiles.Count == 0 ? Visibility.Visible : Visibility.Collapsed;

        StatusText.Text = profiles.Count == 0
            ? ""
            : "Click a profile to open VS Code.";
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
        if (sender is Button btn && btn.Tag is VsCodeProfile profile)
        {
            StatusText.Text = $"Opening {profile.Name}...";
            try
            {
                var args = $"--user-data-dir \"{profile.UserDataPath}\" --extensions-dir \"{profile.ExtensionsPath}\"";
                Process.Start(new ProcessStartInfo
                {
                    FileName = _settings.VsCodeExePath,
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
    }

    private void Settings_Click(object sender, RoutedEventArgs e)
    {
        var win = new SettingsWindow(_settings) { Owner = this };
        win.ShowDialog();
        if (win.Saved)
        {
            _settings = SettingsService.Load();
            SearchBox.Clear();
            Refresh();
        }
    }
}
