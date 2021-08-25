#---------------------------------------------------------
#General Functions
#---------------------------------------------------------
Function Get-TimeStamp {
    return Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
}

function Exit-WithCode
{
    param
    (
		[string]$ErrorMsg,
		$ErrorObj,
        [int32]$ExitCode
    )
    $ErrorObj = ($ErrorObj | ConvertTo-Json)
	Write-Error $ErrorMsg
	Write-Error $ErrorObj
	Stop-Transcript
	Read-Host
    $Host.SetShouldExit($Exitcode)
    exit
}

function Remove-OldLog {
    [CmdletBinding()]
    param (
        [string]$LogFolder,
        [int32]$Days=30
    )
    #Delete old logs
    Write-Output "Deleting logs older than 30 days"
    $Limit=(Get-Date).AddDays(-$Days)
    Get-ChildItem -Path $LogFolder -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $Limit } | Remove-Item -Force
}

Export-ModuleMember -Function Get-TimeStamp, Exit-WithCode, Remove-OldLog