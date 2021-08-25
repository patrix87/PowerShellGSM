function Stop-Server {
    param (
        $Server
    )
    if(-not $Server.HasExited){
        Write-Output "Closing Main Windows..."
        $Server.CloseMainWindow()
        $Server.WaitForExit()
        Start-Sleep -s 10
        if ($Server.HasExited) {
            Write-Output "Server succesfully shutdown"
        }else{
            Write-Output "Trying again to stop the Server..."
            #Try Again
            Stop-Process $Server
            Start-Sleep -s 10
            if ($Server.HasExited) {
                Write-Output "Server succesfully shutdown on second try"
            }else{
                Write-Output "Forcing server shutdown..."
                #Force Stop
                Stop-Process $Server -Force
            }
        }
    }
    if ($Server) {
        return $False
    } else {
        return $True
    }
}
Export-ModuleMember -Function Stop-Server