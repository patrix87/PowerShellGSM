function Get-TaskConfig {
  Write-ScriptMsg "Getting Tasks Schedule..."
  $EmptyDate = (Get-Date).AddYear(-1).ToString($Global.DateTimeFormat)
  $NextAlive = Get-IniValue -file ".\servers\$($Server.Name).INI" -category "Schedule" -key "NextAlive"
  if([string]::IsNullOrEmpty($NextAlive)) $NextAlive = $EmptyDate
  $NextUpdate = Get-IniValue -file ".\servers\$($Server.Name).INI" -category "Schedule" -key "NextUpdate"
  if([string]::IsNullOrEmpty($NextUpdate)) $NextUpdate = $EmptyDate
  $NextRestart = Get-IniValue -file ".\servers\$($Server.Name).INI" -category "Schedule" -key "NextRestart"
  if([string]::IsNullOrEmpty($NextRestart)) $NextRestart = $EmptyDate
  return [hashtable] @{
    NextAlive   = $NextAlive;
    NextUpdate  = $NextUpdate;
    NextRestart = $NextRestart;
  }
}
Export-ModuleMember -Function Get-TaskConfig
