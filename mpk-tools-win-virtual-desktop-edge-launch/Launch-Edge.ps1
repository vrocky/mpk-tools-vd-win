#Requires -Version 5.1
<#
.SYNOPSIS
    Opens Microsoft Edge with an isolated profile for the current virtual desktop.
    Profile dirs: C:\EdgeProfiles\virtual_desktop_[N]\

.EXAMPLE
    .\Launch-Edge.ps1
    .\Launch-Edge.ps1 -Desktop 3
    .\Launch-Edge.ps1 -Url "https://github.com"
#>
param(
    [int]$Desktop = 0,
    [string]$Url  = ""
)

$EdgeExe      = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
$ProfilesRoot = "C:\EdgeProfiles"

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
$userDataDir = "$ProfilesRoot\$profileName"

# ── Ensure dir exists ─────────────────────────────────────────────────────────
New-Item -ItemType Directory -Path $userDataDir -Force | Out-Null

# ── Build args ────────────────────────────────────────────────────────────────
$edgeArgs = @(
    "--user-data-dir=`"$userDataDir`"",
    "--new-window"
)

if ($Url) {
    $edgeArgs += $Url
}

# ── Print info ────────────────────────────────────────────────────────────────
Write-Host "Desktop   : $desktopNum"   -ForegroundColor Cyan
Write-Host "Profile   : $profileName"  -ForegroundColor Cyan
Write-Host "Data dir  : $userDataDir"  -ForegroundColor DarkGray
if ($Url) {
    Write-Host "URL       : $Url" -ForegroundColor Yellow
}

Start-Process -FilePath $EdgeExe -ArgumentList $edgeArgs
