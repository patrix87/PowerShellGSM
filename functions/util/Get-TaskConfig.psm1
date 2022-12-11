function Get-TaskConfig {
    Write-ScriptMsg "Getting Tasks Schedule..."
	$NextAlive = Get-IniValue -file ".\servers\$($Server.UID).INI" -key "NextAlive"
	$NextUpdate = Get-IniValue -file ".\servers\$($Server.UID).INI" -key "NextUpdate"
	$NextRestart = Get-IniValue -file ".\servers\$($Server.UID).INI" -key "NextRestart"
	return {
		NextAlive: $NextAlive,
		NextUpdate: $NextUpdate,
		NextRestart: $NextRestart
	}
 }
Export-ModuleMember -Function Get-TaskConfig