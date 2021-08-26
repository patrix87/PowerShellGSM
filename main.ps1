# August 2021
# Created by and Patrix87 of https://bucherons.ca
# Run this script to Stop->Backup->Update->Start your server.

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $ServerCfg
)

#---------------------------------------------------------
# Set Script Directory as Working Directory
Write-Verbose "Setting Working Directory."
#---------------------------------------------------------

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path -Path $scriptpath
$dir = Resolve-Path -Path $dir
Set-Location -Path $dir

#---------------------------------------------------------
# Import Functions and Modules
Write-Verbose "Importing modules."
#---------------------------------------------------------

# Core Function
try {
    Get-ChildItem -Path ".\functions" -Include "*.psm1" -Recurse | Import-Module -Verbose:$false
}
catch {
    Write-Warning "Unable to import functions."
}

# Modules
try {
    Get-ChildItem -Path ".\Modules" -Include "*.psm1" -Recurse | Import-Module -Verbose:$false
}
catch {
    Exit-WithCode -ErrorMsg "Unable to import module." -ErrorObj $_ -ExitCode 404
}

#---------------------------------------------------------
# Import Variables
Write-Verbose "Importing functions and variables from $ServerCfg"
#---------------------------------------------------------

# Global Variables
try {
    Import-Module -Name ".\configs\global.psm1" -Verbose:$false
}
catch {
    Exit-WithCode -ErrorMsg "Unable to import global configuration." -ErrorObj $_ -ExitCode 404
}

# Server Variables and Functions
try {
    Import-Module -Name ".\configs\$ServerCfg.psm1" -Verbose:$false
}
catch {
    Exit-WithCode -ErrorMsg "Unable to import server configuration." -ErrorObj $_ -ExitCode 404
}

#---------------------------------------------------------
# Start Logging
#---------------------------------------------------------

$LogFile="$(Get-TimeStamp).txt"
# Start Logging
Start-Transcript -Path "$LogFolder\$LogFile" -IncludeInvocationHeader

#---------------------------------------------------------
# Install Dependencies
Write-Verbose "Installing Dependencies..."
#---------------------------------------------------------

[Hashtable]$Dependencies=@{
    SevenZip=$SevenZip
    Mcrcon=$Mcrcon
    SteamCMD=$SteamCMD
}

[System.Collections.ArrayList]$MissingDependencies=@()

foreach ($Key in $Dependencies.keys) {
    if (!(Test-Path $Dependencies[$Key])) {
        $MissingDependencies.Add($Key)
    }
}

if ($MissingDependencies.Count -gt 0){
    #Create Temporary Download Folder
    New-Item -Path ".\downloads" -ItemType "directory" -ErrorAction SilentlyContinue

    foreach ($Item in $MissingDependencies) {
        $Cmd="Install-$Item"
        &$Cmd -Application $Dependencies[$Item]
    }

    #Cleanup
    Remove-Item -Path ".\downloads" -Recurse -Force -ErrorAction SilentlyContinue
}

#---------------------------------------------------------
# Install Server
Write-Verbose "Verifying Server installation"
#---------------------------------------------------------
if (!(Test-Path $ServerExec)){
    Write-Verbose "Server is not installed : Installing $ServerName Server..."
    $Code=Update-Server -ServerPath $ServerPath -SteamCMD $SteamCMD -SteamAppID $SteamAppID -Beta $Beta -BetaBuild $BetaBuild -BetaBuildPassword $BetaBuildPassword -UpdateType "Installing"
    if ($Code -ne 0) {
        Exit-WithCode -ErrorMsg "Unable to update server." -ErrorObj " " -ExitCode 500
    } else {
        Write-Verbose "Server successfully installed."
    }
}

#---------------------------------------------------------
# If Server is running warn players then stop server
Write-Verbose "Verifying Server State"
#---------------------------------------------------------

If ($UseWarnings) {
    Send-RestartWarning -ProcessName $ProcessName -Mcrcon $Mcrcon -RconIP $RconIP -RconPort $RconPort -RconPassword $RconPassword -RestartTimers $RestartTimers -RestartMessageMinutes $RestartMessageMinutes -RestartMessageSeconds $RestartMessageSeconds -MessageCmd $MessageCmd -ServerStopCmd $ServerStopCmd
} else {
    $Server=Get-Process $ProcessName -ErrorAction SilentlyContinue
    Stop-Server -Server $Server
}

#---------------------------------------------------------
# Backup
Write-Verbose "Backups."
#---------------------------------------------------------

if ($UseBackups) {
    Backup-Server -BackupPath $BackupPath -ServerSaves $ServerSaves -SevenZip $SevenZip -BackupDays $BackupDays -BackupWeeks $BackupWeeks
}

#---------------------------------------------------------
# Update
Write-Verbose "Updating Server..."
#---------------------------------------------------------

$Code=Update-Server -ServerPath $ServerPath -SteamCMD $SteamCMD -SteamAppID $SteamAppID -Beta $Beta -BetaBuild $BetaBuild -BetaBuildPassword $BetaBuildPassword -UpdateType "Updating"
if ($Code -ne 0) {
    Exit-WithCode -ErrorMsg "Unable to update server." -ErrorObj " " -ExitCode 500
} else {
    Write-Verbose "Server successfully installed."
}

#---------------------------------------------------------
# Start Server
Write-Verbose "Starting Server..."
#---------------------------------------------------------

try {
    Start-Server
}
catch {
    Exit-WithCode -ErrorMsg "Unable to start server." -ErrorObj $_ -ExitCode 500
}

#---------------------------------------------------------
# Cleanup
Write-Verbose "Cleaning old logs."
#---------------------------------------------------------

try {
    Remove-OldLog -LogFolder $LogFolder -Days 30
}
catch {
    Exit-WithCode -ErrorMsg "Unable clean old logs." -ErrorObj $_ -ExitCode 401
}

#---------------------------------------------------------
# Stop Logging
#---------------------------------------------------------

Write-Verbose "Script successfully completed."

Stop-Transcript

Start-Sleep -s 5