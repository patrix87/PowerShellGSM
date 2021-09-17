function Get-PID {
    [CmdletBinding()]
    [OutputType([Int])]
    param (
    )
    try {
        #Read the process ID from the PID file named by the UID defined in the server cfg file.
        $ServerPID = Get-Content -Path ".\servers\$($Server.UID).PID" -ErrorAction Continue
    }
    catch {
        return 0
    }
    return $ServerPID
 }
Export-ModuleMember -Function Get-PID