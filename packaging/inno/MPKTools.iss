#define MyAppName "MPK Tools"
#ifndef AppVersion
  #define AppVersion "1.6.0"
#endif

[Setup]
AppId={{A3A6FB9E-9775-42DB-95BF-0A9E8D4D2B36}
AppName={#MyAppName}
AppVersion={#AppVersion}
AppPublisher=MPK
DefaultDirName={autopf}\MPK Tools
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputBaseFilename=MPK-Tools-Setup-{#AppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin

[Code]
function CheckDotNetRuntime: Boolean;
var
  InstallPath: String;
begin
  Result := True;

  // Check for .NET 8 Desktop Runtime in the registry
  // Framework-dependent apps require .NET 8 Desktop Runtime to be installed
  if not RegKeyExists(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{03a59918-ec21-42bc-87fd-6ad2a67df3b1}') then
  begin
    if MsgBox('This application requires .NET 8 Desktop Runtime.' + #13#13 +
              'Please install it from: https://dotnet.microsoft.com/download/dotnet/8.0' + #13#13 +
              'Click OK to continue, or Cancel to exit.', mbConfirmation, MB_OKCANCEL) = IDCANCEL then
    begin
      Result := False;
    end;
  end;
end;

procedure InitializeWizard;
begin
  if not CheckDotNetRuntime then
    Abort;
end;

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create desktop shortcuts"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
; Paths are relative to this .iss file (packaging\inno\), so dist is two levels up
Source: "..\..\dist\staging\Scripts\*.ico"; DestDir: "{app}\Scripts"; Flags: recursesubdirs createallsubdirs ignoreversion
Source: "..\..\dist\staging\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
; Desktop apps
Name: "{group}\VS Code Profile Picker";          Filename: "{app}\Apps\MPK.VsCode.ProfilePicker\VsCodeProfilePicker.exe"
Name: "{group}\VS Code Project Search";          Filename: "{app}\Apps\MPK.VsCode.ProjectSearch\VsCodeProfileProjectSearch.exe"
Name: "{group}\Sticky Notes Profile Picker";     Filename: "{app}\Apps\MPK.StickyNotes.ProfilePicker\StickyNotesProfilePicker.exe"
Name: "{group}\Sticky Notes Text Search";        Filename: "{app}\Apps\MPK.StickyNotes.TextSearch\StickyNotesProfileTextSearch.exe"
Name: "{group}\AntiGravity Profile Picker";      Filename: "{app}\Apps\MPK.AntiGravity.ProfilePicker\AntigravityProfilePicker.exe"
Name: "{group}\AntiGravity Project Search";      Filename: "{app}\Apps\MPK.AntiGravity.ProjectSearch\AntigravityProfileProjectSearch.exe"
Name: "{group}\MPK Tools Updater";               Filename: "{app}\Updater\MPKToolsUpdater.exe"

; Virtual desktop launchers
Name: "{group}\Launch Chrome (Virtual Desktop)";      Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\chrome\Launch-Chrome.ps1"""; WorkingDir: "{app}\Scripts\chrome"
Name: "{group}\Launch VS Code (Virtual Desktop)";     Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\vscode\Launch-VSCode.ps1"""; WorkingDir: "{app}\Scripts\vscode"
Name: "{group}\Launch Edge (Virtual Desktop)";        Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\edge\Launch-Edge.ps1"""; WorkingDir: "{app}\Scripts\edge"
Name: "{group}\Launch Claude (Virtual Desktop)";      Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\claude\Launch-Claude.ps1"""; WorkingDir: "{app}\Scripts\claude"
Name: "{group}\Launch Sticky Notes (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\sticky-notes\Launch-StickyNotes.ps1"""; WorkingDir: "{app}\Scripts\sticky-notes"
Name: "{group}\Launch AntiGravity (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\antigravity\Launch-AntiGravity.ps1"""; WorkingDir: "{app}\Scripts\antigravity"

; Optional desktop shortcuts
Name: "{autodesktop}\MPK VS Code Profile Picker";      Filename: "{app}\Apps\MPK.VsCode.ProfilePicker\VsCodeProfilePicker.exe"; Tasks: desktopicon
Name: "{autodesktop}\MPK VS Code Project Search";      Filename: "{app}\Apps\MPK.VsCode.ProjectSearch\VsCodeProfileProjectSearch.exe"; Tasks: desktopicon
Name: "{autodesktop}\MPK Sticky Notes Profile Picker"; Filename: "{app}\Apps\MPK.StickyNotes.ProfilePicker\StickyNotesProfilePicker.exe"; Tasks: desktopicon
Name: "{autodesktop}\MPK Sticky Notes Text Search";    Filename: "{app}\Apps\MPK.StickyNotes.TextSearch\StickyNotesProfileTextSearch.exe"; Tasks: desktopicon
Name: "{autodesktop}\MPK AntiGravity Profile Picker";  Filename: "{app}\Apps\MPK.AntiGravity.ProfilePicker\AntigravityProfilePicker.exe"; Tasks: desktopicon
Name: "{autodesktop}\MPK AntiGravity Project Search";  Filename: "{app}\Apps\MPK.AntiGravity.ProjectSearch\AntigravityProfileProjectSearch.exe"; Tasks: desktopicon
Name: "{autodesktop}\MPK Tools Updater";               Filename: "{app}\Updater\MPKToolsUpdater.exe"; Tasks: desktopicon

[Run]
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Scripts\antigravity\Create-Shortcut.ps1"""; WorkingDir: "{app}\Scripts\antigravity"; Flags: runhidden runasoriginaluser
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Scripts\chrome\Create-Shortcut.ps1"""; WorkingDir: "{app}\Scripts\chrome"; Flags: runhidden runasoriginaluser
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Scripts\claude\Create-Shortcut.ps1"""; WorkingDir: "{app}\Scripts\claude"; Flags: runhidden runasoriginaluser
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Scripts\edge\Create-Shortcut.ps1"""; WorkingDir: "{app}\Scripts\edge"; Flags: runhidden runasoriginaluser
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Scripts\sticky-notes\Create-Shortcut.ps1"""; WorkingDir: "{app}\Scripts\sticky-notes"; Flags: runhidden runasoriginaluser
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Scripts\vscode\Create-Shortcut.ps1"""; WorkingDir: "{app}\Scripts\vscode"; Flags: runhidden runasoriginaluser
Filename: "{app}\Apps\MPK.VsCode.ProfilePicker\VsCodeProfilePicker.exe"; Description: "Launch VS Code Profile Picker"; Flags: postinstall shellexec skipifsilent unchecked

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
