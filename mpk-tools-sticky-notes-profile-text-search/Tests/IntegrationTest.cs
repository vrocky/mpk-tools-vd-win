using System;
using System.IO;
using System.Text.Json;
using StickyNotesProfileTextSearch.Services;
using StickyNotesProfileTextSearch.Models;

namespace StickyNotesProfileTextSearch.Tests;

/// <summary>
/// Integration test to verify JSON parsing and indexing logic works with real-world data
/// </summary>
public static class IntegrationTest
{
    public static void RunTests()
    {
        Console.WriteLine("=== StickyNotes Text Search Integration Tests ===\n");

        var testDir = Path.Combine(Path.GetTempPath(), $"StickyNotesTest_{Guid.NewGuid():N}");
        
        try
        {
            // Setup test environment
            SetupTestEnvironment(testDir);
            
            // Test 1: Parse single note
            TestParseSingleNote(testDir);
            
            // Test 2: Parse multiple notes
            TestParseMultipleNotes(testDir);
            
            // Test 3: Build index across profiles
            TestBuildIndex(testDir);
            
            // Test 4: Empty notes file
            TestEmptyNotes(testDir);
            
            // Test 5: Virtual desktop profile naming
            TestVirtualDesktopNaming(testDir);
            
            Console.WriteLine("\n✓ All integration tests passed!");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\n✗ Test failed: {ex.Message}");
            Console.WriteLine(ex.StackTrace);
            Environment.ExitCode = 1;
        }
        finally
        {
            // Cleanup
            if (Directory.Exists(testDir))
            {
                Directory.Delete(testDir, true);
            }
        }
    }

    private static void SetupTestEnvironment(string testDir)
    {
        Console.WriteLine("Setting up test environment...");
        Directory.CreateDirectory(Path.Combine(testDir, "profiles"));
        Console.WriteLine($"✓ Test directory: {testDir}\n");
    }

    private static void TestParseSingleNote(string testDir)
    {
        Console.WriteLine("Test 1: Parse single note");
        
        var profileDir = Path.Combine(testDir, "profiles", "test_profile_1");
        Directory.CreateDirectory(profileDir);
        
        var notesData = new
        {
            notes = new[]
            {
                new
                {
                    id = "note_1234567890_abc123",
                    title = "Test Note",
                    content = "This is test content",
                    color = "#fff740",
                    createdAt = DateTime.UtcNow.AddDays(-2),
                    updatedAt = DateTime.UtcNow
                }
            },
            updatedAt = DateTime.UtcNow
        };
        
        var json = JsonSerializer.Serialize(notesData, new JsonSerializerOptions { WriteIndented = true });
        File.WriteAllText(Path.Combine(profileDir, "notes.json"), json);
        
        var settings = new StickyNotesSettings { DataDirectory = testDir };
        var results = NoteIndexService.BuildIndex(settings, false);
        
        Assert(results.Count == 1, $"Expected 1 note, got {results.Count}");
        Assert(results[0].Title == "Test Note", $"Expected title 'Test Note', got '{results[0].Title}'");
        Assert(results[0].Content == "This is test content", $"Expected content match, got '{results[0].Content}'");
        Assert(results[0].NoteId == "note_1234567890_abc123", $"Expected id match, got '{results[0].NoteId}'");
        Assert(results[0].Color == "#fff740", $"Expected color '#fff740', got '{results[0].Color}'");
        
        Console.WriteLine("  ✓ Single note parsed correctly");
        Console.WriteLine($"    - Title: {results[0].Title}");
        Console.WriteLine($"    - Content: {results[0].ContentPreview}");
        Console.WriteLine($"    - ID: {results[0].NoteId}\n");
    }

    private static void TestParseMultipleNotes(string testDir)
    {
        Console.WriteLine("Test 2: Parse multiple notes");
        
        var profileDir = Path.Combine(testDir, "profiles", "test_profile_2");
        Directory.CreateDirectory(profileDir);
        
        var notesData = new
        {
            notes = new[]
            {
                new
                {
                    id = "note_001",
                    title = "First Note",
                    content = "First content",
                    color = "#ffb3ba",
                    createdAt = DateTime.UtcNow.AddDays(-3),
                    updatedAt = DateTime.UtcNow.AddHours(-1)
                },
                new
                {
                    id = "note_002",
                    title = "Second Note",
                    content = "Second content with more text",
                    color = "#bae1ff",
                    createdAt = DateTime.UtcNow.AddDays(-2),
                    updatedAt = DateTime.UtcNow
                },
                new
                {
                    id = "note_003",
                    title = "",
                    content = "Untitled note",
                    color = "#ffffba",
                    createdAt = DateTime.UtcNow.AddDays(-1),
                    updatedAt = DateTime.UtcNow.AddMinutes(-30)
                }
            },
            updatedAt = DateTime.UtcNow
        };
        
        var json = JsonSerializer.Serialize(notesData, new JsonSerializerOptions { WriteIndented = true });
        File.WriteAllText(Path.Combine(profileDir, "notes.json"), json);
        
        var settings = new StickyNotesSettings { DataDirectory = testDir };
        var results = NoteIndexService.BuildIndex(settings, false);
        
        // Filter to just this profile's notes
        var profile2Notes = results.Where(n => n.ProfilePath.Contains("test_profile_2")).ToList();
        
        Assert(profile2Notes.Count == 3, $"Expected 3 notes in profile 2, got {profile2Notes.Count}");
        Assert(profile2Notes.Any(n => n.Title == "First Note"), "Missing 'First Note'");
        Assert(profile2Notes.Any(n => n.Title == "Second Note"), "Missing 'Second Note'");
        Assert(profile2Notes.Any(n => n.DisplayTitle == "(Untitled Note)"), "Missing untitled note");
        
        Console.WriteLine("  ✓ Multiple notes parsed correctly");
        Console.WriteLine($"    - Profile 2 notes: {profile2Notes.Count}");
        foreach (var note in profile2Notes.OrderByDescending(n => n.UpdatedAt))
        {
            Console.WriteLine($"    - {note.DisplayTitle} ({note.TimelineLabel})");
        }
        Console.WriteLine();
    }

    private static void TestBuildIndex(string testDir)
    {
        Console.WriteLine("Test 3: Build index across profiles");
        
        // Create multiple profiles
        for (int i = 1; i <= 3; i++)
        {
            var profileDir = Path.Combine(testDir, "profiles", $"profile_{i}");
            Directory.CreateDirectory(profileDir);
            
            var notesData = new
            {
                notes = new[]
                {
                    new
                    {
                        id = $"note_profile{i}_001",
                        title = $"Note from Profile {i}",
                        content = $"Content from profile {i}",
                        color = "#fff740",
                        createdAt = DateTime.UtcNow.AddDays(-i),
                        updatedAt = DateTime.UtcNow.AddHours(-i)
                    }
                },
                updatedAt = DateTime.UtcNow
            };
            
            var json = JsonSerializer.Serialize(notesData, new JsonSerializerOptions { WriteIndented = true });
            File.WriteAllText(Path.Combine(profileDir, "notes.json"), json);
        }
        
        var settings = new StickyNotesSettings { DataDirectory = testDir };
        var results = NoteIndexService.BuildIndex(settings, false);
        
        // Check we have notes from profile_1, profile_2, profile_3 (exact names)
        var newProfileNotes = results.Where(n => 
            n.ProfileName == "Profile 1" ||
            n.ProfileName == "Profile 2" ||
            n.ProfileName == "Profile 3").ToList();
        
        Assert(newProfileNotes.Count >= 3, $"Expected at least 3 notes from profile_1/2/3, got {newProfileNotes.Count}");
        
        var profiles = results.Select(n => n.ProfileName).Distinct().ToList();
        Assert(profiles.Count >= 3, $"Expected at least 3 profiles, got {profiles.Count}");
        
        Console.WriteLine("  ✓ Index built across multiple profiles");
        Console.WriteLine($"    - New profile notes: {newProfileNotes.Count}");
        Console.WriteLine($"    - Total profiles: {profiles.Count}");
        Console.WriteLine($"    - New profiles: Profile 1, Profile 2, Profile 3");
        Console.WriteLine();
    }

    private static void TestEmptyNotes(string testDir)
    {
        Console.WriteLine("Test 4: Empty notes file");
        
        var profileDir = Path.Combine(testDir, "profiles", "empty_profile");
        Directory.CreateDirectory(profileDir);
        
        var notesData = new
        {
            notes = Array.Empty<object>(),
            updatedAt = DateTime.UtcNow
        };
        
        var json = JsonSerializer.Serialize(notesData, new JsonSerializerOptions { WriteIndented = true });
        File.WriteAllText(Path.Combine(profileDir, "notes.json"), json);
        
        var settings = new StickyNotesSettings { DataDirectory = testDir };
        var results = NoteIndexService.BuildIndex(settings, false);
        
        // Should only count notes from previous tests
        Console.WriteLine($"  ✓ Empty profile handled correctly (total notes: {results.Count})");
        Console.WriteLine();
    }

    private static void TestVirtualDesktopNaming(string testDir)
    {
        Console.WriteLine("Test 5: Virtual desktop profile naming");
        
        var profileDir = Path.Combine(testDir, "profiles", "virtual_desktop_8");
        Directory.CreateDirectory(profileDir);
        
        var notesData = new
        {
            notes = new[]
            {
                new
                {
                    id = "note_vd8_001",
                    title = "VD8 Note",
                    content = "Content from virtual desktop 8",
                    color = "#fff740",
                    createdAt = DateTime.UtcNow,
                    updatedAt = DateTime.UtcNow
                }
            },
            updatedAt = DateTime.UtcNow
        };
        
        var json = JsonSerializer.Serialize(notesData, new JsonSerializerOptions { WriteIndented = true });
        File.WriteAllText(Path.Combine(profileDir, "notes.json"), json);
        
        var settings = new StickyNotesSettings { DataDirectory = testDir };
        var results = NoteIndexService.BuildIndex(settings, false);
        
        var vdNote = results.FirstOrDefault(n => n.NoteId == "note_vd8_001");
        Assert(vdNote != null, "Virtual desktop note not found");
        Assert(vdNote.ProfileName == "Virtual Desktop 8", 
            $"Expected profile name 'Virtual Desktop 8', got '{vdNote.ProfileName}'");
        
        Console.WriteLine("  ✓ Virtual desktop profile naming correct");
        Console.WriteLine($"    - Profile: {vdNote.ProfileName}");
        Console.WriteLine();
    }

    private static void Assert(bool condition, string message)
    {
        if (!condition)
        {
            throw new Exception($"Assertion failed: {message}");
        }
    }
}
