#Requires -Version 5.1
<#
.SYNOPSIS
    Detects the current Windows 11 virtual desktop (index + GUID).
.EXAMPLE
    .\Get-VirtualDesktop.ps1
    .\Get-VirtualDesktop.ps1 -Watch          # polls every 300ms, prints on change
    .\Get-VirtualDesktop.ps1 -WindowTitle "Notepad"
#>
param(
    [switch]$Watch,
    [string]$WindowTitle
)

# ── C# helpers: COM + Win32 (wrapped so PowerShell -as quirks are avoided) ───
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;

// ── Public COM interface (stable across all Win10/11 builds) ─────────────────
[ComImport]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
[Guid("A5CD92FF-29BE-454C-8D04-D82879FB3F1B")]
public interface IVirtualDesktopManager
{
    [return: MarshalAs(UnmanagedType.Bool)]
    bool IsWindowOnCurrentVirtualDesktop(IntPtr topLevelWindow);
    Guid GetWindowDesktopId(IntPtr topLevelWindow);
    void MoveWindowToDesktop(IntPtr topLevelWindow, ref Guid desktopId);
}

[ComImport]
[Guid("AA509086-5CA9-4C25-8F95-589D3C07B48A")]
public class VirtualDesktopManagerCoClass { }

// ── Wrapper so we avoid PowerShell's broken -as for COM interfaces ───────────
public static class VDM
{
    private static IVirtualDesktopManager _vdm;

    private static IVirtualDesktopManager Get()
    {
        if (_vdm == null)
            _vdm = (IVirtualDesktopManager)new VirtualDesktopManagerCoClass();
        return _vdm;
    }

    public static bool IsOnCurrentDesktop(IntPtr hWnd)
    {
        try { return Get().IsWindowOnCurrentVirtualDesktop(hWnd); }
        catch { return false; }
    }

    public static string GetDesktopGuid(IntPtr hWnd)
    {
        try { return Get().GetWindowDesktopId(hWnd).ToString(); }
        catch { return "(error)"; }
    }
}

// ── Win32 helpers ────────────────────────────────────────────────────────────
public static class Win32
{
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern int    GetWindowText(IntPtr h, StringBuilder sb, int n);
    [DllImport("user32.dll")] public static extern bool   EnumWindows(EnumWinProc fn, IntPtr lp);
    [DllImport("user32.dll")] public static extern bool   IsWindowVisible(IntPtr h);
    public delegate bool EnumWinProc(IntPtr hWnd, IntPtr lp);

    public static string GetTitle(IntPtr hWnd)
    {
        var sb = new StringBuilder(256);
        GetWindowText(hWnd, sb, 256);
        return sb.ToString();
    }
}
"@ -ErrorAction Stop

# ── Registry approach: current desktop + full list ───────────────────────────
function Get-DesktopInfoFromRegistry {
    $regPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops'
    $reg     = Get-ItemProperty $regPath -ErrorAction Stop

    $allBytes = [byte[]]$reg.VirtualDesktopIDs
    $curBytes = [byte[]]$reg.CurrentVirtualDesktop

    # Build current GUID
    $curGuid = [Guid]::new($curBytes)

    # Build list — use Array.Copy to get real byte[] chunks (not object[])
    $desktops = [System.Collections.Generic.List[Guid]]::new()
    $count = $allBytes.Length / 16
    for ($i = 0; $i -lt $count; $i++) {
        $chunk = New-Object byte[] 16
        [Array]::Copy($allBytes, $i * 16, $chunk, 0, 16)
        $desktops.Add([Guid]::new($chunk))
    }

    $index = -1
    for ($i = 0; $i -lt $desktops.Count; $i++) {
        if ($desktops[$i] -eq $curGuid) { $index = $i; break }
    }

    return [pscustomobject]@{
        Index       = $index        # 0-based position in stored list
        Number      = $index + 1    # human-friendly
        Total       = $desktops.Count
        CurrentGuid = $curGuid
        AllGuids    = $desktops.ToArray()
    }
}

# ── COM approach: check any window's desktop membership ─────────────────────
function Get-WindowDesktopInfo {
    param([IntPtr]$hWnd)
    return [pscustomobject]@{
        Handle       = $hWnd
        Title        = [Win32]::GetTitle($hWnd)
        DesktopGuid  = [VDM]::GetDesktopGuid($hWnd)
        OnCurrent    = [VDM]::IsOnCurrentDesktop($hWnd)
    }
}

# ── Enumerate visible windows matching a title substring ─────────────────────
function Find-WindowByTitle {
    param([string]$TitlePart)
    $results = [System.Collections.Generic.List[IntPtr]]::new()
    $cb = [Win32+EnumWinProc]{
        param($hWnd, $lp)
        if ([Win32]::IsWindowVisible($hWnd)) {
            $t = [Win32]::GetTitle($hWnd)
            if ($t -and $t -match [regex]::Escape($TitlePart)) {
                $results.Add($hWnd)
            }
        }
        return $true
    }
    [Win32]::EnumWindows($cb, [IntPtr]::Zero) | Out-Null
    return $results
}

# ── Pretty print ─────────────────────────────────────────────────────────────
function Show-Status {
    $info = Get-DesktopInfoFromRegistry

    Write-Host ""
    Write-Host "=== Virtual Desktop Status ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host ("  Current : Desktop {0}  (of {1} stored GUIDs)" -f $info.Number, $info.Total) -ForegroundColor Yellow
    Write-Host ("  GUID    : {0}" -f $info.CurrentGuid) -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Stored Desktop GUIDs:" -ForegroundColor Cyan

    for ($i = 0; $i -lt $info.AllGuids.Count; $i++) {
        $isCurrent = ($i -eq $info.Index)
        $marker    = if ($isCurrent) { "  <-- YOU ARE HERE" } else { "" }
        $color     = if ($isCurrent) { "Yellow" } else { "DarkGray" }
        Write-Host ("    [{0,2}] {1}{2}" -f ($i + 1), $info.AllGuids[$i], $marker) -ForegroundColor $color
    }

    # COM: foreground window check
    Write-Host ""
    Write-Host "  Foreground Window (via COM IVirtualDesktopManager):" -ForegroundColor Cyan
    $hwnd = [Win32]::GetForegroundWindow()
    $w = Get-WindowDesktopInfo -hWnd $hwnd
    Write-Host ("    Title        : {0}" -f $w.Title)
    Write-Host ("    Desktop GUID : {0}" -f $w.DesktopGuid) -ForegroundColor DarkGray
    $c = if ($w.OnCurrent) { "Green" } else { "Red" }
    Write-Host ("    On current   : {0}" -f $w.OnCurrent) -ForegroundColor $c

    # Optional: search by window title
    if ($WindowTitle) {
        Write-Host ""
        Write-Host ("  Windows matching '{0}':" -f $WindowTitle) -ForegroundColor Cyan
        $handles = Find-WindowByTitle -TitlePart $WindowTitle
        if ($handles.Count -eq 0) {
            Write-Host "    (none found)" -ForegroundColor DarkGray
        }
        foreach ($h in $handles) {
            $wi = Get-WindowDesktopInfo -hWnd $h
            $wc = if ($wi.OnCurrent) { "Green" } else { "Red" }
            Write-Host ("    [{0}]" -f $wi.Title)
            Write-Host ("      Desktop GUID : {0}" -f $wi.DesktopGuid) -ForegroundColor DarkGray
            Write-Host ("      On current   : {0}" -f $wi.OnCurrent) -ForegroundColor $wc
        }
    }

    Write-Host ""
}

# ── Entry point ───────────────────────────────────────────────────────────────
if ($Watch) {
    Write-Host "Watching for virtual desktop changes (Ctrl+C to stop)..." -ForegroundColor DarkGray
    $last = $null
    while ($true) {
        $info = Get-DesktopInfoFromRegistry
        if ($info.CurrentGuid -ne $last) {
            Clear-Host
            Show-Status
            $last = $info.CurrentGuid
        }
        Start-Sleep -Milliseconds 300
    }
} else {
    Show-Status
}
