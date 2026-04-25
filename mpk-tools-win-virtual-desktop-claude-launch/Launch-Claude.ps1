#Requires -Version 5.1
<#
.SYNOPSIS
    Opens Claude Code (claudew) in an isolated working directory for the current virtual desktop.
    Working dirs: C:\claude-ws\vd-profiles\vd-[N]

.EXAMPLE
    .\Launch-Claude.ps1
    .\Launch-Claude.ps1 -Resume
    .\Launch-Claude.ps1 -Desktop 3 -Resume
#>
param(
    [int]$Desktop   = 0,
    [switch]$Resume
)

$ProfilesRoot = "C:\claude-ws\vd-profiles"

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
$profileDir  = "$ProfilesRoot\vd-$desktopNum"

# ── Ensure dir exists ─────────────────────────────────────────────────────────
New-Item -ItemType Directory -Path $profileDir -Force | Out-Null

# ── Print info ────────────────────────────────────────────────────────────────
$resumeFlag = if ($Resume) { "--resume" } else { "" }
Write-Host "Desktop : $desktopNum"                           -ForegroundColor Cyan
Write-Host "Dir     : $profileDir"                           -ForegroundColor Cyan
Write-Host "Command : claude $resumeFlag".Trim()            -ForegroundColor DarkGray

# ── Resolve shell (PowerShell 7 preferred, fall back to Windows PowerShell) ───
$shell = if (Test-Path "$env:ProgramFiles\PowerShell\7\pwsh.exe") {
    "$env:ProgramFiles\PowerShell\7\pwsh.exe"
} else {
    "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
}

# ── Open Windows Terminal in the profile dir running claudew ──────────────────
$wtArgs = @(
    "new-tab",
    "--startingDirectory", $profileDir,
    "--",
    $shell, "-NoExit", "-Command", "claude", $resumeFlag
) | Where-Object { $_ -ne "" }

Start-Process "wt" -ArgumentList $wtArgs
