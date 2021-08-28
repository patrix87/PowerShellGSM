function Send-RestartWarning {
    [CmdletBinding()]
    [OutputType([boolean])]
    param (
        [Parameter(Mandatory)]
        $ServerProcess
    )
    $Stopped = $false
    $Failed = $false
    while ($Warnings.Timers.Count -gt 0) {
        $Timer = $Warnings.Timers[0]
        $TimeLeft = 0
        $Warnings.Timers | ForEach-Object { $TimeLeft +=  $_}
        $Warnings.Timers.RemoveAt(0)
        if ($TimeLeft -lt 60) {
            $Message = $Warnings.MessageSec
            $TimerText = [string]$TimeLeft
        } else {
            $Message = $Warnings.MessageMin
            $TimerText = [string][Math]::Round($TimeLeft / 60,[MidpointRounding]::AwayFromZero)
        }
        $Message = $Message -replace "%", $TimerText
        $Success = Send-Command -Command $Warnings.CmdMessage -Message $Message
        if ($Success) {
            Write-ServerMsg "Waiting $Timer seconds before next warning..."
            Start-Sleep -Seconds $Timer
        } else {
            Write-Warning "Unable to send restart warning."
            $Failed = $true
            break
        }
    }
    if (-not ($Failed)) {
        if (-not ($null -eq $Warnings.CmdSave)){
            Write-ServerMsg "Saving server."
            $Success = Send-Command -Command $Warnings.CmdSave
            if ($Success) {
                Start-Sleep -Seconds $Warnings.SaveDelay
            } else {
                Write-Warning "Unable to send save command."
            }
        }
        Write-ServerMsg "Closing server."
        $Stopped = Send-Command -Command $Warnings.CmdStop
        Start-Sleep -Seconds 10
        if (-Not ($Stopped)) {
            $Stopped = Stop-Server -ServerProcess $ServerProcess
        }
    }
    return $Stopped
}

Export-ModuleMember -Function Send-RestartWarning