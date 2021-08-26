function Send-Command {
    [CmdletBinding()]
    [OutputType([boolean])]
    param (
        [Parameter(Mandatory)]
        [string]$Mcrcon,
        [string]$RconIP,
        [int32]$RconPort,
        [securestring]$RconPassword,
        [string]$Command
    )
    $Task=Start-Process $Mcrcon -ArgumentList "-c -H $RconIP -P $RconPort -p $RconPassword `"$Command`"" -Wait -PassThru -NoNewWindow
    if ($Task.ExitCode -eq 0) {
        Write-Verbose "Command Sent"
        return $True
    } else {
        Write-Warning "Unable to send command"
        return $False
    }
}

function Send-RestartWarning {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ProcessName,
        [string]$Mcrcon,
        [string]$RconIP,
        [int32]$RconPort,
        [securestring]$RconPassword,
        [array]$RestartTimers,
        [string]$RestartMessageMinutes,
        [string]$RestartMessageSeconds,
        [string]$MessageCmd,
        [string]$ServerStopCmd
    )
    $Server=Get-Process $ProcessName -ErrorAction SilentlyContinue
    $exited = $false
    foreach ($Timer in $RestartTimers) {
        if (!$server -or $Server.HasExited) {
            $exited = $true
            break
        }
        Write-Verbose "Server is running... Warning users about upcomming restart..."
        if ($Timer -lt 60) {
            $Message = $RestartMessageSeconds
        } else {
            $Message = $RestartMessageMinutes
            $TimerText = [string][Math]::Round($Timer / 60,[MidpointRounding]::AwayFromZero)
        }
        $Message -replace "%", $TimerText
        $Command = "$MessageCmd $Message"
        $Success = Send-Command -Mcrcon $Mcrcon -RconIP $RconIP -RconPort $RconPort -RconPassword $RconPassword -Command $Command
        if ($Success) {
            Write-Verbose "Waiting $Timer seconds..."
            Start-Sleep $Timer
        } else {
            Write-Warning "Unable to send server reboot warning."
            Write-Warning "Stopping now."
            Stop-Server -Server $Server
            $exited = $true
            break
        }
    }
    if (!$exited){
        $Success = Send-Command -Mcrcon $Mcrcon -RconIP $RconIP -RconPort $RconPort -RconPassword $RconPassword -Command $ServerStopCmd
        if ($Success) {
            Write-Verbose "Server closed"
            Start-Sleep 5
        } else {
            Write-Warning "Unable to send server stop command."
            Write-Warning "Stopping now."
            try {
                Stop-Server -Server $Server
            }
            catch {
                Exit-WithCode -ErrorMsg "Unable to stop server." -ErrorObj " " -ExitCode 500
            }
        }

    }
}

Export-ModuleMember -Function Send-RestartWarning -Verbose:$false