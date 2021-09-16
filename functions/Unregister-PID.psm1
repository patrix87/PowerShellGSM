function Unregister-PID {
    [CmdletBinding()]
    [OutputType([Bool])]
    param (
    )
    try {
        Remove-Item -Path ".\servers\$($Server.UID).PID" -Confirm:$false -ErrorAction Continue
    }
    catch {
        return $false
    }
    return $true
}
Export-ModuleMember -Function Unregister-PID