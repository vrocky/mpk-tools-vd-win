# MPK Tools Restructuring — Status & Next Steps

**Date:** 2026-05-19  
**Target Version:** v1.5 (Restructuring Release)  
**Status:** Planning & Preparation Phase

---

## What Was Done

### 1. Documentation Created

✅ **`.project.md`** (at root)
- Comprehensive project analysis
- Current structure issues identified
- All 14 submodules catalogued
- Technology stack documented
- Build & release process explained
- Recommendations for refactoring

✅ **`docs/architecture/v1.5-restructuring-proposal.md`**
- Moved from `docs/versions/v2/updates.md` to semantic location
- Detailed v1.5 architecture proposal
- Better source directory structure
- Improved naming conventions
- Build process improvements
- Launcher pattern refactoring
- Migration plan outline

✅ **`docs/architecture/MIGRATION-GUIDE-v1.5.md`**
- Step-by-step migration guide
- 5 phases: Prepare, Reorganize, Move, Verify, Commit
- Detailed submodule move instructions
- Build script refactoring examples
- Testing & validation steps
- Rollback procedures
- Common issues & solutions
- Post-migration checklist

### 2. Git Configuration Created

✅ **`.gitmodules.v1.5`** (new file, not yet active)
- All 14 submodules remapped to new paths
- GitHub URLs unchanged (only local paths reorganized)
- Organized by category:
  - `src/desktop/` — WPF applications
  - `src/features/` — App-specific features
  - `src/launchers/` — PowerShell launchers
  - `src/shared/` — Shared libraries
  - `src/tools/` — Build tools & updater
  - `legacy/poc/` — Archive for POC code

### 3. Directory Structure Prepared

✅ Created new directories (ready for migration):
```
docs/architecture/      (moved v1.5 proposal here)
docs/guides/           (for developer guides)
docs/process/          (for operational docs)
```

---

## Current Directory Structure

**Before (Now):**
```
mpk-tools-vd-win/
├── .gitmodules              (14 submodules, mixed paths)
├── apps/                    (8 submodules: WPF apps + libs + POC)
├── launch/                  (6 submodules: launchers only)
├── installer/               (build scripts + Inno Setup)
├── feature-updates/         (strategy docs)
├── docs/
│   ├── versions/v2/updates.md  (architectural proposal)
│   └── architecture/           (new - v1.5 docs moved here)
└── ... (other files)
```

**After Migration (Target):**
```
mpk-tools-vd-win/
├── VERSION                  (single suite version)
├── CHANGELOG.md             (release history)
├── README.md               (project overview)
├── .gitmodules             (updated: 14 remapped paths)
├── .gitmodules.v1.5        (reference for new structure)
│
├── src/
│   ├── desktop/            (WPF GUI applications)
│   ├── features/           (app-specific modules)
│   ├── launchers/          (PS launchers + _shared/)
│   ├── shared/             (reusable libraries)
│   └── tools/              (updater, utilities)
│
├── build/                  (build orchestration scripts)
├── packaging/inno/         (Inno Setup installer config)
├── docs/
│   ├── architecture/       (architecture docs)
│   ├── guides/             (developer guides)
│   └── process/            (operational docs)
├── tests/                  (unit & integration tests)
├── legacy/poc/             (archived POC code)
└── dist/                   (build output)
```

---

## Submodule Reorganization Map

| Current Path | Target Path | Type | Component |
|---|---|---|---|
| `apps/mpk-tools-vscode-profile-picker` | `src/desktop/MPK.VsCode.ProfilePicker` | App | WPF GUI |
| `apps/mpk-tools-sticky-notes-profile-picker` | `src/desktop/MPK.StickyNotes.ProfilePicker` | App | WPF GUI |
| `apps/mpk-tools-antigravity-profile-picker` | `src/desktop/MPK.AntiGravity.ProfilePicker` | App | WPF GUI |
| `apps/mpk-tools-vscode-profile-project-search` | `src/features/MPK.VsCode.ProjectSearch` | Feature | App extension |
| `apps/mpk-tools-sticky-notes-profile-text-search` | `src/features/MPK.StickyNotes.TextSearch` | Feature | App extension |
| `apps/mpk-tools-antigravity-profile-project-search` | `src/features/MPK.AntiGravity.ProjectSearch` | Feature | App extension |
| `launch/mpk-tools-win-virtual-desktop-chrome-launch` | `src/launchers/chrome` | Launcher | PS script |
| `launch/mpk-tools-win-virtual-desktop-edge-launch` | `src/launchers/edge` | Launcher | PS script |
| `launch/mpk-tools-win-virtual-desktop-vscode-launch` | `src/launchers/vscode` | Launcher | PS script |
| `launch/mpk-tools-win-virtual-desktop-claude-launch` | `src/launchers/claude` | Launcher | PS script |
| `launch/mpk-tools-win-virtual-desktop-sticky-notes-launch` | `src/launchers/sticky-notes` | Launcher | PS script |
| `launch/mpk-tools-win-virtual-desktop-antigravity-launch` | `src/launchers/antigravity` | Launcher | PS script |
| `apps/mpk-tools-mpk-profile-common-libs` | `src/shared/MPK.Profile.Core` | Library | Shared code |
| `apps/mpk-tools-win-virtual-desktop-poc` | `legacy/poc/virtual-desktop-poc` | Archive | Research only |

---

## What Still Needs to Be Done

### Phase 1: Preparation ✅ DONE
- [x] Create `.project.md` context document
- [x] Create v1.5 architectural proposal
- [x] Create migration guide
- [x] Create `.gitmodules.v1.5` reference file
- [x] Plan directory structure

### Phase 2: Reorganize Submodules ⏳ PENDING
- [ ] Create new `src/`, `build/`, `packaging/`, `docs/`, `tests/`, `legacy/`, `dist/` directories
- [ ] Update `.gitmodules` with new paths
- [ ] Move submodules using `git mv` (preserves history)
- [ ] Reinitialize with `git submodule sync`
- [ ] Verify all submodules accessible at new paths

### Phase 3: Move Build & Installer ⏳ PENDING
- [ ] Move `installer/Build-MpkToolsInstaller.ps1` → `build/Build.ps1`
- [ ] Move `installer/MPKTools.iss` → `packaging/inno/MPKTools.iss`
- [ ] Move `installer/MPKToolsUpdater/` → `src/tools/MPK.Updater/`
- [ ] Remove empty `installer/` directory
- [ ] Create helper scripts: `Publish-DesktopApps.ps1`, `Publish-Launchers.ps1`, `Stage-Installer.ps1`
- [ ] Update build script with new paths

### Phase 4: Add Root-Level Files ⏳ PENDING
- [ ] Create `VERSION` file with `1.5.0-rc1`
- [ ] Create `CHANGELOG.md` with v1.5 entry
- [ ] Create `README.md` with project overview

### Phase 5: Verify & Test ⏳ PENDING
- [ ] Test directory structure
- [ ] Test submodule initialization
- [ ] Test build process
- [ ] Test installer on clean VM
- [ ] Create git commit with migration

### Phase 6: Post-Migration (Future) ⏳ NOT STARTED
- [ ] Add GitHub Actions CI/CD workflows
- [ ] Implement shared launcher pattern
- [ ] Add unit tests
- [ ] Add integration tests
- [ ] Implement semantic versioning
- [ ] Write developer guide
- [ ] Write contributing guidelines

---

## Files Created

| File | Location | Purpose |
|---|---|---|
| `.project.md` | Root | Comprehensive project analysis & context |
| `v1.5-restructuring-proposal.md` | `docs/architecture/` | Detailed v1.5 design |
| `MIGRATION-GUIDE-v1.5.md` | `docs/architecture/` | Step-by-step migration instructions |
| `.gitmodules.v1.5` | Root | Reference for new submodule configuration |
| `RESTRUCTURING-STATUS.md` | `docs/` | This file — current status |

---

## Key Benefits of v1.5 Structure

1. **Visual Clarity**
   - `src/desktop/` → where WPF apps live
   - `src/launchers/` → where PS launchers live
   - `src/shared/` → where shared code lives
   - No confusion about what goes where

2. **Build Simplification**
   - Single command: `.\build\Build.ps1`
   - Reads version from `VERSION` file
   - Helper scripts for each build stage
   - Clear separation: build logic vs. packaging logic

3. **Professional Appearance**
   - Proper README at root
   - Changelog tracking
   - Clear architecture documentation
   - Semantic versioning

4. **Scalability**
   - Easy to add new apps (just add to `src/desktop/`)
   - Easy to add new launchers (just add to `src/launchers/`)
   - No path confusion or naming conflicts

5. **Maintainability**
   - Tests organized by component
   - Documentation organized by purpose
   - Legacy code clearly archived
   - Build infrastructure isolated

---

## How to Proceed

### For User Review
1. Review `.project.md` for overall context
2. Review `v1.5-restructuring-proposal.md` for design details
3. Review `MIGRATION-GUIDE-v1.5.md` for step-by-step process
4. Confirm the new structure makes sense

### Option A: Full Migration (Recommended)
Follow `MIGRATION-GUIDE-v1.5.md` step-by-step:
1. Create new directories
2. Create root files (VERSION, CHANGELOG.md, README.md)
3. Update `.gitmodules` from `.gitmodules.v1.5`
4. Move submodules with `git mv`
5. Move build scripts and update paths
6. Test on clean VM
7. Commit changes

**Estimated time:** 2-3 hours (mostly testing)

### Option B: Phased Approach
1. Implement structure but keep `.gitmodules` unchanged initially
2. Test that new structure + old .gitmodules works
3. Then update `.gitmodules` separately

### Option C: Let an Agent Handle It
If you prefer, you can ask another Claude agent to execute the migration automatically using this documentation as a guide.

---

## Important Notes

⚠️ **Backup Before Starting**
```bash
git tag -a backup-pre-v1.5 -m "Backup before restructuring"
```

⚠️ **Submodule Operations Are Careful**
- Moving submodules with `git mv` preserves history
- `git submodule sync` reinitializes references
- Rollback is possible but requires `git submodule deinit -a -f`

⚠️ **Path Updates Are Necessary**
- `.gitmodules` must be updated
- Build scripts must reference new paths
- Installer config must reference new paths

⚠️ **Testing Is Critical**
- Test on a clean VM after migration
- Verify updater still works
- Verify all shortcuts create correctly

---

## Success Criteria

Migration is complete when:
- ✅ All 14 submodules are at new paths in `src/`
- ✅ Build runs without path errors: `.\build\Build.ps1`
- ✅ Installer produces valid `.exe`: `MPK-Tools-Setup-1.5.0.exe`
- ✅ Installer deploys to `C:\Program Files\MPK Tools\` correctly
- ✅ All shortcuts work and apps launch
- ✅ Updater can query releases and download new installers
- ✅ Git history is preserved (no force-pushes)
- ✅ README, VERSION, CHANGELOG are in place

---

## Next Agent Brief

If delegating to another agent, provide:
1. This file (RESTRUCTURING-STATUS.md)
2. `.project.md` (project context)
3. `v1.5-restructuring-proposal.md` (design details)
4. `MIGRATION-GUIDE-v1.5.md` (step-by-step instructions)
5. `.gitmodules.v1.5` (reference configuration)

Agent should:
- Follow migration guide phase by phase
- Update paths in build scripts
- Test on clean VM
- Create final commit

---

## Questions?

Refer to:
- **Project Context:** `.project.md`
- **Design Rationale:** `v1.5-restructuring-proposal.md`
- **How-To:** `MIGRATION-GUIDE-v1.5.md`
- **Git Submodules:** `git help submodule`
- **Rollback Plan:** See MIGRATION-GUIDE-v1.5.md § Phase 5
