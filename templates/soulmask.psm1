#Server Name, Always Match the Launcher and config file name.
$Name = $ServerCfg

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

  #Login username used by SteamCMD
  Login                 = "anonymous"

  #Name of the server in the Server Browser
  SessionName           = "Soulmask"

  #Maximum Number of Players
  MaxPlayers            = 20

  #Password to join the server *NO SPACES*
  Password              = ""
  
  #Admin Password to manage your Server *NO SPACES*
  AdminPassword         = ""

  #Server Port
  Port                  = 7777

  #Query Port
  QueryPort             = 27015

  #Enable PVE "True" or "False"
  ServerPVE             = "True"
  
  #Turns on game console output. "True" or "False"
  ServerLog             = "True"
  
  #Specifies the interval for writing game objects to the database (unit: seconds).
  ServerSaving			= 600
  
  #Specifies the interval for writing the game database to disk (unit: seconds).
  ServerBackup       	= 900
  
  #Specifies how often (minutes) to automatically back up the world save.
  BackupInterval 		= 10
  
  #Specifies the local listening address. Use 0.0.0.0 or the local network card address.
  MultihomeIP           = "0.0.0.0"
  
  #Maintenance port, used for local telnet server maintenance, TCP, does not need to be open.
  ManagementPort        = 18888
  
  #Backs up game saves when the game starts. "True" or "False"
  InitBackup 			= "True"

  #---------------------------------------------------------
  # Server Installation Details
  #---------------------------------------------------------

  #Name of the Server Instance
  Name                   = $Name

  #Server Installation Path
  Path                   = ".\servers\$Name"

  #Server configuration folder
  ConfigFolder           = ".\servers\$Name\WS\Saved\Config\WindowsServer"

  #Steam Server App Id
  AppID                  = 3017310

  #Name of the Beta Build
  BetaBuild              = ""

  #Beta Build Password
  BetaBuildPassword      = ""

  #Set to $true if you want this server to automatically update.
  AutoUpdates            = $true

  #Set to $true if you want this server to automatically restart on crash.
  AutoRestartOnCrash     = $true

  #Set to $true if you want this server to automatically restart at set hour.
  AutoRestart            = $true

  #The time at which the server will restart daily.
  #(Hour, Minute, Seconds)
  AutoRestartTime        = @(4, 0, 0)

  #Process name in the task manager
  ProcessName            = "WSServer-Win64-Shipping"

  #Use PID instead of Process Name.
  UsePID                 = $true

  #Server Executable
  Exec                   = ".\servers\$Name\WSServer.exe"

  #Allow force close, usefull for server without RCON and Multiple instances.
  AllowForceClose        = $true

  #Process Priority Realtime, High, AboveNormal, Normal, BelowNormal, Low
  UsePriority            = $true
  AppPriority            = "High"

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

  UseAffinity            = $false
  AppAffinity            = 15

  #Should the server validate install after installation or update *(recommended)
  Validate               = $true

  #How long should it wait to check if the server is stable
  StartupWaitTime        = 10
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
  Path  = ".\Backup\$($Server.Name)"

  #Number of days of backups to keep.
  Days  = 7

  #Number of weeks of weekly backups to keep.
  Weeks = 16

  #Folder to include in backup
  Saves = ".\servers\$($Server.Name)\WS\Saved\Worlds\Dedicated\Level01_Main"
}
#Create the object
$Backups = New-Object -TypeName PsObject -Property $BackupsDetails

#---------------------------------------------------------
# Restart Warnings (Require RCON, Telnet or WebSocket API)
#---------------------------------------------------------

$WarningsDetails = @{
  #Use Rcon to restart server softly.
  Use        = $true

  #What protocol to use : Rcon, Telnet, Websocket
  Protocol   = "Telnet"

  #Times at which the servers will warn the players that it is about to restart. (in seconds between each timers)
  Timers     = [System.Collections.ArrayList]@(240, 50, 10) #Total wait time is 240+50+10 = 300 seconds or 5 minutes

  #message that will be sent. % is a wildcard for the timer.
  MessageMin = "The server will restart in % minutes !"

  #message that will be sent. % is a wildcard for the timer.
  MessageSec = "The server will restart in % seconds !"

  #command to send a message.
  CmdMessage = ""

  #command to save the server
  CmdSave    = ""

  #How long to wait in seconds after the save command is sent.
  SaveDelay  = 15

  #command to stop the server
  CmdStop    = ""
}
#Create the object
$Warnings = New-Object -TypeName PsObject -Property $WarningsDetails

#---------------------------------------------------------
# Launch Arguments
#---------------------------------------------------------

#Launch Arguments
$ArgumentList = @(
  "Level01_Main ",
  "-server ",
  "-UTF8Output ",
  "-SteamServerName=`"$($Server.SessionName)`" ",
  "-PSW=`"$($Server.Password)`" ",
  "-adminpsw=`"$($Server.AdminPassword)`" ",
  "-MaxPlayers=$($Server.MaxPlayers) ",
  "-backup=$($Server.ServerBackup) ",
  "-saving=$($Server.ServerSaving) ",
  "-MULTIHOME=`"$($Server.MultihomeIP)`" ",
  "-Port=$($Server.Port) ",
  "-QueryPort=$($Server.QueryPort) ",
  "-EchoPort=$($Server.ManagementPort) ",
  "-backupinterval=$($Server.BackupInterval) ",
  "-forcepassthrough "
)

if ($Server.ServerLog -eq "True") {
  $ArgumentList += "-log "
}

if ($Server.InitBackup -eq "True") {
  $ArgumentList += "-initbackup "
}

Add-Member -InputObject $Server -Name "ArgumentList" -Type NoteProperty -Value $ArgumentList
Add-Member -InputObject $Server -Name "Launcher" -Type NoteProperty -Value "$($Server.Exec)"
Add-Member -InputObject $Server -Name "WorkingDirectory" -Type NoteProperty -Value "$($Server.Path)"

#---------------------------------------------------------
# Function that runs just before the server starts.
#---------------------------------------------------------

function Start-ServerPrep {

  Write-ScriptMsg "Port Forward : $($Server.Port), $($Server.Port+1) and $($Server.QueryPort) in TCP & UDP to $($Global.InternalIP)"

}

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server", "Backups", "Warnings")
