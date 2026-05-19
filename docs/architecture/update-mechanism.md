# MPK Tools Auto-Update Strategy

## Goal
Add a reliable, secure, and low-maintenance update mechanism for the full MPK Tools suite (multiple WPF executables + launcher scripts) delivered by one Inno Setup installer.

## Recommended Model
Use suite-level updating via installer replacement, not per-app self-replacement.

Why:
- All tools are installed together under one product identity.
- Shared scripts and app binaries stay version-aligned.
- Upgrade flow stays simple: download latest installer, verify, run silent upgrade.

## Current Packaging Context
- Build script stages published apps and scripts: installer/Build-MpkToolsInstaller.ps1
- Final package is built by Inno Setup: installer/MPKTools.iss
- Installer already uses a stable AppId, so upgrades can be in-place.

## Target Architecture
1. Update Feed
- Use GitHub Releases as the update source (no external manifest server).
- Updater reads latest release metadata with GitHub CLI (`gh release view`).
- Updater downloads installer asset with GitHub CLI (`gh release download`).
- Standardize release asset name: `MPK-Tools-Setup-<version>.exe`.

2. Updater Component
- Implement one standalone updater executable (dotnet) outside the individual WPF apps.
- Responsibilities:
  - Query latest GitHub release
  - Compare versions
  - Download installer to temp path
  - Prompt user (or silent policy mode)
  - Start installer with silent flags

3. App Integration
- Keep app projects decoupled from updater logic.
- Trigger updater via standalone script/command (manual, scheduler, or launcher).
- Optionally add a thin "Open Updater" action in apps later without embedding update logic.

4. Installer Upgrade Behavior
- Keep same AppId across versions.
- Ensure silent upgrade flags are supported:
  - /VERYSILENT
  - /SUPPRESSMSGBOXES
  - /NORESTART
- Validate close/restart behavior for running processes.
- Consider enabling and testing:
  - CloseApplications=yes
  - RestartApplications=no

## Security Requirements
- Use authenticated GitHub CLI (`gh`) and HTTPS GitHub endpoints.
- Sign installer executable with code-signing certificate.
- Optionally enforce signer validation before running installer.

## Versioning Policy
- Use SemVer for suite releases.
- Single suite version for all packaged apps and scripts.
- Reject downgrade attempts unless explicitly allowed for recovery.

## Release Pipeline (CI/CD)
1. Build and publish all apps to staging.
2. Compile Inno installer.
3. Upload installer as GitHub release asset (`MPK-Tools-Setup-<version>.exe`).
4. Publish release notes.

## Rollout Plan
Phase 1 (MVP)
- Standalone updater executable with manual check + prompt-based install.
- No background auto-install.
- GitHub release lookup + asset download + silent installer launch.

Phase 2
- Scheduled background check (daily).
- Optional deferred reminders ("Later", "Skip this version").

Phase 3
- Channel support (stable/beta).
- Policy controls for enterprise machines.

## Failure Handling
- Feed unavailable: log and continue normally.
- Download failure: retry with backoff.
- Hash mismatch: block install and show security warning.
- Installer exit code non-zero: capture and surface diagnostics.

## Telemetry and Logging (Optional but Useful)
Track:
- check_started/check_success/check_failed
- update_available/update_not_available
- download_success/download_failed
- install_started/install_succeeded/install_failed

## Minimal Implementation Checklist
- [ ] Add standalone updater executable in installer package.
- [ ] Add version comparator + throttle persistence.
- [ ] Add secure download using `gh release download`.
- [ ] Add installer launch command builder.
- [ ] Validate standalone updater invocation from installed path.
- [ ] Validate end-to-end upgrade on clean VM.
- [ ] Add CI step to publish release assets with consistent naming.

## Suggested Next Step
Run a full installer-upgrade cycle on a clean VM and confirm updater behavior with `gh` authenticated and release asset naming conventions in place.