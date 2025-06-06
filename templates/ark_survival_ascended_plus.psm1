# This script is meant to allow you to easily setup multiple ASA Servers using shared configurations.
# Makes sure the json file is in the correct location and the name matches.
$jsonFilePath = ".\configs\shared\ark_shared.json"
$ServerData = Get-Content $jsonFilePath | ConvertFrom-Json

#Server Name, Always Match the Launcher and config file name.
$Name = $ServerCfg

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

  #Server specific settings
  #Name of the server in the Server Browser *No Question Mark*
  SessionName            = "PowerShellGSM Ark Ascended Server"

  #Server Port
  Port                   = 7777

  #World Name *NO SPACES or Question Mark*
  WorldName              = "TheIsland_WP"

  #Rcon Port
  ManagementPort         = 27020

  #Shared Server Settings, set values directly if you don't want to use the shared data.
  #Login username used by SteamCMD
  Login                  = $ServerData.Login # or "anonymous"

  #Maximum Number of Players
  MaxPlayers             = $ServerData.MaxPlayers # or 64

  #Password to join the server *NO SPACES or Question Mark*
  Password               = $ServerData.Password # or "CHANGEME"

  #Enable PVE "True" or "False"
  ServerPVE              = $ServerData.ServerPVE # or "True"

  #Enable BattlEye "True" or "False"
  BattlEye               = $ServerData.BattlEye # or "True"

  # Savegame Folder - Leave blank for default.
  SaveFolder             = $ServerData.SaveFolder # or ""

  # Comma Separated list of Mod/Project IDs from https://www.curseforge.com/ark-survival-ascended (no spaces) - Use empty string "" if you use no mods.
  Mods                   = $ServerData.Mods # or ""

  # IF isCluster is true, CusterId and CusterDirOverride are required
  IsCluster              = $ServerData.IsCluster # or $false

  # Cluster ID for Cross Server Transfers
  ClusterId              = $ServerData.ClusterId # or ""

  # Cluster Dir for Cross Server Transfers
  ClusterDirOverride     = $ServerData.ClusterDirOverride # or ""

  # What platforms can play on this server (PC, PS5, XSX, WINGDK, ALL)
  ServerPlatform         = $ServerData.ServerPlatform # or "ALL"

  # Enforce Exclusive Join to require a whitelist of players allowed to join this server.
  EnableExclusiveJoin    = $ServerData.EnableExclusiveJoin # or $false

  # Exlusive Join List of EOSIDs, comma separated.
  # If excluded then will use the files found in the /ShooterGame/Binaries/Win64 folder.
  # PlayersExclusiveJoinList.txt - Whitelist of players
  # PlayersJoinNoCheckList.txt - Whitelist of players that con join over capacity
  ExclusiveJoinList     = $ServerData.ExclusiveJoinList # or ""

  # Extra parameters - Leave blank for default.
  ExtraParams            = $ServerData.ExtraParams # or "-NoTransferFromFiltering -ServerGameLogIncludeTribeLogs -ServerGameLog -AutoManagedMods"

  #Enable Rcon "True" or "False"
  EnableRcon             = $ServerData.EnableRcon # or "True"

  #User Store - This saves Survivor and Tribe data as part of the world save instead of using seperate files.
  EnableUsesStore        = $ServerData.EnableUsesStore # or $false

  #Rcon IP, usually localhost
  ManagementIP           = $ServerData.ManagementIP # or "127.0.0.1"

  #Rcon / Admin Password *NO SPACES or Question Mark*
  ManagementPassword     = $ServerData.ManagementPassword

  #---------------------------------------------------------
  # Server Installation Details
  #---------------------------------------------------------

  #Name of the Server Instance
  Name                   = $Name

  #Server Installation Path
  Path                   = ".\servers\$Name"

  #Server configuration folder
  ConfigFolder           = ".\servers\$Name\ShooterGame\Saved\Config\WindowsServer"

  #Steam Server App Id
  AppID                  = 2430930

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
  AutoRestartTime        = @(3, 0, 0)

  #Process name in the task manager
  ProcessName            = "ArkAscendedServer"

  #Use PID instead of Process Name.
  UsePID                 = $true

  #Server Executable
  Exec                   = ".\servers\$Name\ShooterGame\Binaries\Win64\ArkAscendedServer.exe"

  #Allow force close, usefull for server without RCON.
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
  Path  = ".\backups\$($Server.Name)"

  #Number of days of backups to keep.
  Days  = 7

  #Number of weeks of weekly backups to keep.
  Weeks = 4

  #Folder to include in backup
  Saves = ".\servers\$($Server.Name)\ShooterGame\Saved"

  #Exclusions (Regex use | as separator)
  Exclusions = "(.*\d{2}\.\d{2}\.\d{2}\.ark$|.*\.profilebak$|.*\.tribebak$)"
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
  CmdMessage = "ServerChat"

  #command to save the server
  CmdSave    = "SaveWorld"

  #How long to wait in seconds after the save command is sent.
  SaveDelay  = 15

  #command to stop the server
  CmdStop    = "DoExit"
}
#Create the object
$Warnings = New-Object -TypeName PsObject -Property $WarningsDetails

#---------------------------------------------------------
# Launch Arguments
#---------------------------------------------------------

#Launch Arguments
$ArgumentList = @(
  "$($Server.WorldName)",
  "?listen",
  "?SessionName=`"`"`"$($Server.SessionName)`"`"`"", #Yes, triple double quotes are needed only here.
  "?Port=$($Server.Port)",
  "?RCONEnabled=$($Server.EnableRcon)",
  "?RCONPort=$($Server.ManagementPort)",
  "?ServerPVE=$($Server.ServerPVE)"
)

if($Server.Password) {
  $ArgumentList += "?ServerPassword=`"$($Server.Password)`"" #If using Exclusive Join, then a Server Password can be excluded.
}

if ($Server.SaveFolder) {
  $ArgumentList += "?AltSaveDirectoryName=$($Server.SaveFolder)"
}

if ($Server.ManagementPassword) {
  $ArgumentList += "?ServerAdminPassword=`"$($Server.ManagementPassword)`"" #Fix Server Admin Password Issues.
}

$ArgumentList += " -WinLiveMaxPlayers=$($Server.MaxPlayers)" #Fix MaxPlayers not working.

if($Server.IsCluster) {
  if ($Server.ClusterId) {
    $ArgumentList += " -clusterid=$($Server.ClusterId) -ClusterDirOverride=`"$($Server.ClusterDirOverride)`""
  }
}

if ($Server.ServerPlatform) {
  $ArgumentList += " -ServerPlatform=$($Server.ServerPlatform)"
}

if ($Server.EnableExclusiveJoin)
{
  if($Server.ExclusiveJoinList) {
    $ArgumentList += " -exclusivejoin=$($Server.ExclusiveJoinList)"
  } else {
    $ArgumentList += " -exclusivejoin"
  }
}

if($Server.EnableUsesStore){
  $ArgumentList += " -usestore"
}

if ($Server.BattlEye -eq "False") {
  $ArgumentList += " -NoBattlEye"
}

if ($Server.Mods) {
  $ArgumentList += " -Mods=$($Server.Mods)"
}

if ($Server.ExtraParams) {
  $ArgumentList += " " + $Server.ExtraParams
}

Add-Member -InputObject $Server -Name "ArgumentList" -Type NoteProperty -Value $ArgumentList
Add-Member -InputObject $Server -Name "Launcher" -Type NoteProperty -Value "$($Server.Exec)"
Add-Member -InputObject $Server -Name "WorkingDirectory" -Type NoteProperty -Value "$($Server.Path)"

#---------------------------------------------------------
# Function that runs just before the server starts.
#---------------------------------------------------------

function Start-ServerPrep {

  Write-ScriptMsg "Port Forward : $($Server.Port) and $($Server.Port+1) in TCP & UDP to $($Global.InternalIP)"

}

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server", "Backups", "Warnings")
