function Start-ConsoleProcess {
  <#
    Start a program through Windows Console Host (conhost.exe), in its own window, or with no window at
    all with -Headless. Starting conhost.exe explicitly bypasses the user's default terminal setting.
    With Windows Terminal as the default terminal, a program would otherwise run inside
    WindowsTerminal.exe: it has no window of its own to close, and it dies whenever Windows Terminal
    crashes or updates.
    GUI programs have no console, so they are started directly.
    Returns the program's process, or conhost's process when the program could not be found (it already exited).
  #>
  [CmdletBinding()]
  [OutputType([System.Diagnostics.Process])]
  param (
    [Parameter(Mandatory)]
    [string]$FilePath,
    [string]$Arguments = "",
    [string]$WorkingDirectory = (Get-Location).Path,
    #Window title. Programs that set their own title replace it.
    [string]$Title = "",
    [switch]$Headless
  )
  $Program = (Resolve-Path -Path $FilePath -ErrorAction Stop).Path
  if (-not (Test-ConsoleProgram -Path $Program)) {
    $StartParams = @{
      FilePath         = $Program
      WorkingDirectory = $WorkingDirectory
      PassThru         = $true
    }
    if ($Arguments.Length -gt 0) {
      $StartParams.ArgumentList = $Arguments
    }
    return Start-Process @StartParams
  }

  $ConhostArguments = "`"$Program`" $Arguments".Trim()
  if ($Headless) {
    $ConhostArguments = "--headless $ConhostArguments"
  }
  $Conhost = Start-Process -FilePath "conhost.exe" -ArgumentList $ConhostArguments -WorkingDirectory $WorkingDirectory -PassThru

  #conhost.exe starts the program as its child.
  $ProgramProcess = $null
  $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
  while ((-not $ProgramProcess) -and (-not $Conhost.HasExited) -and ($Stopwatch.Elapsed.TotalSeconds -lt 10)) {
    $Child = Get-CimInstance -ClassName "Win32_Process" -Filter "ParentProcessId = $($Conhost.Id)" -ErrorAction SilentlyContinue |
    Where-Object { $_.ExecutablePath -eq $Program } | Select-Object -First 1
    if ($Child) {
      $ProgramProcess = Get-Process -Id $Child.ProcessId -ErrorAction SilentlyContinue
    }
    else {
      Start-Sleep -Milliseconds 200
    }
  }
  if (-not $ProgramProcess) {
    return $Conhost
  }
  if ($Title -and (-not $Headless)) {
    $null = Invoke-ConsoleControl -TargetPid $ProgramProcess.Id -Title $Title
  }
  return $ProgramProcess
}
Export-ModuleMember -Function Start-ConsoleProcess
