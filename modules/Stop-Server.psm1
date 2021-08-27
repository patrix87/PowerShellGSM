function Stop-Server {
    param (
        $Server
    )
    if(-not $Server.HasExited){
        Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Closing Main Windows..."
        $Server.CloseMainWindow()
        $Server.WaitForExit(30000)
        Start-Sleep -Seconds 5
        if ($Server.HasExited) {
            Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Server succesfully shutdown."
        }else{
            Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Trying again to stop the Server..."
            #Try Again
            Stop-Process $Server
            Start-Sleep -Seconds 5
            if ($Server.HasExited) {
                Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Server succesfully shutdown on second try."
            }else{
                Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Forcing server shutdown..."
                #Force Stop
                Stop-Process $Server -Force
            }
        }
    }
    Start-Sleep -Seconds 5
    if ($Server.HasExited) {
        return $true
    } else {
        return $false
    }
}
Export-ModuleMember -Function Stop-Server