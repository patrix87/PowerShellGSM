function Unregister-Task {
    $title = "Tasks-$($server.Name)"
	$null = Unregister-ScheduledTask -TaskName $title -Confirm:$false
	$null = Remove-TaskConfig
}
Export-ModuleMember -Function Unregister-Task