# v1.5 Known Gaps & v1.6 Opportunities

## What's Missing in v1.5

| Gap | Impact | Planned For | Effort |
|-----|--------|-------------|--------|
| **No automated tests** | No regression coverage, manual QA only | v1.6 | Medium |
| **No CI/CD pipeline** | All builds/releases manual, no automation | v1.6 | High |
| **No shared launcher engine** | Each launcher duplicates VD detection code | v1.6 | Medium |
| **No unified profile root** | Chrome, Edge, VS Code, AntiGravity each have separate roots | v1.6 | Medium |
| **No package manifest** | No single source for dependencies (nuget, npm versions) | v1.6 | Low |
| **No release automation** | GitHub releases created manually | v1.6 | Medium |
| **Submodule on master branch** | `src/desktop/MPK.VsCode.ProfilePicker` tracks `heads/master` instead of `heads/main` | v1.6 | Low |

## v1.6 Priorities

### High Priority

**1. Shared Launcher Engine** (src/launchers/_shared/)

**Why:** Currently each of 6 launchers implements VD detection separately. Code duplication.

**What:** Extract common logic into PowerShell module:
- Registry GUID parsing (HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops)
- Desktop number calculation
- Profile folder creation
- IVirtualDesktopManager COM interface wrapping

**Effort:** 1–2 days. Existing code in 6 launchers provides template.

**Result:** Each launcher becomes 20 lines instead of 50+. Easy to test in isolation.

---

**2. Automated Tests** (tests/ directories)

**What:** Unit + integration tests for:
- VD detection logic (mock registry, assert correct desktop number)
- Profile picker apps (XAML data binding, search filtering)
- Shared library (ProfileScanService, SettingsService)
- Launcher scripts (PowerShell Pester framework)

**Effort:** 2–3 weeks (for comprehensive coverage)

**Result:** Regression safety for future features (e.g., Windows 12 VD API changes).

---

**3. CI/CD Pipeline** (GitHub Actions)

**What:**
- Trigger on push to main: `git clone --recursive`, `.build\Build.ps1`, upload to GitHub Releases
- Trigger on PR: build, run tests, upload to Actions artifacts for testing
- Code signing support (Inno Setup can sign .exe with cert)
- Release notes generation (from CHANGELOG.md)

**Effort:** 3–5 days (GitHub Actions YAML + script debugging)

**Result:** Zero-touch releases. Each version properly versioned and distributed.

---

### Medium Priority

**4. Unified Profile Root Structure**

**Current State:**
```
C:\ChromeProfiles\virtual_desktop_N\
C:\EdgeProfiles\virtual_desktop_N\
C:\VSCodeProfiles\virtual_desktop_N\
C:\StickyNotesProfiles\profiles\virtual_desktop_N\
C:\AntiGravityProfiles\virtual_desktop_N\
C:\claude-ws\vd-profiles\vd-N\
```

**Proposed for v1.6:**
```
C:\MPKTools\Profiles\
├── chrome\virtual_desktop_N\
├── edge\virtual_desktop_N\
├── vscode\virtual_desktop_N\
├── sticky-notes\virtual_desktop_N\
├── antigravity\virtual_desktop_N\
└── claude\vd-N\
```

**Effort:** Medium (migration script + installer updates)

**Benefit:** Easier to backup, move between machines, understand at a glance.

---

**5. Release Automation** (GitHub Actions)

**What:** Script that:
- Reads VERSION file
- Generates GitHub Release with CHANGELOG.md entry
- Uploads installer .exe as asset
- Auto-posts release notes to repo

**Effort:** 1–2 days

**Result:** One-command releases: `git push` → automatic GitHub Release + installer distribution.

---

### Low Priority

**6. Package Manifest**

**What:** Root-level nuget.json or similar documenting:
- .NET SDK 8.0+
- Inno Setup 6.0+
- PowerShell 5.1+
- Optional: GitHub CLI (for updates)

**Why:** Easier onboarding for new developers, CI/CD setup verification.

**Effort:** < 1 day

---

**7. Fix Submodule Branch**

**Current:** `src/desktop/MPK.VsCode.ProfilePicker` on `heads/master`  
**Target:** All submodules on `heads/main`

**Action:** One-time fix in that submodule's GitHub repo (rename default branch or update tracking).

**Effort:** < 30 min

---

## v1.7+ Ideas

- **Dark theme option** for VS Code Profile Picker (currently hardcoded #1e1e1e)
- **Profile sync across machines** (cloud backup of profile configs)
- **Multi-monitor workspace support** (extend VD detection to per-monitor settings)
- **Portable mode** (profiles in repo subdirectory instead of C:\ drive)
- **Custom app profiles** (user adds new app type, system auto-detects and creates profile)

## Recommendations for v1.6 Start

1. **First:** Implement shared launcher engine (unblocks all launchers)
2. **Second:** Set up GitHub Actions CI/CD (enables safe refactoring)
3. **Third:** Write launcher + shared lib tests (builds confidence in shared engine)
4. **Fourth:** Tackle unified profile root (breaking change, needs careful migration)

This order provides incremental value: shared engine → automated builds → tests catch regressions → cleaner structure.

## Links to Related Docs

- v1.5 accomplishments: see `.agent/v1.5/CONTEXT.md`
- Current submodule status: see `.agent/v1.5/SUBMODULES.md`
- Build process details: see `.agent/v1.5/BUILD.md`
