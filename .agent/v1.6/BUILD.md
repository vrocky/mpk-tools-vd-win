# v1.6 Build System

**See [v1.5 BUILD.md](../.agent/v1.5/BUILD.md) for full build architecture.**

## Changes

### New: Incremental Builds
```powershell
function Should-Republish {
    if (-not (Test-Path $OutputPath)) { return $true }
    $sourceNewest = Get-ChildItem -Path (Split-Path $ProjectPath) -Recurse |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $outputNewest = Get-ChildItem -Path $OutputPath -Recurse |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    return ($sourceNewest.LastWriteTime -gt $outputNewest.LastWriteTime)
}
```

Skips rebuild if source files haven't changed.

### New: Framework-Dependent Publishing
Removed `--self-contained` flag. Each app now 2 MB instead of 150 MB.

**Requires**: .NET 8 Desktop Runtime on target machine
**Checked by**: Installer (registry validation in `MPKTools.iss`)

### Unified App Array
Merged `$desktopProjects` + `$featureProjects` into single `$allApps`:

```powershell
$allApps = @(
    @{ Id = "MPK.VsCode.ProfilePicker"; Project = "src/apps/..." },
    # ...
)
```

No distinction between "desktop" and "feature" apps anymore.

### Parameters

| Param | Purpose |
|-------|---------|
| `-Configuration` | Release/Debug |
| `-Version` | Override VERSION file |
| `-ForceRebuild` | Rebuild all projects |
| `-Only <name>` | Single project only |
| `-SkipCompileInstaller` | Stage without Inno Setup |

**Removed**: `-SkipPublish`, `-ReusePublishedApps`, `-Runtime`

### Build Output

Displays published vs skipped count:
```
  Published: 3 apps
  Skipped: 3 apps (up-to-date)
```
