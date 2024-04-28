#Server Name, Always Match the Launcher and config file name.
$Name = $ServerCfg

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

  #Login username used by SteamCMD
  Login              = "anonymous"

  #Server Name
  ServerName         = "My PalWorld Server"

  #Server Description
  ServerDescription  = "My PalWorld Server Description"

  #Server Region
  Region             = "NA"

  #Server Password
  Password           = "CHANGEME"

  #Maximum number of players
  MaxPlayers         = 32

  #Is the server listed in the community server list
  Public             = $true

  #Server Port
  Port               = 8211

  #Rcon IP
  ManagementIP       = "127.0.0.1"

  #Rcon Port
  ManagementPort     = "25575"

  #Rcon Password
  ManagementPassword = "CHANGEMETOO"

  #EDIT OTHER SERVER SETTINGS AT THE BOTTOM OF THIS FILE

  #---------------------------------------------------------
  # Server Installation Details
  #---------------------------------------------------------

  #Name of the Server Instance
  Name               = $Name

  #Server Installation Path
  Path               = ".\servers\$Name"

  #Server configuration folder
  ConfigFolder       = ".\servers\$Name\Pal\Saved\Config\WindowsServer"

  #Steam Server App Id
  AppID              = 2394010

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
  ProcessName        = "PalServer-Win64-Shipping-Cmd"

  #Use PID instead of Process Name.
  UsePID             = $true

  #Server Executable
  Exec               = ".\servers\$Name\PalServer.exe"

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
  Saves = ".\servers\$($Server.Name)\Pal\Saved"

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
  Protocol   = "ARRCON"

  #Times at which the servers will warn the players that it is about to restart. (in seconds between each timers)
  Timers     = [System.Collections.ArrayList]@(240, 50, 10) #Total wait time is 240+50+10 = 300 seconds or 5 minutes

  #message that will be sent. % is a wildcard for the timer.
  MessageMin = "The_server_will_restart_in_%_minutes_!"

  #message that will be sent. % is a wildcard for the timer.
  MessageSec = "The_server_will_restart_in_%_seconds_!"

  #command to send a message.
  CmdMessage = "Broadcast"

  #command to save the server
  CmdSave    = "Save"

  #How long to wait in seconds after the save command is sent.
  SaveDelay  = 75

  #command to stop the server
  CmdStop    = "Shutdown"
}
#Create the object
$Warnings = New-Object -TypeName PsObject -Property $WarningsDetails

#---------------------------------------------------------
# Launch Arguments
#---------------------------------------------------------

#Launch Arguments
$ArgumentList = @(
  "-ServerName=`"$($Server.ServerName)`" ",
  "-port=$($Server.Port) ",
  "-players=$($Server.MaxPlayers) ",
  "-log ",
  "-nosteam ",
  "-useperfthreads ",
  "-NoAsyncLoadingThread ",
  "-UseMultithreadForDS ",
  "EpicApp=PalServer"
)
Add-Member -InputObject $Server -Name "ArgumentList" -Type NoteProperty -Value $ArgumentList
Add-Member -InputObject $Server -Name "Launcher" -Type NoteProperty -Value "$($Server.Exec)"
Add-Member -InputObject $Server -Name "WorkingDirectory" -Type NoteProperty -Value "$($Server.Path)"

#---------------------------------------------------------
# Function that runs just before the server starts.
#---------------------------------------------------------

function Start-ServerPrep {
  Write-ScriptMsg "Writing config to $($Server.ConfigFolder)\PalWorldSettings.ini"

  # YOU MUST EDIT THE CONFIGURATION BELLOW AS THE FILE WILL BE OVERWRITTEN AT EACH LAUNCH.

  $content ="[/Script/Pal.PalGameWorldSettings]`r`n" +
  'OptionSettings=(' +
  'Difficulty=None,' +
  'DayTimeSpeedRate=1.000000,' +
  'NightTimeSpeedRate=1.000000,' +
  'ExpRate=1.000000,' +
  'PalCaptureRate=1.000000,' +
  'PalSpawnNumRate=1.000000,' +
  'PalDamageRateAttack=1.000000,' +
  'PalDamageRateDefense=1.000000,' +
  'PlayerDamageRateAttack=1.000000,' +
  'PlayerDamageRateDefense=1.000000,' +
  'PlayerStomachDecreaceRate=1.000000,' +
  'PlayerStaminaDecreaceRate=1.000000,' +
  'PlayerAutoHPRegeneRate=1.000000,' +
  'PlayerAutoHpRegeneRateInSleep=1.000000,' +
  'PalStomachDecreaceRate=1.000000,' +
  'PalStaminaDecreaceRate=1.000000,' +
  'PalAutoHPRegeneRate=1.000000,' +
  'PalAutoHpRegeneRateInSleep=1.000000,' +
  'BuildObjectDamageRate=1.000000,' +
  'BuildObjectDeteriorationDamageRate=1.000000,' +
  'CollectionDropRate=1.000000,' +
  'CollectionObjectHpRate=1.000000,' +
  'CollectionObjectRespawnSpeedRate=1.000000,' +
  'EnemyDropItemRate=1.000000,' +
  'DeathPenalty=Item,' +
  'bEnablePlayerToPlayerDamage=False,' +
  'bEnableFriendlyFire=False,' +
  'bEnableInvaderEnemy=True,' +
  'bActiveUNKO=False,' +
  'bEnableAimAssistPad=True,' +
  'bEnableAimAssistKeyboard=False,' +
  'DropItemMaxNum=3000,' +
  'DropItemMaxNum_UNKO=100,' +
  'BaseCampMaxNum=128,' +
  'BaseCampWorkerMaxNum=15,' +
  'DropItemAliveMaxHours=1.000000,' +
  'bAutoResetGuildNoOnlinePlayers=False,' +
  'AutoResetGuildTimeNoOnlinePlayers=72.000000,' +
  'GuildPlayerMaxNum=20,' +
  'PalEggDefaultHatchingTime=72.000000,' +
  'WorkSpeedRate=1.000000,' +
  'bIsMultiplay=False,' +
  'bIsPvP=False,' +
  'bCanPickupOtherGuildDeathPenaltyDrop=False,' +
  'bEnableNonLoginPenalty=True,' +
  'bEnableFastTravel=True,' +
  'bIsStartLocationSelectByMap=True,' +
  'bExistPlayerAfterLogout=False,' +
  'bEnableDefenseOtherGuildPlayer=False,' +
  'CoopPlayerMaxNum=4,' +
  'ServerPlayerMaxNum=32,' +
  'ServerName="Default Palworld Server",' +
  'ServerDescription="",' +
  'AdminPassword="",' +
  'ServerPassword="",' +
  'PublicPort=8211,' +
  'PublicIP="",' +
  'RCONEnabled=False,' +
  'RCONPort=25575,' +
  'Region="",' +
  'bUseAuth=True,' +
  'BanListURL="https://api.palworldgame.com/api/banlist.txt")'

  # YOU MUST EDIT THE CONFIGURATION ABOVE AS THE FILE WILL BE OVERWRITTEN AT EACH LAUNCH.

  $content = $content.Replace('ServerName="Default Palworld Server"', "ServerName=`"$($Server.ServerName)`"")
  $content = $content.Replace('ServerDescription=""', "ServerDescription=`"$($Server.ServerDescription)`"")
  $content = $content.Replace('AdminPassword=""', "AdminPassword=`"$($Server.ManagementPassword)`"")
  $content = $content.Replace('ServerPassword=""', "ServerPassword=`"$($Server.Password)`"")
  $content = $content.Replace('ServerPlayerMaxNum=32', "ServerPlayerMaxNum=$($Server.MaxPlayers)")
  $content = $content.Replace('PublicPort=8211', "PublicPort=$($Server.Port)")
  $content = $content.Replace('RCONPort=25575', "RCONPort=$($Server.ManagementPort)")
  $content = $content.Replace('Region=""', "Region=`"$($Server.Region)`"")
  $content = $content.Replace('RCONEnabled=False', "RCONEnabled=$($WarningsDetails.Use.ToString())")
  if (-not (Test-Path -Path $Server.ConfigFolder)) {
    New-Item -ItemType Directory -Path $Server.ConfigFolder -Force | Out-Null
  }
  Set-Content -Path "$($Server.ConfigFolder)/PalWorldSettings.ini" -Value $content

  Write-ScriptMsg "Port Forward : $($Server.Port) in TCP and UDP to $($Global.InternalIP)"
}

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server", "Backups", "Warnings")
