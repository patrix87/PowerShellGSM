function Get-PowerShellPath {
  [CmdletBinding()]
  [OutputType([string])]
  param (
  )
  #The PowerShell executable PowerShellGSM runs on. Every PowerShell process it starts uses this one.
  return (Get-Process -Id $PID).Path
}
Export-ModuleMember -Function Get-PowerShellPath
