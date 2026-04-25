#Requires -Version 5.1
Add-Type -AssemblyName System.Drawing

$appExePath  = "$env:LOCALAPPDATA\Programs\AntiGravity\AntiGravity.exe"
$launcherPs1 = "C:\Scripts\AntiGravityProfiles\Launch-AntiGravity.ps1"
$iconPath    = "C:\Scripts\AntiGravityProfiles\antigravity_desktop.ico"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcut    = "$desktopPath\AntiGravity (Virtual Desktop).lnk"

if (Test-Path $appExePath) {
    # Extract app icon and save as .ico.
    $srcIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($appExePath)

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

    Write-Host "Icon saved : $iconPath" -ForegroundColor Green
}
else {
    Write-Warning "AntiGravity executable not found at '$appExePath'. Shortcut will use the default PowerShell icon."
}

$wsh = New-Object -ComObject WScript.Shell
$lnk = $wsh.CreateShortcut($shortcut)

$lnk.TargetPath       = "powershell.exe"
$lnk.Arguments        = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$launcherPs1`""
$lnk.WorkingDirectory = "C:\Scripts\AntiGravityProfiles"
if (Test-Path $iconPath) {
    $lnk.IconLocation = "$iconPath,0"
}
$lnk.Description      = "Open AntiGravity for the current virtual desktop"
$lnk.Save()

Write-Host "Shortcut   : $shortcut" -ForegroundColor Green
