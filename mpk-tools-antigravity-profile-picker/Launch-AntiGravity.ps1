#Requires -Version 5.1
<#
.SYNOPSIS
    Opens AntiGravity with an isolated profile for the current virtual desktop.
    Profile dirs: C:\AntiGravityProfiles\virtual_desktop_[N]\data

.EXAMPLE
    .\Launch-AntiGravity.ps1
    .\Launch-AntiGravity.ps1 -Desktop 3
    .\Launch-AntiGravity.ps1 -AppExePath "C:\Path\To\AntiGravity.exe"
#>
param(
    [int]$Desktop = 0,
    [string]$AppExePath = "$env:LOCALAPPDATA\Programs\AntiGravity\AntiGravity.exe"
)

$ProfilesRoot = "C:\AntiGravityProfiles"

# Gets current virtual desktop number from the registry.
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

if (-not (Test-Path $AppExePath)) {
    throw "AntiGravity executable not found at '$AppExePath'. Use -AppExePath to specify the correct path."
}

$desktopNum  = if ($Desktop -gt 0) { $Desktop } else { Get-CurrentDesktopNumber }
$profileName = "virtual_desktop_$desktopNum"
$userDataDir = "$ProfilesRoot\$profileName\data"

New-Item -ItemType Directory -Path $userDataDir -Force | Out-Null

$appArgs = @(
    "--user-data-dir=$userDataDir",
    "--new-window"
)

Write-Host "Desktop   : $desktopNum"  -ForegroundColor Cyan
Write-Host "Profile   : $profileName" -ForegroundColor Cyan
Write-Host "Data dir  : $userDataDir" -ForegroundColor DarkGray
Write-Host "App path  : $AppExePath"  -ForegroundColor DarkGray

& $AppExePath @appArgs
