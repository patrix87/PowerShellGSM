function New-Task {
  #Build a scheduled task running PowerShell with the given arguments, following TaskHeadless and TaskRunWhileLoggedOff.
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$Description,
    [Parameter(Mandatory)]
    [string]$Arguments,
    [Parameter(Mandatory)]
    [string]$WorkingDirectory,
    [Parameter(Mandatory)]
    $Trigger,
    [Parameter(Mandatory)]
    $Settings
  )
  if ($Global.TaskHeadless) {
    $action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless Powershell.exe $Arguments" -WorkingDirectory $WorkingDirectory
  }
  else {
    $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument $Arguments -WorkingDirectory $WorkingDirectory
  }
  $TaskParams = @{
    Description = $Description
    Action      = $action
    Trigger     = $Trigger
    Settings    = $Settings
  }
  if ($Global.TaskRunWhileLoggedOff) {
    #S4U runs the task whether the user is logged on or not, without storing a password.
    $TaskParams.Principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType S4U
  }
  return New-ScheduledTask @TaskParams
}
Export-ModuleMember -Function New-Task
