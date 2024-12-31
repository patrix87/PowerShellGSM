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

#Server Name, Always Match the Launcher and config file name.
$Name = $ServerCfg

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

  #Login username used by SteamCMD
  Login              = "anonymous"

  #Rcon IP, usually localhost
  ManagementIP       = "127.0.0.1"

  #Rcon Port in servertest.ini
  ManagementPort     = 27015

  #Rcon Password as set in servertest.ini (Do not use " " in servertest.ini)
  ManagementPassword = "CHANGEME"

  #---------------------------------------------------------
  # Server Installation
  #---------------------------------------------------------

  #Name of the Server Instance
  Name               = $Name

  #Server Installation Path
  Path               = ".\servers\$Name"

  #Server configuration folder
  ConfigFolder       = "$Env:userprofile\Zomboid\Server"

  #Steam Server App Id
  AppID              = 380870

  #Name of the Beta Build
  BetaBuild          = ""

  #Beta Build Password
  BetaBuildPassword  = ""

  #Set to $true if you want this server to automatically update.
  AutoUpdates        = $true

  #Set to $true if you want this server to automatically restart on crash.
  AutoRestartOnCrash = $true

  #Set to $true if you want this server to automatically restart at set hour.
  AutoRestart        = $true

  #The time at which the server will restart daily.
  #(Hour, Minute, Seconds)
  AutoRestartTime    = @(3, 0, 0)

  #Process name in the task manager
  ProcessName        = "java"

  #Use PID instead of Process Name.
  UsePID             = $true

  #Server Executable
  Exec               = ".\servers\$Name\StartServer64.bat"

  #Allow force close, usefull for server without RCON.
  AllowForceClose    = $true

  #Process Priority Realtime, High, AboveNormal, Normal, BelowNormal, Low
  UsePriority        = $true
  AppPriority        = "High"

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
  ----------------------------
  8 Cores = > 11111111 = > 255
  4 Cores = > 00001111 = > 15
  2 Cores = > 00000011 = > 3
  #>

  UseAffinity        = $false
  AppAffinity        = 15

  #Should the server validate install after installation or update *(recommended)
  Validate           = $true

  #How long should it wait to check if the server is stable
  StartupWaitTime    = 10
}
#Create the object
$Server = New-Object -TypeName PsObject -Property $ServerDetails

#---------------------------------------------------------
# Backups
#---------------------------------------------------------
$BackupsDetails = @{
  #Do Backups
  Use   = $true

  #Backup Folder
  Path  = ".\backups\$($Server.Name)"

  #Number of days of backups to keep.
  Days  = 7

  #Number of weeks of weekly backups to keep.
  Weeks = 4

  #Folder to include in backup
  Saves = "$Env:userprofile\Zomboid"

  #Exclusions (Regex use | as separator)
  Exclusions = ""
}
#Create the object
$Backups = New-Object -TypeName PsObject -Property $BackupsDetails

#---------------------------------------------------------
# Restart Warnings (Require RCON, Telnet or WebSocket API)
#---------------------------------------------------------
$WarningsDetails = @{
  #Use Rcon to restart server softly.
  Use        = $true

  #What protocol to use : RCON, ARRCON, Telnet, Websocket
  Protocol   = "RCON"

  #Times at which the servers will warn the players that it is about to restart. (in seconds between each timers)
  Timers     = [System.Collections.ArrayList]@(240, 50, 10) #Total wait time is 240+50+10 = 300 seconds or 5 minutes

  #message that will be sent. % is a wildcard for the timer.
  MessageMin = "`\`"The server will restart in % minutes !`\`""
  
  #message that will be sent. % is a wildcard for the timer.
  MessageSec = "`\`"The server will restart in % seconds !`\`""

  #command to send a message.
  CmdMessage = "servermsg"

  #command to save the server
  CmdSave    = "save"

  #How long to wait in seconds after the save command is sent.
  SaveDelay  = 15

  #command to stop the server
  CmdStop    = "quit"
}
#Create the object
$Warnings = New-Object -TypeName PsObject -Property $WarningsDetails

#---------------------------------------------------------
# Launch Arguments
#---------------------------------------------------------

#Java Arguments
$PZ_CLASSPATH_LIST = @(
  "java/istack-commons-runtime.jar;",
  "java/jassimp.jar;",
  "java/javacord-2.0.17-shaded.jar;",
  "java/javax.activation-api.jar;",
  "java/jaxb-api.jar;",
  "java/jaxb-runtime.jar;",
  "java/lwjgl.jar;",
  "java/lwjgl-natives-windows.jar;",
  "java/lwjgl-glfw.jar;",
  "java/lwjgl-glfw-natives-windows.jar;",
  "java/lwjgl-jemalloc.jar;",
  "java/lwjgl-jemalloc-natives-windows.jar;",
  "java/lwjgl-opengl.jar;",
  "java/lwjgl-opengl-natives-windows.jar;",
  "java/lwjgl_util.jar;",
  "java/commons-compress-1.18.jar;",
  "java/sqlite-jdbc-3.27.2.1.jar;",
  "java/trove-3.0.3.jar;",
  "java/uncommons-maths-1.2.3.jar;",
  "java/"
)

$PZ_CLASSPATH = $PZ_CLASSPATH_LIST -join ""
#Launch Arguments
$ArgumentList = @(
  "-Djava.awt.headless=true ",
  "-Dzomboid.steam=1 ",
  "-Dzomboid.znetlog=1 ",
  "-XX:+UseZGC ",
  "-XX:-CreateCoredumpOnCrash ",
  "-XX:-OmitStackTraceInFastThrow ",
  "-Xms16g ",
  "-Xmx16g ",
  "-Djava.library.path=natives/;natives/win64/;. ",
  "-cp $PZ_CLASSPATH zombie.network.GameServer ",
  "-statistic 0"
)

Add-Member -InputObject $Server -Name "ArgumentList" -Type NoteProperty -Value $ArgumentList
Add-Member -InputObject $Server -Name "Launcher" -Type NoteProperty -Value "$($Server.Path)\jre64\bin\java.exe"
Add-Member -InputObject $Server -Name "WorkingDirectory" -Type NoteProperty -Value "$($Server.Path)"

#---------------------------------------------------------
# Function that runs just before the server starts.
#---------------------------------------------------------

function Start-ServerPrep {

  Write-ScriptMsg "Port Forward : 16261, 8766 and 8767 in TCP and UDP to $($Global.InternalIP)"

}

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server", "Backups", "Warnings")
