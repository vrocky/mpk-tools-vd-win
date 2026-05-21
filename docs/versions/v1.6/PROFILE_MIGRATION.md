# v1.6 Profile Migration Guide

## What's Changing

v1.6 consolidates all virtual desktop profiles under a single unified root: `C:\MPKTools\Profiles\`

### Old Structure (v1.5)
```
C:\ChromeProfiles\virtual_desktop_1\
C:\EdgeProfiles\virtual_desktop_1\
C:\VSCodeProfiles\virtual_desktop_1\
C:\StickyNotesProfiles\profiles\virtual_desktop_1\
C:\AntiGravityProfiles\virtual_desktop_1\data\
C:\claude-ws\vd-profiles\vd-1\
```

### New Structure (v1.6)
```
C:\MPKTools\Profiles\
├── chrome\virtual_desktop_1\
├── edge\virtual_desktop_1\
├── vscode\virtual_desktop_1\
│   ├── data\
│   └── extensions\
├── sticky-notes\virtual_desktop_1\
├── antigravity\virtual_desktop_1\
│   └── data\
└── claude\vd-1\
```

## Why Change?

1. **Simpler backups** — Backup one directory: `xcopy C:\MPKTools\Profiles\ backup\ /S /E /H /I`
2. **Easier migration** — Move everything with one command
3. **Cleaner system** — No scattered profile directories across C:\ drive
4. **Better documentation** — Single location to manage all profiles

## Migration Steps

### Automatic Migration (Recommended)

The included migration script handles everything:

```powershell
.\scripts\Migrate-Profiles.ps1
```

This script:
1. Previews what will be moved
2. Asks for confirmation
3. Creates backup at `C:\MPKTools\Profiles\.backup\`
4. Moves all profiles to new structure
5. Verifies success

### Preview Migration (Safe)

See what would be moved without making changes:

```powershell
.\scripts\Migrate-Profiles.ps1 -DryRun
```

### Forced Migration (No Prompts)

For automated/CI scenarios:

```powershell
.\scripts\Migrate-Profiles.ps1 -Force
```

---

## Manual Migration (If Needed)

If you prefer manual control:

```powershell
# Create unified profiles directory
mkdir C:\MPKTools\Profiles

# Backup existing profiles
robocopy C:\ChromeProfiles C:\MPKTools\Profiles\.backup\chrome /S /E
robocopy C:\EdgeProfiles C:\MPKTools\Profiles\.backup\edge /S /E
# ... repeat for each app

# Move profiles to new location
move C:\ChromeProfiles C:\MPKTools\Profiles\chrome
move C:\EdgeProfiles C:\MPKTools\Profiles\edge
move C:\VSCodeProfiles C:\MPKTools\Profiles\vscode
move C:\StickyNotesProfiles C:\MPKTools\Profiles\sticky-notes
move C:\AntiGravityProfiles C:\MPKTools\Profiles\antigravity
move C:\claude-ws\vd-profiles C:\MPKTools\Profiles\claude
```

---

## After Migration

Once migration is complete:

1. **Install v1.6** — Run the new installer (MPK-Tools-Setup-1.6.0.exe)
2. **Create shortcuts** — Run `Create-Shortcut.ps1` in each launcher (or re-install to auto-run them)
3. **Verify profiles** — Launch an app and confirm it opens with existing data

All launchers are already updated to use the new path, so they will automatically find profiles in `C:\MPKTools\Profiles\`

---

## Rollback (If Needed)

If something goes wrong, profiles are backed up at:
```
C:\MPKTools\Profiles\.backup\
```

To rollback:
```powershell
# Restore from backup
robocopy C:\MPKTools\Profiles\.backup\chrome C:\ChromeProfiles /S /E
robocopy C:\MPKTools\Profiles\.backup\edge C:\EdgeProfiles /S /E
# ... repeat for each app
```

---

## Profile Usage in v1.6

### Virtual Desktop Launchers

All VD launchers automatically use the new unified root:

```powershell
.\Launch-Chrome.ps1          # Opens C:\MPKTools\Profiles\chrome\virtual_desktop_N\
.\Launch-VSCode.ps1          # Opens C:\MPKTools\Profiles\vscode\virtual_desktop_N\
.\Launch-Claude.ps1 -Resume  # Opens C:\MPKTools\Profiles\claude\vd-N\
```

### Profile Picker Applications

When you first open a profile picker (VS Code Profile Picker, etc.), it will look for profiles in the new location. If you want to add the old location:

1. Open the app's Settings window
2. Click "Browse..." and select `C:\MPKTools\Profiles\vscode\` (or appropriate app)
3. The app will scan and display all profiles

The registry setting will be:
```
HKCU:\Software\VsCodeProfilePicker\ProfileRoot = "C:\MPKTools\Profiles\vscode"
```

---

## FAQ

**Q: Do I need to migrate?**  
A: No, v1.5 profiles continue to work. Migration is optional but recommended.

**Q: What if I skip migration?**  
A: Old profile locations (`C:\ChromeProfiles\`, etc.) continue to work. New launchers check the old paths first for backward compatibility (TBD - verify if implemented).

**Q: Can I migrate partially?**  
A: Yes. The migration script skips apps that already exist in the new location. Manually migrate only what you need.

**Q: How much disk space is needed?**  
A: Enough for 2× your profiles (original + backup). For example, if your profiles use 5GB, you need 10GB free.

**Q: Will apps see the migrated profiles?**  
A: Yes. All launchers and pickers are updated to use `C:\MPKTools\Profiles\` by default in v1.6.

---

See also: [DEVELOPMENT_GUIDE.md](../DEVELOPMENT_GUIDE.md) for adding new apps/launchers
