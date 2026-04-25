using StickyNotesProfileTextSearch.Tests;

Console.WriteLine("StickyNotes Profile Text Search - Integration Tests");
Console.WriteLine("====================================================\n");

try
{
    IntegrationTest.RunTests();
}
catch (Exception ex)
{
    Console.WriteLine($"\n✗ Test suite failed: {ex.Message}");
    return 1;
}

return 0;
