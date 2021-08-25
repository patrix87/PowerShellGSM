<#
#Change your servers settings in C:\Users\%username%\Zomboid\Server\servertest.ini

Options to look for when setting your server in servertest.ini (Suggested values)
```
DefaultPort=16261
MaxPlayers=64
Open=true
PVP=true
Password=My server password
PauseEmpty=true
PingFrequency=10
PingLimit=200
Public=true
PublicDescription=My server Description
PublicName=My server name
RCONPassword=RCONPassword from ProjectZomboid.ps1 without "
RCONPort=27015
SteamPort1=8766
SteamPort2=8767
```

You need to port forward the following Ports on your router, both in TCP and UDP

```
DefaultPort=16261
SteamPort1=8766
SteamPort2=8767
```
You do not need to forward RCON.

#>

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------
#Rcon IP, usually localhost
[string]$RconIP="127.0.0.1"

#Rcon Port in servertest.ini
[int32]$RconPort=27015

#Rcon Password as set in servertest.ini (Do not use " " in servertest.ini)
[securestring]$RconPassword = ConvertTo-SecureString -String "CHANGEME" -AsPlainText -Force

#---------------------------------------------------------
# Server Installation
#---------------------------------------------------------

#Name of the Server Instance
[string]$ServerName="Project Zomboid"

#Server Installation Path
[string]$ServerPath=".\ProjectZomboidServer"

#Steam Server App Id
[int32]$SteamAppID=380870

#Use Beta builds $True or $False
[bool]$Beta=$False

#Name of the Beta Build
[string]$BetaBuild="iwillbackupmysave"

#Beta Build Password
[securestring]$BetaBuildPassword = ConvertTo-SecureString -String "iaccepttheconsequences" -AsPlainText -Force

#Process name in the task manager
[string]$ProcessName="java"

#ProjectZomboid64.exe
[string]$ServerExec=".\ProjectZomboidServer\ProjectZomboid64.exe"

#Process Priority Realtime, High, Above normal, Normal, Below normal, Low
[bool]$UsePriority=$True
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

[bool]$UseAffinity=$False
[int32]$AppAffinity=15

#---------------------------------------------------------
# Backups
#---------------------------------------------------------

#Do Backups
[bool]$UseBackups=$True

#Backup Folder
[string]$BackupPath=".\ProjectZomboidServerBackups"

#Number of days of backups to keep.
[int32]$BackupDays=7

#Number of weeks of weekly backups to keep.
[int32]$BackupWeeks=4

#Folder to include in backup
[string]$ServerSaves="$Env:userprofile\Zomboid"

#---------------------------------------------------------
# Restart Warnings (Require RCON)
#---------------------------------------------------------
#Use Rcon to restart server softly.
[bool]$UseRcon=$True

#Times at which the servers will warn the players that it is about to restart. (in seconds before restart)
[int32[]]$RestartTimers=@(300,60,10)

#message that will be sent.
[string]$RestartMessageMinutes="The server will restart in % minutes !"

#message that will be sent.
[string]$RestartMessageSeconds="The server will restart in % seconds !"

#command to send a message.
[string]$MessageCmd="servermsg"

#command to stop the server
[string]$ServerStopCmd="quit"

#---------------------------------------------------------
# Launch Arguments
#---------------------------------------------------------

#Java Arguments
[string]$PZ_CLASSPATH="java/jinput.jar;java/lwjgl.jar;java/lwjgl_util.jar;java/sqlite-jdbc-3.8.10.1.jar;java/trove-3.0.3.jar;java/uncommons-maths-1.2.3.jar;java/javacord-2.0.17-shaded.jar;java/guava-23.0.jar;java/"

#Launch Arguments
[string]$ArgumentList="`
-Dzomboid.steam=1 `
-Dzomboid.znetlog=1 `
-XX:+UseConcMarkSweepGC `
-XX:-CreateMinidumpOnCrash `
-XX:-OmitStackTraceInFastThrow `
-Xms2048m `
-Xmx2048m `
-Djava.library.path=natives/;. `
-cp $PZ_CLASSPATH zombie.network.GameServer"

[string]$Launcher="$ServerPath\jre64\bin\java.exe"

#---------------------------------------------------------
# Launch Function
#---------------------------------------------------------

function Start-Server {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

    )
    Write-Output "Starting Server..."

    if ($PSCmdlet.ShouldProcess("Target", "Operation"))
    {
        $App=Start-Process -FilePath $Launcher -WorkingDirectory $ServerPath -ArgumentList $ArgumentList -PassThru
    }
    else
    {
        Write-Output ("Start-Process -FilePath $Launcher -WorkingDirectory $ServerPath -ArgumentList $ArgumentList")
    }

    #Wait to see if the server is stable.
    Start-Sleep 10
    if ($App){
        Write-Output "Server Started."
    } else {
        Write-Error "Server Failed to launch."
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