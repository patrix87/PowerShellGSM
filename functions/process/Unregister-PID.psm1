function Unregister-PID {
    [CmdletBinding()]
    [OutputType([Bool])]
    param (
    )
    try {
        #Delete the PID file based on the Server UID.
        $null = Remove-Item -Path ".\servers\$($Server.Name).PID" -Confirm:$false -ErrorAction SilentlyContinue
    }
    catch {
        return $false
    }
    return $true
}
Export-ModuleMember -Function Unregister-PID