function Get-TaskConfig {
  Write-ScriptMsg "Getting Tasks Schedule..."
  $NextAlive = Get-IniValue -file ".\servers\$($Server.Name).INI" -category "Schedule" -key "NextAlive"
  $NextUpdate = Get-IniValue -file ".\servers\$($Server.Name).INI" -category "Schedule" -key "NextUpdate"
  $NextRestart = Get-IniValue -file ".\servers\$($Server.Name).INI" -category "Schedule" -key "NextRestart"
  return [hashtable] @{
    NextAlive   = $NextAlive;
    NextUpdate  = $NextUpdate;
    NextRestart = $NextRestart;
  }
}
Export-ModuleMember -Function Get-TaskConfig