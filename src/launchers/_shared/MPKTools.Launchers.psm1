# MPK Tools Launcher Module
# Shared functionality for all virtual desktop launchers
# Eliminates code duplication across launcher scripts

function Get-VDNumber {
    <#
    .SYNOPSIS
    Detects the current Windows virtual desktop number (1, 2, 3, etc.)
    .DESCRIPTION
    Reads Windows Registry to find the active virtual desktop GUID,
    matches it against the ordered list of all desktops, and returns its position.
    .OUTPUTS
    [int] Desktop number (1-indexed). Returns 1 if detection fails.
    #>
    try {
        $regPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops'
        $reg = Get-ItemProperty $regPath -ErrorAction Stop

        $allBytes = [byte[]]$reg.VirtualDesktopIDs
        $curBytes = [byte[]]$reg.CurrentVirtualDesktop
        $curGuid = [Guid]::new($curBytes)

        $count = $allBytes.Length / 16
        for ($i = 0; $i -lt $count; $i++) {
            $chunk = New-Object byte[] 16
            [Array]::Copy($allBytes, $i * 16, $chunk, 0, 16)
            if ([Guid]::new($chunk) -eq $curGuid) {
                return $i + 1
            }
        }
        return 1
    }
    catch {
        Write-Warning "Failed to detect virtual desktop: $_"
        return 1
    }
}

function Get-ProfilePath {
    <#
    .SYNOPSIS
    Constructs the profile path for an app on a specific virtual desktop.
    .DESCRIPTION
    Returns the path to an app's profile directory under C:\MPKTools\Profiles\[app]\virtual_desktop_[N]
    or C:\MPKTools\Profiles\[app]\vd-[N] for Claude (special case).
    .PARAMETER AppName
    Application name (e.g., 'chrome', 'vscode', 'claude', 'edge', 'sticky-notes', 'antigravity')
    .PARAMETER Desktop
    Virtual desktop number. If 0, detects current desktop automatically.
    .PARAMETER CreateIfMissing
    Auto-create the directory if it doesn't exist (default: $true)
    .OUTPUTS
    [string] Full path to profile folder. Creates folder if needed.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$AppName,

        [int]$Desktop = 0,

        [bool]$CreateIfMissing = $true
    )

    $desktopNum = if ($Desktop -gt 0) { $Desktop } else { Get-VDNumber }
    $profileRoot = "C:\MPKTools\Profiles"

    $path = if ($AppName -eq 'claude') {
        # Claude uses 'vd-N' format (session-based, not profile-based)
        "$profileRoot\$AppName\vd-$desktopNum"
    } else {
        # All other apps: [app]\virtual_desktop_[N]
        "$profileRoot\$AppName\virtual_desktop_$desktopNum"
    }

    if ($CreateIfMissing -and -not (Test-Path $path)) {
        New-Item -ItemType Directory -Force $path | Out-Null
    }

    return $path
}

function New-LauncherShortcut {
    <#
    .SYNOPSIS
    Creates a desktop shortcut for a launcher script.
    .PARAMETER Name
    Display name for the shortcut (e.g., 'Chrome (VD)', 'VS Code (VD)')
    .PARAMETER ScriptPath
    Full path to the Launch-*.ps1 script
    .PARAMETER IconPath
    Full path to the .ico icon file
    .PARAMETER RunAsAdmin
    If $true, shortcut runs with admin elevation
    .PARAMETER Arguments
    Additional arguments to pass to the script (optional)
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [string]$ScriptPath,

        [Parameter(Mandatory=$true)]
        [string]$IconPath,

        [bool]$RunAsAdmin = $false,

        [string]$Arguments = ""
    )

    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "$Name.lnk"

    try {
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)

        $shortcut.TargetPath = "powershell.exe"
        $shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" $Arguments"
        $shortcut.IconLocation = if (Test-Path $IconPath) { $IconPath } else { "powershell.exe" }
        $shortcut.WorkingDirectory = Split-Path $ScriptPath -Parent

        if ($RunAsAdmin) {
            # Set admin flag in shortcut (byte 0x15 of link file)
            $bytes = [System.IO.File]::ReadAllBytes($shortcutPath)
            $bytes[0x15] = $bytes[0x15] -bor 0x20
            [System.IO.File]::WriteAllBytes($shortcutPath, $bytes)
        }

        $shortcut.Save()
        Write-Host "Created shortcut: $shortcutPath"
    }
    catch {
        Write-Error "Failed to create shortcut: $_"
    }
}

Export-ModuleMember -Function Get-VDNumber, Get-ProfilePath, New-LauncherShortcut
