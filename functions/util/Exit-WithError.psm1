function Exit-WithError {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$ErrorMsg
  )
  #Write error in red on black, stop logging, pause, exit.
  Write-Host -ForegroundColor "Red" -BackgroundColor "Black" -Object $ErrorMsg
  $null = Unlock-Process
  $null = Stop-Transcript
  if ($Global.PauseOnErrors) {
    Read-Host "Press Enter to close this window."
  }
  exit
}

Export-ModuleMember -Function Exit-WithError