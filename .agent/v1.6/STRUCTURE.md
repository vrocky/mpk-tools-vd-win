# v1.6 Directory Structure

## What Changed

### Apps Consolidated
```
Before (v1.5):
src/desktop/
├── MPK.VsCode.ProfilePicker/
├── MPK.StickyNotes.ProfilePicker/
└── MPK.AntiGravity.ProfilePicker/

src/features/
├── MPK.VsCode.ProjectSearch/
├── MPK.StickyNotes.TextSearch/
└── MPK.AntiGravity.ProjectSearch/

After (v1.6):
src/apps/
├── MPK.VsCode.ProfilePicker/
├── MPK.StickyNotes.ProfilePicker/
├── MPK.AntiGravity.ProfilePicker/
├── MPK.VsCode.ProjectSearch/
├── MPK.StickyNotes.TextSearch/
└── MPK.AntiGravity.ProjectSearch/
```

All 6 WPF applications in one location.

### Launchers Enhanced
```
src/launchers/
├── _shared/                              ← NEW: shared module
│   └── MPKTools.Launchers.psm1
├── chrome/
│   ├── Launch-Chrome.ps1                 ← simplified
│   └── Create-Shortcut.ps1               ← standardized
├── edge/
├── vscode/
├── claude/
├── sticky-notes/
└── antigravity/
```

Shared module: VD detection, profile paths, shortcut creation.

### Scripts Added
```
scripts/
└── Migrate-Profiles.ps1    ← v1.5→v1.6 migration
```

## Submodule Paths Updated

.gitmodules now references `src/apps/*` instead of `src/desktop/*` and `src/features/*`.

If cloning fresh: `git clone --recursive` picks up new paths automatically.

## Full Structure

See [v1.5 STRUCTURE.md](../.agent/v1.5/STRUCTURE.md) for unchanged components (shared, tools, build, packaging, docs, legacy).
