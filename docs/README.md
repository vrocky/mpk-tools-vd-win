# MPK Tools Documentation

Complete documentation for MPK Tools v1.6 — architecture, setup, and development guides.

---

## 🚀 Getting Started

### For Users
- **[README.md](../README.md)** — Project overview, features, and installation
- **[v1.6/INSTALL.md](versions/v1.6/INSTALL.md)** — Installation, migration from v1.5, profile locations
- **[v1.6/UPDATES.md](versions/v1.6/UPDATES.md)** — What's new in v1.6 (smaller installer, faster builds, simpler launchers)

### For Developers
- **[v1.6/UNDERSTANDING.md](versions/v1.6/UNDERSTANDING.md)** — How the system works, file purposes, error messages
- **[v1.6/TASKFILE.md](versions/v1.6/TASKFILE.md)** — Task runner for building (recommended method)
- **[BUILD.md](../Taskfile.yml)** — Build system configuration

### For v1.5 Users Migrating to v1.6
- **[v1.6/PROFILE_MIGRATION.md](versions/v1.6/PROFILE_MIGRATION.md)** — Automatic migration tool for profile folders
- **[v1.6/INSTALL.md](versions/v1.6/INSTALL.md)** — Step-by-step migration walkthrough

---

## 📚 Version Documentation

### v1.6 (Current)
**Complete v1.6 implementation — simplified, fast, robust**

| Document | Purpose |
|----------|---------|
| [UPDATES.md](versions/v1.6/UPDATES.md) | What changed, why, improvements |
| [INSTALL.md](versions/v1.6/INSTALL.md) | Installation and migration |
| [UNDERSTANDING.md](versions/v1.6/UNDERSTANDING.md) | How it works, system design |
| [TASKFILE.md](versions/v1.6/TASKFILE.md) | Task runner guide |
| [PROFILE_MIGRATION.md](versions/v1.6/PROFILE_MIGRATION.md) | Detailed migration reference |

**Key Files:**
- `Taskfile.yml` — Simple build tasks (`task`, `task build:force`, etc.)
- `build/Build.ps1` — Build script with incremental builds
- `scripts/Migrate-Profiles.ps1` — v1.5→v1.6 profile migration
- `src/launchers/_shared/` — Shared launcher module

### v1.5 (Previous Release)
**See [versions/v1.5/](versions/v1.5/) for v1.5 documentation**

---

## 📖 Architecture & Design

### v1.6 Implementation
- **[.agent/v1.6/CONTEXT.md](../.agent/v1.6/CONTEXT.md)** — Quick facts and key files for agents
- **[.agent/v1.6/BUILD.md](../.agent/v1.6/BUILD.md)** — Incremental build system details
- **[.agent/v1.6/STRUCTURE.md](../.agent/v1.6/STRUCTURE.md)** — Directory consolidation (src/apps/)
- **[.agent/v1.6/UPDATES.md](../.agent/v1.6/UPDATES.md)** — Technical changes in v1.6

### Previous Versions
- **[RESTRUCTURING-STATUS.md](RESTRUCTURING-STATUS.md)** — v1.5 restructuring progress
- **[architecture/v1.5-restructuring-proposal.md](architecture/v1.5-restructuring-proposal.md)** — v1.5 design rationale

---

## File Organization

### v1.6 User & Developer Docs
```
docs/versions/v1.6/
├── INSTALL.md              Installation, migration, profile locations
├── UPDATES.md              What's new, improvements, benefits
├── UNDERSTANDING.md        How it works, system design, errors
├── TASKFILE.md             Task runner guide
└── PROFILE_MIGRATION.md    Detailed migration reference
```

### Agent-Focused Docs
```
.agent/v1.6/
├── CONTEXT.md              Quick facts, key files
├── BUILD.md                Build system and parameters
├── STRUCTURE.md            Directory structure changes
└── UPDATES.md              Technical changes summary
```

### Root-Level Files
```
./
├── VERSION                 Current version (1.6.0)
├── CHANGELOG.md            Release history
├── README.md               Project overview
├── Taskfile.yml            Build tasks
├── build/Build.ps1         Build script
└── scripts/Migrate-Profiles.ps1  Migration tool
```

---

## Common Tasks

### Building
**Recommended (with Taskfile):**
```bash
task              # Build
task build:force  # Force rebuild
task build:app -- MPK.VsCode.ProfilePicker  # Single app
```

**Direct PowerShell:**
```powershell
.\build\Build.ps1                          # Build
.\build\Build.ps1 -ForceRebuild            # Force rebuild
.\build\Build.ps1 -Only MPK.VsCode.ProfilePicker  # Single app
```

See [v1.6/TASKFILE.md](versions/v1.6/TASKFILE.md) for all tasks.

### Migrating from v1.5
```powershell
.\scripts\Migrate-Profiles.ps1              # Interactive
.\scripts\Migrate-Profiles.ps1 -DryRun      # Preview
.\scripts\Migrate-Profiles.ps1 -Force       # Auto
```

See [v1.6/PROFILE_MIGRATION.md](versions/v1.6/PROFILE_MIGRATION.md) for details.

### Understanding the System
Read [v1.6/UNDERSTANDING.md](versions/v1.6/UNDERSTANDING.md) for:
- How virtual desktop detection works
- Profile isolation mechanism
- The complete build→install→launch flow
- Error messages and solutions
- How to add new launchers

---

## Key Improvements in v1.6

✅ **Simplified Build** — Incremental builds, only changed apps rebuild  
✅ **Shared Launchers** — Eliminated 6 copies of VD detection code  
✅ **Smaller Installer** — 300 MB → 15 MB (framework-dependent .NET 8)  
✅ **Unified Profiles** — All profiles in `C:\MPKTools\Profiles\`  
✅ **Better DX** — Clear error messages, validation, helpful logs  
✅ **Task Runner** — Simple `task` commands instead of long PowerShell  
✅ **Solid Docs** — Token-efficient, clear, reference v1.5 for details  

---

## Status

| Component | Status |
|-----------|--------|
| **v1.6 Core** | ✅ Complete |
| **Build System** | ✅ Incremental, validated |
| **Launchers** | ✅ Simplified, robust |
| **Installer** | ✅ Updated, .NET 8 check |
| **Migration Tool** | ✅ Tested, backup support |
| **Documentation** | ✅ Comprehensive |
| **Task Runner** | ✅ 10 tasks, all working |
| **DX & Logging** | ✅ Clear errors, good output |

---

## See Also

- **README.md** — Project overview and installation
- **GitHub** — https://github.com/vrocky/mpk-tools-vd-win
- **Releases** — https://github.com/vrocky/mpk-tools-vd-win/releases
- **Taskfile Docs** — https://taskfile.dev

---

**Last Updated:** 2026-05-21  
**Version:** 1.6.0
