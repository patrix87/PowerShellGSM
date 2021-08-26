function Stop-Server {
    param (
        $Server
    )
    if(-not $Server.HasExited){
        Write-Verbose "Closing Main Windows..."
        $Server.CloseMainWindow()
        $Server.WaitForExit()
        Start-Sleep -s 10
        if ($Server.HasExited) {
            Write-Verbose "Server succesfully shutdown"
        }else{
            Write-Verbose "Trying again to stop the Server..."
            #Try Again
            Stop-Process $Server
            Start-Sleep -s 10
            if ($Server.HasExited) {
                Write-Verbose "Server succesfully shutdown on second try"
            }else{
                Write-Verbose "Forcing server shutdown..."
                #Force Stop
                Stop-Process $Server -Force
            }
        }
    }
    if ($Server.HasExited) {
        return $True
    } else {
        return $False
    }
}
Export-ModuleMember -Function Stop-Server -Verbose:$false