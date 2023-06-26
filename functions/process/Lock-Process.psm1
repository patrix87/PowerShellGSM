function Lock-Process {
  [CmdletBinding()]
  [OutputType([boolean])]
  param (
  )
  try {
    $null = New-Item -Path ".\servers\" -Name "$($Server.Name).LOCK" -ItemType "file" -Force -ErrorAction SilentlyContinue
    Write-ScriptMsg "Process Locked."
  }
  catch {
    return $false
  }
  return $true
}
Export-ModuleMember -Function Lock-Process