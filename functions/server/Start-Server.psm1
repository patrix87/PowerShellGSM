function Start-Server {
  try {
    Write-ScriptMsg "Starting Server Preparation..."
    Start-ServerPrep
  }
  catch {
    Write-Error $_
    Exit-WithError -ErrorMsg "Unable to complete the server preparation."
  }
  try {
    Write-ScriptMsg "Starting Server..."
    #Create a Timestamp
    $timestamp = Get-TimeStamp
    Add-Member -InputObject $Server -Name "StartTime" -Type NoteProperty -Value $timestamp
    if ($Warnings.Use -and $Warnings.Protocol -eq "StdIn") {
      Write-ServerMsg "Starting Server $($Server.Launcher) via StdIn host with Arguments: $($Server.Arguments)"
      $ServerProcess = Start-StdInHost
    }
    else {
      if ($Server.Arguments.length -gt 0) {
        Write-ServerMsg "Starting Server $($Server.Launcher) with Arguments: $($Server.Arguments)"
      }
      else {
        Write-ServerMsg "Starting Server $($Server.Launcher) with no Arguments."
      }
      $ServerProcess = Start-ConsoleProcess -FilePath $Server.Launcher -Arguments $Server.Arguments -WorkingDirectory $Server.WorkingDirectory -Title $Server.Name
    }
    #Wait to see if the server is stable.
    Start-Sleep -Seconds $Server.StartupWaitTime
    if (($null -eq $ServerProcess) -or ($ServerProcess.HasExited)) {
      Exit-WithError "Server Failed to launch."
    }
    else {
      Write-ServerMsg "Server Started."
    }
    $ServerProcess = Register-PID -ServerProcess $ServerProcess
    if (-not $ServerProcess) {
      Write-ServerMsg "Failed to Register PID file."
    }
    else {
      $null = Set-Priority -ServerProcess $ServerProcess
    }
    $null = Register-TaskConfig
  }
  catch {
    Write-Error $_
    Exit-WithError -ErrorMsg "Unable to start server."
  }
}
Export-ModuleMember -Function Start-Server