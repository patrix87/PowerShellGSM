function Unlock-Process {
    [CmdletBinding()]
    [OutputType([boolean])]
    param (
    )
    try {
        #Delete the LOCK file based on the Server UID.
        $null = Remove-Item -Path ".\servers\$($Server.UID).LOCK" -Confirm:$false -ErrorAction SilentlyContinue
		Write-ScriptMsg "Process Unlocked."
    }
    catch {
        return $false
    }
    return $true
}
Export-ModuleMember -Function Unlock-Process