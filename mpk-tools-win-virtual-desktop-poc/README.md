# Virtual Desktop POC — Windows 11

Detect the current Windows 11 virtual desktop from PowerShell using two complementary approaches: the public COM `IVirtualDesktopManager` API and the registry.

---

## Files

```
VirtualDesktopPOC/
├── Get-VirtualDesktop.ps1   # Main script
└── README.md                # This file
```

---

## How It Works

### Approach 1 — Registry (primary)

Windows stores virtual desktop state in:

```
HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
```

| Value | Type | Content |
|---|---|---|
| `CurrentVirtualDesktop` | `REG_BINARY` | 16-byte GUID of the active desktop |
| `VirtualDesktopIDs` | `REG_BINARY` | Concatenated 16-byte GUIDs of all desktops (including historical) |

Each GUID is stored in the native Windows GUID binary layout (mixed-endian), which `[System.Guid]::new(byte[])` parses correctly.

> **Note:** Windows never removes GUIDs from `VirtualDesktopIDs` when desktops are deleted. The list grows over time and includes historical entries. The current desktop GUID is always present somewhere in the list.

### Approach 2 — COM `IVirtualDesktopManager` (per-window)

The public COM interface `IVirtualDesktopManager` (CLSID `AA509086-5CA9-4C25-8F95-589D3C07B48A`) exposes:

| Method | Description |
|---|---|
| `IsWindowOnCurrentVirtualDesktop(hWnd)` | Returns `true` if the window is on the active desktop |
| `GetWindowDesktopId(hWnd)` | Returns the GUID of the desktop the window lives on |
| `MoveWindowToDesktop(hWnd, guid)` | Moves a window to a specific desktop |

This API is stable across all Windows 10 and 11 builds.

> **PowerShell quirk:** PowerShell's `-as` operator does not reliably cast COM objects to custom interfaces. The script wraps all COM calls in a static C# helper class (`VDM`) compiled at runtime via `Add-Type` to avoid this.

---

## Usage

### One-shot — print current desktop info

```powershell
.\Get-VirtualDesktop.ps1
```

**Output:**
```
=== Virtual Desktop Status ===

  Current : Desktop 3  (of 8 stored GUIDs)
  GUID    : 590e2e6e-f1f7-424c-b00f-570ccea0c28c

  Stored Desktop GUIDs:
    [ 1] bb5a8586-152f-4cf7-abf9-9e8d54c02632
    [ 2] e471f288-20ed-4fc5-86a6-d9b62bf59513
    [ 3] 590e2e6e-f1f7-424c-b00f-570ccea0c28c  <-- YOU ARE HERE
    ...

  Foreground Window (via COM IVirtualDesktopManager):
    Title        : Notepad
    Desktop GUID : 590e2e6e-f1f7-424c-b00f-570ccea0c28c
    On current   : True
```

### Watch mode — live desktop switching

```powershell
.\Get-VirtualDesktop.ps1 -Watch
```

Polls every 300ms and reprints whenever the current desktop changes. Press `Ctrl+C` to stop.

### Check a specific window

```powershell
.\Get-VirtualDesktop.ps1 -WindowTitle "Notepad"
```

Enumerates all visible windows whose title contains the string and reports their desktop GUID and whether they are on the current desktop.

---

## Parameters

| Parameter | Type | Description |
|---|---|---|
| `-Watch` | Switch | Poll continuously and print on desktop change |
| `-WindowTitle` | String | Title substring to search for across all visible windows |

---

## Architecture

```
Get-VirtualDesktop.ps1
│
├── Get-DesktopInfoFromRegistry
│     reads HKCU registry
│     parses 16-byte GUID chunks via Array.Copy
│     returns: Index, Number, Total, CurrentGuid, AllGuids[]
│
├── Get-WindowDesktopInfo  (wraps VDM static C# class)
│     calls IVirtualDesktopManager COM via C# shim
│     returns: Handle, Title, DesktopGuid, OnCurrent
│
└── Find-WindowByTitle
      EnumWindows + IsWindowVisible + GetWindowText
      returns: List<IntPtr>
```

---

## Limitations

| Limitation | Detail |
|---|---|
| Historical GUIDs | `VirtualDesktopIDs` accumulates GUIDs over time and is never pruned |
| Desktop names | Not exposed by the public COM API; requires undocumented internal COM interfaces whose GUIDs change per Windows build |
| GUID-to-index mapping | Index in the stored list may not equal the visual position shown in Task View if historical entries exist between active ones |
| No event subscription | The registry approach uses polling; there is no public WinAPI event for desktop switches |

---

## Requirements

- Windows 10 or Windows 11
- PowerShell 5.1+
- No external dependencies or admin rights required
