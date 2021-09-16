function Set-Priority {
    [CmdletBinding()]
    [OutputType([Bool])]
    param (
        [Parameter(Mandatory)]
        $ServerProcess
    )
    try {
        # Set the priority and affinity
        if ($Server.UsePriority) {
            $ServerProcess.PriorityClass = $Server.AppPriority
        }
        if ($Server.UseAffinity){
            $ServerProcess.ProcessorAffinity = $Server.AppAffinity
        }
    }
    catch {
        return $false
    }
    return $true
 }
Export-ModuleMember -Function Set-Priority