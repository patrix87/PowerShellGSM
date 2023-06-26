function Send-Command {
  [CmdletBinding()]
  [OutputType([boolean])]
  param (
    [Parameter()]
    $Command,
    $Message = ""
  )

  $Result = $null
  $Success = $false
  #Select Protocol
  switch ($Warnings.Protocol) {
    "Rcon" {
      #send Rcon command.
      $Result = Start-Process $Global.Mcrcon -ArgumentList "-c -H $($Server.ManagementIP) -P $($Server.ManagementPort) -p $($Server.ManagementPassword) `"$Command $Message`"" -Wait -PassThru -NoNewWindow
      if ($Result.ExitCode -eq 0) {
        $Success = $true
      }
    }

    "Telnet" {
      #send Telnet command.
      $Result = Get-Telnet -Command "$Command `"$Message`"" -RemoteHost $Server.ManagementIP -Port $Server.ManagementPort -Password $Server.ManagementPassword
      Write-Host $Result
      if (-not (($Result -like "*Unable to connect to host:*") -or ($Result -like "*incorrect*"))) {
        $Success = $true
      }
    }

    "Websocket" {
      #send Websocket command.
      Write-Warning "Protocol Not Implemented Yet"
      #TODO
    }

    Default {
      Write-Warning "Protocol $($Warnings.Protocol) Not Found"
    }
  }
  if ($Success) {
    Write-ServerMsg "Command Sent."
  }
  else {
    Write-ServerMsg "Failed to send command."
  }
  Return $Success
}

Export-ModuleMember -Function Send-Command