using System.Windows;
using StickyNotesProfileTextSearch.Services;

namespace StickyNotesProfileTextSearch;

public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);
        LoggingService.Initialize();
        LoggingService.Info("Application started");
    }

    protected override void OnExit(ExitEventArgs e)
    {
        LoggingService.Info("Application exiting");
        base.OnExit(e);
    }
}
