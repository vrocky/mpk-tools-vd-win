Add-Type -AssemblyName System.Drawing

$launcherPs1 = "C:\Scripts\ClaudeProfiles\Launch-Claude.ps1"
$iconPath    = "C:\Scripts\ClaudeProfiles\claude.ico"
$claudeExe   = "$env:LOCALAPPDATA\SquirrelTemp\tempb\lib\net45\claude.exe"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcut    = "$desktopPath\Claude Code (Virtual Desktop).lnk"
$resumeShortcut = "$desktopPath\Claude Code Resume (Virtual Desktop).lnk"

# ── Extract Claude icon and save as .ico ─────────────────────────────────────
$srcIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($claudeExe)

$bmp = New-Object System.Drawing.Bitmap 256, 256
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($srcIcon.ToBitmap(), 0, 0, 256, 256)
$g.Dispose()

$resized = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
$fs = [System.IO.File]::OpenWrite($iconPath)
$resized.Save($fs)
$fs.Close()
$bmp.Dispose()

Write-Host "Icon     : $iconPath" -ForegroundColor Green

# ── Create desktop shortcuts (.lnk) ──────────────────────────────────────────
$wsh = New-Object -ComObject WScript.Shell

function New-ClaudeShortcut {
	param(
		[Parameter(Mandatory = $true)]
		[string]$Path,
		[Parameter(Mandatory = $true)]
		[string]$Arguments,
		[Parameter(Mandatory = $true)]
		[string]$Description
	)

	$lnk = $wsh.CreateShortcut($Path)
	$lnk.TargetPath       = "powershell.exe"
	$lnk.Arguments        = $Arguments
	$lnk.WorkingDirectory = "C:\Scripts\ClaudeProfiles"
	$lnk.IconLocation     = "$iconPath,0"
	$lnk.Description      = $Description
	$lnk.Save()

	Write-Host "Shortcut : $Path" -ForegroundColor Green
}

New-ClaudeShortcut `
	-Path $shortcut `
	-Arguments "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$launcherPs1`"" `
	-Description "Open Claude Code for the current virtual desktop"

New-ClaudeShortcut `
	-Path $resumeShortcut `
	-Arguments "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$launcherPs1`" -Resume" `
	-Description "Open Claude Code (Resume) for the current virtual desktop"
