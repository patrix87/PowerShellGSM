function Register-Task {
  $arguments = "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$scriptpath`" -ServerCfg `"$ServerCfg`" -Task"
  $trigger = New-ScheduledTaskTrigger -Daily -At 12am
  $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 3)
  $description = "Run Tasks for $($server.Name)"
  $title = "Tasks-$($server.Name)"
  $task = New-Task -Description $description -Arguments $arguments -WorkingDirectory $dir -Trigger $trigger -Settings $settings
  $RegisteredTask = Register-ScheduledTask $title -InputObject $task
  $RegisteredTask.Triggers.Repetition.Duration = "P1D" #Repeat for a duration of one day
  $RegisteredTask.Triggers.Repetition.Interval = "PT$($Global.TaskCheckFrequency)M" #Repeat every X minutes, use PT1H for every hour
  $null = Set-ScheduledTask $RegisteredTask
}
Export-ModuleMember -Function Register-Task
