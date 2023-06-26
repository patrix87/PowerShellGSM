function Stop-ServerProcess {
  [CmdletBinding()]
  [OutputType([int])]
  param (
    [Parameter(Mandatory)]
    $ServerProcess
  )
  #if the server is still running

  #Check if process name matches the information from the config.
  if ($ServerProcess.Processname -ne $Server.ProcessName) {
    return -1
  }

  Write-ServerMsg "Closing main window..."
  #Close the main windows.
  $null = $ServerProcess.CloseMainWindow()
  #Wait for exit for at most 30 seconds.
  $null = $ServerProcess.WaitForExit($Warnings.SaveDelay * 1000)
  #if the process exited send success message
  if ($ServerProcess.HasExited) {
    Write-ServerMsg "Server succesfully stopped."
  }
  else {
    Write-Warning "Trying again to stop the server..."
    #else try to stop server with stop-process.
    $null = Stop-Process $ServerProcess
    #Wait for exit for at most 30 seconds.
    $null = $ServerProcess.WaitForExit($Warnings.SaveDelay * 1000)
    #If process is still running, force stop-process.
    if ($null -eq (Get-Process -ID ($ServerProcess.Id) -ErrorAction SilentlyContinue)) {
      Write-Warning "Server succesfully stopped on second try."
    }
    else {
      Write-Warning "Forcefully stopping server..."
      $null = Stop-Process $ServerProcess -Force
    }
  }
  #Safety timer for allowing the files to unlock before backup.
  Start-Sleep -Seconds 10
  if ($ServerProcess.HasExited) {
    return 1
  }
  else {
    return 0
  }
}
Export-ModuleMember -Function Stop-ServerProcess