function Register-UpdateTask {
  #Register the PowerShellGSM-Update task, or register it again when it no longer matches the current settings.
  $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$dir\update.ps1`""
  $interval = New-TimeSpan -Hours $Global.ToolUpdateFrequency
  $trigger = New-ScheduledTaskTrigger -Once -At 12am -RepetitionInterval $interval
  $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 1)
  $description = "Update PowerShellGSM"
  $title = "PowerShellGSM-Update"
  $task = New-Task -Description $description -Arguments $arguments -WorkingDirectory $dir -Trigger $trigger -Settings $settings
  if (Test-TaskCurrent -TaskName $title -Task $task -Interval $interval) {
    return
  }
  Write-ScriptMsg "Registering PowerShellGSM Update Task..."
  $null = Register-ScheduledTask $title -InputObject $task -Force
}
Export-ModuleMember -Function Register-UpdateTask
