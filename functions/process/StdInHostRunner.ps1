<#
  Not a module function. Launched as its own detached, headless PowerShell process by
  Start-StdInHost, and stays alive for as long as the game process runs so that later,
  separate invocations of main.ps1 can deliver console commands (save/exit/etc) through
  the named pipe instead of relying on CloseMainWindow/Stop-Process.

  It also watches the console window that stands in for the server's own window: if that
  window goes away without detaching first, the server is stopped gracefully.
#>
[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [string]$ParamsFile
)

$ErrorActionPreference = "Stop"

$HostParams = Get-Content -Path $ParamsFile -Raw | ConvertFrom-Json

$Psi = New-Object System.Diagnostics.ProcessStartInfo
$Psi.FileName = $HostParams.Exec
$Psi.Arguments = $HostParams.Arguments
$Psi.WorkingDirectory = $HostParams.WorkingDirectory
$Psi.RedirectStandardInput = $true
$Psi.RedirectStandardOutput = $true
$Psi.RedirectStandardError = $true
$Psi.UseShellExecute = $false
$Psi.CreateNoWindow = $true

$GameProcess = New-Object System.Diagnostics.Process
$GameProcess.StartInfo = $Psi

#Keep one shared writer open with FileShare.ReadWrite so the console window can tail this
#file live while we are still appending to it.
$LogStream = [System.IO.FileStream]::new($HostParams.LogFile, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite)
$LogStreamWriter = [System.IO.StreamWriter]::new($LogStream)
$LogStreamWriter.AutoFlush = $true
#Output events fire on a background thread, so the writer has to be synchronized.
$LogWriter = [System.IO.TextWriter]::Synchronized($LogStreamWriter)

$LogAction = {
  if (-not [string]::IsNullOrEmpty($EventArgs.Data)) {
    $Event.MessageData.WriteLine($EventArgs.Data)
  }
}

$null = $GameProcess.Start()
#Published so a console window opened later can find the server to attach to.
Set-Content -Path $HostParams.HostPidFile -Value $PID -Encoding UTF8
$null = Register-ObjectEvent -InputObject $GameProcess -EventName OutputDataReceived -Action $LogAction -MessageData $LogWriter
$null = Register-ObjectEvent -InputObject $GameProcess -EventName ErrorDataReceived -Action $LogAction -MessageData $LogWriter
$GameProcess.BeginOutputReadLine()
$GameProcess.BeginErrorReadLine()

<#
  Console window states, read from the PID file the console window writes for itself:
    file missing         -> nobody attached (never opened, or detached on purpose)
    file + live process  -> attached
    file + dead process  -> the window was closed or killed, so stop the server
#>
function Test-ConsoleWindow {
  param ([string]$PidFile)
  if (-not (Test-Path -Path $PidFile -PathType "Leaf" -ErrorAction SilentlyContinue)) {
    return "Detached"
  }
  $ConsolePID = 0
  if (-not [int]::TryParse((Get-Content -Path $PidFile -ErrorAction SilentlyContinue), [ref]$ConsolePID)) {
    return "Detached"
  }
  if (Get-Process -Id $ConsolePID -ErrorAction SilentlyContinue) {
    return "Attached"
  }
  return "Closed"
}

$ConsoleWasAttached = $false
$StopRequested = $false

#Accept one command per pipe connection, re-arming the listener between each, until the
#game process exits (gracefully via a stop command, or a crash/force-kill from elsewhere).
while ((-not $GameProcess.HasExited) -and (-not $StopRequested)) {
  $Pipe = New-Object System.IO.Pipes.NamedPipeServerStream($HostParams.PipeName, [System.IO.Pipes.PipeDirection]::In, 1)
  try {
    $ConnectTask = $Pipe.WaitForConnectionAsync()
    while ((-not $ConnectTask.IsCompleted) -and (-not $GameProcess.HasExited) -and (-not $StopRequested)) {
      Start-Sleep -Milliseconds 500
      switch (Test-ConsoleWindow -PidFile $HostParams.ConsolePidFile) {
        "Attached" { $ConsoleWasAttached = $true }
        "Detached" { $ConsoleWasAttached = $false }
        "Closed" {
          if ($ConsoleWasAttached) {
            $LogWriter.WriteLine("[StdInHost] Console window was closed, stopping server...")
            $StopRequested = $true
          }
        }
      }
    }
    if ($ConnectTask.IsCompleted -and $Pipe.IsConnected) {
      $Reader = New-Object System.IO.StreamReader($Pipe)
      $Line = $Reader.ReadLine()
      $Reader.Dispose()
      if ((-not [string]::IsNullOrWhiteSpace($Line)) -and (-not $GameProcess.HasExited)) {
        $GameProcess.StandardInput.WriteLine($Line)
        $GameProcess.StandardInput.Flush()
      }
    }
  }
  catch {
    $LogWriter.WriteLine("[StdInHost] Pipe error: $_")
  }
  finally {
    $Pipe.Dispose()
  }
}

#The console window went away, so send the stop command on its behalf and give the server
#time to save before falling back to a kill.
if ($StopRequested -and (-not $GameProcess.HasExited)) {
  try {
    $GameProcess.StandardInput.WriteLine($HostParams.StopCommand)
    $GameProcess.StandardInput.Flush()
  }
  catch {
    $LogWriter.WriteLine("[StdInHost] Unable to send stop command: $_")
  }
  if (-not $GameProcess.WaitForExit($HostParams.StopTimeout * 1000)) {
    $LogWriter.WriteLine("[StdInHost] Server did not stop in $($HostParams.StopTimeout)s, forcing it closed.")
    try {
      $GameProcess.Kill()
    }
    catch {
      $LogWriter.WriteLine("[StdInHost] Unable to force close the server: $_")
    }
  }
}

Get-EventSubscriber -ErrorAction SilentlyContinue | Where-Object { $_.SourceObject -eq $GameProcess } | Unregister-Event
$LogWriter.WriteLine("[StdInHost] Server process exited.")
$LogWriter.Dispose()
Remove-Item -Path $HostParams.ConsolePidFile -Force -ErrorAction SilentlyContinue
Remove-Item -Path $HostParams.HostPidFile -Force -ErrorAction SilentlyContinue
Remove-Item -Path $ParamsFile -Force -ErrorAction SilentlyContinue
