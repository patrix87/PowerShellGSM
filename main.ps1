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
# Import Functions and Modules
#---------------------------------------------------------

# Core Function
try {
    Get-ChildItem -Path ".\functions" -Include "*.psm1" -Recurse | Import-Module
}
catch {
    Write-Error "Unable to import functions."
}

# Modules
try {
    Get-ChildItem -Path ".\Modules" -Include "*.psm1" -Recurse | Import-Module
}
catch {
    Exit-WithCode -ErrorMsg "Unable to import module." -ErrorObj $_ -ExitCode 404
}

#---------------------------------------------------------
# Import Variables
#---------------------------------------------------------

# Global Variables
try {
    Import-Module -Name ".\configs\global.psm1"
}
catch {
    Exit-WithCode -ErrorMsg "Unable to import global configuration." -ErrorObj $_ -ExitCode 404
}

# Server Variables and Functions
try {
    Import-Module -Name ".\configs\$ServerCfg.psm1"
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
#---------------------------------------------------------

[Hashtable]$Dependencies=@{
    SevenZip=$7Zip
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
#---------------------------------------------------------
if (!(Test-Path $ServerExec)){
    Write-Output "Server is not installed : Installing $ServerName Server..."
    $Code = Update-Server -ServerPath $ServerPath -SteamCMD $SteamCMD -SteamAppID $SteamAppID -Beta $Beta -BetaBuild $BetaBuild -BetaBuildPassword $BetaBuildPassword
    if ($Code -ne 0) {
        Exit-WithCode -ErrorMsg "Unable to update server." -ErrorObj $_ -ExitCode 500
    } else {
        Write-Output "Server successfully installed."
    }
}

#---------------------------------------------------------
# If Server is running warn players then stop server
#---------------------------------------------------------

If ($UseRcon) {
    Send-RestartWarning -ProcessName $ProcessName -Mcrcon $Mcrcon -RconIP $RconIP -RconPort $RconPort -RconPassword $RconPassword
} else {
    $Server=Get-Process $ProcessName -ErrorAction SilentlyContinue
    Stop-Server -Server $Server
}

#---------------------------------------------------------
# Backup
#---------------------------------------------------------

if ($UseBackups) {
    Backup-Server -BackupPath $BackupPath -ServerSaves $ServerSaves -7Zip $7Zip -BackupDays $BackupDays -BackupWeeks $BackupWeeks
}

#---------------------------------------------------------
# Update
#---------------------------------------------------------

Write-Output "Updating Server..."
try {
    Update-Server -ServerPath $ServerPath -SteamCMD $SteamCMD -SteamAppID $SteamAppID -Beta $Beta -BetaBuild $BetaBuild -BetaBuildPassword $BetaBuildPassword
}
catch {
    Exit-WithCode -ErrorMsg "Unable to update server." -ErrorObj $_ -ExitCode 500
}

#---------------------------------------------------------
# Start Server
#---------------------------------------------------------

try {
    Start-Server
}
catch {
    Exit-WithCode -ErrorMsg "Unable to start server." -ErrorObj $_ -ExitCode 500
}

#---------------------------------------------------------
# Cleanup
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

Write-Output "Script successfully completed."

Stop-Transcript

Start-Sleep -s 5