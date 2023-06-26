function Set-Priority {
  [CmdletBinding()]
  [OutputType([Bool])]
  param (
    [Parameter(Mandatory)]
    $ServerProcess
  )
  try {
    # Set the process priority
    if ($Server.UsePriority) {
      $ServerProcess.PriorityClass = $Server.AppPriority
    }
    # Set the process affinity
    if ($Server.UseAffinity) {
      $ServerProcess.ProcessorAffinity = $Server.AppAffinity
    }
  }
  catch {
    return $false
  }
  return $true
}
Export-ModuleMember -Function Set-Priority