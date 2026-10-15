# Update PowerShellGSM to the latest version of its upstream branch.
# Run by the PowerShellGSM-Update scheduled task when AutoUpdateTool is enabled.
# Local changes to tracked files are overwritten. Ignored files (configs, launchers, servers, backups, logs) are kept.

Set-Location -Path $PSScriptRoot
git fetch
git reset --hard "@{u}"
