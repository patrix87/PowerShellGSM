#Copy this file to override.psm1 and keep only the settings you want to change from defaults.psm1.
#override.psm1 is not tracked by git, so PowerShellGSM updates never overwrite it.

$OverrideDetails = @{
  #AutoUpdateTool        = $false
  #TaskRunWhileLoggedOff = $true
  #TaskHeadless          = $true
  #StopAfterFreshInstall = $false
}

Export-ModuleMember -Variable "OverrideDetails"
