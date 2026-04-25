#define MyAppName "MPK Tools"
#ifndef AppVersion
  #define AppVersion "1.0.0"
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
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create desktop shortcuts"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "dist\staging\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
; WPF tools
Name: "{group}\VS Code Profile Picker"; Filename: "{app}\Apps\mpk-tools-vscode-profile-picker\VsCodeProfilePicker.exe"
Name: "{group}\VS Code Profile Project Search"; Filename: "{app}\Apps\mpk-tools-vscode-profile-project-search\VsCodeProfileProjectSearch.exe"
Name: "{group}\Sticky Notes Profile Picker"; Filename: "{app}\Apps\mpk-tools-sticky-notes-profile-picker\StickyNotesProfilePicker.exe"
Name: "{group}\Sticky Notes Profile Text Search"; Filename: "{app}\Apps\mpk-tools-sticky-notes-profile-text-search\StickyNotesProfileTextSearch.exe"
Name: "{group}\Antigravity Profile Picker"; Filename: "{app}\Apps\mpk-tools-antigravity-profile-picker\AntigravityProfilePicker.exe"
Name: "{group}\Antigravity Profile Project Search"; Filename: "{app}\Apps\mpk-tools-antigravity-profile-project-search\AntigravityProfileProjectSearch.exe"
Name: "{group}\Edge Profile Picker"; Filename: "{app}\Apps\mpk-tools-win-virtual-desktop-edge-launch\EdgeProfilePicker.exe"
Name: "{group}\Virtual Desktop Antigravity Picker"; Filename: "{app}\Apps\mpk-tools-win-virtual-desktop-antigravity-launch\AntigravityProfilePicker.exe"
Name: "{group}\Virtual Desktop Sticky Notes Picker"; Filename: "{app}\Apps\mpk-tools-win-virtual-desktop-sticky-notes-launch\StickyNotesProfilePicker.exe"

; Script launchers
Name: "{group}\Launch Chrome (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-chrome-launch\Launch-Chrome.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-chrome-launch"
Name: "{group}\Launch VS Code (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-vscode-launch\Launch-VSCode.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-vscode-launch"
Name: "{group}\Launch Edge (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-edge-launch\Launch-Edge.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-edge-launch"
Name: "{group}\Launch Claude (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-claude-launch\Launch-Claude.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-claude-launch"
Name: "{group}\Launch Sticky Notes (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-sticky-notes-launch\Launch-StickyNotes.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-sticky-notes-launch"
Name: "{group}\Launch Antigravity (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-antigravity-launch\Launch-AntiGravity.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-antigravity-launch"

; Optional desktop shortcuts for commonly used launchers
Name: "{autodesktop}\MPK Launch Chrome (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-chrome-launch\Launch-Chrome.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-chrome-launch"; Tasks: desktopicon
Name: "{autodesktop}\MPK Launch VS Code (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-vscode-launch\Launch-VSCode.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-vscode-launch"; Tasks: desktopicon

[Run]
Filename: "{app}\Apps\mpk-tools-vscode-profile-picker\VsCodeProfilePicker.exe"; Description: "Launch VS Code Profile Picker"; Flags: postinstall shellexec skipifsilent unchecked

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
