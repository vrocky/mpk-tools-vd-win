Add-Type -AssemblyName System.Drawing

$stickyNotesExe = "C:\Program Files\StickyNotesApp\StickyNotesApp.exe"
$launcherPs1    = "C:\Scripts\StickyNotesProfiles\Launch-StickyNotes.ps1"
$iconPath       = "C:\Scripts\StickyNotesProfiles\stickynotes_desktop.ico"
$desktopPath    = [Environment]::GetFolderPath("Desktop")
$shortcut       = "$desktopPath\StickyNotes (Virtual Desktop).lnk"

# ── Extract StickyNotes icon and save as .ico ─────────────────────────────────
$srcIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($stickyNotesExe)

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
$lnk.WorkingDirectory = "C:\Scripts\StickyNotesProfiles"
$lnk.IconLocation     = "$iconPath,0"
$lnk.Description      = "Open StickyNotes for the current virtual desktop"
$lnk.Save()

Write-Host "Shortcut   : $shortcut" -ForegroundColor Green
