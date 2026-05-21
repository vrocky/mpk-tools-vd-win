# Development Guide

How to add new features, components, and launchers to MPK Tools.

---

## Prerequisites

- **Git:** Clone with submodules: `git clone --recursive https://github.com/vrocky/mpk-tools-vd-win.git`
- **.NET SDK 8.0+:** For C# projects (WPF apps, shared lib, updater)
- **PowerShell 5.1+:** For launcher scripts and build script
- **Visual Studio 2022 or VS Code:** For C# development
- **Inno Setup 6.0+:** For packaging (add to PATH)
- **GitHub CLI (`gh`):** For release management (optional)

---

## Adding a New Virtual Desktop Launcher

### Scenario: Launch Blender with VD isolation

**Steps:**

#### 1. Create Repository (on GitHub)

Name: `mpk-tools-win-virtual-desktop-blender-launch`

```powershell
git init mpk-tools-win-virtual-desktop-blender-launch
cd mpk-tools-win-virtual-desktop-blender-launch
git remote add origin https://github.com/YOUR_USERNAME/mpk-tools-win-virtual-desktop-blender-launch.git
```

#### 2. Create Launcher Script

**File:** `Launch-Blender.ps1`

```powershell
param(
    [int]$Desktop = 0,
    [string]$File = ""
)

# Virtual desktop detection (copy from existing launcher)
function Get-CurrentDesktopNumber {
    try {
        $regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops"
        $currentVD = (Get-ItemProperty -Path $regPath -Name "CurrentVirtualDesktop").CurrentVirtualDesktop
        
        if (-not $currentVD) {
            return 1  # Default to Desktop 1 if registry read fails
        }
        
        $currentGUID = [guid]::new($currentVD, 0)
        $vdIDs = (Get-ItemProperty -Path $regPath -Name "VirtualDesktopIDs").VirtualDesktopIDs
        
        $allVDs = @()
        for ($i = 0; $i -lt $vdIDs.Length; $i += 16) {
            $vdGUID = [guid]::new($vdIDs, $i)
            $allVDs += $vdGUID
        }
        
        return $allVDs.IndexOf($currentGUID) + 1
    }
    catch {
        Write-Warning "Could not detect virtual desktop: $_"
        return 1
    }
}

# Determine desktop number
$desktopNumber = if ($Desktop -gt 0) { $Desktop } else { Get-CurrentDesktopNumber }

# Profile root directory
$profileRoot = "C:\BlenderProfiles"
$profileFolder = Join-Path $profileRoot "virtual_desktop_$desktopNumber"

# Create profile folder if it doesn't exist
if (-not (Test-Path $profileFolder)) {
    New-Item -ItemType Directory -Force $profileFolder | Out-Null
}

# Build launch command
$blenderPath = "C:\Program Files\Blender Foundation\Blender\blender.exe"

if (-not (Test-Path $blenderPath)) {
    Write-Error "Blender not found at $blenderPath"
    exit 1
}

# Blender uses --factory-startup to specify startup folder, but doesn't have --user-data-dir
# Instead, set environment variable for Blender's config directory
$env:BLENDER_USER_CONFIG = $profileFolder

# Launch Blender
if ($File) {
    & $blenderPath --window-geometry 100 100 1920 1080 $File
} else {
    & $blenderPath --window-geometry 100 100 1920 1080
}
```

#### 3. Create Shortcut Generator

**File:** `Create-Shortcut.ps1`

```powershell
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "Launch Blender.lnk"

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSScriptRoot\Launch-Blender.ps1`""
$shortcut.IconLocation = "$PSScriptRoot\blender.ico"
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.Save()

Write-Host "Shortcut created: $shortcutPath"
```

#### 4. Add Icon

Download or create `blender.ico` (32x32 pixels recommended).

#### 5. Add README

**File:** `README.md`

```markdown
# Blender Virtual Desktop Launcher

Launches Blender with per-desktop profile isolation.

## Usage

```powershell
.\Launch-Blender.ps1                  # Current desktop
.\Launch-Blender.ps1 -Desktop 2       # Force Desktop 2
.\Launch-Blender.ps1 -File "model.blend"
```

## Profiles

Profiles stored in: `C:\BlenderProfiles\virtual_desktop_N\`

Each desktop gets its own Blender config:
- Recent files list
- Preferences
- Add-ons
- Themes

## Installation

Run `Create-Shortcut.ps1` to create a desktop shortcut.
```

#### 6. Add to Main Repository

**In main repo** (`mpk-tools-vd-win`):

```powershell
# Add submodule
git submodule add https://github.com/YOUR_USERNAME/mpk-tools-win-virtual-desktop-blender-launch.git src/launchers/blender
git add .gitmodules src/launchers/blender
git commit -m "Add Blender launcher submodule"
```

#### 7. Update Build Script

**File:** `build/Build.ps1`

Find this section:
```powershell
$launchers = @("chrome", "edge", "vscode", "claude", "sticky-notes", "antigravity")
```

Add `"blender"`:
```powershell
$launchers = @("chrome", "edge", "vscode", "claude", "sticky-notes", "antigravity", "blender")
```

(Rest of build script auto-processes all launcher directories)

#### 8. Update Installer

**File:** `packaging/inno/MPKTools.iss`

Find `[Icons]` section, add:
```ini
Name: "{group}\Blender Launcher"; Filename: "{app}\Scripts\blender\Launch-Blender.ps1"; IconFilename: "{app}\Scripts\blender\blender.ico"
```

Find `[Run]` section, add:
```ini
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\Scripts\blender\Create-Shortcut.ps1"""; Flags: skipifdoesntexist runascurrentuser
```

#### 9. Test

```powershell
# Build
.\build\Build.ps1 -Configuration Release -SkipCompileInstaller

# Verify launcher staged correctly
ls .\dist\staging\Scripts\blender\
# Should see: Launch-Blender.ps1, Create-Shortcut.ps1, blender.ico

# Test launcher
& ".\src\launchers\blender\Launch-Blender.ps1" -Desktop 1

# Verify profile created
ls C:\BlenderProfiles\virtual_desktop_1\
```

#### 10. Commit

```powershell
git add build/Build.ps1 packaging/inno/MPKTools.iss
git commit -m "Add Blender launcher to build and installer"
git push
```

---

## Adding a New Profile Picker App

### Scenario: Create Notepad++ Profile Picker

**Steps:**

#### 1. Create Project (Visual Studio)

- New WPF Application (.NET 8)
- Name: `MPK.Notepadpp.ProfilePicker`
- Add NuGet reference: `MPK.Profile.Core` (from GitHub, or local reference)

#### 2. Copy Existing Picker Structure

Copy from `src/desktop/MPK.VsCode.ProfilePicker/`:
- `MainWindow.xaml` → Adapt for Notepad++
- `MainWindow.xaml.cs` → Rename classes (VsCodeProfilePicker → NotepadppProfilePicker)
- `Views/SettingsWindow.xaml` → Reuse as-is
- `Views/SettingsWindow.xaml.cs` → Reuse as-is
- `app.ico` → Replace with Notepad++ icon
- `VsCodeProfilePicker.csproj` → Rename to `NotepadppProfilePicker.csproj`, update package refs

#### 3. Implement App-Specific Logic

**Key difference:** Notepad++ uses different command-line flags than VS Code.

```csharp
// MainWindow.xaml.cs
private void LaunchProfile(VsCodeProfile profile)
{
    // VS Code: --user-data-dir and --extensions-dir
    // Notepad++: different flags, or environment variables
    
    var notepadppPath = "C:\\Program Files\\Notepad++\\notepad++.exe";
    
    // Notepad++ doesn't have built-in profile isolation
    // Options:
    // 1. Use portable mode + config folder
    // 2. Launch with environment variables
    // 3. Copy config files before launch
    
    var args = $@"-settingsDir=""{profile.UserDataPath}""";
    
    Process.Start(new ProcessStartInfo
    {
        FileName = notepadppPath,
        Arguments = args,
        UseShellExecute = false
    });
}
```

#### 4. Registry Settings

Modify `SettingsService.cs` reference to use new registry key:

```csharp
private const string RegistryPath = @"Software\NotepadppProfilePicker";
```

#### 5. Add to Repository

```powershell
# Create GitHub repo: mpk-tools-notepadpp-profile-picker
# Push project

# Add as submodule
git submodule add https://github.com/YOUR_USERNAME/mpk-tools-notepadpp-profile-picker.git src/desktop/MPK.Notepadpp.ProfilePicker
git add .gitmodules src/desktop/MPK.Notepadpp.ProfilePicker
git commit -m "Add Notepad++ Profile Picker as submodule"
```

#### 6. Update Build Script

**File:** `build/Build.ps1`

Update `$desktopProjects` array:
```powershell
$desktopProjects = @(
    "src/desktop/MPK.VsCode.ProfilePicker/VsCodeProfilePicker.csproj",
    "src/desktop/MPK.StickyNotes.ProfilePicker/StickyNotesProfilePicker.csproj",
    "src/desktop/MPK.AntiGravity.ProfilePicker/AntigravityProfilePicker.csproj",
    "src/desktop/MPK.Notepadpp.ProfilePicker/NotepadppProfilePicker.csproj"
)
```

#### 7. Update Installer

**File:** `packaging/inno/MPKTools.iss`

Add to `[Icons]`:
```ini
Name: "{group}\Notepad++ Profile Picker"; Filename: "{app}\Apps\MPK.Notepadpp.ProfilePicker\NotepadppProfilePicker.exe"; IconFilename: "{app}\Apps\MPK.Notepadpp.ProfilePicker\app.ico"
```

#### 8. Test

```powershell
.\build\Build.ps1 -Configuration Release

ls .\dist\staging\Apps\MPK.Notepadpp.ProfilePicker\
# Should contain: NotepadppProfilePicker.exe, VsCodeProfileCommon.dll, etc.

# Run app
& ".\dist\staging\Apps\MPK.Notepadpp.ProfilePicker\NotepadppProfilePicker.exe"
```

---

## Extending the Shared Library

### Scenario: Add FileSearchService for full-text search

**Steps:**

#### 1. Create New Service

**File:** `src/shared/MPK.Profile.Core/Services/FileSearchService.cs`

```csharp
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace VsCodeProfileCommon.Services
{
    public class FileSearchService
    {
        public List<string> SearchInFiles(string directory, string pattern, string fileExtension = "*")
        {
            var results = new List<string>();
            
            try
            {
                var files = Directory.GetFiles(directory, $"*{fileExtension}", SearchOption.AllDirectories);
                
                foreach (var file in files)
                {
                    try
                    {
                        var content = File.ReadAllText(file);
                        if (content.Contains(pattern, StringComparison.OrdinalIgnoreCase))
                        {
                            results.Add(file);
                        }
                    }
                    catch
                    {
                        // Skip files that can't be read
                    }
                }
            }
            catch
            {
                // Directory doesn't exist or access denied
            }
            
            return results;
        }
    }
}
```

#### 2. Build

```powershell
cd src/shared/MPK.Profile.Core
dotnet build -c Release
```

#### 3. Use in Project

**In a profile picker or feature app:**

```csharp
using VsCodeProfileCommon.Services;

var searchService = new FileSearchService();
var results = searchService.SearchInFiles("C:\\VSCodeProfiles\\", "TODO", ".json");
// Returns: list of JSON files containing "TODO"
```

#### 4. Commit

```powershell
git add src/shared/MPK.Profile.Core/Services/FileSearchService.cs
git commit -m "Add FileSearchService to shared library"
```

---

## Common Gotchas

| Issue | Cause | Fix |
|-------|-------|-----|
| **Launcher fails silently** | PowerShell execution policy | Add `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` to build script |
| **App doesn't use correct profile** | Wrong `--user-data-dir` path | Check launcher script quotes and path separators (use `\`, not `/`) |
| **Registry key not found** | App never set registry value | Initialize registry key in SettingsService constructor |
| **Profile folder not created** | Path doesn't exist, no `New-Item` call | Check PowerShell script uses `New-Item -ItemType Directory -Force` |
| **Submodule branch mismatch** | Submodule on `master`, main repo expects `main` | `git submodule update --init --recursive`, then update `.gitmodules` |
| **Build fails with "ProjectRoot not found"** | Missing dependency or incorrect project path | Verify `.csproj` references are correct, run `dotnet restore` |
| **Installer doesn't include new launcher** | Not added to build script or `.iss` file | Check both `build/Build.ps1` and `packaging/inno/MPKTools.iss` updated |

---

## Testing Checklist

**For new launcher:**
- [ ] VD detection works (test on multiple desktops)
- [ ] Profile folder created on first launch
- [ ] App launches with correct isolated data
- [ ] Create-Shortcut.ps1 creates desktop shortcut
- [ ] Shortcut icon appears correctly
- [ ] Build script includes launcher in staging
- [ ] Installer includes launcher in deployment

**For new WPF app:**
- [ ] App launches and displays UI
- [ ] Dark theme looks consistent
- [ ] Settings window opens and folder picker works
- [ ] Profile list displays and updates
- [ ] Search/filtering works
- [ ] Click profile launches app in correct isolation
- [ ] Build script publishes app to staging
- [ ] Installer creates Start Menu shortcut

**For shared library addition:**
- [ ] New service builds without errors
- [ ] Existing apps still build (no breaking changes)
- [ ] Test new service with sample data
- [ ] Update docs in service's XML comments
- [ ] All apps can import new service

---

## Debugging Tips

### PowerShell Launcher Debugging

```powershell
# Add verbose output
Write-Host "Desktop number: $desktopNumber"
Write-Host "Profile folder: $profileFolder"
Write-Host "Launch command: $launchCommand"

# Test registry read
$regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops"
Get-ItemProperty -Path $regPath

# Check if app executable exists
Test-Path "C:\Program Files\Chrome\chrome.exe"

# Run without silent flags to see errors
powershell -ExecutionPolicy Bypass -File ".\Launch-Chrome.ps1"
```

### WPF App Debugging

```csharp
// Add debug output
System.Diagnostics.Debug.WriteLine($"Profiles found: {profiles.Count}");

// Check registry access
try
{
    var key = Registry.CurrentUser.OpenSubKey(@"Software\VsCodeProfilePicker");
    Debug.WriteLine($"Registry key exists: {key != null}");
}
catch (Exception ex)
{
    Debug.WriteLine($"Registry access error: {ex.Message}");
}

// Log file system errors
try
{
    var files = Directory.GetFiles(profileRoot);
}
catch (Exception ex)
{
    Debug.WriteLine($"File system error: {ex.Message}");
}
```

### Build Script Debugging

```powershell
# Run build with verbose output
$VerbosePreference = "Continue"
.\build\Build.ps1 -Configuration Release -Verbose

# Check intermediate outputs
ls .\dist\staging\
ls .\dist\staging\Apps\
ls .\dist\staging\Scripts\

# Verify dotnet publish
dotnet publish "src/desktop/MPK.VsCode.ProfilePicker/VsCodeProfilePicker.csproj" -c Release -f net8.0-windows -o "test-output" --self-contained
```

---

## Documentation Updates

When adding new components, update:

1. **README.md** (repo root) — Add component to list with brief description
2. **CHANGELOG.md** — Document in unreleased section
3. **docs/versions/v1.5/docs/COMPONENTS.md** — Add full spec to relevant section
4. **docs/versions/v1.5/docs/ARCHITECTURE.md** — Update dependency graph if applicable
5. **.gitmodules** — Update if adding new submodule

---

Return to [README.md](README.md)
