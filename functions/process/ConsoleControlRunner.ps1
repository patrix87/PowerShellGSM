<#
  Not a module function. Started by Invoke-ConsoleControl as a separate PowerShell process: it leaves
  the console it inherited, attaches to the target program's console, and acts on it.
  Exits with 0 on success, 1 on failure.
#>
[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [int]$TargetPid,
  [string]$Title = ""
)

Add-Type -Namespace "PowerShellGSM" -Name "ConsoleApi" -MemberDefinition @"
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool FreeConsole();
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool AttachConsole(uint dwProcessId);
[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
public static extern bool SetConsoleTitle(string lpConsoleTitle);
"@

$null = [PowerShellGSM.ConsoleApi]::FreeConsole()
if (-not [PowerShellGSM.ConsoleApi]::AttachConsole($TargetPid)) {
  exit 1
}
$Success = $true
if ($Title) {
  $Success = [PowerShellGSM.ConsoleApi]::SetConsoleTitle($Title) -and $Success
}
$null = [PowerShellGSM.ConsoleApi]::FreeConsole()
if ($Success) {
  exit 0
}
exit 1
