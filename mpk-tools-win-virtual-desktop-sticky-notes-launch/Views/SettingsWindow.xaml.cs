using Microsoft.Win32;
using System.IO;
using System.Windows;
using StickyNotesProfilePicker.Models;
using StickyNotesProfilePicker.Services;

namespace StickyNotesProfilePicker.Views;

public partial class SettingsWindow : Window
{
    private readonly StickyNotesSettings _settings;
    public bool Saved { get; private set; }

    public SettingsWindow(StickyNotesSettings settings)
    {
        InitializeComponent();
        _settings = settings;
        
        DataDirectoryBox.Text = _settings.DataDirectory;
        ExePathBox.Text = _settings.StickyNotesExePath;
    }

    private void BrowseDataDir_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFolderDialog
        {
            Title = "Select StickyNotes data directory",
            Multiselect = false
        };

        if (!string.IsNullOrWhiteSpace(_settings.DataDirectory) && Directory.Exists(_settings.DataDirectory))
        {
            dialog.InitialDirectory = _settings.DataDirectory;
        }

        if (dialog.ShowDialog(this) == true)
        {
            DataDirectoryBox.Text = dialog.FolderName;
        }
    }

    private void BrowseExe_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog
        {
            Title = "Select StickyNotesApp.exe",
            Filter = "Executable Files (*.exe)|*.exe|All Files (*.*)|*.*",
            CheckFileExists = true
        };

        if (!string.IsNullOrWhiteSpace(_settings.StickyNotesExePath) && File.Exists(_settings.StickyNotesExePath))
        {
            dialog.InitialDirectory = Path.GetDirectoryName(_settings.StickyNotesExePath);
            dialog.FileName = Path.GetFileName(_settings.StickyNotesExePath);
        }

        if (dialog.ShowDialog(this) == true)
        {
            ExePathBox.Text = dialog.FileName;
        }
    }

    private void Save_Click(object sender, RoutedEventArgs e)
    {
        _settings.DataDirectory = DataDirectoryBox.Text.Trim();
        _settings.StickyNotesExePath = ExePathBox.Text.Trim();
        
        StickyNotesSettingsService.Save(_settings);
        Saved = true;
        Close();
    }

    private void Cancel_Click(object sender, RoutedEventArgs e)
    {
        Close();
    }
}
