# Integration Tests for StickyNotes Profile Text Search

This test suite validates that the JSON parsing and note indexing logic works correctly with real-world StickyNotes data.

## Test Coverage

### Test 1: Parse Single Note
- Creates a test profile with one note
- Verifies the note is correctly parsed from `notes.json`
- Validates all properties (id, title, content, color, timestamps)

### Test 2: Parse Multiple Notes  
- Creates a profile with 3 notes (including an untitled note)
- Verifies all notes are parsed correctly
- Tests the DisplayTitle property for untitled notes

### Test 3: Build Index Across Profiles
- Creates multiple profiles (profile_1, profile_2, profile_3)
- Verifies the index aggregates notes from all profiles
- Tests profile counting and note aggregation

### Test 4: Empty Notes File
- Tests handling of profiles with no notes
- Ensures empty arrays don't cause errors

### Test 5: Virtual Desktop Profile Naming
- Creates a `virtual_desktop_8` profile
- Verifies the profile name is formatted as "Virtual Desktop 8"
- Tests the profile name formatting logic

## Running the Tests

```powershell
cd Tests
dotnet run
```

Or build and run separately:

```powershell
cd Tests
dotnet build
dotnet run --no-build
```

## Test Output

Successful test run shows:
```
✓ Test 1: Parse single note  
✓ Test 2: Parse multiple notes
✓ Test 3: Build index across profiles
✓ Test 4: Empty notes file
✓ Test 5: Virtual desktop profile naming

✓ All integration tests passed!
```

## What the Tests Validate

1. **JSON Deserialization**: System.Text.Json correctly deserializes notes.json with PropertyNameCaseInsensitive
2. **Note Properties**: All note fields (id, title, content, color, timestamps) are parsed
3. **Profile Scanning**: Multiple profiles are discovered and indexed
4. **Profile Naming**: Virtual desktop profiles get user-friendly names
5. **Edge Cases**: Empty notes arrays and untitled notes are handled gracefully

## Test Data Structure

The tests create temporary profiles in `%TEMP%\StickyNotesTest_*` with this structure:

```
profiles/
  test_profile_1/
    notes.json
  test_profile_2/
    notes.json
  profile_1/
    notes.json
  ...
```

Each `notes.json` follows the StickyNotes format:

```json
{
  "notes": [
    {
      "id": "note_...",
      "title": "Note Title",
      "content": "Note content",
      "color": "#fff740",
      "createdAt": "2026-04-25T...",
      "updatedAt": "2026-04-25T..."
    }
  ],
  "updatedAt": "2026-04-25T..."
}
```

## Key Fix Validated

The integration tests verify the critical fix for case-sensitive JSON deserialization:

```csharp
var options = new JsonSerializerOptions
{
    PropertyNameCaseInsensitive = true  // Allows "notes" to map to "Notes"
};
var notesData = JsonSerializer.Deserialize<NotesData>(json, options);
```

Without this option, the lowercase JSON property names wouldn't map to the PascalCase C# properties, resulting in zero notes being parsed.
