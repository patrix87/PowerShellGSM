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
$ServerInternalIP = (
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected"
    }
).IPv4Address.IPAddress

$ServerExternalIP = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()

Write-ScriptMsg "Server local IP : $ServerInternalIP"
Write-ScriptMsg "Server external IP : $ServerExternalIP"

Add-Member -InputObject $Global -Name "ServerInternalIP" -Type NoteProperty -Value $ServerInternalIP
Add-Member -InputObject $Global -Name "ServerExternalIP" -Type NoteProperty -Value $ServerExternalIP

#---------------------------------------------------------
# Start Logging
#---------------------------------------------------------

$LogFile = "$(Get-TimeStamp).txt"
# Start Logging
Start-Transcript -Path "$($Global.LogFolder)\$LogFile" -IncludeInvocationHeader

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

$ServerProcess = Get-Process $Server.ProcessName -ErrorAction SilentlyContinue
Write-ScriptMsg "Verifying Server State..."
if (-not ($ServerProcess) -or $ServerProcess.HasExited) {
    Write-ServerMsg "Server is not running."
} else {
    if ($Warnings.Use -and -not ($FreshInstall)) {
        Write-ServerMsg "Server is running, warning users about upcomming restart."
        $Stopped = Send-RestartWarning -ServerProcess $ServerProcess
    } else {
        Write-ServerMsg "Server is running, stopping server."
        $Stopped = Stop-Server -ServerProcess $ServerProcess
    }
    if ($Stopped) {
        Write-ServerMsg "Server stopped."
    } else {
        Exit-WithError "Unable to stop server."
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
    Update-Server -UpdateType "Updating / Verifying"
    Write-ServerMsg "Server successfully updated and/or verified."
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