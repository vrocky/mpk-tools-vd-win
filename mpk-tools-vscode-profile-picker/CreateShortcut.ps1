$s = New-Object -ComObject WScript.Shell
$sc = $s.CreateShortcut("$env:USERPROFILE\Desktop\VS Code Profile Picker.lnk")
$sc.TargetPath = "C:\Users\ws-user\Documents\project-8\vscode-profile-picker\bin\Debug\net8.0-windows\VsCodeProfilePicker.exe"
$sc.IconLocation = "C:\Users\ws-user\Documents\project-8\vscode-profile-picker\bin\Debug\net8.0-windows\VsCodeProfilePicker.exe,0"
$sc.WorkingDirectory = "C:\Users\ws-user\Documents\project-8\vscode-profile-picker\bin\Debug\net8.0-windows"
$sc.Save()
Write-Host "Shortcut updated."
