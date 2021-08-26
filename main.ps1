# August 2021
# Created by and Patrix87 of https://bucherons.ca
# Run this script to Stop->Backup->Update->Start your server.

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $ServerCfg
)

#Console Output Text Color
[string]$FgColor="Green"

#Console Output Text Color for sections
[string]$SectionColor="Blue"

#Console Output Background Color
[string]$BgColor="Black"

#---------------------------------------------------------
# Set Script Directory as Working Directory
Write-Host -ForegroundColor $SectionColor -BackgroundColor $BgColor -Object "Setting Working Directory..."
#---------------------------------------------------------

$scriptpath=$MyInvocation.MyCommand.Path
$dir=Split-Path -Path $scriptpath
$dir=Resolve-Path -Path $dir
Set-Location -Path $dir

#---------------------------------------------------------
# Import Functions and Modules
Write-Host -ForegroundColor $SectionColor -BackgroundColor $BgColor -Object "Importing modules..."
#---------------------------------------------------------

# Core Function
try {
    Get-ChildItem -Path ".\functions" -Include "*.psm1" -Recurse | Import-Module
}
catch {
    Write-Warning "Unable to import functions."
}

# Modules
try {
    Get-ChildItem -Path ".\Modules" -Include "*.psm1" -Recurse | Import-Module
}
catch {
    Exit-WithError -ErrorMsg "Unable to import module."
}

#---------------------------------------------------------
# Import Variables
Write-Host -ForegroundColor $SectionColor -BackgroundColor $BgColor -Object "Importing functions and variables from $ServerCfg ..."
#---------------------------------------------------------

# Global Variables
try {
    Import-Module -Name ".\configs\global.psm1"
}
catch {
    Exit-WithError -ErrorMsg "Unable to import global configuration."
}

# Server Variables and Functions
try {
    Import-Module -Name ".\configs\$ServerCfg.psm1"
}
catch {
    Exit-WithError -ErrorMsg "Unable to import server configuration."
}

#---------------------------------------------------------
# Start Logging
#---------------------------------------------------------

$LogFile="$(Get-TimeStamp).txt"
# Start Logging
Start-Transcript -Path "$LogFolder\$LogFile" -IncludeInvocationHeader

#---------------------------------------------------------
# Install Dependencies
Write-Host -ForegroundColor $SectionColor -BackgroundColor $BgColor -Object "Verifying Dependencies..."
#---------------------------------------------------------

[Hashtable]$Dependencies=@{
    SevenZip=$SevenZip
    Mcrcon=$Mcrcon
    SteamCMD=$SteamCMD
}

[System.Collections.ArrayList]$MissingDependencies=@()

foreach ($Key in $Dependencies.keys) {
    if (!(Test-Path $Dependencies[$Key])) {
        $null=$MissingDependencies.Add($Key)
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
Write-Host -ForegroundColor $SectionColor -BackgroundColor $BgColor -Object "Verifying Server installation..."
#---------------------------------------------------------

if (!(Test-Path $ServerExec)){
    Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Server is not installed : Installing $ServerName Server."
    Update-Server -ServerPath $ServerPath -SteamCMD $SteamCMD -SteamAppID $SteamAppID -Beta $Beta -BetaBuild $BetaBuild -BetaBuildPassword $BetaBuildPassword -UpdateType "Installing"
    Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Server successfully installed."
}

#---------------------------------------------------------
# If Server is running warn players then stop server
Write-Host -ForegroundColor $SectionColor -BackgroundColor $BgColor -Object "Verifying Server State..."
#---------------------------------------------------------

If ($UseWarnings) {
    Send-RestartWarning -ProcessName $ProcessName -Mcrcon $Mcrcon -RconIP $RconIP -RconPort $RconPort -RconPassword $RconPassword -RestartTimers $RestartTimers -RestartMessageMinutes $RestartMessageMinutes -RestartMessageSeconds $RestartMessageSeconds -MessageCmd $MessageCmd -ServerStopCmd $ServerStopCmd
} else {
    $Server=Get-Process $ProcessName -ErrorAction SilentlyContinue
    $Stopped=Stop-Server -Server $Server
    if ($Stopped) {
        Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Server closed."
    } else {
        Exit-WithError -ErrorMsg "Unable to stop server."
    }
}

#---------------------------------------------------------
# Backup
Write-Host -ForegroundColor $SectionColor -BackgroundColor $BgColor -Object "Verifying Backups..."
#---------------------------------------------------------

if ($UseBackups) {
    Backup-Server -BackupPath $BackupPath -ServerSaves $ServerSaves -SevenZip $SevenZip -BackupDays $BackupDays -BackupWeeks $BackupWeeks
}

#---------------------------------------------------------
# Update
Write-Host -ForegroundColor $SectionColor -BackgroundColor $BgColor -Object "Updating Server..."
#---------------------------------------------------------

Update-Server -ServerPath $ServerPath -SteamCMD $SteamCMD -SteamAppID $SteamAppID -Beta $Beta -BetaBuild $BetaBuild -BetaBuildPassword $BetaBuildPassword -UpdateType "Updating"
Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Server successfully updated and/or verified."

#---------------------------------------------------------
# Start Server
Write-Host -ForegroundColor $SectionColor -BackgroundColor $BgColor -Object "Starting Server..."
#---------------------------------------------------------

try {
    Start-Server
}
catch {
    Exit-WithError -ErrorMsg "Unable to start server."
}

#---------------------------------------------------------
# Cleanup
Write-Host -ForegroundColor $SectionColor -BackgroundColor $BgColor -Object "Cleaning old logs..."
#---------------------------------------------------------

try {
    Remove-OldLog -LogFolder $LogFolder -Days 30
}
catch {
    Exit-WithError -ErrorMsg "Unable clean old logs."
}

#---------------------------------------------------------
# Stop Logging
#---------------------------------------------------------

Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Script successfully completed."

Stop-Transcript

Start-Sleep -Seconds 5