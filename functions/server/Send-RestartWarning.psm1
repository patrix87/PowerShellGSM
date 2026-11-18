function Send-RestartWarning {
  #Warn the players at each of the Warnings.Timers, waiting in between. Returns $false when a message could not be sent.
  [CmdletBinding()]
  [OutputType([boolean])]
  param (
  )
  #Loop until the list of timers is empty
  while ($Warnings.Timers.Count -gt 0) {
    #Select first timer in the list
    $Timer = $Warnings.Timers[0]
    #Set variable
    $TimeLeft = 0
    #Add all timers to find total wait time.
    $Warnings.Timers | ForEach-Object { $TimeLeft += $_ }
    #Remove first timer from the list.
    $Warnings.Timers.RemoveAt(0)
    #if the timer is shorter than 60 seconds show minutes
    if ($TimeLeft -lt 60) {
      #select Seconds message.
      $Message = $Warnings.MessageSec
      $TimerText = [string]$TimeLeft
    }
    else {
      #Calculate minutes and select minutes message.
      $Message = $Warnings.MessageMin
      $TimerText = [string][Math]::Round($TimeLeft / 60, [MidpointRounding]::AwayFromZero)
    }
    #Insert time in messages.
    $Message = $Message -replace "%", $TimerText
    #Send the message, then sleep until the next one.
    if (-not (Send-Command -Command $Warnings.CmdMessage -Message $Message)) {
      Write-Warning "Unable to send restart warning."
      return $false
    }
    Write-ServerMsg "Waiting $Timer seconds before next warning..."
    Start-Sleep -Seconds $Timer
  }
  return $true
}

Export-ModuleMember -Function Send-RestartWarning
