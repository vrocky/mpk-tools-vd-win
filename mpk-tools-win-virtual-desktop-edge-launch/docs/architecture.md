# Architecture â Edge Profile Picker

This document describes the internal design, component responsibilities, data flow, and the on-disk format consumed by the application.

---

## Overview

Edge Profile Picker is a single-window WPF application targeting .NET 8 on Windows. It follows a minimal layered design with three distinct concerns:

| Layer | Namespace | Purpose |
|---|---|---|
| Data model | `EdgeProfilePicker.Models` | Plain C# record-like class representing one profile |
| Service | `EdgeProfilePicker.Services` | File-system and JSON I/O; no WPF dependencies |
| Presentation | `EdgeProfilePicker` (root) | XAML + code-behind; all WPF types live here |
| Converters | `EdgeProfilePicker.Converters` | Stateless `IValueConverter` implementations |

There is no view-model layer or MVVM framework. Because the UI state is simple (one list, one search string, one status label) the code-behind in `MainWindow.xaml.cs` acts directly on named XAML elements. This avoids the ceremony of a full MVVM setup while remaining readable and easy to extend.

---

## Component Responsibilities

### `Models/EdgeProfile.cs`

A plain data-transfer object with no logic. Properties:

| Property | Type | Description |
|---|---|---|
| `Folder` | `string` | Profile directory name (`Default`, `Profile 1`, ...) |
| `Name` | `string` | Human-readable display name from `Preferences` |
| `Email` | `string` | Signed-in account address, or `"No account signed in"` |
| `Initials` | `string` | Up to two upper-case characters derived from `Name` |
| `AvatarColor` | `string` | Hex colour string, cycled from a fixed palette |
| `PicturePath` | `string?` | Absolute path to `Edge Profile.ico`, or `null` |
| `HasPicture` | `bool` (computed) | `true` when `PicturePath` is non-null/non-empty |

`HasPicture` is a calculated property (no setter) used as a `DataTrigger` binding target in XAML to toggle avatar image visibility without a converter.

---

### `Services/EdgeProfileService.cs`

A `static` class. All methods are pure with respect to WPF â they return plain .NET types only, making them independently unit-testable.

#### `EdgeExePath`

