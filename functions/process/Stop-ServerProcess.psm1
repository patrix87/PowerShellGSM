function Stop-ServerProcess {
  <#
    Stop the server with the graceful methods listed in the template's StopMethods, in order, giving
    each one up to Warnings.SaveDelay seconds. Then, when AllowForceClose is set, kill it.
      Command     : CmdSave (then wait SaveDelay) and CmdStop through the Warnings protocol. Only when
                    the server answers remote commands (-CommandAvailable).
      CtrlC       : Ctrl+C sent to the server's console.
      CloseWindow : close the server's window.
    Templates without StopMethods use Command then CloseWindow.
    Returns 1 when stopped, 0 when still running, -1 when the process is not the server.
  #>
  [CmdletBinding()]
  [OutputType([int])]
  param (
    [Parameter(Mandatory)]
    $ServerProcess,
    [bool]$CommandAvailable = $false
  )
  #Check if process name matches the information from the config.
  if ($ServerProcess.Processname -ne $Server.ProcessName) {
    return -1
  }

  $Methods = @("Command", "CloseWindow")
  if ($Server.StopMethods) {
    $Methods = @($Server.StopMethods)
  }
  $Timeout = 60
  if ($Warnings.SaveDelay) {
    $Timeout = $Warnings.SaveDelay
  }

  foreach ($Method in $Methods) {
    if ($ServerProcess.HasExited) {
      break
    }
    if ($Method -eq "Command") {
      if (-not $CommandAvailable) {
        Write-ServerMsg "Skipping stop method Command: the server does not answer remote commands."
        continue
      }
      if (-not [string]::IsNullOrWhiteSpace($Warnings.CmdSave)) {
        Write-ServerMsg "Saving server."
        if (Send-Command -Command $Warnings.CmdSave) {
          Start-Sleep -Seconds $Warnings.SaveDelay
        }
        else {
          Write-Warning "Unable to send save command."
        }
      }
      Write-ServerMsg "Stopping server with its stop command..."
      if (-not (Send-Command -Command $Warnings.CmdStop)) {
        continue
      }
    }
    elseif ($Method -eq "CtrlC") {
      Write-ServerMsg "Stopping server with Ctrl+C..."
      if (-not (Invoke-ConsoleControl -TargetPid $ServerProcess.Id -CtrlC)) {
        Write-Warning "Unable to send Ctrl+C to the server."
        continue
      }
    }
    elseif ($Method -eq "CloseWindow") {
      Write-ServerMsg "Closing main window..."
      if (-not $ServerProcess.CloseMainWindow()) {
        Write-Warning "The server has no window to close."
        continue
      }
    }
    else {
      Write-Warning "Unknown stop method '$Method', skipping it."
      continue
    }
    $null = $ServerProcess.WaitForExit($Timeout * 1000)
    if ($ServerProcess.HasExited) {
      Write-ServerMsg "Server succesfully stopped ($Method)."
    }
    else {
      Write-Warning "Server still running $Timeout seconds after stop method $Method."
    }
  }

  if ((-not $ServerProcess.HasExited) -and $Server.AllowForceClose) {
    Write-Warning "Forcefully stopping server..."
    $null = Stop-Process -InputObject $ServerProcess -Force
    $null = $ServerProcess.WaitForExit(30000)
  }
  #Safety timer for allowing the files to unlock before backup.
  Start-Sleep -Seconds 10
  if ($ServerProcess.HasExited) {
    return 1
  }
  return 0
}
Export-ModuleMember -Function Stop-ServerProcess
