# ClaudeProfiles

PowerShell scripts for launching Claude Code (`claudew`) in an isolated working directory per Windows virtual desktop.

## What this does

- `Launch-Claude.ps1` opens Windows Terminal in the VD-specific directory and runs `claude`.
- `Create-Shortcut.ps1` generates desktop shortcuts that run the launcher.

Each virtual desktop gets its own working directory under `C:\claude-ws\vd-profiles\vd-[N]\`.

## Requirements

- Windows 11 (Windows Terminal must be available as `wt`)
- PowerShell 5.1 or later
- `claudew` on PATH (installed via `npm install -g @anthropic-ai/claude-code`)

## Launching Claude Code

Run the launcher directly from PowerShell:

```powershell
.\Launch-Claude.ps1
```

Optional parameters:

```powershell
.\Launch-Claude.ps1 -Desktop 3       # force a specific desktop number
.\Launch-Claude.ps1 -Resume          # resume previous session
```

## What the launcher does

`Launch-Claude.ps1`:

- Detects the current virtual desktop by reading the Windows registry.
- Builds a profile name like `vd-1`, `vd-2`, and so on.
- Creates `C:\claude-ws\vd-profiles\vd-[N]` if it does not already exist.
- Opens Windows Terminal in that directory running `claude` (or `claude --resume` with `-Resume`).

## Creating the desktop shortcut

Run:

```powershell
.\Create-Shortcut.ps1
```

This creates a desktop shortcut named `Claude Code (Virtual Desktop).lnk`.

It also creates `Claude Code Resume (Virtual Desktop).lnk` to launch directly with `-Resume`.

## Folder layout

```
C:\Scripts\ClaudeProfiles\
  Launch-Claude.ps1
  Create-Shortcut.ps1
  README.md

C:\claude-ws\vd-profiles\
  vd-1\
  vd-2\
  vd-3\
  ...
```

Each `vd-[N]` directory holds the `.claude` session state that Claude Code creates automatically on first run.
