#define MyAppName "MPK Tools"
#ifndef AppVersion
  #define AppVersion "1.1.0"
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

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create desktop shortcuts"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "dist\staging\Scripts\*.ico"; DestDir: "{app}\Scripts"; Flags: recursesubdirs createallsubdirs ignoreversion
Source: "dist\staging\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
; WPF tools
Name: "{group}\VS Code Profile Picker"; Filename: "{app}\Apps\mpk-tools-vscode-profile-picker\VsCodeProfilePicker.exe"
Name: "{group}\VS Code Profile Project Search"; Filename: "{app}\Apps\mpk-tools-vscode-profile-project-search\VsCodeProfileProjectSearch.exe"
Name: "{group}\Sticky Notes Profile Picker"; Filename: "{app}\Apps\mpk-tools-sticky-notes-profile-picker\StickyNotesProfilePicker.exe"
Name: "{group}\Sticky Notes Profile Text Search"; Filename: "{app}\Apps\mpk-tools-sticky-notes-profile-text-search\StickyNotesProfileTextSearch.exe"
Name: "{group}\Antigravity Profile Picker"; Filename: "{app}\Apps\mpk-tools-antigravity-profile-picker\AntigravityProfilePicker.exe"
Name: "{group}\Antigravity Profile Project Search"; Filename: "{app}\Apps\mpk-tools-antigravity-profile-project-search\AntigravityProfileProjectSearch.exe"

; Script launchers
Name: "{group}\Launch Chrome (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-chrome-launch\Launch-Chrome.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-chrome-launch"
Name: "{group}\Launch VS Code (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-vscode-launch\Launch-VSCode.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-vscode-launch"
Name: "{group}\Launch Edge (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-edge-launch\Launch-Edge.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-edge-launch"
Name: "{group}\Launch Claude (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-claude-launch\Launch-Claude.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-claude-launch"
Name: "{group}\Launch Sticky Notes (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-sticky-notes-launch\Launch-StickyNotes.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-sticky-notes-launch"
Name: "{group}\Launch Antigravity (Virtual Desktop)"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-antigravity-launch\Launch-AntiGravity.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-antigravity-launch"

; Optional desktop shortcuts for commonly used launchers
; Optional desktop shortcuts for installed app executables
Name: "{autodesktop}\MPK VS Code Profile Picker"; Filename: "{app}\Apps\mpk-tools-vscode-profile-picker\VsCodeProfilePicker.exe"; Tasks: desktopicon
Name: "{autodesktop}\MPK VS Code Profile Project Search"; Filename: "{app}\Apps\mpk-tools-vscode-profile-project-search\VsCodeProfileProjectSearch.exe"; Tasks: desktopicon
Name: "{autodesktop}\MPK Sticky Notes Profile Picker"; Filename: "{app}\Apps\mpk-tools-sticky-notes-profile-picker\StickyNotesProfilePicker.exe"; Tasks: desktopicon
Name: "{autodesktop}\MPK Sticky Notes Profile Text Search"; Filename: "{app}\Apps\mpk-tools-sticky-notes-profile-text-search\StickyNotesProfileTextSearch.exe"; Tasks: desktopicon
Name: "{autodesktop}\MPK Antigravity Profile Picker"; Filename: "{app}\Apps\mpk-tools-antigravity-profile-picker\AntigravityProfilePicker.exe"; Tasks: desktopicon
Name: "{autodesktop}\MPK Antigravity Profile Project Search"; Filename: "{app}\Apps\mpk-tools-antigravity-profile-project-search\AntigravityProfileProjectSearch.exe"; Tasks: desktopicon

[Run]
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-antigravity-launch\Create-Shortcut.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-antigravity-launch"; Flags: runhidden runasoriginaluser
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-chrome-launch\Create-Shortcut.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-chrome-launch"; Flags: runhidden runasoriginaluser
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-claude-launch\Create-Shortcut.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-claude-launch"; Flags: runhidden runasoriginaluser
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-edge-launch\Create-Shortcut.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-edge-launch"; Flags: runhidden runasoriginaluser
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-sticky-notes-launch\Create-Shortcut.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-sticky-notes-launch"; Flags: runhidden runasoriginaluser
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\Scripts\mpk-tools-win-virtual-desktop-vscode-launch\Create-Shortcut.ps1"""; WorkingDir: "{app}\Scripts\mpk-tools-win-virtual-desktop-vscode-launch"; Flags: runhidden runasoriginaluser
Filename: "{app}\Apps\mpk-tools-vscode-profile-picker\VsCodeProfilePicker.exe"; Description: "Launch VS Code Profile Picker"; Flags: postinstall shellexec skipifsilent unchecked

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
