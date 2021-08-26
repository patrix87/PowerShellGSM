Function Get-TimeStamp {
    return Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
}

function Exit-WithError
{
    param
    (
        [string]$ErrorMsg
    )
    Write-Host -ForegroundColor "Red" -BackgroundColor "Black" -Object $ErrorMsg
    Stop-Transcript
    Read-Host
    exit
}

function Remove-OldLog {
    [CmdletBinding()]
    param (
        [string]$LogFolder,
        [int32]$Days=30
    )
    #Delete old logs
    Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Deleting logs older than $Days days."
    $Limit=(Get-Date).AddDays(-$Days)
    Get-ChildItem -Path $LogFolder -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $Limit } | Remove-Item -Force
}

Export-ModuleMember -Function Get-TimeStamp, Exit-WithError, Remove-OldLog