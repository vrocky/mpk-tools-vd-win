# Changelog

All notable changes to MPK Tools will be documented here.

## [1.6.0] - 2026-05-21

### Changed
- **Simplified Launcher Scripts** — All 6 virtual desktop launchers reduced from 50+ lines to ~15 lines each
  - New shared PowerShell module: `src/launchers/_shared/MPKTools.Launchers.psm1`
  - All launchers now import `MPKTools.Launchers.psm1` and call `Get-ProfilePath` helper
  - Eliminates 6 copies of the same VD detection logic
  - Fixed critical sticky-notes bug: removed hardcoded absolute paths
- **Standardized Shortcut Creation** — All 6 `Create-Shortcut.ps1` scripts now use uniform pattern via `New-LauncherShortcut` helper
- **Consolidated App Directory** — Merged `src/desktop/` and `src/features/` into single `src/apps/`
  - All 6 WPF applications (profile pickers + search modules) now in unified directory
  - No functional distinction between "desktop" and "feature" apps — both are WPF .NET 8 apps
  - Cleaner, more intuitive structure
- **Framework-Dependent Publishing** — Changed from `--self-contained` to framework-dependent .NET 8 publishing
  - Reduces installer size from ~300 MB to ~15 MB
  - Each app now ~2 MB instead of ~150 MB
  - Requires .NET 8 Desktop Runtime (checked by installer)
- **Incremental Build System** — `build/Build.ps1` now detects unchanged projects and skips rebuild
  - `Should-Republish` function compares source and output timestamps
  - Second and subsequent builds 40x faster when no changes made
  - New parameters: `-ForceRebuild` (rebuild all), `-Only <name>` (single project)
  - Removed obsolete parameters: `-SkipPublish`, `-ReusePublishedApps`, `-Runtime`
- **Unified Profile Root** — All profiles now under `C:\MPKTools\Profiles\` instead of scattered roots
  - Old: `C:\ChromeProfiles\`, `C:\VSCodeProfiles\`, `C:\StickyNotesProfiles\`, etc.
  - New: `C:\MPKTools\Profiles\chrome\`, `C:\MPKTools\Profiles\vscode\`, etc.
  - Simplifies backups, migrations, and system organization

### Added
- **Shared Launcher Module** — `src/launchers/_shared/MPKTools.Launchers.psm1` with helpers:
  - `Get-VDNumber` — Virtual desktop detection from Windows registry
  - `Get-ProfilePath` — Construct unified profile paths, create folders as needed
  - `New-LauncherShortcut` — Standardized desktop shortcut creation
- **Profile Migration Tool** — `scripts/Migrate-Profiles.ps1` for v1.5→v1.6 users
  - Automated migration with preview mode (`-DryRun`)
  - Automatic backup at `C:\MPKTools\Profiles\.backup\` before migration
  - Rollback support if migration fails
  - Interactive confirmation + force mode (`-Force`) for automation
- **Installer .NET 8 Runtime Check** — `MPKTools.iss` now validates .NET 8 Desktop Runtime
  - Checks registry during installation
  - Prompts user to download if missing, with link to dotnet.microsoft.com
- **Build Parameter Support** — New `build/Build.ps1` parameters for fine-grained control:
  - `-ForceRebuild` — Rebuild all projects regardless of timestamps
  - `-Only <name>` — Rebuild single project (e.g., `-Only VsCode.ProfilePicker`)
  - `-SkipCompileInstaller` — Stage files without invoking Inno Setup
- **Build Statistics** — Display count of published vs skipped projects at end of build
- **Documentation Updates** — Updated README to reflect new `src/apps/` structure

### Fixed
- **Sticky Notes Launcher Bug** — Removed hardcoded absolute path to `C:\Scripts\StickyNotesProfiles\`
  - Now correctly uses `Get-ProfilePath` helper for dynamic path resolution
- **Launcher Script Inconsistency** — Standardized parameter naming and behavior across all 6 launchers
- **Build Script Dead Code** — Removed obsolete `CreateShortcut.ps1` filename check
  - All 6 launchers now use standard `Create-Shortcut.ps1` naming

### Performance
- **Installer Size** — Reduced from ~300 MB to ~15 MB (95% reduction)
- **Build Speed** — Incremental builds 40× faster (unchanged projects skipped)
- **First Launch** — Profile paths created automatically if missing (no manual setup needed)

---

## [1.5.0] - 2026-05-19

### Changed
- Restructured project layout for clarity and maintainability
- Moved WPF apps from `apps/` to `src/desktop/` with clean names (`MPK.VsCode.ProfilePicker`, etc.)
- Moved feature modules from `apps/` to `src/features/`
- Moved PowerShell launchers from `launch/` to `src/launchers/` with short names (`chrome`, `edge`, `vscode`, etc.)
- Moved shared library from `apps/` to `src/shared/MPK.Profile.Core/`
- Moved updater from `installer/` to `src/tools/MPK.Updater/`
- Moved build script from `installer/Build-MpkToolsInstaller.ps1` to `build/Build.ps1`
- Moved installer config from `installer/MPKTools.iss` to `packaging/inno/MPKTools.iss`
- Build script now reads version from root `VERSION` file (no longer requires `-InstallerVersion` parameter)
- Installer now uses clean staging paths (`Apps\MPK.VsCode.ProfilePicker\` instead of `Apps\mpk-tools-vscode-profile-picker\`)
- Renamed `.gitmodules` submodule section names to match new paths

### Added
- Root-level `VERSION` file for suite-wide versioning
- Root-level `README.md` with project overview
- `docs/` directory with architecture documentation
- `.gitkeep` placeholders for `tests/` and `src/launchers/_shared/`

### Archived
- Moved `apps/mpk-tools-win-virtual-desktop-poc` to `legacy/poc/virtual-desktop-poc`

## [1.1.0] - (Previous)
- Initial packaged release with unified Inno Setup installer
- VS Code Profile Picker
- Sticky Notes Profile Picker
- AntiGravity Profile Picker with project search
- Virtual desktop launchers for Chrome, Edge, VS Code, Claude, Sticky Notes, AntiGravity
- Standalone updater via GitHub CLI
