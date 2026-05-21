#Requires -Version 5.1
<#
.SYNOPSIS
    Migrate user profiles from v1.5 scattered roots to v1.6 unified structure.

.DESCRIPTION
    v1.5 stored profiles in scattered locations (C:\ChromeProfiles\, C:\VSCodeProfiles\, etc.)
    v1.6 consolidates them under C:\MPKTools\Profiles\

    This script migrates existing profiles to the new structure with automatic backup.

.PARAMETER DryRun
    Preview what would be moved without making changes

.PARAMETER Force
    Skip confirmation prompts (for automation)

.EXAMPLE
    .\Migrate-Profiles.ps1                # Interactive with confirmations
    .\Migrate-Profiles.ps1 -DryRun        # Preview only
    .\Migrate-Profiles.ps1 -Force         # Auto-migrate without prompts
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProfileRoot = "C:\MPKTools\Profiles"
$BackupRoot = "$ProfileRoot\.backup"

# Map old roots to app names in new structure
$migrations = @(
    @{ OldRoot = "C:\ChromeProfiles"; NewApp = "chrome" },
    @{ OldRoot = "C:\EdgeProfiles"; NewApp = "edge" },
    @{ OldRoot = "C:\VSCodeProfiles"; NewApp = "vscode" },
    @{ OldRoot = "C:\StickyNotesProfiles"; NewApp = "sticky-notes" },
    @{ OldRoot = "C:\AntiGravityProfiles"; NewApp = "antigravity" },
    @{ OldRoot = "C:\claude-ws\vd-profiles"; NewApp = "claude" }
)

Write-Host "MPK Tools v1.5 → v1.6 Profile Migration" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Find profiles to migrate
$toMigrate = @()
foreach ($item in $migrations) {
    if (Test-Path $item.OldRoot) {
        $size = (Get-ChildItem -Path $item.OldRoot -Recurse -File -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
        $toMigrate += @{
            OldRoot = $item.OldRoot
            NewApp = $item.NewApp
            SizeBytes = $size
        }
    }
}

if ($toMigrate.Count -eq 0) {
    Write-Host "No v1.5 profiles found. Already migrated or nothing to migrate." -ForegroundColor Green
    exit 0
}

Write-Host "Found $($toMigrate.Count) profile(s) to migrate:" -ForegroundColor Yellow
Write-Host ""

$totalSize = 0
foreach ($item in $toMigrate) {
    $sizeMB = [math]::Round($item.SizeBytes / 1MB, 2)
    Write-Host "  • $($item.OldRoot)" -ForegroundColor DarkGray
    Write-Host "    → $ProfileRoot\$($item.NewApp)\ ($sizeMB MB)" -ForegroundColor Green
    $totalSize += $item.SizeBytes
}

$totalMB = [math]::Round($totalSize / 1MB, 2)
Write-Host ""
Write-Host "Total size to migrate: $totalMB MB" -ForegroundColor Yellow

if ($DryRun) {
    Write-Host ""
    Write-Host "DRY RUN - no changes made. Run without -DryRun to migrate." -ForegroundColor Cyan
    exit 0
}

if (-not $Force) {
    Write-Host ""
    $confirm = Read-Host "Proceed with migration? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Host "Migration cancelled." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host ""
Write-Host "Creating backup..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

foreach ($item in $toMigrate) {
    $backupDest = Join-Path $BackupRoot $item.NewApp
    Write-Host "  Backing up $($item.OldRoot) → $backupDest" -ForegroundColor DarkGray
    robocopy "$($item.OldRoot)" "$backupDest" /S /E /DCOPY:DAT /COPY:DAT /IS /IT /XJ /R:0 | Out-Null
}

Write-Host "✓ Backup complete at $BackupRoot" -ForegroundColor Green
Write-Host ""
Write-Host "Moving profiles to new structure..." -ForegroundColor Cyan

foreach ($item in $toMigrate) {
    $newDest = Join-Path $ProfileRoot $item.NewApp
    Write-Host "  Moving $($item.OldRoot) → $newDest" -ForegroundColor DarkGray

    New-Item -ItemType Directory -Path $newDest -Force | Out-Null

    robocopy "$($item.OldRoot)" "$newDest" /S /E /MOVE /DCOPY:DAT /COPY:DAT /IS /IT /XJ /R:0 | Out-Null

    if (Test-Path $item.OldRoot) {
        Remove-Item $item.OldRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "✓ Profiles moved to new locations" -ForegroundColor Green
Write-Host ""
Write-Host "Migration complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Install MPK Tools v1.6"
Write-Host "  2. Run Create-Shortcut.ps1 in each launcher (or reinstall to auto-run)"
Write-Host "  3. Verify: launch an app and confirm it opens with your existing data"
Write-Host ""
Write-Host "If something goes wrong, rollback is available at:" -ForegroundColor Yellow
Write-Host "  $BackupRoot"
