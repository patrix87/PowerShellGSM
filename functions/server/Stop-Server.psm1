function Stop-Server {
  $ServerProcess = Get-ServerProcess
  #Check if the process was found.
  if (-not ($ServerProcess)) {
    Write-ServerMsg "Server is not running."
  }
  else {
    #Check if the server answers remote commands, and warn the players before stopping it.
    $CommandAvailable = $false
    if ($Warnings.Use) {
      <#
      Liveness probe. "help" exists on most RCON and Telnet servers, but an API
      based protocol has no such command, so a template can name its own harmless
      read only command with Warnings.CmdCheck.
      #>
      $CmdCheck = if ($Warnings.CmdCheck) { $Warnings.CmdCheck } else { "help" }
      $CommandAvailable = Send-Command -Command $CmdCheck
      if ($CommandAvailable) {
        Write-ServerMsg "Server is responding to remote messages."
        Write-ServerMsg "Server is running, warning users about upcomming restart."
        $CommandAvailable = Send-RestartWarning
      }
      else {
        Write-ServerMsg "Server is not responding to remote messages."
      }
    }
    Write-ServerMsg "Server is running, stopping server."
    $Stopped = Stop-ServerProcess -ServerProcess $ServerProcess -CommandAvailable $CommandAvailable
    #If the server stopped, send messages, if not check if it's normal, then stopped it, if it fails, exit with error.
    switch ($Stopped) {
      -1 {
        Write-ServerMsg "Server not found. Unregistering PID"
      }
      0 {
        if ($Server.AllowForceClose) {
          Exit-WithError "Failed to stop server."
        }
        else {
          Write-ServerMsg "Server not stopped."
        }
      }
      1 {
        Write-ServerMsg "Server stopped."
      }
      Default {
        Write-ServerMsg "Server state unknown."
      }
    }
  }
  #Unregister the PID
  if ($Server.UsePID) {
    if (-not $(Unregister-PID)) {
      Write-ServerMsg "Failed to remove PID file."
    }
  }
}
Export-ModuleMember -Function Stop-Server