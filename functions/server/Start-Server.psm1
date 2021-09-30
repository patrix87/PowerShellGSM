function Start-Server {
    try {
        Write-ScriptMsg "Starting Server Preparation..."
        Start-ServerPrep
        Write-ScriptMsg "Starting Server..."
        if ($Server.Arguments.length -gt 0){
            $App = Start-Process -FilePath $Server.Launcher -WorkingDirectory $($Server.WorkingDirectory) -ArgumentList $Server.Arguments -PassThru
        } else {
            $App = Start-Process -FilePath $Server.Launcher -WorkingDirectory $($Server.WorkingDirectory) -PassThru
        }
        #Wait to see if the server is stable.
        Start-Sleep -Seconds $Server.StartupWaitTime
        if (($null -eq $App) -or ($App.HasExited)){
            Exit-WithError "Server Failed to launch."
        } else {
            Write-ServerMsg "Server Started."
            $null = Set-Priority -ServerProcess $App
        }
        # TODO - Hunt for the correct process.
        if (-not (Register-PID -ServerProcess $App)){
            Write-ServerMsg "Failed to Register PID file."
        }
    }
    catch {
        Write-Error $_
        Exit-WithError -ErrorMsg "Unable to start server."
    }
}
Export-ModuleMember -Function Start-Server