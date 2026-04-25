#Requires -Version 5.1
<#
.SYNOPSIS
    Opens VS Code with an isolated profile for the current virtual desktop.
    Profile dirs: C:\VSCodeProfiles\virtual_desktop_[N]\data|extensions

.EXAMPLE
    .\Launch-VSCode.ps1
    .\Launch-VSCode.ps1 -Desktop 3
    .\Launch-VSCode.ps1 -DevExtPath "C:\Users\ws-user\Documents\project-8\workspace-info-batch"
#>
param(
    [int]$Desktop    = 0,
    [string]$DevExtPath = ""
)

$VSCodeExe    = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
$ProfilesRoot = "C:\VSCodeProfiles"

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

$desktopNum   = if ($Desktop -gt 0) { $Desktop } else { Get-CurrentDesktopNumber }
$profileName  = "virtual_desktop_$desktopNum"
$userDataDir  = "$ProfilesRoot\$profileName\data"
$extensionDir = "$ProfilesRoot\$profileName\extensions"

# ── Ensure dirs exist ─────────────────────────────────────────────────────────
New-Item -ItemType Directory -Path $userDataDir  -Force | Out-Null
New-Item -ItemType Directory -Path $extensionDir -Force | Out-Null

# ── Build args ────────────────────────────────────────────────────────────────
$codeArgs = @(
    "--user-data-dir", $userDataDir,
    "--extensions-dir", $extensionDir,
    "--new-window"
)

if ($DevExtPath -and (Test-Path $DevExtPath)) {
    $codeArgs += "--extensionDevelopmentPath=$DevExtPath"
}

# ── Print info ────────────────────────────────────────────────────────────────
Write-Host "Desktop   : $desktopNum"    -ForegroundColor Cyan
Write-Host "Profile   : $profileName"  -ForegroundColor Cyan
Write-Host "Data dir  : $userDataDir"  -ForegroundColor DarkGray
Write-Host "Ext dir   : $extensionDir" -ForegroundColor DarkGray
if ($DevExtPath) {
    Write-Host "Dev ext   : $DevExtPath" -ForegroundColor Yellow
}

& $VSCodeExe @codeArgs
