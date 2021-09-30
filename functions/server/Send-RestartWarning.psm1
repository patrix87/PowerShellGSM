function Send-RestartWarning {
    [CmdletBinding()]
    [OutputType([boolean])]
    param (
        [Parameter(Mandatory)]
        $ServerProcess
    )
    $Stopped = 0
    $Failed = $false
    #Loop until the list of timers is empty
    while ($Warnings.Timers.Count -gt 0) {
        #Select first timer in the list
        $Timer = $Warnings.Timers[0]
        #Set variable
        $TimeLeft = 0
        #Add all timers to find total wait time.
        $Warnings.Timers | ForEach-Object { $TimeLeft +=  $_}
        #Remove first timer from the list.
        $Warnings.Timers.RemoveAt(0)
        #if the timer is shorter than 60 seconds show minutes
        if ($TimeLeft -lt 60) {
            #select Seconds message.
            $Message = $Warnings.MessageSec
            $TimerText = [string]$TimeLeft
        } else {
            #Calculate minutes and select minutes message.
            $Message = $Warnings.MessageMin
            $TimerText = [string][Math]::Round($TimeLeft / 60,[MidpointRounding]::AwayFromZero)
        }
        #Insert time in messages.
        $Message = $Message -replace "%", $TimerText
        #Send the message.
        $Success = Send-Command -Command $Warnings.CmdMessage -Message $Message
        #If the command succeed, sleep until next command, else break.
        if ($Success) {
            Write-ServerMsg "Waiting $Timer seconds before next warning..."
            Start-Sleep -Seconds $Timer
        } else {
            Write-Warning "Unable to send restart warning."
            $Failed = $true
            break
        }
    }
    #If warning messages commands succeeded, send save cmd and wait safety timer.
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
        #Send server stop command and wait for the process to exit for at most 60 seconds.
        Write-ServerMsg "Closing server."
        if (Send-Command -Command $Warnings.CmdStop) {
            $Stopped = 1
        } else {
            $Stopped = 0
        }
        $ServerProcess.WaitForExit(30000)
        Start-Sleep -Seconds 5
    }
    #if the process is still running, if allowed, stop process.
    if(-not ($ServerProcess.HasExited) -and ($Server.AllowForceClose)){
        $Stopped = Stop-ServerProcess -ServerProcess $ServerProcess
    }
    return $Stopped
}

Export-ModuleMember -Function Send-RestartWarning