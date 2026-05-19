# MPK Tools Documentation

Welcome to the MPK Tools documentation. This directory contains project architecture, guides, and processes.

---

## Quick Navigation

### 📋 Project Overview
- **[`.project.md`](../.project.md)** — Comprehensive project context, current issues, and recommendations
  - Start here to understand the project structure and why restructuring is needed

### 🏗️ Architecture & Restructuring
- **[`RESTRUCTURING-STATUS.md`](RESTRUCTURING-STATUS.md)** — Current status of v1.5 restructuring effort
  - What's been done, what's pending, and success criteria

- **[`architecture/v1.5-restructuring-proposal.md`](architecture/v1.5-restructuring-proposal.md)** — Detailed v1.5 design
  - Why the new structure is better
  - How the build process will change
  - What the final directory layout will look like

- **[`architecture/MIGRATION-GUIDE-v1.5.md`](architecture/MIGRATION-GUIDE-v1.5.md)** — Step-by-step migration guide
  - Preparation phase
  - Submodule reorganization
  - Build script updates
  - Testing and verification
  - Rollback procedures

### 👨‍💻 For Developers
*Documentation guides for contributors (to be created)*

- `guides/development.md` — How to build and run the project locally
- `guides/adding-new-app.md` — How to add a new desktop application
- `guides/adding-new-launcher.md` — How to add a new virtual desktop launcher
- `guides/contributing.md` — Contributing guidelines and code standards

### 🔄 Operational & Process Docs
*Process documentation (to be created)*

- `process/release-process.md` — How to cut a release
- `process/versioning-policy.md` — Semantic versioning rules
- `process/update-mechanism.md` — How the auto-update system works

---

## Files by Purpose

### Planning & Status
| File | Purpose |
|------|---------|
| `.project.md` (root) | Project analysis and context |
| `RESTRUCTURING-STATUS.md` | v1.5 restructuring progress |
| `.gitmodules.v1.5` (root) | Reference for new submodule paths |

### Architecture & Design
| File | Purpose |
|------|---------|
| `architecture/v1.5-restructuring-proposal.md` | v1.5 architecture proposal |
| `architecture/MIGRATION-GUIDE-v1.5.md` | Step-by-step migration |

### Development (Planned)
| File | Purpose |
|------|---------|
| `guides/development.md` | Build & development setup |
| `guides/adding-new-app.md` | Adding WPF applications |
| `guides/adding-new-launcher.md` | Adding PS launchers |

### Operations (Planned)
| File | Purpose |
|------|---------|
| `process/release-process.md` | Release procedures |
| `process/versioning-policy.md` | Version numbering |
| `process/update-mechanism.md` | Update system design |

---

## Current Directory Structure

```
docs/
├── README.md                          (this file)
├── RESTRUCTURING-STATUS.md            (v1.5 progress tracking)
├── architecture/
│   ├── v1.5-restructuring-proposal.md (detailed design)
│   └── MIGRATION-GUIDE-v1.5.md        (step-by-step instructions)
├── guides/                            (to be created)
├── process/                           (to be created)
└── versions/                          (legacy versioned docs)
```

---

## Key Paths

### Project Files
| Path | Purpose |
|------|---------|
| `./VERSION` | Suite version (to be created) |
| `./CHANGELOG.md` | Release history (to be created) |
| `./README.md` | Project overview (to be created) |
| `./.gitmodules.v1.5` | New submodule configuration |

### Source Code (After Migration)
| Path | Contents |
|------|----------|
| `./src/desktop/` | WPF applications |
| `./src/features/` | App-specific features |
| `./src/launchers/` | PowerShell launchers |
| `./src/shared/` | Shared libraries |
| `./src/tools/` | Build tools & updater |

### Build & Packaging
| Path | Purpose |
|------|---------|
| `./build/` | Build orchestration scripts (to be created) |
| `./packaging/inno/` | Installer configuration (to be created) |
| `./dist/` | Build output (to be created) |

---

## Status of Documentation

### ✅ Complete
- `.project.md` — Comprehensive project analysis
- `RESTRUCTURING-STATUS.md` — v1.5 status tracker
- `architecture/v1.5-restructuring-proposal.md` — Detailed design
- `architecture/MIGRATION-GUIDE-v1.5.md` — Step-by-step migration
- `.gitmodules.v1.5` — Reference configuration

### ⏳ In Progress
- Nothing currently (planning phase complete)

### ❓ Not Yet Started
- `guides/` directory and developer documentation
- `process/` directory and operational documentation
- Root-level `README.md` and `CHANGELOG.md`
- CI/CD workflow documentation

---

## How to Use This Documentation

### If You're New to the Project
1. Start with `.project.md` (root level)
2. Read `RESTRUCTURING-STATUS.md` to see what's happening
3. Review `architecture/v1.5-restructuring-proposal.md` for the vision

### If You're Implementing v1.5 Migration
1. Follow `architecture/MIGRATION-GUIDE-v1.5.md` step-by-step
2. Refer to `.gitmodules.v1.5` for submodule mapping
3. Use `RESTRUCTURING-STATUS.md` to track progress

### If You're Contributing Code
*Guides not yet created, but will be in `guides/` soon*

### If You're Cutting a Release
*Process documentation to be added to `process/` directory*

---

## Important Notes

⚠️ **v1.5 Is a Restructuring Release**
- No product changes — only organization and build improvements
- Existing functionality remains unchanged
- All 14 submodules are reorganized, not rewritten

⚠️ **Migration Requires Planning**
- Follow the migration guide carefully
- Test on a clean VM before deploying
- Backup git tags before starting: `git tag -a backup-pre-v1.5 ...`

ℹ️ **GitHub Repos Won't Be Renamed**
- Only local directory paths change
- GitHub repository names stay the same
- Submodule URLs don't need to change

---

## Quick Reference: Key Concepts

### What is a Submodule?
A git submodule is a repository linked inside another repository. MPK Tools uses 14 submodules:
- 3 WPF desktop applications
- 3 feature modules
- 6 PowerShell launchers
- 1 shared library
- 1 updater tool

### Virtual Desktop Profile Isolation
The core feature: each application gets an isolated profile folder per Windows virtual desktop.
- Example: Chrome on Desktop 1 gets `C:\ChromeProfiles\virtual_desktop_1\`
- Example: Chrome on Desktop 2 gets `C:\ChromeProfiles\virtual_desktop_2\`
- Settings, bookmarks, and extensions remain separate per desktop

### Why v1.5 Structure Matters
- Current structure: mix of apps, libraries, and experiments in one `apps/` folder
- v1.5 structure: clear separation — `src/desktop/`, `src/launchers/`, `src/shared/`, etc.
- Benefit: easier to maintain, scale, and onboard new developers

---

## See Also

- **Project Root** — `.project.md` contains comprehensive context
- **Git Submodules** — `git help submodule` for git documentation
- **GitHub Releases** — https://github.com/vrocky/mpk-tools-vd-win/releases

---

## Document History

| Date | Author | Change |
|------|--------|--------|
| 2026-05-19 | Claude Code | Initial documentation setup for v1.5 planning |

---

**Last Updated:** 2026-05-19
