function Stop-Server {
    [CmdletBinding()]
    [OutputType([boolean])]
    param (
        [Parameter(Mandatory)]
        $ServerProcess
    )
    if(-not $Server.HasExited){
        Write-ServerMsg "Closing main window..."
        $ServerProcess.CloseMainWindow()
        $ServerProcess.WaitForExit(30000)
        if ($ServerProcess.HasExited) {
            Write-ServerMsg "Server succesfully stopped."
        }else{
            Write-Warning "Trying again to stop the server..."
            Stop-Process $ServerProcess
            $ServerProcess.WaitForExit(30000)
            if ($ServerProcess.HasExited) {
                Write-Warning "Server succesfully stopped on second try."
            }else{
                Write-Warning "Forcefully stopping server..."
                Stop-Process $ServerProcess -Force
            }
        }
    }
    Start-Sleep -Seconds 10
    if ($ServerProcess.HasExited) {
        return $true
    } else {
        return $false
    }
}
Export-ModuleMember -Function Stop-Server