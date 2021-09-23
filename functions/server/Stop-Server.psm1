function Stop-Server {
    if ($Server.UsePID){
        #Get the PID from the .PID market file.
        $ServerPID = Get-PID
        #If it returned 0, it failed to get a PID
        if ($null -ne $ServerPID) {
            $ServerProcess = Get-Process -ID $ServerPID -ErrorAction SilentlyContinue
        }
    } else {
        # Find the process by name.
        $ServerProcess = Get-Process -Name $Server.ProcessName -ErrorAction SilentlyContinue
    }
    #Check if the process was found.
    if ($null -eq $ServerProcess) {
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
        if ($Stopped) {
            Write-ServerMsg "Server stopped."
        } else {
            if ($Server.AllowForceClose) {
                Exit-WithError "Failed to stop server."
            } else {
                Write-ServerMsg "Server not stopped."
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