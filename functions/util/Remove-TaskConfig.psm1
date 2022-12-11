function Remove-TaskConfig {
    [CmdletBinding()]
    [OutputType([boolean])]
    param (
    )
    try {
        #Delete the INI file based on the Server UID.
        $null = Remove-Item -Path ".\servers\$($Server.UID).INI" -Confirm:$false -ErrorAction SilentlyContinue
		Write-ScriptMsg "Task Config Removed."
    }
    catch {
        return $false
    }
    return $true
}
Export-ModuleMember -Function Remove-TaskConfig