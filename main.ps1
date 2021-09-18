# August 2021
# Created by and Patrix87 of https://bucherons.ca
# Run this script to Stop->Backup->Update->Start your server.

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$ServerCfg
)

#---------------------------------------------------------
# Importing functions and variables.
#---------------------------------------------------------

# import global config, all functions. Exit if fails.
try {
    Import-Module -Name ".\configs\global.psm1"
    Get-ChildItem -Path ".\functions" -Include "*.psm1" -Recurse | Import-Module
}
catch {
    Exit-WithError -ErrorMsg "Unable to import modules."
    exit
}

#---------------------------------------------------------
# Start Logging
#---------------------------------------------------------

#Define Logfile by TimeStamp-ServerCfg.
$LogFile = "$(Get-TimeStamp)-$($ServerCfg).txt"
# Start Logging
Start-Transcript -Path "$($Global.LogFolder)\$LogFile" -IncludeInvocationHeader

#---------------------------------------------------------
# Set Script Directory as Working Directory
#---------------------------------------------------------

#Find the location of the current invocation of main.ps1, remove the filename, set the working directory to that path.
Write-ScriptMsg "Setting Script Directory as Working Directory..."
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path -Path $scriptpath
$dir = Resolve-Path -Path $dir
Set-Location -Path $dir
Write-ScriptMsg "Working Directory : $(Get-Location)"

#---------------------------------------------------------
# Get server IPs
#---------------------------------------------------------

#Get current internal ip from active network interface.
Write-ScriptMsg "Finding server IPs..."
$InternalIP = (
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected"
    }
).IPv4Address.IPAddress

#Get current external ip from ifconfig.me
$ExternalIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()

Write-ScriptMsg "Server local IP : $InternalIP"
Write-ScriptMsg "Server external IP : $ExternalIP"

#Add propreties to global.
Add-Member -InputObject $Global -Name "InternalIP" -Type NoteProperty -Value $InternalIP
Add-Member -InputObject $Global -Name "ExternalIP" -Type NoteProperty -Value $ExternalIP

#---------------------------------------------------------
# Install Dependencies
#---------------------------------------------------------

#Define variables
Write-ScriptMsg "Verifying Dependencies..."
$Dependencies = @{
    SevenZip = $Global.SevenZip
    Mcrcon = $Global.Mcrcon
    SteamCMD = $Global.SteamCMD
}

[System.Collections.ArrayList]$MissingDependencies = @()

#For each dependency check if the excutable exist, if not, add the key of the dependency to the MissingDependencies list.
foreach ($Key in $Dependencies.keys) {
    if (-not (Test-Path -Path $Dependencies[$Key])) {
        $null = $MissingDependencies.Add($Key)
    }
}

#If there is missing dependencies, create the download folder and for each missing dependency, run the installation script.
if ($MissingDependencies.Count -gt 0){
    #Create Temporary Download Folder
    New-Item -Path ".\downloads" -ItemType "directory" -ErrorAction SilentlyContinue

    foreach ($Item in $MissingDependencies) {
        $Cmd = "Install-$Item"
        &$Cmd -Application $Dependencies[$Item]
    }

    #Cleanup
    Remove-Item -Path ".\downloads" -Recurse -Force -ErrorAction SilentlyContinue
}

#---------------------------------------------------------
# Importing server configuration.
#---------------------------------------------------------

Write-ScriptMsg "Importing Server Configuration..."
#Check if requested config exist in the config folder, if not, copy it from the templates. Exit if fails.
if (-not (Test-Path -Path ".\configs\$ServerCfg.psm1" -PathType "Leaf")) {
    if (Test-Path -Path ".\templates\$ServerCfg.psm1" -PathType "Leaf"){
        Copy-Item -Path ".\templates\$ServerCfg.psm1" -Destination ".\configs\$ServerCfg.psm1" -ErrorAction SilentlyContinue
    } else {
        Exit-WithError -ErrorMsg "Unable to find configuration file."
    }
}

# import the current server config file. Exit if fails.
try {
    Import-Module -Name ".\configs\$ServerCfg.psm1"
}
catch {
    Exit-WithError -ErrorMsg "Unable to server configuration."
    exit
}

#---------------------------------------------------------
# Install Server
#---------------------------------------------------------

Write-ScriptMsg "Verifying Server installation..."
#Flag of a fresh installation in the current instance.
[boolean]$FreshInstall = $false
#If the server executable is missing, run SteamCMD and install the server.
if (-not(Test-Path -Path $Server.Exec)){
    Write-ServerMsg "Server is not installed : Installing $($Server.Name) Server."
    Update-Server -UpdateType "Installing"
    Write-ServerMsg "Server successfully installed."
    $FreshInstall = $true
}

#---------------------------------------------------------
# If Server is running warn players then stop server
#---------------------------------------------------------
Write-ScriptMsg "Verifying Server State..."
#If the server is not freshly installed.
if (-not ($FreshInstall)) {
    #Get the PID from the .PID market file.
    $ServerPID = Get-PID
    #If it returned 0, it failed to get a PID
    if ($null -ne $ServerPID) {
        $ServerProcess = Get-Process -ID $ServerPID -ErrorAction SilentlyContinue
    }
    #If the server process is none-existent, Get the process from the server process name.
    if ($null -ne $ServerProcess) {
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
                $Stopped = Stop-Server -ServerProcess $ServerProcess
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
    if (-not $(Unregister-PID)) {
        Write-ServerMsg "Failed to remove PID file."
    }
}

#---------------------------------------------------------
# Backup
#---------------------------------------------------------

#If not a fresh install and Backups are enabled, run backups.
if ($Backups.Use -and -not ($FreshInstall)) {
    Write-ScriptMsg "Verifying Backups..."
    Backup-Server
}

#---------------------------------------------------------
# Update
#---------------------------------------------------------

#If not a fresh install, update and/or validate server.
if (-not ($FreshInstall)) {
    Write-ScriptMsg "Updating Server..."
    Update-Server -UpdateType "Updating / Validating"
    Write-ServerMsg "Server successfully updated and/or validated."
}

#---------------------------------------------------------
# Start Server
#---------------------------------------------------------

#Try to start the server, then if it's stable, set the priority and affinity then register the PID. Exit with Error if it fails.
try {
    Write-ScriptMsg "Starting Server..."
    Start-ServerPrep
    $App = Start-Process -FilePath $Server.Launcher -WorkingDirectory $Server.WorkingDirectory -ArgumentList $Server.ArgumentList -PassThru
    #Wait to see if the server is stable.
    Start-Sleep -Seconds $Server.StartupWaitTime
    if (-not ($App) -or $App.HasExited){
        Exit-WithError "Server Failed to launch."
    } else {
        Write-ServerMsg "Server Started."
        Set-Priority -ServerProcess $App
    }
    if (-not $(Register-PID -ServerProcess $App)){
        Write-ServerMsg "Failed to Register PID file."
    }
}
catch {
    Write-Error $_
    Exit-WithError -ErrorMsg "Unable to start server."
}

#---------------------------------------------------------
# Cleanup
#---------------------------------------------------------

#Remove old log files.
try {
    Write-ScriptMsg "Deleting logs older than $($Global.Days) days."
    Remove-OldLog
}
catch {
    Exit-WithError -ErrorMsg "Unable clean old logs."
}

#---------------------------------------------------------
# Stop Logging
#---------------------------------------------------------

Write-ServerMsg "Script successfully completed."

Stop-Transcript