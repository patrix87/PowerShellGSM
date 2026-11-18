function Register-Task {
  #Register the server's scheduled task, or register it again when it no longer matches the current settings.
  $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptpath`" -ServerCfg `"$ServerCfg`" -Task"
  $interval = New-TimeSpan -Minutes $Global.TaskCheckFrequency
  $trigger = New-ScheduledTaskTrigger -Daily -At 12am
  $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 3)
  $description = "Run Tasks for $($server.Name)"
  $title = "Tasks-$($server.Name)"
  $task = New-Task -Description $description -Arguments $arguments -WorkingDirectory $dir -Trigger $trigger -Settings $settings
  if (Test-TaskCurrent -TaskName $title -Task $task -Interval $interval) {
    return
  }
  Write-ScriptMsg "Registering Scheduled Task $title..."
  $RegisteredTask = Register-ScheduledTask $title -InputObject $task -Force
  $RegisteredTask.Triggers.Repetition.Duration = "P1D" #Repeat for a duration of one day
  $RegisteredTask.Triggers.Repetition.Interval = [System.Xml.XmlConvert]::ToString($interval) #Repeat every TaskCheckFrequency minutes
  $null = Set-ScheduledTask $RegisteredTask
}
Export-ModuleMember -Function Register-Task
