function New-Task {
  #Build a scheduled task running PowerShellGSM's PowerShell with the given arguments, following TaskRunWhileLoggedOff.
  #It runs through "conhost.exe --headless": no window, and the user's default terminal never applies.
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
  $action = New-ScheduledTaskAction -Execute "conhost.exe" -Argument "--headless `"$(Get-PowerShellPath)`" $Arguments" -WorkingDirectory $WorkingDirectory
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
