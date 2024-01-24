<#
  Edit configuration in : .\servers\PalWorld\Pal\Saved\Config\WindowsServer\PalWorldSettings.ini
  Instructions here
  https://tech.palworldgame.com/optimize-game-balance
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
  ServerName         = "My PalWorld Server"

  #Server Description (should be changed PalWorldSettings.ini if changed here after the first run)
  ServerDescription  = "My PalWorld Server Description"

  #Server Region (should be changed PalWorldSettings.ini if changed here after the first run)
  Region             = "NA"

  #Server Password (should be changed PalWorldSettings.ini if changed here after the first run)
  ServerPassword     = "CHANGEME"

  #Maximum number of players
  MaxPlayers         = 32

  #Is the server listed in the community server list
  Public             = $true

  #Server Port
  Port               = 8211

  #Rcon IP (Set RCONEnabled=True in PalWorldSettings.ini)
  ManagementIP       = "127.0.0.1"

  #Rcon Port
  ManagementPort     = "25575"

  #Rcon Password (should be changed PalWorldSettings.ini if changed here after the first run)
  ManagementPassword = "CHANGEMETOO"

  #---------------------------------------------------------
  # Server Installation Details
  #---------------------------------------------------------

  #Name of the Server Instance
  Name               = $Name

  #Server Installation Path
  Path               = ".\servers\$Name"

  #Server configuration folder
  ConfigFolder       = ".\servers\$Name\Pal\Saved\Config\WindowsServer\"

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
  ProcessName        = "PalServer"

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
  Saves = ".\servers\$($Server.Name)\Pal\Saved\"

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
  Use        = $true

  #What protocol to use : Rcon, Telnet, Websocket
  Protocol   = "Rcon"

  #Times at which the servers will warn the players that it is about to restart. (in seconds between each timers)
  Timers     = [System.Collections.ArrayList]@(240, 50, 10) #Total wait time is 240+50+10 = 300 seconds or 5 minutes

  #message that will be sent. % is a wildcard for the timer.
  MessageMin = "The server will restart in % minutes !"

  #message that will be sent. % is a wildcard for the timer.
  MessageSec = "The server will restart in % seconds !"

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
  "-ServerName=$($Server.ServerName) ",
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
  # Check if the config file is empty and if so, write the default config to it.
  if ((Get-Content -Raw "$($Server.ConfigFolder)/PalWorldSettings.ini" | Select-String -Pattern '\S').Trim() -eq '') {
    Write-ScriptMsg "Writing default config to $($Server.ConfigFolder)/PalWorldSettings.ini"
    # Write the content to the file
    $content = '[/Script/Pal.PalGameWorldSettings]\r\nOptionSettings=(Difficulty=None,DayTimeSpeedRate=1.000000,NightTimeSpeedRate=1.000000,ExpRate=1.000000,PalCaptureRate=1.000000,PalSpawnNumRate=1.000000,PalDamageRateAttack=1.000000,PalDamageRateDefense=1.000000,PlayerDamageRateAttack=1.000000,PlayerDamageRateDefense=1.000000,PlayerStomachDecreaceRate=1.000000,PlayerStaminaDecreaceRate=1.000000,PlayerAutoHPRegeneRate=1.000000,PlayerAutoHpRegeneRateInSleep=1.000000,PalStomachDecreaceRate=1.000000,PalStaminaDecreaceRate=1.000000,PalAutoHPRegeneRate=1.000000,PalAutoHpRegeneRateInSleep=1.000000,BuildObjectDamageRate=1.000000,BuildObjectDeteriorationDamageRate=1.000000,CollectionDropRate=1.000000,CollectionObjectHpRate=1.000000,CollectionObjectRespawnSpeedRate=1.000000,EnemyDropItemRate=1.000000,DeathPenalty=All,bEnablePlayerToPlayerDamage=False,bEnableFriendlyFire=False,bEnableInvaderEnemy=True,bActiveUNKO=False,bEnableAimAssistPad=True,bEnableAimAssistKeyboard=False,DropItemMaxNum=3000,DropItemMaxNum_UNKO=100,BaseCampMaxNum=128,BaseCampWorkerMaxNum=15,DropItemAliveMaxHours=1.000000,bAutoResetGuildNoOnlinePlayers=False,AutoResetGuildTimeNoOnlinePlayers=72.000000,GuildPlayerMaxNum=20,PalEggDefaultHatchingTime=72.000000,WorkSpeedRate=1.000000,bIsMultiplay=False,bIsPvP=False,bCanPickupOtherGuildDeathPenaltyDrop=False,bEnableNonLoginPenalty=True,bEnableFastTravel=True,bIsStartLocationSelectByMap=True,bExistPlayerAfterLogout=False,bEnableDefenseOtherGuildPlayer=False,CoopPlayerMaxNum=4,ServerPlayerMaxNum=32,ServerName="Default Palworld Server",ServerDescription="",AdminPassword="",ServerPassword="",PublicPort=8211,PublicIP="",RCONEnabled=False,RCONPort=25575,Region="",bUseAuth=True,BanListURL="https://api.palworldgame.com/api/banlist.txt")'
    Set-Content -Path "$($Server.ConfigFolder)/PalWorldSettings.ini" -Value $content

    Set-IniValue -Path "$($Server.ConfigFolder)/PalWorldSettings.ini" -Section "/Script/Pal.PalGameWorldSettings" -Key "ServerName" -Value "$($Server.ServerName)"
    Set-IniValue -Path "$($Server.ConfigFolder)/PalWorldSettings.ini" -Section "/Script/Pal.PalGameWorldSettings" -Key "ServerPassword" -Value "$($Server.Password)"
    Set-IniValue -Path "$($Server.ConfigFolder)/PalWorldSettings.ini" -Section "/Script/Pal.PalGameWorldSettings" -Key "PublicPort" -Value "$($Server.Port)"
    if ($WarningsDetails.Use){
      Set-IniValue -Path "$($Server.ConfigFolder)/PalWorldSettings.ini" -Section "/Script/Pal.PalGameWorldSettings" -Key "RCONEnabled" -Value "True"
    }
    Set-IniValue -Path "$($Server.ConfigFolder)/PalWorldSettings.ini" -Section "/Script/Pal.PalGameWorldSettings" -Key "AdminPassword" -Value "$($Server.ManagementPassword)"
    Set-IniValue -Path "$($Server.ConfigFolder)/PalWorldSettings.ini" -Section "/Script/Pal.PalGameWorldSettings" -Key "RCONPort" -Value "$($Server.ManagementPort)"
    Set-IniValue -Path "$($Server.ConfigFolder)/PalWorldSettings.ini" -Section "/Script/Pal.PalGameWorldSettings" -Key "Region" -Value "$($Server.Region)"

  }
  Write-ScriptMsg "Port Forward : $($Server.Port) in TCP and UDP to $($Global.InternalIP)"
}

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server", "Backups", "Warnings")
