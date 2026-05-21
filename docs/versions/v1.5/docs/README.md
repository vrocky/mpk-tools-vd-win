# v1.5 Project Documentation

Complete technical reference for all components, architecture, and design decisions in MPK Tools v1.5.

## Documents

### [COMPONENTS.md](COMPONENTS.md)
Detailed specification of all 14 submodules:
- Desktop applications (3 WPF profile pickers)
- Feature modules (3 search utilities)
- Virtual desktop launchers (6 PowerShell scripts)
- Shared library (registry, profile scanning, VD detection)
- Updater utility
- What each component does, tech stack, dependencies, profiles it manages

### [ARCHITECTURE.md](ARCHITECTURE.md)
How components fit together:
- Monorepo structure and why
- Submodule organization (src/desktop/, src/launchers/, etc.)
- Dependency graph (what references what)
- Data flow (registry → settings → UI)
- Communication patterns between apps and launchers

### [BUILD_SYSTEM.md](BUILD_SYSTEM.md)
How the project builds and packages:
- Build.ps1 script flow
- Publishing WPF apps as self-contained
- Staging launchers and updater
- Inno Setup installer configuration
- Version management
- Build dependencies and requirements

### [VIRTUAL_DESKTOP.md](VIRTUAL_DESKTOP.md)
Virtual desktop detection and profile isolation mechanism:
- Windows Registry structure (VirtualDesktops GUID storage)
- How launchers detect current desktop number
- Profile folder naming convention
- Per-app isolation strategies (--user-data-dir, etc.)
- COM API (IVirtualDesktopManager) reference

### [SETTINGS_AND_REGISTRY.md](SETTINGS_AND_REGISTRY.md)
Profile data storage and persistence:
- Registry keys used by each component
- VS Code Profile Picker settings structure
- How profile lists are discovered and cached
- Profile folder auto-creation logic
- Migration and backup considerations

### [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)
How to add new features or components:
- Adding a new launcher
- Adding a new profile picker app
- Extending shared library (ProfileScanService, etc.)
- Testing profile isolation
- Debugging VD detection
- Common gotchas

---

## Quick Reference

**All components:**
- Language: C# (WPF apps, shared lib, updater) + PowerShell (launchers)
- Framework: .NET 8 (all C# projects)
- Profile storage: Registry-backed (HKCU:\Software\*)
- Virtual desktop detection: Windows Registry + optional COM API
- Distribution: Inno Setup installer, all in one .exe
- Version: Read from VERSION file at repo root

**Key directories:**
- `src/desktop/` — Profile picker WPF apps
- `src/features/` — Search utilities (WPF)
- `src/launchers/` — Virtual desktop launcher scripts (PowerShell)
- `src/shared/` — Shared C# library (registry, VD detection)
- `src/tools/` — Updater console app
- `build/` — Build orchestration script
- `packaging/inno/` — Installer configuration

---

Return to main README: [../../README.md](../../README.md)
