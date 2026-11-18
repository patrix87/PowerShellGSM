function Invoke-ConsoleControl {
  <#
    Act on another program's console: set its window title, or send it Ctrl+C. Runs ConsoleControlRunner.ps1 as a separate PowerShell
    process sharing this console: attaching to another console means leaving our own first, which
    would cut this script off from its own window and log.
    Returns $true on success.
  #>
  [CmdletBinding()]
  [OutputType([bool])]
  param (
    [Parameter(Mandatory)]
    [int]$TargetPid,
    #New window title.
    [string]$Title = "",
    #Send Ctrl+C to the program.
    [switch]$CtrlC
  )
  $RunnerPath = (Resolve-Path -Path ".\functions\process\ConsoleControlRunner.ps1").Path
  $ArgumentList = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", "`"$RunnerPath`"",
    "-TargetPid", $TargetPid
  )
  if ($Title) {
    $ArgumentList += @("-Title", "`"$Title`"")
  }
  if ($CtrlC) {
    $ArgumentList += "-CtrlC"
  }
  $Runner = Start-Process -FilePath (Get-PowerShellPath) -ArgumentList $ArgumentList -NoNewWindow -Wait -PassThru
  return ($Runner.ExitCode -eq 0)
}
Export-ModuleMember -Function Invoke-ConsoleControl
