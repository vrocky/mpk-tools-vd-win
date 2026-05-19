# Changelog

All notable changes to MPK Tools will be documented here.

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
