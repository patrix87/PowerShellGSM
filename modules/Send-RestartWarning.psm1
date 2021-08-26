function Send-Command {
    [CmdletBinding()]
    [OutputType([boolean])]
    param (
        [Parameter(Mandatory)]
        [string]$Mcrcon,
        [string]$RconIP,
        [int32]$RconPort,
        [string]$RconPassword,
        [string]$Command
    )
    $Task=Start-Process $Mcrcon -ArgumentList "-c -H $RconIP -P $RconPort -p $RconPassword `"$Command`"" -Wait -PassThru -NoNewWindow
    if ($Task.ExitCode -eq 0) {
        Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Command Sent."
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
        [string]$RconPassword,
        [System.Collections.ArrayList]$RestartTimers,
        [string]$RestartMessageMinutes,
        [string]$RestartMessageSeconds,
        [string]$MessageCmd,
        [string]$ServerStopCmd
    )
    $Server=Get-Process $ProcessName -ErrorAction SilentlyContinue
    $exited=$false
    while ($RestartTimers.Count -gt 0) {
        $Timer=$RestartTimers[0]
        if (!$server -or $Server.HasExited) {
            $exited=$true
            break
        }
        Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Server is running, warning users about upcomming restart."
        $TimeLeft=0
        $RestartTimers | ForEach-Object { $TimeLeft += $_}
        $RestartTimers.RemoveAt(0)
        if ($TimeLeft -lt 60) {
            $Message=$RestartMessageSeconds
            $TimerText=[string]$TimeLeft
        } else {
            $Message=$RestartMessageMinutes
            $TimerText=[string][Math]::Round($TimeLeft / 60,[MidpointRounding]::AwayFromZero)
        }
        $Message=$Message -replace "%", $TimerText
        $Command="$MessageCmd $Message"
        $Success=Send-Command -Mcrcon $Mcrcon -RconIP $RconIP -RconPort $RconPort -RconPassword $RconPassword -Command $Command
        if ($Success) {
            Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Waiting $Timer seconds before next warning..."
            Start-Sleep -Seconds $Timer
        } else {
            Write-Warning "Unable to send server reboot warning."
            break
        }
    }
    foreach ($Timer in $RestartTimers) {

    }
    if (!$exited){
        Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Closing server."
        $Success=Send-Command -Mcrcon $Mcrcon -RconIP $RconIP -RconPort $RconPort -RconPassword $RconPassword -Command $ServerStopCmd
        if ($Success) {
            Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Server closed."
            Start-Sleep -Seconds 10
        } else {
            Write-Warning "Unable to send server stop command."
            $Stopped=Stop-Server -Server $Server
            if ($Stopped) {
                Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Server closed."
            } else {
                Exit-WithError -ErrorMsg "Unable to stop server."
            }
        }

    }
}

Export-ModuleMember -Function Send-RestartWarning