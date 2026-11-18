<#
  Not a module function. Started by Invoke-ConsoleControl as a separate PowerShell process: it leaves
  the console it inherited, attaches to the target program's console, and acts on it.
  Exits with 0 on success, 1 on failure.
#>
[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [int]$TargetPid,
  [string]$Title = "",
  #Send Ctrl+C to every process attached to the target's console.
  [switch]$CtrlC
)

Add-Type -Namespace "PowerShellGSM" -Name "ConsoleApi" -MemberDefinition @"
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool FreeConsole();
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool AttachConsole(uint dwProcessId);
[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
public static extern bool SetConsoleTitle(string lpConsoleTitle);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool SetConsoleCtrlHandler(IntPtr HandlerRoutine, bool Add);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool GenerateConsoleCtrlEvent(uint dwCtrlEvent, uint dwProcessGroupId);
"@

$null = [PowerShellGSM.ConsoleApi]::FreeConsole()
if (-not [PowerShellGSM.ConsoleApi]::AttachConsole($TargetPid)) {
  exit 1
}
$Success = $true
if ($Title) {
  $Success = [PowerShellGSM.ConsoleApi]::SetConsoleTitle($Title) -and $Success
}
if ($CtrlC) {
  #Ignore the Ctrl+C ourselves: it reaches every process attached to the console, this one included.
  $null = [PowerShellGSM.ConsoleApi]::SetConsoleCtrlHandler([IntPtr]::Zero, $true)
  #CTRL_C_EVENT (0) to process group 0, every process on the console.
  $Success = [PowerShellGSM.ConsoleApi]::GenerateConsoleCtrlEvent(0, 0) -and $Success
  #The event is delivered asynchronously, stay attached until it is.
  Start-Sleep -Milliseconds 500
}
$null = [PowerShellGSM.ConsoleApi]::FreeConsole()
if ($Success) {
  exit 0
}
exit 1
