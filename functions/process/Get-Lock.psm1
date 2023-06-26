function Get-Lock {
  [CmdletBinding()]
  [OutputType([boolean])]
  param (
  )
  if ((Test-Path -Path ".\servers\$($Server.Name).LOCK" -PathType "Leaf" -ErrorAction SilentlyContinue)) {
    return $true
  }
  return $false
}
Export-ModuleMember -Function Get-Lock