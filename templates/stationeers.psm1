<#
  Not tested but should work.
  Edit .\servers\$Name\default.ini to configure this server
#>

#Server Name, Always Match the Launcher and config file name.
$Name = $ServerCfg

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

  #Login username used by SteamCMD
  Login              = "anonymous"

  #Server Name
  SessionName        = "PowerShellGSM Stationeers Server"

  #Auto Save Interval in seconds
  AutoSaveInterval   = 300

  #Server Owner SteamID64 https://steamid.io/
  Creator            = 76561197993918508

  #World Type
  WorldType          = "Mars"

  #World Name *(Save name)
  WorldName          = "Mars1"

  #World that will be loaded
  LoadWorld          = "MyWorld"

  #Game Port
  Port               = 27500

  #Steam Query Port
  QueryPort          = 27015

  #Server Password
  Password           = "Changeme"

  #Max Players
  MaxPlayers         = 16

  #Clear All Interval (Will delete disconnected players)
  ClearAllInterval   = 0

  #Mod Folder Path
  ModPath            = ".\servers\$Name\mods"

  #Rcon IP
  ManagementIP       = "127.0.0.1"

  #Rcon Port
  ManagementPort     = 27500

  #Rcon Password
  ManagementPassword = "stationeers"

  #---------------------------------------------------------
  # Server Installation Details
  #---------------------------------------------------------

  #Name of the Server Instance
  Name               = $Name

  #Server Installation Path
  Path               = ".\servers\$Name"

  #Server configuration folder
  ConfigFolder       = ".\servers\$Name"

  #Steam Server App Id
  AppID              = 600760

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
  ProcessName        = "rocketstation_DedicatedServer"

  #Use PID instead of Process Name.
  UsePID             = $true

  #Server Executable
  Exec               = ".\servers\$Name\rocketstation_DedicatedServer.exe"

  #Allow force close, usefull for server without RCON and Multiple instances.
  AllowForceClose    = $true

  #Process Priority Realtime, High, Above normal, Normal, Below normal, Low
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
  Saves = ".\servers\$($Server.Name)\saves"
}
#Create the object
$Backups = New-Object -TypeName PsObject -Property $BackupsDetails

#---------------------------------------------------------
# Restart Warnings (Require RCON, Telnet or WebSocket API)
#---------------------------------------------------------

$WarningsDetails = @{
  #Use Rcon to restart server softly.
  Use        = $false #Not quite supported.

  #What protocol to use : Rcon, Telnet, Websocket
  Protocol   = "Rcon"

  #Times at which the servers will warn the players that it is about to restart. (in seconds between each timers)
  Timers     = [System.Collections.ArrayList]@(240, 50, 10) #Total wait time is 240+50+10 = 300 seconds or 5 minutes

  #message that will be sent. % is a wildcard for the timer.
  MessageMin = "The server will restart in % minutes !"

  #message that will be sent. % is a wildcard for the timer.
  MessageSec = "The server will restart in % seconds !"

  #command to send a message.
  CmdMessage = "notice"

  #command to save the server
  CmdSave    = "save $($Server.WorldName)"

  #How long to wait in seconds after the save command is sent.
  SaveDelay  = 15

  #command to stop the server
  CmdStop    = "shutdown"
}
#Create the object
$Warnings = New-Object -TypeName PsObject -Property $WarningsDetails

#---------------------------------------------------------
# Launch Arguments
#---------------------------------------------------------

#Address parsing
if ($Server.ModPath -ne "") {
  $Server.ModPath = (Resolve-CompletePath -Path $Server.ModPath -ParentPath ".\servers\")
}
$LogFilePath = (Resolve-CompletePath -Path "$($Server.Path)\$($Server.Name).txt" -ParentPath ".\servers\")
Add-Member -InputObject $Server -Name "LogFile" -Type NoteProperty -Value $LogFilePath

#Launch Arguments
$ArgumentList = @(
  "-batchmode ",
  "-nographics ",
  "-autostart ",
  "-logfile=$($Server.LogFile) ",
  "-servername=$($Server.SessionName) ",
  "-autosaveinterval=$($Server.AutoSaveInterval) ",
  "-creator=$($Server.Creator) ",
  "-worldtype=$($Server.WorldType) ",
  "-worldname=$($Server.WorldName) ",
  "-loadworld=$($Server.LoadWorld) ",
  "-gameport=$($Server.Port) ",
  "-updateport=$($Server.QueryPort) ",
  "-password=$($Server.Password) ",
  "-maxplayer=$($Server.MaxPlayers) ",
  "-clearallinterval=$($Server.ClearAllInterval) ",
  "-modpath=$($Server.ModPath) ",
  "-bindip=$($Global.InternalIP)"
)
Add-Member -InputObject $Server -Name "ArgumentList" -Type NoteProperty -Value $ArgumentList
Add-Member -InputObject $Server -Name "Launcher" -Type NoteProperty -Value "$($Server.Exec)"
Add-Member -InputObject $Server -Name "WorkingDirectory" -Type NoteProperty -Value "$($Server.Path)"

#---------------------------------------------------------
# Function that runs just before the server starts.
#---------------------------------------------------------

function Start-ServerPrep {

  Write-ScriptMsg "Port Forward : $($Server.Port) and $($Server.QueryPort) in TCP and UDP to $($Global.InternalIP)"

}

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server", "Backups", "Warnings")