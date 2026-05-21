# Virtual Desktop Detection & Profile Isolation

Complete reference for how MPK Tools detects virtual desktops and isolates application profiles.

---

## Windows Virtual Desktop Mechanism

### What is a Virtual Desktop?

Windows 11 (and Windows 10 with update) allows users to create multiple workspaces. Press `Win+Tab` to see all desktops and switch between them.

**Key Property:** Each virtual desktop is identified by a unique GUID (Globally Unique Identifier).

**User Perspective:**
- Desktop 1: Work projects, VS Code, Chrome with work profile
- Desktop 2: Personal projects, Chrome with personal profile, notes
- Desktop 3: Gaming, Discord, game launcher

**MPK Tools Perspective:**
- Detect which desktop user is on
- Launch application with desktop-specific profile
- User switches desktops → app switches profiles automatically

---

## Registry-Based Detection (v1.5 Implementation)

### Registry Locations

**All VD information is in:**
```
HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
```

**Two key values:**

#### 1. CurrentVirtualDesktop
```
Type:    REG_BINARY
Value:   16 bytes (128-bit GUID)
Example: 0x01 0x00 0x00 0x00 ... (16 bytes in little-endian format)
```

This is the GUID of the currently active virtual desktop in binary form.

#### 2. VirtualDesktopIDs
```
Type:    REG_BINARY
Value:   N × 16 bytes (concatenated GUIDs of all desktops, in order)
Example: 
  Desktop 1: bytes 0-15
  Desktop 2: bytes 16-31
  Desktop 3: bytes 32-47
```

This is an ordered list of all virtual desktops on the system, each represented as a 16-byte GUID.

### Detection Algorithm

All launchers (Launch-Chrome.ps1, Launch-VSCode.ps1, etc.) follow this algorithm:

```powershell
# Step 1: Read CurrentVirtualDesktop from registry
$regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops"
$currentVD = (Get-ItemProperty -Path $regPath -Name "CurrentVirtualDesktop").CurrentVirtualDesktop

# Step 2: Convert binary GUID to string for comparison
$currentGUID = [guid]::new($currentVD, 0)
# Result: GUID like "a1b2c3d4-e5f6-7890-abcd-ef1234567890"

# Step 3: Read VirtualDesktopIDs (all desktops)
$vdIDs = (Get-ItemProperty -Path $regPath -Name "VirtualDesktopIDs").VirtualDesktopIDs

# Step 4: Parse all VDs from binary
$allVDs = @()
for ($i = 0; $i -lt $vdIDs.Length; $i += 16) {
    $vdGUID = [guid]::new($vdIDs, $i)
    $allVDs += $vdGUID
}

# Step 5: Find index of current VD in the list
$desktopNumber = $allVDs.IndexOf($currentGUID) + 1
# Result: 1, 2, 3, ... (1-indexed)

# Step 6: Create profile folder name
$profileFolder = "virtual_desktop_$desktopNumber"
# Result: "virtual_desktop_1", "virtual_desktop_2", etc.

# Step 7: Launch app with this profile
chrome --user-data-dir "C:\ChromeProfiles\$profileFolder\"
```

### Example

**System state:**
- Desktop 1 active (GUID: a1b2c3d4-...)
- Total desktops: 3

**Registry values:**
```
CurrentVirtualDesktop:  0x01 0x00 0x00 0x00 0xb2 0xc3 0xd4 0xa1 ... (little-endian GUID)
                        ↑ represents GUID a1b2c3d4-...

VirtualDesktopIDs:      [16 bytes: GUID of Desktop 1]
                        [16 bytes: GUID of Desktop 2]
                        [16 bytes: GUID of Desktop 3]
```

**Algorithm result:**
1. Read CurrentVirtualDesktop → a1b2c3d4-...
2. Search VirtualDesktopIDs → found at index 0
3. Calculate desktop number → 0 + 1 = 1
4. Profile folder → "virtual_desktop_1"
5. Launch → `chrome --user-data-dir "C:\ChromeProfiles\virtual_desktop_1\"`

---

## Alternative: COM API (Optional, Not Used in v1.5)

### IVirtualDesktopManager Interface

Windows provides a COM interface for VD detection (internal API, not officially documented):

```csharp
[ComImport]
[Guid("a5cd92ff-29be-454c-8d04-d82879fb3f1b")]
public interface IVirtualDesktopManager
{
    [PreserveSig]
    int IsWindowOnCurrentVirtualDesktop(IntPtr topLevelWindow, out bool isOnCurrentDesktop);
    
    [PreserveSig]
    int GetWindowDesktopId(IntPtr topLevelWindow, out Guid desktopId);
    
    [PreserveSig]
    int MoveWindowToDesktop(IntPtr topLevelWindow, ref Guid desktopId);
}

[ComImport]
[Guid("f31574d6-b682-4cdc-bd56-1edf271d440c")]
public class VirtualDesktopManager { }
```

**Advantages:**
- Official Windows API (stable, documented in latest Windows docs)
- Can move windows between desktops programmatically
- More reliable than registry scraping

**Disadvantages:**
- COM interop overhead (C# only, not PowerShell-friendly)
- Requires `HKEY_CLASSES_ROOT` registry access

**Why not used in v1.5:**
- Registry method is simpler and faster
- Works in PowerShell (launchers are pure PowerShell)
- Both methods read the same underlying data

**Potential for v1.6:** Use COM API in shared C# library, expose as service for WPF apps.

---

## Profile Folder Naming Convention

### Virtual Desktop Launchers

All launchers use this pattern:
```
[ProfileRoot]/virtual_desktop_N/
```

**Examples:**
```
C:\ChromeProfiles\virtual_desktop_1\       (Chrome on Desktop 1)
C:\ChromeProfiles\virtual_desktop_2\       (Chrome on Desktop 2)
C:\VSCodeProfiles\virtual_desktop_1\       (VS Code on Desktop 1)
C:\VSCodeProfiles\virtual_desktop_2\       (VS Code on Desktop 2)
```

**Auto-creation:**
- Launcher checks if folder exists
- If not, creates it: `New-Item -ItemType Directory -Force $profileFolder`
- Some apps auto-initialize their data on first launch (Chrome creates Default profile, VS Code creates storage.json, etc.)

### Profile Picker Applications

Picker apps use arbitrary names:
```
C:\VSCodeProfiles\Work\user-data\
C:\VSCodeProfiles\Work\extensions\

C:\VSCodeProfiles\Personal\user-data\
C:\VSCodeProfiles\Personal\extensions\

C:\VSCodeProfiles\Python\user-data\
C:\VSCodeProfiles\Python\extensions\
```

**Not tied to VD number.** User creates named profiles for different purposes, completely independent of virtual desktops.

---

## Per-Application Isolation Strategies

### Chrome & Edge

**Isolation Method:** `--user-data-dir` flag

```powershell
chrome.exe --user-data-dir "C:\ChromeProfiles\virtual_desktop_1\"
```

**What's Isolated:**
- Bookmarks
- History
- Cookies & cached login sessions
- Extensions
- Preferences (theme, language, etc.)
- Autofill data

**Storage Location:**
```
C:\ChromeProfiles\virtual_desktop_1\
├── Default\                (main profile)
│   ├── Bookmarks
│   ├── History
│   ├── Cookies
│   └── ...
├── Extensions\
└── ...
```

**Key Point:** Everything is isolated. User can be logged into different Gmail accounts on different desktops.

---

### VS Code (Launcher)

**Isolation Method:** Dual flags

```powershell
code.exe --user-data-dir "C:\VSCodeProfiles\virtual_desktop_1\user-data" `
         --extensions-dir "C:\VSCodeProfiles\virtual_desktop_1\extensions"
```

**What's Isolated:**
- User settings (`settings.json`)
- Installed extensions
- Recent workspaces
- VS Code internal storage

**Storage Location:**
```
C:\VSCodeProfiles\virtual_desktop_1\
├── user-data\
│   ├── User\
│   │   └── settings.json
│   ├── workspaceStorage\
│   └── ...
└── extensions\
    ├── ms-python.python\
    └── ... (each extension in own folder)
```

**Why two directories?**
- `--user-data-dir` stores VS Code config + workspace data
- `--extensions-dir` stores installed extensions (can be large)
- Separating them allows sharing extensions across profiles while keeping settings isolated (optional, not done in v1.5)

---

### VS Code (Profile Picker)

**Same isolation as launcher:** `--user-data-dir` + `--extensions-dir`

**Difference:** Picker uses user-named profiles (Work, Personal, Python) instead of virtual_desktop_N

---

### Sticky Notes

**Isolation Method:** `--profile` + `--data-dir` flags

```powershell
StickyNotesApp.exe --profile "virtual_desktop_1" --data-dir "C:\StickyNotesProfiles\profiles\virtual_desktop_1\"
```

**What's Isolated:**
- Note content (stored in database)
- Note categories/collections

---

### Claude Code (CLI)

**Isolation Method:** Working directory (no `--user-data-dir` available)

```powershell
$env:CLAUDEW_HOME = "C:\claude-ws\vd-profiles\vd-1"
wt.exe -d "$env:CLAUDEW_HOME"
claudew.exe
```

**What's Isolated:**
- Session history (in ~/.claude/history/)
- Project context
- Working directory

**Why different:** Claude Code CLI doesn't use `--user-data-dir`. Each session is tied to the current working directory. Different VDs get different work directories.

---

### AntiGravity

**Isolation Method:** `--user-data-dir` flag

```powershell
AntiGravity.exe --user-data-dir "C:\AntiGravityProfiles\virtual_desktop_1\data"
```

---

## Profile Data Persistence

### Where Data is Stored

All profile data is stored **outside Program Files:**
```
C:\ChromeProfiles\
C:\EdgeProfiles\
C:\VSCodeProfiles\
C:\StickyNotesProfiles\
C:\AntiGravityProfiles\
C:\claude-ws\vd-profiles\
```

**Why?**
- Installer/Updater runs as admin (Program Files is protected)
- Profile data is user data (belongs in user's home directory, not Program Files)
- Uninstall doesn't touch profile data (user keeps all notes, bookmarks, history)

### Backup & Migration

**Backup entire profile root:**
```powershell
# Backup all Chrome profiles
xcopy C:\ChromeProfiles\ D:\Backup\ChromeProfiles\ /S /E /H /I

# Backup all VS Code profiles (large due to extensions)
xcopy C:\VSCodeProfiles\ D:\Backup\VSCodeProfiles\ /S /E /H /I
```

**Migrate to new machine:**
1. Install MPK Tools on new machine
2. Copy profile folders: `xcopy D:\Backup\ChromeProfiles\ C:\ChromeProfiles\ /S /E /H /I`
3. Run launchers → profile data is restored

**Export single profile (e.g., Chrome bookmarks):**
```
C:\ChromeProfiles\virtual_desktop_1\Default\Bookmarks (JSON file)
```

---

## Registry Usage by Launchers

**Read-only operations** (launchers don't write, only read):

```powershell
# Detect current desktop
$regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops"
$currentVD = (Get-ItemProperty -Path $regPath -Name "CurrentVirtualDesktop").CurrentVirtualDesktop
```

**No elevation needed** (HKCU = current user's registry)

**Performance:**
- Registry read: ~1 ms
- Profile folder creation: ~5 ms
- App launch: ~500 ms (dominated by app startup, not detection)

---

## Edge Cases & Known Issues

| Case | Behavior |
|------|----------|
| **User adds new VD** | Launcher detects it (reads registry on each launch), creates profile folder on demand |
| **User deletes a VD** | No orphaned profiles (folders remain in C:\*Profiles\, user must delete manually if desired) |
| **VD name changes** | No effect (VDs don't have names in registry, only GUIDs) |
| **Launcher runs while VD switching** | Might launch on old VD (registry read happens immediately, race condition possible but rare) |
| **Registry corrupted** | Launcher fails gracefully (try-catch logs error, still launches app with default profile) |
| **User on VD 4, but only 3 desktops exist** | Launcher creates profiles for desktop numbers beyond actual count (harmless, user just won't use them) |

---

## Testing Virtual Desktop Detection

### Manual Test

**Scenario:** Verify detection works correctly

1. Open PowerShell in repo: `cd C:\Users\globql-local\Documents\projects\mpk-tools-vd-win`
2. Read registry:
   ```powershell
   $regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops"
   $vdIDs = (Get-ItemProperty -Path $regPath -Name "VirtualDesktopIDs").VirtualDesktopIDs
   $currentVD = (Get-ItemProperty -Path $regPath -Name "CurrentVirtualDesktop").CurrentVirtualDesktop
   
   Write-Host "Current VD (hex): $([BitConverter]::ToString($currentVD))"
   Write-Host "All VDs:"
   for ($i = 0; $i -lt $vdIDs.Length; $i += 16) {
       $guid = [guid]::new($vdIDs, $i)
       Write-Host "  Desktop $($i/16 + 1): $guid"
   }
   ```
3. Switch desktops (Win+Tab, click a desktop)
4. Re-run script → CurrentVD should change
5. Run launcher: `.\src\launchers\chrome\Launch-Chrome.ps1`
   - Verify Chrome launches with correct profile: `chrome --user-data-dir "C:\ChromeProfiles\virtual_desktop_N\"`

### Automated Test (v1.6 TODO)

```powershell
# tests/launchers/test-vd-detection.ps1

function Test-VDDetection {
    param([int]$TargetDesktop)
    
    # Mock registry (requires admin for registry mocking)
    # Set-ItemProperty -Path "HKCU:\SOFTWARE\..." -Name "CurrentVirtualDesktop" -Value $mockGUID
    
    # Run launcher script
    & ".\src\launchers\chrome\Launch-Chrome.ps1" -Desktop $TargetDesktop
    
    # Assert Chrome started with correct --user-data-dir
    # Verify C:\ChromeProfiles\virtual_desktop_N\ exists
}
```

---

## Comparison with Other Desktop OSes

| OS | VD Support | Isolation | Unique Feature |
|-------|-----------|-----------|-----------|
| **Windows 11** | Built-in (Win+Tab) | Requires per-app flags | Registry-based GUID detection |
| **macOS** | Built-in (Mission Control) | Per-process PID + environ vars | Launchd plist configuration |
| **Linux (GNOME)** | Built-in (Activities) | Window manager per-workspace | X11/Wayland workspace numbers |
| **Linux (i3)** | Built-in (workspaces) | i3-msg workspace switching | Programmatic workspace API |

**MPK Tools Windows-only.** Would need rewrite for other OSes.

---

## Future Improvements (v1.6+)

**v1.6 Opportunity:**
- Move VD detection to shared C# library (`src/shared/`)
- Expose as service: `VirtualDesktopDetectionService.GetCurrentDesktopNumber()`
- Use COM API for more robustness
- Launchers call the service instead of reimplementing logic

**v1.7 Opportunity:**
- Support custom profile roots per desktop (instead of just numbered folders)
- Sync profiles across machines (cloud backup)
- Per-VD hotkeys (different key combinations for different desktops)

---

Return to [README.md](README.md)
