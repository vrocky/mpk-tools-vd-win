using System.Diagnostics;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using EdgeProfilePicker.Models;
using EdgeProfilePicker.Services;

namespace EdgeProfilePicker;

public partial class MainWindow : Window
{
    private List<EdgeProfile> _allProfiles = [];

    public MainWindow()
    {
        InitializeComponent();
        Loaded += MainWindow_Loaded;
    }

    private void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        _allProfiles = EdgeProfileService.LoadProfiles();
        SubtitleText.Text = $"{_allProfiles.Count} profile{(_allProfiles.Count == 1 ? "" : "s")} found";
        RenderProfiles(_allProfiles);
        SearchBox.Focus();
    }

    private void RenderProfiles(List<EdgeProfile> profiles)
    {
        ProfileListBox.ItemsSource = null;
        ProfileListBox.ItemsSource = profiles;

        StatusText.Text = profiles.Count == 0
            ? "No profiles match your search."
            : "Click a profile to open a new Edge window.";
    }

    private void SearchBox_TextChanged(object sender, TextChangedEventArgs e)
    {
        var query = SearchBox.Text.Trim();
        var filtered = string.IsNullOrEmpty(query)
            ? _allProfiles
            : _allProfiles.Where(p =>
                p.Name.Contains(query, StringComparison.OrdinalIgnoreCase) ||
                p.Email.Contains(query, StringComparison.OrdinalIgnoreCase) ||
                p.Folder.Contains(query, StringComparison.OrdinalIgnoreCase)
            ).ToList();

        RenderProfiles(filtered);
    }

    private void ProfileCard_Click(object sender, RoutedEventArgs e)
    {
        if (sender is Button btn && btn.Tag is string folder)
        {
            StatusText.Text = $"Opening {folder}...";
            try
            {
                Process.Start(new ProcessStartInfo
                {
                    FileName = EdgeProfileService.EdgeExePath,
                    Arguments = $"--profile-directory=\"{folder}\" --new-window about:blank",
                    UseShellExecute = false
                });
                Application.Current.Shutdown();
            }
            catch (Exception ex)
            {
                StatusText.Text = $"Error: {ex.Message}";
            }
        }
    }
}
