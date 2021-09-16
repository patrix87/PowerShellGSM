function Get-PID {
    [CmdletBinding()]
    [OutputType([Int])]
    param (
    )
    try {
        $ServerPID = Get-Content -Path ".\servers\$($Server.UID).PID" -ErrorAction Continue
    }
    catch {
        return 0
    }
    return $ServerPID
 }
Export-ModuleMember -Function Get-PID