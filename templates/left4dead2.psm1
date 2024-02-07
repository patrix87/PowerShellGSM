<#
  Edit configuration in : .\servers\Left4Dead2\left4dead2\cfg\server.cfg
#>

#Server Name, Always Match the Launcher and config file name.
$Name = $ServerCfg

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

  #Login username used by SteamCMD
  Login              = "anonymous"

  #Server Host Name
  SessionName        = "PowerShellGSM Left 4 Dead 2 Server"

  #Game Port
  Port               = 27015

  #Query Port
  QueryPort          = 27005

  #Max number of players
  MaxPlayers         = 4

  #Server Password
  Password           = ""

  #Map
  Map                = "c1m1_hotel"

  #Configuration File
  ConfigFile         = "server.cfg"

  #Rcon IP
  ManagementIP       = "127.0.0.1"

  #Rcon Port
  ManagementPort     = "9000"

  #Rcon Password
  ManagementPassword = ""

  #---------------------------------------------------------
  # Server Installation Details
  #---------------------------------------------------------

  #Name of the Server Instance
  Name               = $Name

  #Server Installation Path
  Path               = ".\servers\$Name"

  #Server configuration folder
  ConfigFolder       = ".\servers\$Name\left4dead2\cfg"

  #Steam Server App Id
  AppID              = 222860

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
  ProcessName        = "srcds"

  #Use PID instead of Process Name.
  UsePID             = $true

  #Server Executable
  Exec               = ".\servers\$Name\srcds.exe"

  #Allow force close, usefull for server without RCON and Multiple instances.
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
  Saves = ".\servers\$($Server.Name)\left4dead2\cfg"

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
  Protocol   = "Telnet"

  #Times at which the servers will warn the players that it is about to restart. (in seconds between each timers)
  Timers     = [System.Collections.ArrayList]@(240, 50, 10) #Total wait time is 240+50+10 = 300 seconds or 5 minutes

  #message that will be sent. % is a wildcard for the timer.
  MessageMin = "The server will restart in % minutes !"

  #message that will be sent. % is a wildcard for the timer.
  MessageSec = "The server will restart in % seconds !"

  #command to send a message.
  CmdMessage = "say"

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

#Launch Arguments
$ArgumentList = @(
  "-console ",
  "-game left4dead2 ",
  "-secure ",
  "-nohltv ",
  "-netconport $($Server.ManagementPort) ",
  "-netconpassword $($Server.ManagementPassword) ",
  "+map $($Server.Map) ",
  "+log on ",
  "+maxplayers $($Server.MaxPlayers) ",
  "+hostport $($Server.Port) ",
  "+clientport $($Server.QueryPort) ",
  "-ip $($Global.InternalIP) ",
  "+hostip $($Global.ExternalIP) ",
  "+exec $($Server.ConfigFile)"
)
Add-Member -InputObject $Server -Name "ArgumentList" -Type NoteProperty -Value $ArgumentList
Add-Member -InputObject $Server -Name "Launcher" -Type NoteProperty -Value "$($Server.Exec)"
Add-Member -InputObject $Server -Name "WorkingDirectory" -Type NoteProperty -Value "$($Server.Path)"

#---------------------------------------------------------
# Function that runs just before the server starts.
#---------------------------------------------------------

$FileContentList = @(
  "hostname `"$($Server.SessionName)`"",
  "rcon_password `"$($Server.ManagementPassword)`"",
  "sv_password `"$($Server.Password)`"",
  "sv_contact `"contact@example.com`"",
  "hostport $($Server.Port)",
  "sv_lan 0",
  "sv_region 0",
  "sv_allow_lobby_connect_only 0",
  "mp_disable_autokick 1",
  "sv_allow_wait_command 0",
  "sv_alternateticks 0",
  "sv_clearhinthistory 0",
  "sv_consistency 0",
  "sv_pausable 0",
  "sv_forcepreload 1",
  "sv_pure_kick_clients 0",
  "sv_pure 0",
  "sv_voiceenable 1",
  "sv_alltalk 1",
  "log on",
  "sv_logecho 0",
  "sv_logfile 1",
  "sv_log_onefile 0",
  "sv_logbans 1",
  "sv_logflush 0",
  "sv_logsdir logs",
  "exec banned_user.cfg",
  "exec banned_ip.cfg",
  "writeip",
  "writeid"
)

$FileContent = ($FileContentList -join "`n")

function Start-ServerPrep {


  #Copy Config File if not created. Do not modify the one in the server directory, it will be overwriten on updates.
  if (-not (Test-Path -Path ".\servers\$($Server.Name)\left4dead2\cfg\$($Server.ConfigFile)" -ErrorAction SilentlyContinue)) {
    Write-Host "Creating Config File"
    New-Item -Path ".\servers\$($Server.Name)\left4dead2\cfg\" -Name "$($Server.ConfigFile)" -ItemType "file" -Value $FileContent
  }

  Write-ScriptMsg "Port Forward : $($Server.Port) in TCP and UDP to $($Global.InternalIP)"

}

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server", "Backups", "Warnings")