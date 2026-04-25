# Test StickyNotes Text Search with Real Data

Write-Host "`n=== StickyNotes Text Search - Real World Validation ===" -ForegroundColor Cyan

# Check if profiles exist
$profilesDir = "C:\StickyNotesProfiles\profiles"
if (!(Test-Path $profilesDir)) {
    Write-Host "`n✗ Profiles directory not found: $profilesDir" -ForegroundColor Red
    Write-Host "  Create some profiles first using StickyNotes Profile Picker" -ForegroundColor Yellow
    exit 1
}

# Scan for profiles and notes
Write-Host "`nScanning profiles..." -ForegroundColor Yellow
$profiles = Get-ChildItem $profilesDir -Directory
Write-Host "Found $($profiles.Count) profile(s):" -ForegroundColor Green

$totalNotes = 0
foreach ($profile in $profiles) {
    $notesFile = Join-Path $profile.FullName "notes.json"
    if (Test-Path $notesFile) {
        try {
            $content = Get-Content $notesFile -Raw | ConvertFrom-Json
            $noteCount = $content.notes.Count
            $totalNotes += $noteCount
            Write-Host "  ✓ $($profile.Name): $noteCount note(s)" -ForegroundColor Cyan
            
            # Show sample note titles
            if ($noteCount -gt 0) {
                $content.notes | Select-Object -First 2 | ForEach-Object {
                    $title = if ($_.title) { $_.title } else { "(untitled)" }
                    Write-Host "     - $title" -ForegroundColor Gray
                }
            }
        }
        catch {
            Write-Host "  ✗ $($profile.Name): Error reading notes.json" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  - $($profile.Name): No notes.json" -ForegroundColor Gray
    }
}

Write-Host "`nTotal notes across all profiles: $totalNotes" -ForegroundColor Green

if ($totalNotes -eq 0) {
    Write-Host "`nNo notes found. Create some notes in StickyNotesApp first." -ForegroundColor Yellow
    exit 0
}

# Launch the app
Write-Host "`nLaunching StickyNotes Text Search..." -ForegroundColor Cyan
$exePath = "C:\Users\ws-user\Documents\project-8\sticky-notes-profile-text-search\bin\Debug\net8.0-windows\StickyNotesProfileTextSearch.exe"

if (Test-Path $exePath) {
    Start-Process $exePath
    Write-Host "✓ Application launched!" -ForegroundColor Green
    Write-Host "`nThe app should display $totalNotes note(s)." -ForegroundColor Yellow
    Write-Host "If it shows 0 notes, check the log at:" -ForegroundColor Yellow
    Write-Host "  $env:LOCALAPPDATA\StickyNotesProfileTextSearch\log.txt" -ForegroundColor Gray
}
else {
    Write-Host "✗ Application not found. Build it first with:" -ForegroundColor Red
    Write-Host "  cd sticky-notes-profile-text-search" -ForegroundColor Gray
    Write-Host "  dotnet build" -ForegroundColor Gray
}

Write-Host ""
