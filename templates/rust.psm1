<#
Edit configuration in ".\servers\Rust\server\[Identity]\cfg\serverauto.cfg"
#>

#Server Name, Always Match the Launcher and config file name.
$Name = $ServerCfg

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

  #Login username used by SteamCMD
  Login              = "anonymous"

  #Name of the server
  Hostname           = "PowerShellGSM Rust Server"

  #Identity of the server
  Identity           = $Name

  #Description of the server \n for new line
  Description        = "Welcome to my server"

  #URL of the website of the server
  Website            = "https://example.com/"

  #URL of the banner of the server (1024 x 512 png or jpg)
  Banner             = "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png"

  #URL of the logo image shown in the Rust+ App (256 x 256 png or jpg)
  Logo               = "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png"

  #Max number of Players
  MaxPlayers         = 50

  #Server Port
  Port               = 28015

  #World Name
  worldName          = "Procedural Map"

  #World Size
  worldSize          = 4000

  #World Seed
  Seed               = 1234

  #PVE mode ("True" = PVE | "False" = PVP)
  PVE                = "False"

  #Save Interval
  saveInterval       = 300

  #Save Interval, Max 30, recommended 10
  TickRate           = 10

  #Decay Scale (1 = normal | 0 = off)
  DecayScale         = 1

  #Enable or disable instant crafting ("True" = instant crafting enabled | "False" = instant crafting disabled)
  InstantCraft       = "False"

  #SteamID64 of the Steam Group associated with the server to whitelist only that group.
  SteamGroup         = ""

  #Enable Easy Anti-Cheat (1 = enabled | 0 = disabled)
  EAC                = 1

  #Enable Valve Anti Cheat security ("True" = enabled | "False" = disabled)
  VAC                = "True"

  #rcon version (0 = Source RCON | 1 = websocket)
  rconVersion        = 0

  #Rcon IP
  ManagementIP       = "127.0.0.1"

  #Rcon Port
  ManagementPort     = 28016

  #Rcon Password
  ManagementPassword = "CHANGEME"

  #---------------------------------------------------------
  # Server Installation Details
  #---------------------------------------------------------

  #Name of the Server Instance
  Name               = $Name

  #Server Installation Path
  Path               = ".\servers\$Name"

  #Server configuration folder
  ConfigFolder       = ".\servers\$Name\server\$Name\cfg"

  #Steam Server App Id
  AppID              = 258550

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
  ProcessName        = "RustDedicated"

  #Use PID instead of Process Name.
  UsePID             = $true

  #Server Executable
  Exec               = ".\servers\$Name\RustDedicated.exe"

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
  StartupWaitTime    = 0
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
  Saves = ".\servers\$($Server.Name)\server\$($Server.Identity)"

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
  MessageMin = "The server will restart in % minutes !"

  #message that will be sent. % is a wildcard for the timer.
  MessageSec = "The server will restart in % seconds !"

  #command to send a message.
  CmdMessage = "say"

  #command to save the server
  CmdSave    = "server.save"

  #How long to wait in seconds after the save command is sent.
  SaveDelay  = 15

  #command to stop the server
  CmdStop    = "server.stop"
}
#Create the object
$Warnings = New-Object -TypeName PsObject -Property $WarningsDetails

#---------------------------------------------------------
# Launch Arguments
#---------------------------------------------------------

#Launch Arguments
$ArgumentList = @(
  "-batchmode ",
  "-nographics ",
  "+server.ip $($Global.InternalIP) ",
  "+server.port $($Server.Port) ",
  "+server.hostname `"$($Server.Hostname)`" ",
  "+server.identity `"$($Server.Identity)`" ",
  "+server.description `"$($Server.Description)`" ",
  "+server.url `"$($Server.Website)`" ",
  "+server.headerimage `"$($Server.Banner)`" ",
  "+server.logoimage `"$($Server.Logo)`" ",
  "+server.maxplayers $($Server.MaxPlayers) ",
  "+server.level `"$($Server.worldName)`" ",
  "+server.worldsize $($Server.worldSize) ",
  "+server.seed $($Server.Seed) ",
  "+server.pve $($Server.PVE) ",
  "+decay.scale $($Server.DecayScale) ",
  "+craft.instant $($Server.InstantCraft) ",
  "+server.steamgroup $($Server.SteamGroup) ",
  "+server.tickrate $($Server.TickRate) ",
  "+server.saveinterval $($Server.saveInterval) ",
  "+server.eac $($Server.EAC) ",
  "+server.secure $($Server.VAC) ",
  "+app.port $($Server.Port + 69) ",
  "+rcon.ip $($Server.ManagementIP) ",
  "+rcon.port $($Server.ManagementPort) ",
  "+rcon.password `"$($Server.ManagementPassword)`" ",
  "+rcon.web $($Server.rconVersion) ",
  "-logfile $($Server.Identity).txt "
)
Add-Member -InputObject $Server -Name "ArgumentList" -Type NoteProperty -Value $ArgumentList
Add-Member -InputObject $Server -Name "Launcher" -Type NoteProperty -Value "$($Server.Exec)"
Add-Member -InputObject $Server -Name "WorkingDirectory" -Type NoteProperty -Value "$($Server.Path)"

#---------------------------------------------------------
# Function that runs just before the server starts.
#---------------------------------------------------------

function Start-ServerPrep {

  Write-ScriptMsg "Port Forward : $($Server.Port), $($Server.ManagementPort), $($Server.Port + 69) in TCP and UDP to $($Global.InternalIP)"

}

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server", "Backups", "Warnings")