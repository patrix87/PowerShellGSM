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
RCONPassword=CHANGEME
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

$Name = "ProjectZomboid"

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

    #Rcon IP, usually localhost
    ManagementIP = "127.0.0.1"

    #Rcon Port in servertest.ini
    ManagementPort = 27015

    #Rcon Password as set in servertest.ini (Do not use " " in servertest.ini)
    ManagementPassword = "CHANGEME"

#---------------------------------------------------------
# Server Installation
#---------------------------------------------------------

    #Name of the Server Instance
    Name = $Name

    #Server Installation Path
    Path = ".\servers\$Name"

    #Steam Server App Id
    AppID = 380870

    #Use Beta builds $true or $false
    Beta = $false

    #Name of the Beta Build
    BetaBuild = "iwillbackupmysave"

    #Beta Build Password
    BetaBuildPassword = "iaccepttheconsequences"

    #Process name in the task manager
    ProcessName = "java"

    #ProjectZomboid64.exe
    Exec = ".\servers\$Name\ProjectZomboid64.exe"

    #Process Priority Realtime, High, Above normal, Normal, Below normal, Low
    UsePriority = $true
    AppPriority = "High"

    <#
    Process Affinity (Core Assignation)
    Core 1 = > 00000001 = > 1
    Core 2 = > 00000010 = > 2
    Core 3 = > 00000100 = > 4
    Core 4 = > 00001000 = > 8
    Core 5 = > 00010000 = > 16
    Core 6 = > 00100000 = > 32
    Core 7 = > 01000000 = > 64
    Core 8 = > 10000000 = > 128
    = = = = = = = = = = = = = = = = = = = = = = = = =  = 
    8 Cores = > 11111111 = > 255
    4 Cores = > 00001111 = > 15
    2 Cores = > 00000011 = > 3
    #>

    UseAffinity = $false
    AppAffinity = 15
}
#Create the object
$Server = New-Object -TypeName PsObject -Property $ServerDetails

#---------------------------------------------------------
# Backups
#---------------------------------------------------------
$BackupsDetails = @{
    #Do Backups
    Use = $true

    #Backup Folder
    Path = ".\backups\$($Server.Name)"

    #Number of days of backups to keep.
    Days = 7

    #Number of weeks of weekly backups to keep.
    Weeks = 4

    #Folder to include in backup
    Saves = "$Env:userprofile\Zomboid"
}
#Create the object
$Backups = New-Object -TypeName PsObject -Property $BackupsDetails

#---------------------------------------------------------
# Restart Warnings (Require RCON, Telnet or WebSocket API)
#---------------------------------------------------------
$WarningsDetails = @{
    #Use Rcon to restart server softly.
    Use = $true

    #What protocol to use : Rcon, Telnet, Websocket
    Protocol = "Telnet"

    #Times at which the servers will warn the players that it is about to restart. (in seconds between each timers)
    Timers = [System.Collections.ArrayList]@(240,50,10) #Total wait time is 240+50+10 = 300 seconds or 5 minutes

    #message that will be sent. % is a wildcard for the timer.
    MessageMin = "The server will restart in % minutes !"

    #message that will be sent. % is a wildcard for the timer.
    MessageSec = "The server will restart in % seconds !"

    #command to send a message.
    CmdMessage = "servermsg"

    #command to save the server
    CmdSave = "save"

    #How long to wait in seconds after the save command is sent.
    SaveDelay = 15

    #command to stop the server
    CmdStop = "quit"
}
#Create the object
$Warnings = New-Object -TypeName PsObject -Property $WarningsDetails

#---------------------------------------------------------
# Launch Arguments
#---------------------------------------------------------

#Java Arguments
$PZ_CLASSPATH = "java/jinput.jar;java/lwjgl.jar;java/lwjgl_util.jar;java/sqlite-jdbc-3.8.10.1.jar;java/trove-3.0.3.jar;java/uncommons-maths-1.2.3.jar;java/javacord-2.0.17-shaded.jar;java/guava-23.0.jar;java/"

#Launch Arguments
$ArgumentList = "-Dzomboid.steam = 1 -Dzomboid.znetlog = 1 -XX:+UseConcMarkSweepGC -XX:-CreateMinidumpOnCrash -XX:-OmitStackTraceInFastThrow -Xms2048m -Xmx2048m -Djava.library.path = natives/;. -cp $PZ_CLASSPATH zombie.network.GameServer"

$Launcher = "$($Server.Path)\jre64\bin\java.exe"

#---------------------------------------------------------
# Launch Function
#---------------------------------------------------------

function Start-Server {
    $App = Start-Process -FilePath $Launcher -WorkingDirectory $Server.Path -ArgumentList $ArgumentList -PassThru

    #Wait to see if the server is stable.
    Start-Sleep -Seconds 10
    if (-not ($App) -or $App.HasExited){
        Write-Warning "Server Failed to launch."
    } else {
        Write-ServerMsg "Server Started."
            # Set the priority and affinity
        if ($Server.UsePriority) {
            $App.PriorityClass = $Server.AppPriority
        }
        if ($Server.UseAffinity){
            $App.ProcessorAffinity = $Server.AppAffinity
        }
    }
}

Export-ModuleMember -Function Start-Server -Variable @("Server","Backups","Warnings")