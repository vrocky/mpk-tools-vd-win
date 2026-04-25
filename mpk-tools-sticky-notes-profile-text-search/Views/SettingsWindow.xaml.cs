using System.IO;
using System.Windows;
using Microsoft.Win32;
using StickyNotesProfileTextSearch.Models;
using StickyNotesProfileTextSearch.Services;

namespace StickyNotesProfileTextSearch.Views;

public partial class SettingsWindow : Window
{
    private readonly StickyNotesSettings _settings;

    public SettingsWindow(StickyNotesSettings settings)
    {
        InitializeComponent();
        _settings = settings;
        
        DataDirTextBox.Text = _settings.DataDirectory;
        ExePathTextBox.Text = _settings.StickyNotesExePath;
    }

    private void BrowseDataDir_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFolderDialog
        {
            Title = "Select Data Directory",
            InitialDirectory = Directory.Exists(_settings.DataDirectory) 
                ? _settings.DataDirectory 
                : Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)
        };

        if (dialog.ShowDialog() == true)
        {
            DataDirTextBox.Text = dialog.FolderName;
        }
    }

    private void BrowseExe_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog
        {
            Title = "Select StickyNotesApp Executable",
            Filter = "Executable Files (*.exe)|*.exe|All Files (*.*)|*.*",
            InitialDirectory = File.Exists(_settings.StickyNotesExePath)
                ? Path.GetDirectoryName(_settings.StickyNotesExePath)
                : @"C:\Program Files"
        };

        if (dialog.ShowDialog() == true)
        {
            ExePathTextBox.Text = dialog.FileName;
        }
    }

    private void Save_Click(object sender, RoutedEventArgs e)
    {
        try
        {
            _settings.DataDirectory = DataDirTextBox.Text.Trim();
            _settings.StickyNotesExePath = ExePathTextBox.Text.Trim();

            StickyNotesSettingsService.Save(_settings);
            LoggingService.Info($"Settings saved. DataDir='{_settings.DataDirectory}', ExePath='{_settings.StickyNotesExePath}'");

            DialogResult = true;
            Close();
        }
        catch (Exception ex)
        {
            LoggingService.Error("Failed to save settings", ex);
            MessageBox.Show($"Failed to save settings: {ex.Message}", "Error", 
                MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }
}
