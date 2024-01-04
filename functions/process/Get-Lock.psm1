function Get-Lock {
  [CmdletBinding()]
  [OutputType([boolean])]
  param (
  )
  if ($Global.Debug){
    Write-ScriptMsg "Debug Mode, skipping Lock check..."
    return $false
  }
  if ((Test-Path -Path ".\servers\$($Server.Name).LOCK" -PathType "Leaf" -ErrorAction SilentlyContinue)) {
    $TimeStamp = [datetime]::ParseExact((Get-IniValue -file ".\servers\$($Server.Name).LOCK" -category "Lock" -key "TimeStamp"), $Global.DateTimeFormat, $null)
    if ($TimeStamp -lt (Get-Date).AddMinutes(-$Global.LockTimeout)) {
      Write-ScriptMsg "Process Lock is too old, removing..."
      $null = Remove-Item -Path ".\servers\$($Server.Name).LOCK" -Force -ErrorAction SilentlyContinue
      return $false
    }
    return $true
  }
  return $false
}
Export-ModuleMember -Function Get-Lock