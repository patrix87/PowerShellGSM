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

if (-not (Test-Path -Path ".\configs\$ServerCfg.psm1" -PathType "Leaf")) {
    if (Test-Path -Path ".\configs-templates\$ServerCfg.psm1" -PathType "Leaf"){
        Copy-Item -Path ".\configs-templates\$ServerCfg.psm1" -Destination ".\configs\$ServerCfg.psm1" -ErrorAction SilentlyContinue
    } else {
        Exit-WithError -ErrorMsg "Unable to find configuration file."
    }
}

try {
    Import-Module -Name ".\configs\global.psm1"
    Get-ChildItem -Path ".\functions" -Include "*.psm1" -Recurse | Import-Module
    Import-Module -Name ".\configs\$ServerCfg.psm1"
}
catch {
    Exit-WithError -ErrorMsg "Unable to import modules."
    exit
}

#---------------------------------------------------------
# Start Logging
#---------------------------------------------------------

$LogFile = "$(Get-TimeStamp).txt"
# Start Logging
Start-Transcript -Path "$($Global.LogFolder)\$LogFile" -IncludeInvocationHeader

#---------------------------------------------------------
# Set Script Directory as Working Directory
#---------------------------------------------------------

Write-ScriptMsg "Setting Script Directory as Working Directory..."
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path -Path $scriptpath
$dir = Resolve-Path -Path $dir
Set-Location -Path $dir
Write-ScriptMsg "Working Directory : $(Get-Location)"

#---------------------------------------------------------
# Get server IPs
#---------------------------------------------------------

Write-ScriptMsg "Finding server IPs..."
$InternalIP = (
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected"
    }
).IPv4Address.IPAddress

$ExternalIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()

Write-ScriptMsg "Server local IP : $InternalIP"
Write-ScriptMsg "Server external IP : $ExternalIP"

Add-Member -InputObject $Global -Name "InternalIP" -Type NoteProperty -Value $InternalIP
Add-Member -InputObject $Global -Name "ExternalIP" -Type NoteProperty -Value $ExternalIP

#---------------------------------------------------------
# Install Dependencies
#---------------------------------------------------------

Write-ScriptMsg "Verifying Dependencies..."
$Dependencies = @{
    SevenZip = $Global.SevenZip
    Mcrcon = $Global.Mcrcon
    SteamCMD = $Global.SteamCMD
}

[System.Collections.ArrayList]$MissingDependencies = @()

foreach ($Key in $Dependencies.keys) {
    if (-not(Test-Path -Path $Dependencies[$Key])) {
        $null = $MissingDependencies.Add($Key)
    }
}

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
# Install Server
#---------------------------------------------------------

Write-ScriptMsg "Verifying Server installation..."
[boolean]$FreshInstall = $false
if (-not(Test-Path -Path $Server.Exec)){
    Write-ServerMsg "Server is not installed : Installing $($Server.Name) Server."
    Update-Server -UpdateType "Installing"
    Write-ServerMsg "Server successfully installed."
    $FreshInstall = $true
}

#---------------------------------------------------------
# If Server is running warn players then stop server
#---------------------------------------------------------
if (-not ($FreshInstall)) {
    $ServerProcess = Get-Process $Server.ProcessName -ErrorAction SilentlyContinue
    Write-ScriptMsg "Verifying Server State..."
    if (-not ($ServerProcess) -or $ServerProcess.HasExited) {
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

        if ($Stopped) {
            Write-ServerMsg "Server stopped."
        } else {
            if ($Server.AllowForceClose) {
                Exit-WithError "Server to stop server."
            } else {
                Write-ServerMsg "Server not stopped."
            }
        }
    }
}

#---------------------------------------------------------
# Backup
#---------------------------------------------------------

if ($Backups.Use -and -not ($FreshInstall)) {
    Write-ScriptMsg "Verifying Backups..."
    Backup-Server
}

#---------------------------------------------------------
# Update
#---------------------------------------------------------

if (-not ($FreshInstall)) {
    Write-ScriptMsg "Updating Server..."
    Update-Server -UpdateType "Updating / Validating"
    Write-ServerMsg "Server successfully updated and/or validated."
}

#---------------------------------------------------------
# Start Server
#---------------------------------------------------------

try {
    Write-ScriptMsg "Starting Server..."
    Start-Server
}
catch {
    Write-Error $_
    Exit-WithError -ErrorMsg "Unable to start server."
}

#---------------------------------------------------------
# Cleanup
#---------------------------------------------------------

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

Start-Sleep -Seconds 5