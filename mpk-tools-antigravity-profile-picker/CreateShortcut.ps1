$s = New-Object -ComObject WScript.Shell
$sc = $s.CreateShortcut("$env:USERPROFILE\Desktop\Antigravity Profile Picker.lnk")
$sc.TargetPath = "C:\Users\ws-user\Documents\project-8\antigravity-profile-picker\bin\Debug\net8.0-windows\AntigravityProfilePicker.exe"
$sc.IconLocation = "C:\Users\ws-user\Documents\project-8\antigravity-profile-picker\bin\Debug\net8.0-windows\AntigravityProfilePicker.exe,0"
$sc.WorkingDirectory = "C:\Users\ws-user\Documents\project-8\antigravity-profile-picker\bin\Debug\net8.0-windows"
$sc.Description = "Launch Antigravity with isolated profile management"
$sc.Save()
Write-Host "Shortcut created on desktop." -ForegroundColor Green
