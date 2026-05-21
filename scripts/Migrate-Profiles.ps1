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

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  MPK Tools v1.5 → v1.6 Profile Migration  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔍 Scanning for v1.5 profiles..." -ForegroundColor Cyan

# Find profiles to migrate
$toMigrate = @()
foreach ($item in $migrations) {
    if (Test-Path $item.OldRoot) {
        Write-Host "   Found: $($item.OldRoot)" -ForegroundColor DarkGray
        $size = (Get-ChildItem -Path $item.OldRoot -Recurse -File -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
        $toMigrate += @{
            OldRoot = $item.OldRoot
            NewApp = $item.NewApp
            SizeBytes = $size
        }
    }
}

Write-Host ""

if ($toMigrate.Count -eq 0) {
    Write-Host "✅ No v1.5 profiles found." -ForegroundColor Green
    Write-Host "   Either already migrated or starting fresh." -ForegroundColor DarkGray
    exit 0
}

Write-Host "📦 Migration Plan:" -ForegroundColor Cyan
Write-Host ""

$totalSize = 0
foreach ($item in $toMigrate) {
    $sizeMB = [math]::Round($item.SizeBytes / 1MB, 2)
    Write-Host "   • $($item.OldRoot)" -ForegroundColor Yellow
    Write-Host "     ↓" -ForegroundColor DarkGray
    Write-Host "     $ProfileRoot\$($item.NewApp)\" -ForegroundColor Green
    Write-Host "     Size: $sizeMB MB" -ForegroundColor DarkGray
    Write-Host ""
    $totalSize += $item.SizeBytes
}

$totalMB = [math]::Round($totalSize / 1MB, 2)
Write-Host "📊 Total: $($toMigrate.Count) profile(s), $totalMB MB" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "🔍 DRY RUN MODE" -ForegroundColor Yellow
    Write-Host "   No changes will be made. Use without -DryRun to actually migrate." -ForegroundColor DarkGray
    exit 0
}

if (-not $Force) {
    Write-Host "⚠️  LIVE MIGRATION" -ForegroundColor Yellow
    Write-Host "   This will move your profiles to the new location." -ForegroundColor DarkGray
    Write-Host "   A backup will be created at: $BackupRoot" -ForegroundColor DarkGray
    Write-Host ""
    $confirm = Read-Host "Type 'yes' to proceed with migration"
    if ($confirm -ne "yes") {
        Write-Host ""
        Write-Host "❌ Migration cancelled." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host ""
Write-Host "💾 Step 1: Creating Backup" -ForegroundColor Cyan
New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

$backupCount = 0
foreach ($item in $toMigrate) {
    $backupDest = Join-Path $BackupRoot $item.NewApp
    Write-Host "   Backing up: $($item.NewApp)" -ForegroundColor DarkGray
    robocopy "$($item.OldRoot)" "$backupDest" /S /E /DCOPY:DAT /COPY:DAT /IS /IT /XJ /R:0 /NJH /NJS | Out-Null
    $backupCount++
}

Write-Host "   ✓ Backup created ($backupCount items)" -ForegroundColor Green
Write-Host "   Location: $BackupRoot" -ForegroundColor DarkGray
Write-Host ""

Write-Host "📦 Step 2: Moving Profiles" -ForegroundColor Cyan
$moveCount = 0
foreach ($item in $toMigrate) {
    $newDest = Join-Path $ProfileRoot $item.NewApp
    Write-Host "   Moving: $($item.NewApp)" -ForegroundColor DarkGray

    New-Item -ItemType Directory -Path $newDest -Force | Out-Null

    robocopy "$($item.OldRoot)" "$newDest" /S /E /MOVE /DCOPY:DAT /COPY:DAT /IS /IT /XJ /R:0 /NJH /NJS | Out-Null

    if (Test-Path $item.OldRoot) {
        Remove-Item $item.OldRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    $moveCount++
}

Write-Host "   ✓ Profiles moved ($moveCount items)" -ForegroundColor Green

Write-Host ""
Write-Host "✅ Migration Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "   ✓ Profiles moved to $ProfileRoot\" -ForegroundColor Green
Write-Host "   ✓ Backup saved to $BackupRoot\" -ForegroundColor Green
Write-Host ""

Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Install MPK Tools v1.6" -ForegroundColor Yellow
Write-Host "   2. Run: .\src\launchers\chrome\Create-Shortcut.ps1 (etc for each launcher)" -ForegroundColor Yellow
Write-Host "   3. Test: Launch an app and verify it has your existing data" -ForegroundColor Yellow
Write-Host ""

Write-Host "💾 Rollback Available:" -ForegroundColor Yellow
Write-Host "   If anything goes wrong, your original profiles are safe at:" -ForegroundColor DarkGray
Write-Host "   $BackupRoot\" -ForegroundColor DarkGray
Write-Host ""
