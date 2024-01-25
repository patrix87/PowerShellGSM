<#
  ".\servers\TheForest\Multiplayer\config.cfg"
#>

#Server Name, Always Match the Launcher and config file name.
$Name = $ServerCfg

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

  #Login username used by SteamCMD
  Login              = "anonymous"

  #Configuration File #Command line parameters overwrite matching entries defined in the config file.
  ConfigFile         = ".\Multiplayer\config.cfg"

  #Steam Port
  SteamPort          = 8766

  #Game Port
  GamePort           = 27015

  #Query Port
  QueryPort          = 27016

  #Set the server display name
  SessionName        = "PowerShellGSM The Forest Server"

  #Maximum number of players
  MaxPlayers         = 8

  #Join Password
  Password           = "CHANGEME"

  #Admin Password
  AdminPassword      = "CHANGEMETOO"

  #Set the autosave interval in minutes, default is 15
  AutoSaveInterval   = 5

  #Set Save Slot ( 1 | 2 | 3 | 4 | 5 )
  SaveSlot           = 1

  #Set Continue State ("New" | "Continue")
  InitType           = "Continue"

  #Set the game difficult level, default is Normal ("Peaceful" | "Normal" | "Hard")
  Difficulty         = "Normal"

  #Rcon IP
  ManagementIP       = "127.0.0.1"

  #Rcon Port
  ManagementPort     = ""

  #Rcon Password
  ManagementPassword = ""

  #---------------------------------------------------------
  # Server Installation Details
  #---------------------------------------------------------

  #Name of the Server Instance
  Name               = $Name

  #Server Installation Path
  Path               = ".\servers\$Name\"

  #Server configuration folder
  ConfigFolder       = ".\servers\$Name\Multiplayer"

  #Steam Server App Id
  AppID              = 556450

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
  ProcessName        = "TheForestDedicatedServer"

  #Use PID instead of Process Name.
  UsePID             = $true

  #Server Executable
  Exec               = ".\servers\$Name\TheForestDedicatedServer.exe"

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
  #Saves = "$Env:userprofile\AppData\LocalLow\SKS\TheForestDedicatedServer"
  Saves = ".\servers\$($Server.Name)\Multiplayer"

  #Exclusions (Regex use | as separator)
  Exclusions = "()"
}
#Create the object
$Backups = New-Object -TypeName PsObject -Property $BackupsDetails

#---------------------------------------------------------
# Restart Warnings (Require RCON, Telnet or WebSocket API)
#---------------------------------------------------------

$WarningsDetails = @{
  #Use Rcon to restart server softly.
  Use        = $false

  #What protocol to use : Rcon, Telnet, Websocket
  Protocol   = "RCON"

  #Times at which the servers will warn the players that it is about to restart. (in seconds between each timers)
  Timers     = [System.Collections.ArrayList]@(240, 50, 10) #Total wait time is 240+50+10 = 300 seconds or 5 minutes

  #message that will be sent. % is a wildcard for the timer.
  MessageMin = "The server will restart in % minutes !"

  #message that will be sent. % is a wildcard for the timer.
  MessageSec = "The server will restart in % seconds !"

  #command to send a message.
  CmdMessage = "say"

  #command to save the server
  CmdSave    = "saveworld"

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

#Launch Arguments
$ArgumentList = @(
  "-batchmode ",
  "-dedicated ",
  "-nographics ",
  "-nosteamclient ",
  "-serverip $($Global.InternalIP) ",
  "-serversteamport $($Server.SteamPort) ",
  "-servergameport $($Server.GamePort) ",
  "-serverqueryport $($Server.QueryPort) ",
  "-servername `"$($Server.SessionName)`" ",
  "-serverplayers $($Server.maxPlayers) ",
  "-serverpassword `"$($Server.Password)`" ",
  "-serverpassword_admin `"$($Server.AdminPassword)`" ",
  "-serverautosaveinterval $($Server.AutoSaveInterval) ",
  "-slot $($Server.SaveSlot) ",
  "-serverautosaveinterval $($Server.InitType) ",
  "-difficulty `"$($Server.Difficulty)`" ",
  "-configfilepath `"$($Server.ConfigFile)`" ",
  "-savefolderpath .\"
)
Add-Member -InputObject $Server -Name "ArgumentList" -Type NoteProperty -Value $ArgumentList
Add-Member -InputObject $Server -Name "Launcher" -Type NoteProperty -Value "$($Server.Exec)"
Add-Member -InputObject $Server -Name "WorkingDirectory" -Type NoteProperty -Value "$($Server.Path)"

#---------------------------------------------------------
# Function that runs just before the server starts.
#---------------------------------------------------------

function Start-ServerPrep {

  Write-ScriptMsg "Port Forward : 8766, 27015, 27016 in TCP and UDP to $($Global.InternalIP)"

}

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server", "Backups", "Warnings")