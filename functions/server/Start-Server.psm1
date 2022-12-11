function Start-Server {
    try {
        Write-ScriptMsg "Starting Server Preparation..."
        Start-ServerPrep
        Write-ScriptMsg "Starting Server..."
        #Create a Timestamp
        $timestamp = Get-Date
        Add-Member -InputObject $Server -Name "StartTime" -Type NoteProperty -Value $timestamp
        if ($Server.Arguments.length -gt 0){
            $ServerProcess = Start-Process -FilePath $Server.Launcher -WorkingDirectory $($Server.WorkingDirectory) -ArgumentList $Server.Arguments -PassThru
        } else {
            $ServerProcess = Start-Process -FilePath $Server.Launcher -WorkingDirectory $($Server.WorkingDirectory) -PassThru
        }
        #Wait to see if the server is stable.
        Start-Sleep -Seconds $Server.StartupWaitTime
        if (($null -eq $ServerProcess) -or ($ServerProcess.HasExited)){
            Exit-WithError "Server Failed to launch."
        } else {
            Write-ServerMsg "Server Started."
        }
        $ServerProcess = Register-PID -ServerProcess $ServerProcess
        if (-not $ServerProcess){
            Write-ServerMsg "Failed to Register PID file."
        } else {
            $null = Set-Priority -ServerProcess $ServerProcess
        }
		$null = Register-TaskConfig
    }
    catch {
        Write-Error $_
        Exit-WithError -ErrorMsg "Unable to start server."
    }
}
Export-ModuleMember -Function Start-Server