function Unregister-UpdateTask {
    $title = "Tasks-$($server.UID)"
	$null = Unregister-ScheduledTask -TaskName $title -Confirm:$false -ErrorAction SilentlyContinue
	Remove-TaskConfig
}
Export-ModuleMember -Function Unregister-UpdateTask