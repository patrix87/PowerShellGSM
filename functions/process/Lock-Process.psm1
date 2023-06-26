function Lock-Process {
  [CmdletBinding()]
  [OutputType([boolean])]
  param (
  )
  try {
    $null = New-Item -Path ".\servers\" -Name "$($Server.Name).LOCK" -ItemType "file" -Force -ErrorAction SilentlyContinue
    Set-IniValue -file ".\servers\$($Server.Name).LOCK" -category "Lock" -key "TimeStamp" -value (Get-Date)
    Write-ScriptMsg "Locking Process."
  }
  catch {
    return $false
  }
  return $true
}
Export-ModuleMember -Function Lock-Process