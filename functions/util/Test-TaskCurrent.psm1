function Test-TaskCurrent {
  #True when the registered task already runs the same action, with the same logon type, at the same interval.
  [CmdletBinding()]
  [OutputType([bool])]
  param (
    [Parameter(Mandatory)]
    [string]$TaskName,
    #The task as New-Task builds it from the current settings.
    [Parameter(Mandatory)]
    $Task,
    [Parameter(Mandatory)]
    [timespan]$Interval
  )
  $Registered = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
  if (-not $Registered) {
    return $false
  }
  $Want = $Task.Actions[0]
  $Have = $Registered.Actions[0]
  if (($Have.Execute -ne $Want.Execute) -or ($Have.Arguments -ne $Want.Arguments) -or ($Have.WorkingDirectory -ne $Want.WorkingDirectory)) {
    return $false
  }
  $WantS4U = [bool]$Global.TaskRunWhileLoggedOff
  if (("$($Registered.Principal.LogonType)" -eq "S4U") -ne $WantS4U) {
    return $false
  }
  $HaveInterval = $Registered.Triggers[0].Repetition.Interval
  if ([string]::IsNullOrEmpty($HaveInterval) -or ([System.Xml.XmlConvert]::ToTimeSpan($HaveInterval) -ne $Interval)) {
    return $false
  }
  return $true
}
Export-ModuleMember -Function Test-TaskCurrent
