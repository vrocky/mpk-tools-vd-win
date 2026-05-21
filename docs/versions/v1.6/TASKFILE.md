# Task Runner (Taskfile.yml)

Simple task runner for MPK Tools build system. Install from [taskfile.dev](https://taskfile.dev)

## Quick Usage

```bash
task              # Build (default)
task build        # Build MPK Tools
task build:force  # Rebuild all apps
task clean        # Remove dist/ output
task migrate      # Migrate v1.5→v1.6 profiles
task version      # Show current version
task help         # List all tasks
```

## All Tasks

### Build

| Task | Description |
|------|-------------|
| `task` | Build with incremental optimization (changed apps only) |
| `task build` | Same as above |
| `task build:force` | Force rebuild all apps |
| `task build:app -- AppName` | Build single app (e.g., `MPK.VsCode.ProfilePicker`) |
| `task build:stage` | Build and stage files (skip installer compilation) |

### Profiles

| Task | Description |
|------|-------------|
| `task migrate` | Interactive migration from v1.5 to v1.6 |
| `task migrate:preview` | Preview migration (-DryRun, no changes) |
| `task migrate:force` | Migrate without prompts (automation) |

### System

| Task | Description |
|------|-------------|
| `task clean` | Delete build output |
| `task version` | Show current version |
| `task version:set -- 1.6.1` | Update version file |
| `task info` | Show version, config, .NET details |
| `task help` | List all tasks |

## Examples

```bash
# Normal workflow
task              # Build everything
task clean        # Clean old builds
task build:force  # Full rebuild

# Development workflow (single app)
task build:app -- MPK.VsCode.ProfilePicker  # Rebuild one app only

# Testing migration
task migrate:preview  # See what would move
task migrate          # Actually migrate

# Version management
task version                # Show current
task version:set -- 1.6.1   # Set to 1.6.1
```

## Install Taskfile

**macOS/Linux** (homebrew):
```bash
brew install go-task
```

**Windows** (scoop/winget):
```powershell
scoop install task
# or
winget install go-task.go-task
```

**Go**:
```bash
go install github.com/go-task/task/v3/cmd/task@latest
```

See [taskfile.dev/installation](https://taskfile.dev/installation) for more options.

## Why Taskfile?

- **Simpler than Make** — YAML instead of cryptic shell syntax
- **Cross-platform** — Works on Windows, macOS, Linux
- **Fast incremental builds** — Avoids rebuilding unchanged apps
- **Clear task names** — Self-documenting workflow
- **Parallel tasks** — Run multiple builds at once (future)

## Configuration

Edit `Taskfile.yml` to:
- Change default config: `CONFIG: Debug`
- Add new tasks following the same pattern
- Customize build paths or options

All tasks use PowerShell with proper error handling (`-ExecutionPolicy Bypass` for subprocesses).
