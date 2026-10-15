function Unregister-UpdateTask {
  $null = Unregister-ScheduledTask -TaskName "PowerShellGSM-Update" -Confirm:$false
}
Export-ModuleMember -Function Unregister-UpdateTask
