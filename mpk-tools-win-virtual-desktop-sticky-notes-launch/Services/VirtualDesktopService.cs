using Microsoft.Win32;

namespace StickyNotesProfilePicker.Services;

public static class VirtualDesktopService
{
    public static int GetCurrentDesktopNumber()
    {
        try
        {
            var regPath = @"SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops";
            using var key = Registry.CurrentUser.OpenSubKey(regPath);
            
            if (key == null)
            {
                return 1; // Default to desktop 1 if registry key doesn't exist
            }

            var allBytes = key.GetValue("VirtualDesktopIDs") as byte[];
            var curBytes = key.GetValue("CurrentVirtualDesktop") as byte[];

            if (allBytes == null || curBytes == null || allBytes.Length == 0 || curBytes.Length != 16)
            {
                return 1;
            }

            var curGuid = new Guid(curBytes);
            var count = allBytes.Length / 16;

            for (int i = 0; i < count; i++)
            {
                var chunk = new byte[16];
                Array.Copy(allBytes, i * 16, chunk, 0, 16);
                if (new Guid(chunk) == curGuid)
                {
                    return i + 1;
                }
            }

            return 1;
        }
        catch
        {
            return 1; // Default to desktop 1 on any error
        }
    }
}
