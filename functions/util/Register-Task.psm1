function Register-Task {
  $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File $scriptpath -ServerCfg `"$ServerCfg`" -Task" -WorkingDirectory $dir
  $trigger = New-ScheduledTaskTrigger -Daily -At 12am -RandomDelay (New-TimeSpan -Minutes $Global.TaskCheckFrequency) -RepetitionInterval (New-TimeSpan -Minutes $Global.TaskCheckFrequency) -RepetitionDuration (New-TimeSpan -Hours 23 -Minutes 55)
  $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 10)
  $description = "Run Tasks for $($server.Name)"
  $title = "Tasks-$($server.Name)"
  $task = New-ScheduledTask -Description $description -Action $action -Trigger $trigger -Settings $settings
  $RegisteredTask = Register-ScheduledTask $title -InputObject $task
  $null = Set-ScheduledTask $RegisteredTask
}
Export-ModuleMember -Function Register-Task
