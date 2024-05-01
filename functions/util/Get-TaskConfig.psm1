function Get-TaskConfig {
  Write-ScriptMsg "Getting Tasks Schedule..."
  $OldDate = [datetime]::ParseExact("2000-01-01_00-00-00","yyyy-MM-dd_HH-mm-ss", $null)

  $NextBackup = Get-IniValue -file ".\servers\$($Server.Name).INI" -category "Schedule" -key "NextBackup"
  if([string]::IsNullOrEmpty($NextBackup)) {
    $NextBackup = $OldDate
  } else {
    $NextBackup = [datetime]::ParseExact($NextBackup, $Global.DateTimeFormat, $null)
  }

  $NextAlive = Get-IniValue -file ".\servers\$($Server.Name).INI" -category "Schedule" -key "NextAlive"
  if([string]::IsNullOrEmpty($NextAlive)) {
    $NextAlive = $OldDate
  } else {
    $NextAlive = [datetime]::ParseExact($NextAlive, $Global.DateTimeFormat, $null)
  }

  $NextUpdate = Get-IniValue -file ".\servers\$($Server.Name).INI" -category "Schedule" -key "NextUpdate"
  if([string]::IsNullOrEmpty($NextUpdate)) {
    $NextUpdate = $OldDate
  } else {
    $NextUpdate = [datetime]::ParseExact($NextUpdate, $Global.DateTimeFormat, $null)
  }

  $NextRestart = Get-IniValue -file ".\servers\$($Server.Name).INI" -category "Schedule" -key "NextRestart"
  if([string]::IsNullOrEmpty($NextRestart)) {
    $NextRestart = $OldDate
  } else {
    $NextRestart = [datetime]::ParseExact($NextRestart, $Global.DateTimeFormat, $null)
  }

  return [hashtable] @{
    NextBackup  = $NextBackup;
    NextAlive   = $NextAlive;
    NextUpdate  = $NextUpdate;
    NextRestart = $NextRestart;
  }
}
Export-ModuleMember -Function Get-TaskConfig
