#!/usr/bin/env powershell
## Usage:
# register-fonts.ps1 [-v] [-unregister <PATH>[,<PATH>...]] [-register  <PATH>[,<PATH>...]] # Register and unregister at same time
# register-fonts.ps1 [-v] -unregister <PATH>
# register-fonts.ps1 [-v] -register <PATH>
# register-fonts.ps1 [-v] <PATH> # Will register font path
Param (
  [Parameter(Mandatory=$False)]
  [String[]]$register,

  [Parameter(Mandatory=$False)]
  [String[]]$unregister
)

# Stop script if command fails https://stackoverflow.com/questions/9948517/how-to-stop-a-powershell-script-on-the-first-error
$ErrorActionPreference = "Stop"

add-type -name Session -namespace "" -member @"
[DllImport("gdi32.dll")]
public static extern bool AddFontResource(string filePath);
[DllImport("gdi32.dll")]
public static extern bool RemoveFontResource(string filePath);
[return: MarshalAs(UnmanagedType.Bool)]
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern bool PostMessage(IntPtr hWnd, int Msg, int wParam = 0, int lParam = 0);
"@

$broadcast = $False;
Foreach ($unregisterFontPath in $unregister) {
  Write-Verbose "Unregistering font $unregisterFontPath"
  # https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-removefontresourcea
  $success = [Session]::RemoveFontResource($unregisterFontPath)
  if (!$success) {
    Throw "Cannot unregister font $unregisterFontPath"
  }
  $broadcast = $True
}

Foreach ($registerFontPath in $register) {
  Write-Verbose "Registering font $registerFontPath"
  # https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-addfontresourcea
  $success = [Session]::AddFontResource($registerFontPath)
  if (!$success) {
    Throw "Cannot register font $registerFontPath"
  }
  $broadcast = $True
}

if ($broadcast) {
  # HWND_BROADCAST https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-postmessagea
  $HWND_BROADCAST = New-Object IntPtr 0xffff
  # WM_FONTCHANGE https://learn.microsoft.com/en-us/windows/win32/gdi/wm-fontchange
  $WM_FONTCHANGE  = 0x1D

  Write-Verbose "Broadcasting font change"
  # Broadcast will let other programs know that fonts were changed https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-postmessagea
  $success = [Session]::PostMessage($HWND_BROADCAST, $WM_FONTCHANGE)
  if (!$success) {
    Throw "Cannot broadcast font change"
  }
}
