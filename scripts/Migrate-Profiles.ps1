#Requires -Version 5.1
<#
.SYNOPSIS
    Migrate user profiles from scattered roots to unified C:\MPKTools\Profiles\ structure.

.DESCRIPTION
    One-time migration script for v1.6 upgrade. Moves profiles from old locations:
    - C:\ChromeProfiles\ → C:\MPKTools\Profiles\chrome\
    - C:\EdgeProfiles\ → C:\MPKTools\Profiles\edge\
    - C:\VSCodeProfiles\ → C:\MPKTools\Profiles\vscode\
    - C:\StickyNotesProfiles\ → C:\MPKTools\Profiles\sticky-notes\
    - C:\AntiGravityProfiles\ → C:\MPKTools\Profiles\antigravity\
    - C:\claude-ws\vd-profiles\ → C:\MPKTools\Profiles\claude\

    Backup created before migration: C:\MPKTools\Profiles\.backup\

.PARAMETER DryRun
    Show what would be moved without actually moving it.

.PARAMETER Force
    Skip confirmation prompts and migrate automatically.

.EXAMPLE
    .\Migrate-Profiles.ps1              # Preview migration
    .\Migrate-Profiles.ps1 -DryRun      # Show what would be moved
    .\Migrate-Profiles.ps1 -Force       # Migrate without prompting
#>
param(
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$profileRoot = "C:\MPKTools\Profiles"
$backupRoot = "$profileRoot\.backup"

$migrations = @(
    @{ OldRoot = "C:\ChromeProfiles";           App = "chrome" },
    @{ OldRoot = "C:\EdgeProfiles";             App = "edge" },
    @{ OldRoot = "C:\VSCodeProfiles";           App = "vscode" },
    @{ OldRoot = "C:\StickyNotesProfiles";      App = "sticky-notes" },
    @{ OldRoot = "C:\AntiGravityProfiles";      App = "antigravity" },
    @{ OldRoot = "C:\claude-ws\vd-profiles";    App = "claude" }
)

Write-Host "=== MPK Tools Profile Migration ===" -ForegroundColor Cyan
Write-Host "Old structure → New unified structure" -ForegroundColor Cyan
Write-Host ""

$toMigrate = @()
foreach ($migration in $migrations) {
    if (Test-Path $migration.OldRoot) {
        $size = (Get-ChildItem -Path $migration.OldRoot -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $sizeGB = [math]::Round($size / 1GB, 2)
        Write-Host "  ✓ $($migration.OldRoot) → $profileRoot\$($migration.App)" -ForegroundColor Green
        Write-Host "    Size: $sizeGB GB" -ForegroundColor DarkGray
        $toMigrate += $migration
    } else {
        Write-Host "  ○ $($migration.OldRoot) (not found, skipping)" -ForegroundColor DarkGray
    }
}

if ($toMigrate.Count -eq 0) {
    Write-Host ""
    Write-Host "No old profile directories found. Migration not needed." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
if ($DryRun) {
    Write-Host "DRY RUN: No changes will be made." -ForegroundColor Yellow
    Write-Host ""
}

if (-not $DryRun -and -not $Force) {
    Write-Host ""
    $confirm = Read-Host "Proceed with migration? (Type 'yes' to confirm)"
    if ($confirm -ne "yes") {
        Write-Host "Migration cancelled." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host ""

if (-not $DryRun) {
    # Create backup before migration
    Write-Host "Creating backup..." -ForegroundColor Cyan
    if (-not (Test-Path $backupRoot)) {
        New-Item -ItemType Directory -Force $backupRoot | Out-Null
    }

    foreach ($migration in $toMigrate) {
        $backupPath = Join-Path $backupRoot $migration.App
        if (Test-Path $backupPath) {
            Remove-Item -Path $backupPath -Recurse -Force -ErrorAction SilentlyContinue
        }
        Copy-Item -Path $migration.OldRoot -Destination $backupPath -Recurse -Force
        Write-Host "  Backed up $($migration.App) to $backupPath" -ForegroundColor DarkGray
    }
    Write-Host "Backup complete: $backupRoot" -ForegroundColor Green
    Write-Host ""
}

# Perform migration
Write-Host "Migrating profiles..." -ForegroundColor Cyan
$successCount = 0
$errorCount = 0

foreach ($migration in $toMigrate) {
    $oldPath = $migration.OldRoot
    $newPath = "$profileRoot\$($migration.App)"

    try {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would move: $oldPath → $newPath" -ForegroundColor DarkGray
        } else {
            # Create parent directory
            if (-not (Test-Path $profileRoot)) {
                New-Item -ItemType Directory -Force $profileRoot | Out-Null
            }

            # Move profile
            if (Test-Path $newPath) {
                Write-Host "  ⚠ $($migration.App) already exists at destination, skipping" -ForegroundColor Yellow
            } else {
                Move-Item -Path $oldPath -Destination $newPath -Force
                Write-Host "  ✓ Migrated $($migration.App)" -ForegroundColor Green
                $successCount++
            }
        }
    } catch {
        Write-Host "  ✗ Error migrating $($migration.App): $_" -ForegroundColor Red
        $errorCount++
    }
}

Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN] Migration would move $($toMigrate.Count) profiles" -ForegroundColor Yellow
    Write-Host "Run without -DryRun to perform actual migration" -ForegroundColor Yellow
} else {
    Write-Host "Migration complete!" -ForegroundColor Green
    Write-Host "  Successful: $successCount" -ForegroundColor Green
    if ($errorCount -gt 0) {
        Write-Host "  Errors: $errorCount" -ForegroundColor Red
        Write-Host "  Backup saved to: $backupRoot" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Profile root: $profileRoot" -ForegroundColor Cyan
Write-Host ""

# Verify migration
if (-not $DryRun -and $successCount -gt 0) {
    Write-Host "Verifying migration..." -ForegroundColor Cyan
    Get-ChildItem -Path $profileRoot -Directory -Exclude ".backup" | ForEach-Object {
        $count = (Get-ChildItem -Path $_.FullName -Recurse -ErrorAction SilentlyContinue).Count
        Write-Host "  $($_.Name): $count items" -ForegroundColor DarkGray
    }
}
