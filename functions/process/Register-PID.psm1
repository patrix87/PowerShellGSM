function Register-PID {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    $ServerProcess
  )
  Write-ScriptMsg "Registering Process..."
  # How long to check for correct process
  $Timeout = New-TimeSpan -Seconds 30
  $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
  # Check if Process is the correct process
  $WrongProcess = $true
  while ($WrongProcess -and $Stopwatch.elapsed -lt $Timeout) {
    #if true, the process is the original process
    #if false, the original process exited or is not the final process.
    if ($ServerProcess.ProcessName -eq $Server.ProcessName) {
      $WrongProcess = $false
    }
    else {
      # Try to find the correct process.
      # Get a process list of all the process name are equal to  $Server.ProcessName where the StartTime is higher than $Server.StartTime
      $CorrectProcess = Get-Process -Name $Server.ProcessName |
      Where-Object -Property StartTime -gt -Value $Server.StartTime
      if ($CorrectProcess) {
        $ServerProcess = $CorrectProcess
        $WrongProcess = $false
      }
    }
  }
  # Could not find the correct process
  if ($WrongProcess) {
    return $null
  }
  $stopwatch.Stop()
  try {
    $null = New-Item -Path ".\servers\" -Name "$($Server.Name).PID" -ItemType "file" -Value "$($ServerProcess.ID)" -Force -ErrorAction SilentlyContinue
    Write-ScriptMsg "Process Registered."
  }
  catch {
    return $null
  }
  return $ServerProcess
}
Export-ModuleMember -Function Register-PID