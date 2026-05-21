# Settings & Registry Configuration

Reference for how MPK Tools stores and retrieves user settings and profile data.

---

## Overview

MPK Tools uses **Windows Registry** exclusively for persistent settings. No JSON files, no INI files, no environment variables.

**Why Registry?**
- Native Windows storage mechanism
- User-scoped (HKCU\ — doesn't require admin)
- Survives uninstall (optional)
- Registry Editor allows manual inspection/debugging

---

## Registry Locations

### VS Code Profile Picker Settings

**Key:**
```
HKCU:\Software\VsCodeProfilePicker
```

**Subkeys & Values:**

| Value Name | Type | Example | Purpose |
|------------|------|---------|---------|
| `ProfileRoot` | REG_SZ | `C:\VSCodeProfiles\` | Root directory to scan for profiles |
| `AutoCreateDirectories` | REG_DWORD | `1` | Auto-create user-data\ and extensions\ subdirs |
| `CacheTTL` | REG_DWORD | `60` | Profile list cache expiry (minutes) |
| `LastScanTime` | REG_QWORD | `132000000000000000` | Timestamp of last profile scan (FILETIME format) |
| `SelectedProfile` | REG_SZ | `Work` | Last-selected profile (for UI state restoration) |

**Registry Editor path:**
```
Computer\HKEY_CURRENT_USER\Software\VsCodeProfilePicker
```

### Sticky Notes Profile Picker Settings

**Key:**
```
HKCU:\Software\StickyNotesProfilePicker
```

Same structure as VS Code picker (not yet implemented in v1.5, but reserved for future).

### AntiGravity Profile Picker Settings

**Key:**
```
HKCU:\Software\AntiGravityProfilePicker
```

---

## Virtual Desktop Detection Registry

Used by all launchers (see [VIRTUAL_DESKTOP.md](VIRTUAL_DESKTOP.md)):

**Key:**
```
HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
```

| Value Name | Type | Purpose |
|------------|------|---------|
| `CurrentVirtualDesktop` | REG_BINARY (16 bytes) | GUID of active desktop |
| `VirtualDesktopIDs` | REG_BINARY (N × 16 bytes) | Ordered list of all desktops |

**Example values:**
```
CurrentVirtualDesktop:  01 00 00 00 A7 8F 1E 05 44 E4 E5 43 87 B7 E4 6C
                        (little-endian GUID in binary form)

VirtualDesktopIDs:      01 00 00 00 A7 8F 1E 05 44 E4 E5 43 87 B7 E4 6C  <- Desktop 1
                        02 00 00 00 B8 9F 2F 06 55 F5 F6 54 98 C8 F5 7D  <- Desktop 2
                        03 00 00 00 C9 A0 30 07 66 G6 G7 65 A9 D9 G6 8E  <- Desktop 3
```

---

## Profile Scanning Logic (SettingsService)

**How profiles are discovered:**

```
1. Read HKCU:\Software\VsCodeProfilePicker\ProfileRoot
   → C:\VSCodeProfiles\

2. Scan directory for subdirectories
   → [Work, Personal, Python, ...]

3. For each subdirectory:
   a. Check if user-data\ exists
   b. Check if extensions\ exists
   c. If either missing AND AutoCreateDirectories=1, create it
   d. Read modification time (LastWriteTime)
   e. Create VsCodeProfile object
   
4. Cache in memory with TTL (default 60 minutes)
   Set LastScanTime = current FILETIME

5. Bind to UI (MainWindow.xaml GridView)
```

---

## Profile Structure

### VS Code Profile Picker

**Registry Setting:**
```
HKCU:\Software\VsCodeProfilePicker\ProfileRoot
Value: C:\VSCodeProfiles\
```

**Actual directory structure:**
```
C:\VSCodeProfiles\
├── Work\
│   ├── user-data\          (--user-data-dir points here)
│   │   ├── User\
│   │   │   └── settings.json
│   │   ├── storage.json    (recent projects)
│   │   └── workspaceStorage\
│   └── extensions\         (--extensions-dir points here)
│       ├── ms-python.python\
│       ├── ms-vscode.cpptools\
│       └── ...
│
├── Personal\
│   ├── user-data\
│   └── extensions\
│
└── Python\
    ├── user-data\
    └── extensions\
```

**Auto-creation on first scan:**
- If `Work/` exists but `Work/user-data/` doesn't → create it
- If `Work/` exists but `Work/extensions/` doesn't → create it
- VS Code auto-initializes content on first launch

### Virtual Desktop Launchers

**No registry setting required.** Profile root is hardcoded in launcher script:

```powershell
# src/launchers/chrome/Launch-Chrome.ps1
$profileRoot = "C:\ChromeProfiles"

$desktopNumber = ...  # Detected from registry
$profileFolder = Join-Path $profileRoot "virtual_desktop_$desktopNumber"

# Create if not exists
if (-not (Test-Path $profileFolder)) {
    New-Item -ItemType Directory -Force $profileFolder | Out-Null
}

# Launch
chrome.exe --user-data-dir $profileFolder
```

**Result:**
```
C:\ChromeProfiles\
├── virtual_desktop_1\
│   ├── Default\           (auto-created by Chrome)
│   │   ├── Bookmarks
│   │   ├── History
│   │   ├── Cookies
│   │   └── ...
│   └── ...
│
├── virtual_desktop_2\
│   └── ...
│
└── virtual_desktop_3\
    └── ...
```

---

## SettingsService Implementation

**Location:** `src/shared/MPK.Profile.Core/Services/SettingsService.cs`

**Core Methods:**

```csharp
public class SettingsService
{
    private const string RegistryPath = @"Software\VsCodeProfilePicker";
    
    public string GetProfileRoot()
    {
        var key = Registry.CurrentUser.OpenSubKey(RegistryPath);
        return key?.GetValue("ProfileRoot", "C:\\VSCodeProfiles\\")?.ToString() ?? "C:\\VSCodeProfiles\\";
    }
    
    public void SetProfileRoot(string path)
    {
        var key = Registry.CurrentUser.CreateSubKey(RegistryPath);
        key?.SetValue("ProfileRoot", path);
    }
    
    public int GetCacheTTL()
    {
        var key = Registry.CurrentUser.OpenSubKey(RegistryPath);
        return (int)(key?.GetValue("CacheTTL", 60) ?? 60);
    }
    
    public bool GetAutoCreateDirectories()
    {
        var key = Registry.CurrentUser.OpenSubKey(RegistryPath);
        return ((int)(key?.GetValue("AutoCreateDirectories", 1) ?? 1)) == 1;
    }
}
```

**Usage in UI:**
```csharp
// MainWindow.cs
var settingsService = new SettingsService();
var profileRoot = settingsService.GetProfileRoot();

// Settings window
if (DialogResult == DialogResult.OK)
{
    settingsService.SetProfileRoot(selectedFolder);
}
```

---

## ProfileScanService Implementation

**Location:** `src/shared/MPK.Profile.Core/Services/ProfileScanService.cs`

**Core Logic:**

```csharp
public class ProfileScanService
{
    public List<VsCodeProfile> ScanProfiles(string rootPath, bool autoCreate = true)
    {
        var profiles = new List<VsCodeProfile>();
        
        if (!Directory.Exists(rootPath))
            return profiles;
        
        foreach (var dir in Directory.GetDirectories(rootPath))
        {
            var name = Path.GetFileName(dir);
            
            // Ensure user-data and extensions subdirs exist
            var userDataPath = Path.Combine(dir, "user-data");
            var extensionsPath = Path.Combine(dir, "extensions");
            
            if (autoCreate)
            {
                if (!Directory.Exists(userDataPath))
                    Directory.CreateDirectory(userDataPath);
                if (!Directory.Exists(extensionsPath))
                    Directory.CreateDirectory(extensionsPath);
            }
            
            // Read metadata
            var info = new DirectoryInfo(dir);
            var profile = new VsCodeProfile
            {
                Name = name,
                Path = dir,
                UserDataPath = userDataPath,
                ExtensionsPath = extensionsPath,
                LastModified = info.LastWriteTime,
                AvatarColor = DeriveColorFromName(name)
            };
            
            profiles.Add(profile);
        }
        
        return profiles.OrderByDescending(p => p.LastModified).ToList();
    }
    
    private string DeriveColorFromName(string name)
    {
        // Deterministic color based on name hash
        // "Work" always gets same color, "Personal" always gets different color
    }
}
```

---

## Data Flow: Reading Settings

```
User opens VS Code Profile Picker
    ↓
MainWindow constructor
    ↓
SettingsService.GetProfileRoot()
    → Query HKCU:\Software\VsCodeProfilePicker\ProfileRoot
    → Return "C:\VSCodeProfiles\"
    ↓
SettingsService.GetCacheTTL()
    → Query HKCU:\Software\VsCodeProfilePicker\CacheTTL
    → Return 60
    ↓
SettingsService.GetAutoCreateDirectories()
    → Query HKCU:\Software\VsCodeProfilePicker\AutoCreateDirectories
    → Return true
    ↓
ProfileScanService.ScanProfiles(profileRoot)
    → List all subdirectories of C:\VSCodeProfiles\
    → For each [Work, Personal, Python, ...]:
        - Create user-data\ and extensions\ if missing
        - Read modification time
    → Return List<VsCodeProfile>
    ↓
Update HKCU:\Software\VsCodeProfilePicker\LastScanTime = now
    ↓
Bind profiles to MainWindow.xaml GridView
    ↓
User sees profile cards with avatars, timestamps
```

---

## Data Flow: Writing Settings

```
User opens Settings window
    ↓
User clicks "Browse..." button
    ↓
Windows FolderBrowserDialog opens
    ↓
User selects "D:\MyVSCodeProfiles\"
    ↓
Click "OK"
    ↓
SettingsService.SetProfileRoot("D:\MyVSCodeProfiles\")
    → Write to HKCU:\Software\VsCodeProfilePicker\ProfileRoot = "D:\MyVSCodeProfiles\"
    ↓
Refresh profile list
    ↓
ProfileScanService.ScanProfiles("D:\MyVSCodeProfiles\")
    → Lists folders in new location
    ↓
MainWindow updates GridView
```

---

## Persistence & Uninstall

### After Uninstall

**Inno Setup uninstaller removes:**
```
C:\Program Files\MPK Tools\     (all executables, dlls, scripts)
```

**Inno Setup preserves:**
```
C:\ChromeProfiles\              (user data, untouched)
C:\VSCodeProfiles\              (user data, untouched)
C:\StickyNotesProfiles\         (user data, untouched)
C:\AntiGravityProfiles\         (user data, untouched)
C:\claude-ws\vd-profiles\       (user data, untouched)

HKCU:\Software\VsCodeProfilePicker\   (registry settings, untouched)
```

**User can:**
- Reinstall MPK Tools → settings and profiles preserved
- Manually delete `C:\*Profiles\` folders if desired (user's choice)
- Export/backup profile folders separately

### Backup Strategy

**Recommended user backup:**
```powershell
# Backup everything in one command
$backupRoot = "D:\MPKToolsBackup\$(Get-Date -Format 'yyyy-MM-dd')"
mkdir $backupRoot

xcopy C:\ChromeProfiles $backupRoot\ChromeProfiles /S /E /H /I
xcopy C:\VSCodeProfiles $backupRoot\VSCodeProfiles /S /E /H /I
xcopy C:\StickyNotesProfiles $backupRoot\StickyNotesProfiles /S /E /H /I
xcopy C:\AntiGravityProfiles $backupRoot\AntiGravityProfiles /S /E /H /I
xcopy C:\claude-ws\vd-profiles $backupRoot\claude-ws\vd-profiles /S /E /H /I

# Also export registry
reg export "HKEY_CURRENT_USER\Software\VsCodeProfilePicker" "$backupRoot\registry.reg"
```

---

## Registry Tools for Debugging

### View Registry in Registry Editor

```
Windows + R
regedit
Navigate to: HKEY_CURRENT_USER\Software\VsCodeProfilePicker
View all values
```

### Export Registry to File

```powershell
reg export "HKEY_CURRENT_USER\Software\VsCodeProfilePicker" "profile-picker-settings.reg"
```

**Output format:**
```
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\VsCodeProfilePicker]
"ProfileRoot"="C:\\VSCodeProfiles\\"
"AutoCreateDirectories"=dword:00000001
"CacheTTL"=dword:0000003c
"LastScanTime"=hex(b):00,c8,dd,e5,fb,6f,cb,01
```

### Import Registry from File

```powershell
reg import "profile-picker-settings.reg"
```

### Delete Registry Key (Reset to Defaults)

```powershell
Remove-Item "HKCU:\Software\VsCodeProfilePicker" -Force
```

---

## Migration Between Machines

**Export from old machine:**
```powershell
# Export settings
reg export "HKEY_CURRENT_USER\Software\VsCodeProfilePicker" "C:\temp\vscode-picker-settings.reg"

# Copy profile data
robocopy C:\VSCodeProfiles Z:\Backup\VSCodeProfiles /S /E
robocopy C:\ChromeProfiles Z:\Backup\ChromeProfiles /S /E
robocopy C:\StickyNotesProfiles Z:\Backup\StickyNotesProfiles /S /E
robocopy C:\AntiGravityProfiles Z:\Backup\AntiGravityProfiles /S /E
```

**Import on new machine:**
```powershell
# Install MPK Tools first
# Then restore profiles
robocopy Z:\Backup\VSCodeProfiles C:\VSCodeProfiles /S /E
robocopy Z:\Backup\ChromeProfiles C:\ChromeProfiles /S /E
robocopy Z:\Backup\StickyNotesProfiles C:\StickyNotesProfiles /S /E
robocopy Z:\Backup\AntiGravityProfiles C:\AntiGravityProfiles /S /E

# Import registry settings
reg import C:\temp\vscode-picker-settings.reg
```

---

## v1.6 Opportunities

**Current state:** Each app (Chrome, Edge, VS Code, Sticky Notes) stores data in separate roots.

**Proposed for v1.6:** Unified profile root under `C:\MPKTools\Profiles\`

```
C:\MPKTools\Profiles\
├── virtual_desktop_1\
│   ├── chrome\     (Chrome profile for Desktop 1)
│   ├── edge/       (Edge profile for Desktop 1)
│   ├── vscode/     (VS Code profile for Desktop 1)
│   └── ...
├── virtual_desktop_2\
│   ├── chrome/
│   └── ...
└── Work\           (Named profile, optional)
    ├── chrome/
    └── vscode/
```

**Benefits:**
- Easier to backup (single `C:\MPKTools\Profiles\` folder)
- Clearer structure (all profiles in one place)
- Simpler migration scripts

**Migration path:**
- Create migration script
- Run on first launch after v1.6 update
- Copy existing profiles to new structure
- Update registry settings to point to new location

---

Return to [README.md](README.md)
