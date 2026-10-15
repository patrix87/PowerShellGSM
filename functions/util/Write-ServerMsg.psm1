function Write-ServerMsg {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$Message
  )
  #Write server message with the colors defined in defaults.psm1
  Write-Host -ForegroundColor $Global.FGColor -BackgroundColor $Global.BgColor -Object $Message
}

Export-ModuleMember -Function Write-ServerMsg