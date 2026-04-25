#Requires -Version 5.1
<#
.SYNOPSIS
    Opens StickyNotesApp with an isolated profile for the current virtual desktop.
    Profile dirs: C:\StickyNotesProfiles\profiles\virtual_desktop_[N]\

.EXAMPLE
    .\Launch-StickyNotes.ps1
    .\Launch-StickyNotes.ps1 -Desktop 3
#>
param(
    [int]$Desktop = 0
)

$StickyNotesExe = "C:\Program Files\StickyNotesApp\StickyNotesApp.exe"
$ProfilesRoot   = "C:\StickyNotesProfiles"

# ── Get current virtual desktop number ───────────────────────────────────────
function Get-CurrentDesktopNumber {
    $regPath  = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops'
    $reg      = Get-ItemProperty $regPath -ErrorAction Stop
    $allBytes = [byte[]]$reg.VirtualDesktopIDs
    $curBytes = [byte[]]$reg.CurrentVirtualDesktop
    $curGuid  = [Guid]::new($curBytes)

    $count = $allBytes.Length / 16
    for ($i = 0; $i -lt $count; $i++) {
        $chunk = New-Object byte[] 16
        [Array]::Copy($allBytes, $i * 16, $chunk, 0, 16)
        if ([Guid]::new($chunk) -eq $curGuid) { return $i + 1 }
    }
    return 1
}

$desktopNum  = if ($Desktop -gt 0) { $Desktop } else { Get-CurrentDesktopNumber }
$profileName = "virtual_desktop_$desktopNum"

# ── Ensure base dir exists ───────────────────────────────────────────────────
New-Item -ItemType Directory -Path $ProfilesRoot -Force | Out-Null

# ── Build args ────────────────────────────────────────────────────────────────
$appArgs = @(
    "--profile", $profileName,
    "--data-dir", $ProfilesRoot
)

# ── Print info ────────────────────────────────────────────────────────────────
Write-Host "Desktop   : $desktopNum"   -ForegroundColor Cyan
Write-Host "Profile   : $profileName"  -ForegroundColor Cyan
Write-Host "Data dir  : $ProfilesRoot\profiles\$profileName" -ForegroundColor DarkGray

# ── Launch StickyNotesApp with profile arguments ─────────────────────────────
Start-Process -FilePath $StickyNotesExe -ArgumentList $appArgs
