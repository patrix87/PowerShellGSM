function Send-RestartWarning {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ProcessName,
        [string]$Mcrcon,
        [string]$RconIP,
        [int32]$RconPort,
        [securestring]$RconPassword
    )
    Write-Output "Checking if server is running"
    $Server=Get-Process $ProcessName -ErrorAction SilentlyContinue
    if ($Server) {
        Write-Output "Server is running... Warning users about restart..."
        $Task=Start-Process $Mcrcon -ArgumentList "-c -H $RconIP -P $RconPort -p $RconPassword `"servermsg THE SERVER WILL REBOOT IN 5 MINUTES !`"" -Wait -PassThru -NoNewWindow
        if ($Task.ExitCode -eq 0) {
            Write-Output "Message Sent."
            Write-Output "Waiting 4 Minutes"
            Start-Sleep -s 240
        } else {
            Write-Error "Unable to send server reboot warning."
            Write-Output "Hard Restarting now."
            Stop-Server($Server)
        }
        $Task=Start-Process $Mcrcon -ArgumentList "-c -H $RconIP -P $RconPort -p $RconPassword `"servermsg THE SERVER WILL REBOOT IN 1 MINUTE !`"" -Wait -PassThru -NoNewWindow
        if ($Task.ExitCode -eq 0) {
            Write-Output "Message Sent."
            Write-Output "Waiting 1 Minutes"
            Start-Sleep -s 60
        } else {
            Write-Error "Unable to send server reboot warning."
            Write-Output "Hard Restarting now."
            Stop-Server($Server)
        }
        $Task=Start-Process $Mcrcon -ArgumentList "-c -H $RconIP -P $RconPort -p $RconPassword `"servermsg THE SERVER IS REBOOTING !`"" -Wait -PassThru -NoNewWindow
        if ($Task.ExitCode -eq 0) {
            Write-Output "Message Sent."
            Write-Output "Waiting 5 Seconds"
            Start-Sleep -s 5
        } else {
            Write-Error "Unable to send server reboot warning."
            Write-Output "Hard Restarting now."
            Stop-Server($Server)
        }
        $Task=Start-Process $Mcrcon -ArgumentList "-c -H $RconIP -P $RconPort -p $RconPassword `"quit`"" -Wait -PassThru -NoNewWindow
        if ($Task.ExitCode -eq 0) {
            Write-Output "Message Sent."
            Write-Output "Saving and shutting down server."
            Start-Sleep -s 30
        } else {
            Write-Error "Unable to send server reboot command"
            Write-Output "Hard Restarting now."
            Stop-Server($Server)
        }
    }else{
        Write-Output "Server is not running"
    }
}
Export-ModuleMember -Function Send-RestartWarning