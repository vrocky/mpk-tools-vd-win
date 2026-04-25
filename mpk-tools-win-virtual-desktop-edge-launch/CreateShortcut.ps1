$s = New-Object -ComObject WScript.Shell
$sc = $s.CreateShortcut("$env:USERPROFILE\Desktop\Edge Profile Picker.lnk")
$sc.TargetPath = "C:\Users\ws-user\Documents\project-8\edge-profile-picker\bin\Debug\net8.0-windows\EdgeProfilePicker.exe"
$sc.IconLocation = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe,0"
$sc.WorkingDirectory = "C:\Users\ws-user\Documents\project-8\edge-profile-picker\bin\Debug\net8.0-windows"
$sc.Save()
Write-Host "Shortcut created on desktop."
