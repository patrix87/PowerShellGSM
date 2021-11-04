function Register-UpdateTask {
    $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File $scriptpath -ServerCfg `"$ServerCfg`" -UpdateCheck" -WorkingDirectory $dir
    $trigger = New-ScheduledTaskTrigger -Daily -At 12am
    $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 10)
    $description = "Check if updates are available for $($server.Name)"
    $title = "UpdateCheck-$($server.Name)"
    $task = New-ScheduledTask -Description $description -Action $action -Trigger $trigger -Settings $settings
    $RegisteredTask = Register-ScheduledTask $title -InputObject $task
    $RegisteredTask.Triggers.Repetition.Duration = "P1D" #Repeat for a duration of one day
    $RegisteredTask.Triggers.Repetition.Interval = "PT$($Global.UpdateCheckFrequency)M" #Repeat every 30 minutes, use PT1H for every hour
    $null = Set-ScheduledTask $RegisteredTask
}
Export-ModuleMember -Function Register-UpdateTask