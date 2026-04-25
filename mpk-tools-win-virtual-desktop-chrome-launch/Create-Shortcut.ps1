Add-Type -AssemblyName System.Drawing

$chromeExe   = "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
$launcherPs1 = "C:\Scripts\ChromeProfiles\Launch-Chrome.ps1"
$iconPath    = "C:\Scripts\ChromeProfiles\chrome_desktop.ico"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcut    = "$desktopPath\Chrome (Virtual Desktop).lnk"

# ── Extract Chrome icon and save as .ico ──────────────────────────────────────
$srcIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($chromeExe)

# Rebuild at 256x256 for a crisp shortcut icon
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

# ── Create desktop shortcut (.lnk) ───────────────────────────────────────────
$wsh  = New-Object -ComObject WScript.Shell
$lnk  = $wsh.CreateShortcut($shortcut)

$lnk.TargetPath       = "powershell.exe"
$lnk.Arguments        = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$launcherPs1`""
$lnk.WorkingDirectory = "C:\Scripts\ChromeProfiles"
$lnk.IconLocation     = "$iconPath,0"
$lnk.Description      = "Open Chrome for the current virtual desktop"
$lnk.Save()

Write-Host "Shortcut   : $shortcut" -ForegroundColor Green
