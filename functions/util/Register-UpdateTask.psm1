function Register-UpdateTask {
  $arguments = "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$dir\update.ps1`""
  $trigger = New-ScheduledTaskTrigger -Once -At 12am -RepetitionInterval (New-TimeSpan -Hours $Global.ToolUpdateFrequency)
  $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 1)
  $description = "Update PowerShellGSM"
  $title = "PowerShellGSM-Update"
  $task = New-Task -Description $description -Arguments $arguments -WorkingDirectory $dir -Trigger $trigger -Settings $settings
  $null = Register-ScheduledTask $title -InputObject $task
}
Export-ModuleMember -Function Register-UpdateTask
