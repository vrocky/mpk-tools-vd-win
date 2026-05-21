# v1.6 Installation & Migration

## Install v1.6

Download from [Releases](https://github.com/vrocky/mpk-tools-vd-win/releases):
```
MPK-Tools-Setup-1.6.0.exe
```

Requires: **Windows 10/11 + .NET 8 Desktop Runtime**
- Installer checks for .NET 8 and prompts download if missing
- [Download .NET 8](https://dotnet.microsoft.com/download/dotnet/8.0)

## Migrate from v1.5

Your profiles are safe. Automated migration available:

```powershell
.\scripts\Migrate-Profiles.ps1
```

**Options:**
- Run without flags for interactive mode
- `-DryRun` to preview what''ll move
- `-Force` to skip confirmations

**Backup**: Auto-created at `C:\MPKTools\Profiles\.backup\` before migration

After migration:
1. Run installer (or already installed v1.6)
2. Run `Create-Shortcut.ps1` in each launcher (or reinstall)
3. Launch an app → verify it opens with your existing data

See [PROFILE_MIGRATION.md](PROFILE_MIGRATION.md) for detailed steps.

## Profile Locations (v1.6)

All profiles now in: **`C:\MPKTools\Profiles\`**

| App | Path |
|-----|------|
| Chrome | `C:\MPKTools\Profiles\chrome\virtual_desktop_[N]\` |
| Edge | `C:\MPKTools\Profiles\edge\virtual_desktop_[N]\` |
| VS Code | `C:\MPKTools\Profiles\vscode\virtual_desktop_[N]\` |
| Sticky Notes | `C:\MPKTools\Profiles\sticky-notes\virtual_desktop_[N]\` |
| AntiGravity | `C:\MPKTools\Profiles\antigravity\virtual_desktop_[N]\` |
| Claude | `C:\MPKTools\Profiles\claude\vd-[N]\` |

Single backup location simplifies data protection.

## Key Improvements

✓ **15 MB installer** (was 300 MB) — faster downloads  
✓ **Unified profiles** — easier backups and migration  
✓ **Simpler launchers** — less code duplication  
✓ **Faster builds** — incremental builds skip unchanged apps  

See [UPDATES.md](UPDATES.md) for full list.
