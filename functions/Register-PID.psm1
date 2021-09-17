function Register-PID {
    [CmdletBinding()]
    [OutputType([Bool])]
    param (
        [Parameter(Mandatory)]
        $ServerProcess
    )
    try {
        New-Item -Path ".\servers\" -Name "$($Server.UID).PID" -ItemType "file" -Value "$($ServerProcess.ID)" -Force -ErrorAction Continue
    }
    catch {
        return $false
    }
    return $true
 }
Export-ModuleMember -Function Register-PID