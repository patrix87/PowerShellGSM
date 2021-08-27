<#
#Change your servers settings in C:\Users\%username%\AppData\Roaming\7DaysToDie\Saves\serverconfig.xml
#>

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

#Server Configuration
[string]$ConfigFile="$Env:userprofile\AppData\Roaming\7DaysToDie\Saves\serverconfig.xml"

#Rcon IP, usually localhost
[string]$RconIP="127.0.0.1"

#Rcon Port in serverconfig.xml
[int32]$RconPort=8081

#Rcon Password as set in serverconfig.xml
[string]$RconPassword=""

#Server Log File
[string]$ServerLogFile="$Env:userprofile\AppData\Roaming\7DaysToDie\Logs\$(Get-TimeStamp).txt"

#---------------------------------------------------------
# Server Installation
#---------------------------------------------------------

#Name of the Server Instance
[string]$ServerName="7DaysToDie"

#Server Installation Path
[string]$ServerPath=".\servers\$ServerName"

#Steam Server App Id
[int32]$SteamAppID=294420

#Use Beta builds $true or $false
[bool]$Beta=$false

#Name of the Beta Build
[string]$BetaBuild="iwillbackupmysave"

#Beta Build Password
[string]$BetaBuildPassword="iaccepttheconsequences"

#Process name in the task manager
[string]$ProcessName="7DaysToDieServer"

#ProjectZomboid64.exe
[string]$ServerExec=".\servers\$ServerName\7DaysToDieServer.exe"

#Process Priority Realtime, High, Above normal, Normal, Below normal, Low
[bool]$UsePriority=$true
[string]$AppPriority="High"

<#
Process Affinity (Core Assignation)
Core 1=> 00000001=> 1
Core 2=> 00000010=> 2
Core 3=> 00000100=> 4
Core 4=> 00001000=> 8
Core 5=> 00010000=> 16
Core 6=> 00100000=> 32
Core 7=> 01000000=> 64
Core 8=> 10000000=> 128
==========================
8 Cores=> 11111111=> 255
4 Cores=> 00001111=> 15
2 Cores=> 00000011=> 3
#>

[bool]$UseAffinity=$false
[int32]$AppAffinity=15

#---------------------------------------------------------
# Backups
#---------------------------------------------------------

#Do Backups
[bool]$UseBackups=$true

#Backup Folder
[string]$BackupPath=".\backups\$ServerName"

#Number of days of backups to keep.
[int32]$BackupDays=7

#Number of weeks of weekly backups to keep.
[int32]$BackupWeeks=4

#Folder to include in backup
[string]$ServerSaves="$Env:userprofile\AppData\Roaming\7DaysToDie"

#---------------------------------------------------------
# Restart Warnings (Require RCON)
#---------------------------------------------------------

#Use Rcon to restart server softly.
[bool]$UseWarnings=$true

#Use Telnet protocol instead of RCON
[string]$protocol="Telnet"

#Times at which the servers will warn the players that it is about to restart. (in seconds between each timers)
[System.Collections.ArrayList]$RestartTimers=@(240,50,10) #Total wait time is 240+50+10=300 seconds or 5 minutes

#message that will be sent. % is a wildcard for the timer.
[string]$RestartMessageMinutes="The server will restart in % minutes !"

#message that will be sent. % is a wildcard for the timer.
[string]$RestartMessageSeconds="The server will restart in % seconds !"

#command to send a message.
[string]$MessageCmd="say"

#command to save the server
[string]$ServerSaveCmd="saveworld"

#command to stop the server
[string]$ServerStopCmd="shutdown"

#---------------------------------------------------------
# Launch Arguments
#---------------------------------------------------------

#Launch Arguments
[string]$ArgumentList="-logfile $ServerLogFile -configfile=$ConfigFile -batchmode -nographics -dedicated -quit"

#Server Launcher
[string]$Launcher=$ServerExec

#---------------------------------------------------------
# Launch Function
#---------------------------------------------------------

function Start-Server {
    #Copy Config File if not created. Do not modify the one in the server directory, it will be overwriten on updates.
    If(-Not (Test-Path -Path $ConfigFile -PathType "leaf")){
        Copy-Item -Path "$ServerPath\serverconfig.xml" -Destination $ConfigFile
    }
    #Start Server
    $App=Start-Process -FilePath $Launcher -WorkingDirectory $ServerPath -ArgumentList $ArgumentList -PassThru

    #Wait to see if the server is stable.
    Start-Sleep -Seconds 10
    if ($App.HasExited){
        Write-Warning "Server Failed to launch."
    } else {
        Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Server Started."
    }

    # Set the priority and affinity
    if ($UsePriority) {
        $App.PriorityClass=$AppPriority
    }
    if ($UseAffinity){
        $App.ProcessorAffinity=$AppAffinity
    }
}

Export-ModuleMember -Function * -Variable *