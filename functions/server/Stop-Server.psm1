function Stop-Server {
    $ServerProcess = Get-ServerProcess
    #Check if the process was found.
    if (-not ($ServerProcess)) {
        Write-ServerMsg "Server is not running."
    } else {
        #Check if it's the right server via RCON if possible.
        $Success = $false
        if ($Warnings.Use){
            $Success = Send-Command("help")
            if ($Success) {
                Write-ServerMsg "Server is responding to remote messages."
            } else {
                Write-ServerMsg "Server is not responding to remote messages."
            }
        }
        #If Rcon worked, send stop warning.
        if ($Success) {
            Write-ServerMsg "Server is running, warning users about upcomming restart."
            $Stopped = Send-RestartWarning -ServerProcess $ServerProcess
        } else {
            #If Server is allow to be closed, close it.
            if ($Server.AllowForceClose){
                Write-ServerMsg "Server is running, stopping server."
                $Stopped = Stop-ServerProcess -ServerProcess $ServerProcess
            }
        }
        #If the server stopped, send messages, if not check if it's normal, then stopped it, if it fails, exit with error.
        switch ($Stopped) {
            -1 {
                Write-ServerMsg "Server not found. Unregistering PID"
            }
            0 {
                if ($Server.AllowForceClose) {
                    Exit-WithError "Failed to stop server."
                } else {
                    Write-ServerMsg "Server not stopped."
                }
            }
            1 {
                Write-ServerMsg "Server stopped."
            }
            Default {
                Write-ServerMsg "Server state unknown."
            }
        }
    }
    #Unregister the PID
    if ($Server.UsePID) {
        if (-not $(Unregister-PID)) {
            Write-ServerMsg "Failed to remove PID file."
        }
    }
}
Export-ModuleMember -Function Stop-Server