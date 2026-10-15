function Write-ScriptMsg {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$Message
  )
  #Write script message with the colors defined in defaults.psm1
  Write-Host -ForegroundColor $Global.SectionColor -BackgroundColor $Global.SectionBgColor -Object $Message
}

Export-ModuleMember -Function Write-ScriptMsg