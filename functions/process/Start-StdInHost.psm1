function Start-StdInHost {
  [CmdletBinding()]
  [OutputType([System.Diagnostics.Process])]
  param (
  )
  $RunnerPath = (Resolve-Path -Path ".\functions\process\StdInHostRunner.ps1").Path
  $ParamsFile = ".\servers\$($Server.Name).stdinhost.json"
  $ConsoleLog = ".\servers\$($Server.Name).console.log"
  $ConsolePidFile = ".\servers\$($Server.Name).console.pid"
  $HostPidFile = ".\servers\$($Server.Name).stdinhost.pid"

  #Start each run with a fresh console log so the window shows this run, not the last one,
  #and drop any stale attachment left behind by a previous run.
  $null = Remove-Item -Path $ConsoleLog -Force -ErrorAction SilentlyContinue
  $null = Remove-Item -Path $ConsolePidFile -Force -ErrorAction SilentlyContinue
  $null = Remove-Item -Path $HostPidFile -Force -ErrorAction SilentlyContinue
  $null = New-Item -Path ".\servers\" -Name "$($Server.Name).console.log" -ItemType "file" -Force -ErrorAction SilentlyContinue

  #Parameters are passed via a file instead of the command line to avoid multiple layers
  #of quoting/escaping on the already-quoted Server.Arguments string.
  $HostParams = @{
    Exec             = $Server.Exec
    Arguments        = $Server.Arguments
    WorkingDirectory = $Server.WorkingDirectory
    PipeName         = $Server.PipeName
    LogFile          = (Resolve-Path -Path $ConsoleLog).Path
    #Used when the console window is closed, to stop the server on its behalf.
    ConsolePidFile   = (Join-Path (Resolve-Path -Path ".\servers\").Path "$($Server.Name).console.pid")
    #Lets a console window opened later find this host to attach to.
    HostPidFile      = (Join-Path (Resolve-Path -Path ".\servers\").Path "$($Server.Name).stdinhost.pid")
    StopCommand      = $Warnings.CmdStop
    StopTimeout      = 120
  }
  $HostParams | ConvertTo-Json | Set-Content -Path $ParamsFile -Encoding UTF8

  $Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$RunnerPath`" -ParamsFile `"$((Resolve-Path -Path $ParamsFile).Path)`""
  $HostProcess = Start-ConsoleProcess -FilePath (Get-PowerShellPath) -Arguments $Arguments -Headless

  #Open the visible console window that stands in for the server's own window.
  $null = Start-ServerConsole -WatchPID $HostProcess.Id

  return $HostProcess
}
Export-ModuleMember -Function Start-StdInHost
