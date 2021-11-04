function Get-ServerProcess {
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
    if (-not ($null -eq $ServerProcess)) {
        return $ServerProcess
    }
    return $false
}
Export-ModuleMember -Function Get-ServerProcess