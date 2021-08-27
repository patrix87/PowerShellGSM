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
        return $true
    } else {
        Write-Warning "Unable to send command"
        return $false
    }
}

function Send-TelnetCommand {
    [CmdletBinding()]
    [OutputType([boolean])]
    param (
        [Parameter(Mandatory)]
        [string]$RconIP,
        [int32]$RconPort,
        [string]$RconPassword,
        [string]$Command
    )
    $Result=Get-Telnet -Command $Command -RemoteHost $RconIP -Port $RconPort -Password $RconPassword
    Write-Host $Result
    if (($Result -like "*Unable to connect to host:*") -or ($Result -like "*incorrect*")) {
        Write-Warning "Unable to send command."
        return $false
    } else {
        Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Command Sent."
        return $true
    }
}

function Send-RestartWarning {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ProcessName,
        [string]$Mcrcon,
        [string]$RconIP,
        [int32]$RconPort,
        [string]$RconPassword,
        [System.Collections.ArrayList]$RestartTimers,
        [string]$RestartMessageMinutes,
        [string]$RestartMessageSeconds,
        [string]$MessageCmd,
        [string]$ServerStopCmd,
        [Parameter(Mandatory=$false)]
        [string]$ServerSaveCmd=$null,
        [string]$protocol="RCON"
    )
    $Server=Get-Process $ProcessName -ErrorAction SilentlyContinue
    $exited=$false
    while ($RestartTimers.Count -gt 0) {
        $Timer=$RestartTimers[0]
        if (!$server -or $Server.HasExited) {
            $exited=$true
            Write-Warning "Server is not running."
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
        if ($protocol -eq "RCON"){
            $Command="$MessageCmd $Message"
            $Success=Send-Command -Mcrcon $Mcrcon -RconIP $RconIP -RconPort $RconPort -RconPassword $RconPassword -Command $Command
        }
        if ($protocol -eq "Telnet"){
            $Command="$MessageCmd `"$Message`""
            $Success=Send-TelnetCommand -RconIP $RconIP -RconPort $RconPort -RconPassword $RconPassword -Command $Command
        }
        if ($Success) {
            Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Waiting $Timer seconds before next warning..."
            Start-Sleep -Seconds $Timer
        } else {
            Write-Warning "Unable to send server reboot warning."
            break
        }
    }
    if (!$exited){
        if (-not ($ServerSaveCmd -eq $null)){
            Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Saving server."
            if ($protocol -eq "RCON"){
                $Success=Send-Command -Mcrcon $Mcrcon -RconIP $RconIP -RconPort $RconPort -RconPassword $RconPassword -Command $ServerSaveCmd
            }
            if ($protocol -eq "Telnet"){
                $Success=Send-TelnetCommand -RconIP $RconIP -RconPort $RconPort -RconPassword $RconPassword -Command $ServerSaveCmd
            }
            if ($Success) {
                Start-Sleep -Seconds 5
            } else {
                Write-Warning "Unable to send server save command."
            }
        }
        Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Closing server."
        if ($protocol -eq "RCON"){
            $Success=Send-Command -Mcrcon $Mcrcon -RconIP $RconIP -RconPort $RconPort -RconPassword $RconPassword -Command $ServerStopCmd
        }
        if ($protocol -eq "Telnet"){
            $Success=Send-TelnetCommand -RconIP $RconIP -RconPort $RconPort -RconPassword $RconPassword -Command $ServerStopCmd
        }
        if ($Success) {
            Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Server closed."
            Start-Sleep -Seconds 5
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