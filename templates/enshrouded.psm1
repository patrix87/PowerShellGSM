#Server Name, Always Match the Launcher and config file name.
$Name = $ServerCfg

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

  #Login username used by SteamCMD
  Login              = "anonymous"

  #Server Name
  ServerName         = "My Enshrouded Server"

  #All passwords must be unique and at least 8 characters long.
  #Visitor Password
  VisitorPassword    = "CHANGEME0"

  #Guest / Helper Password
  GuestPassword      = "CHANGEME1"

  #Friend Password
  FriendPassword     = "CHANGEME2"

  #Admin Password
  AdminPassword      = "CHANGEME3"

  #$true : write every setting from the $Settings table in Start-ServerPrep at each launch.
  #$false : only set the name, port, player slots and passwords, every other setting stays as in the server's own file (changed in game or by hand).
  UseFullConfig      = $true

  #Maximum number of players
  MaxPlayers         = 16

  #Server Query Port
  Port               = 15637

  #Rcon IP (Not available yet)
  ManagementIP       = "127.0.0.1"

  #Rcon Port
  ManagementPort     = "15638"

  #Rcon Password
  ManagementPassword = "CHANGEMETOO"

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
  AppID              = 2278520

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
  ProcessName        = "enshrouded_server"

  #Use PID instead of Process Name.
  UsePID             = $true

  #Server Executable
  Exec               = ".\servers\$Name\enshrouded_server.exe"

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
  Saves = ".\servers\$($Server.Name)\savegame"

  #Exclusions (Regex use | as separator)
  Exclusions = ""
}
#Create the object
$Backups = New-Object -TypeName PsObject -Property $BackupsDetails

#---------------------------------------------------------
# Restart Warnings (Require RCON, Telnet, StdIn or REST API)
#---------------------------------------------------------

$WarningsDetails = @{
  #Use Rcon to restart server softly.
  Use        = $false

  #What protocol to use : RCON, ARRCON, Telnet, StdIn, RestAPI
  Protocol   = "ARRCON"

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
  "-log"
)
Add-Member -InputObject $Server -Name "ArgumentList" -Type NoteProperty -Value $ArgumentList
Add-Member -InputObject $Server -Name "Launcher" -Type NoteProperty -Value "$($Server.Exec)"
Add-Member -InputObject $Server -Name "WorkingDirectory" -Type NoteProperty -Value "$($Server.Path)"

#---------------------------------------------------------
# Function that runs just before the server starts.
#---------------------------------------------------------

function Start-ServerPrep {
  $ConfigFile = "$($Server.ConfigFolder)\enshrouded_server.json"
  Write-ScriptMsg "Writing config to $ConfigFile"

  <#
  YOU MUST EDIT THE CONFIGURATION BELOW AS THE FILE WILL BE OVERWRITTEN AT EACH LAUNCH.
  (Only when UseFullConfig is $true. With $false, this table is not used.)

  Values below are the defaults from the enshrouded_server.json the dedicated server
  generates itself (Enshrouded 1.0, build 25936466, 2026-10-15), kept in the same order
  as that file.
  Reference : https://enshrouded.zendesk.com/hc/en-us/articles/20453241249821-Server-Gameplay-Settings

  Numbers outside a setting's range are clamped to its minimum or maximum.
  Invalid text stops the server from booting, and the console names the bad value.
  Durations are in nanoseconds : 1 minute = 60000000000.

  Entries marked "MANAGED" are overwritten further down from the Server Configuration
  section at the top of this file. Do not edit them here.
  #>

  $Settings = [ordered]@{

    #--- Server ---------------------------------------------------------------

    name                 = "MANAGED"
    saveDirectory        = "MANAGED"
    logDirectory         = "MANAGED"
    ip                   = "MANAGED"
    queryPort            = "MANAGED"
    slotCount            = "MANAGED"

    #Server list tags. Not documented by Keen.
    tags                 = @()

    #Proximity or Global (one server wide channel).
    voiceChatMode        = "Proximity"
    enableVoiceChat      = $false
    enableTextChat       = $false

    #Default, Relaxed, Hard, Survival or Custom.
    #Relaxed : fewer enemies, more resources and loot.
    #Hard : more and more aggressive enemies.
    #Survival : Hard plus additional survival mechanics.
    #gameSettings below only applies with Custom.
    gameSettingsPreset   = "Default"

    #--- Gameplay Settings (Custom preset only) -------------------------------

    gameSettings         = [ordered]@{

      #Player max health, mana and stamina. 0.25 to 4.
      playerHealthFactor                = 1
      playerManaFactor                  = 1
      playerStaminaFactor               = 1

      #Body heat against cold weather : 0.5 Low, 1 Default, 1.5 High, 2 Max.
      playerBodyHeatFactor              = 1

      #Oxygen, so time underwater. 0.5 to 2.
      playerDivingTimeFactor            = 1

      #$false : weapons never break.
      enableDurability                  = $true

      #Hunger and starvation : starving players lose health until they eat or drink.
      enableStarvingDebuff              = $false

      #Food buff durations. 0.5 to 2.
      foodBuffDurationFactor            = 1

      #Time in the hungry state before starving sets in. 5 to 20 minutes.
      fromHungerToStarving              = 600000000000

      #Time players can stay inside the Shroud. 0.5 to 2.
      shroudTimeFactor                  = 1

      #What players lose on death, stored in a tombstone to recover.
      #AddBackpackMaterials (only materials), Everything or NoTombstone.
      tombstoneMode                     = "AddBackpackMaterials"

      #$false : the glider ignores air turbulence.
      enableGliderTurbulences           = $true

      #New weather phenomena : Disabled, Rare, Normal or Often.
      weatherFrequency                  = "Normal"

      #Fish strength : VeryEasy, Easy, Normal, Hard or VeryHard.
      fishingDifficulty                 = "Normal"

      #Mining damage : more terraforming and resources per hit. 0.5 to 2.
      miningDamageFactor                = 1

      #Plant growth speed. 0.25 to 2.
      plantGrowthSpeedFactor            = 1

      #Materials per loot stack (chests, defeated enemies...). 0.25 to 2.
      resourceDropStackAmountFactor     = 1

      #Production times of workshop items. 0.25 to 2.
      factoryProductionSpeedFactor      = 1

      #Runes returned when salvaging upgraded weapons. 0 to 1.
      perkUpgradeRecyclingFactor        = 0.5

      #Runes needed to upgrade weapons. 0.25 to 2.
      perkCostFactor                    = 1

      #XP from combat (0.25 to 2), mining (0 to 2), exploring and quests (0.25 to 2).
      experienceCombatFactor            = 1
      experienceMiningFactor            = 1
      experienceExplorationQuestsFactor = 1

      #Enemies per encounter : Automatic, Few, Normal, Many or Extreme.
      #Automatic scales it to the players actively playing nearby.
      randomSpawnerAmount               = "Automatic"

      #Enemies allowed to attack at the same time : Few, Normal, Many or Extreme.
      aggroPoolAmount                   = "Normal"

      #Enemy damage (0.25 to 5 before 1.0, reworked in 1.0) and health (0.25 to 4). Bosses excluded.
      enemyDamageFactor                 = 1
      enemyHealthFactor                 = 1

      #Enemy stamina, higher takes longer to stun. 0.5 to 2. Bosses excluded.
      enemyStaminaFactor                = 1

      #How far enemies see and hear players. 0.5 to 2. Bosses excluded.
      enemyPerceptionRangeFactor        = 1

      #Boss damage and health. 0.2 to 5.
      bossDamageFactor                  = 1
      bossHealthFactor                  = 1

      #How often enemies attack. 0.25 to 4. Bosses excluded.
      threatBonus                       = 1

      #$true : enemies only attack once attacked. Bosses excluded.
      pacifyAllEnemies                  = $false

      #Taming progress lost when startling the animal :
      #KeepProgress, LoseSomeProgress or LoseAllProgress.
      tamingStartleRepercussion         = "LoseSomeProgress"

      #Length of the day and of the night. 2 to 60 minutes.
      dayTimeDuration                   = 1800000000000
      nightTimeDuration                 = 720000000000

      #Shroud curse : Easy (off), Normal or Hard (double chance).
      curseModifier                     = "Normal"

      #Flame level at which Flame Altars can push back the Shroud.
      flameLevelFogRemoval              = 11
    }

    #--- User Groups ------------------------------------------------------------

    #The password a player joins with decides their group and permissions.
    #Every group can play the world outside bases : combat, gathering, digging, quests.
    #canKickBan : kick and ban players.
    #canAccessInventories : chests and other containers.
    #canEditWorld : change the world outside bases.
    #canEditBase : change bases (blocks, props, terraforming).
    #canExtendBase : add, upgrade and remove Flame Altars.
    #reservedSlots : slots kept free for the group. Once only reserved slots remain, the server shows as full to other groups.
    #More groups can be added with their own name and password.
    userGroups           = @(
      [ordered]@{
        name                 = "Admin"
        password             = "MANAGED"
        canKickBan           = $true
        canAccessInventories = $true
        canEditWorld         = $true
        canEditBase          = $true
        canExtendBase        = $true
        reservedSlots        = 0
      },
      [ordered]@{
        name                 = "Friend"
        password             = "MANAGED"
        canKickBan           = $false
        canAccessInventories = $true
        canEditWorld         = $true
        canEditBase          = $true
        canExtendBase        = $false
        reservedSlots        = 0
      },
      [ordered]@{
        name                 = "Guest"
        password             = "MANAGED"
        canKickBan           = $false
        canAccessInventories = $false
        canEditWorld         = $true
        canEditBase          = $false
        canExtendBase        = $false
        reservedSlots        = 0
      },
      [ordered]@{
        name                 = "Visitor"
        password             = "MANAGED"
        canKickBan           = $false
        canAccessInventories = $false
        canEditWorld         = $false
        canEditBase          = $false
        canExtendBase        = $false
        reservedSlots        = 0
      }
    )

    #Players banned in game. Kept from the existing file, not set here.
    bannedAccounts       = @()
  }

  # YOU MUST EDIT THE CONFIGURATION ABOVE AS THE FILE WILL BE OVERWRITTEN AT EACH LAUNCH.

  if ($Server.UseFullConfig) {
    #Keep the bans made in game.
    if (Test-Path -Path $ConfigFile) {
      try {
        $Current = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json
        if ($Current.bannedAccounts) {
          $Settings.bannedAccounts = @($Current.bannedAccounts)
        }
      }
      catch {
        Write-Warning -Message "Unable to read the bans from $ConfigFile, they will be reset."
      }
    }
  }
  else {
    #Only the MANAGED values below are set, every other setting stays as in the server's own file.
    if (-not (Test-Path -Path $ConfigFile)) {
      Write-ScriptMsg "Configuration file not found, the server creates it on its first start."
      return
    }
    try {
      $Settings = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json
    }
    catch {
      Write-Warning -Message "Unable to read $ConfigFile, leaving it unchanged."
      return
    }
  }

  #Values driven by the Server Configuration section at the top of this file.
  $Settings.name          = $Server.ServerName
  $Settings.saveDirectory = "./savegame"
  $Settings.logDirectory  = "./logs"
  $Settings.ip            = $Global.InternalIP
  $Settings.queryPort     = $Server.Port
  $Settings.slotCount     = $Server.MaxPlayers

  $Passwords = @{
    Admin   = $Server.AdminPassword
    Friend  = $Server.FriendPassword
    Guest   = $Server.GuestPassword
    Visitor = $Server.VisitorPassword
  }
  foreach ($Group in $Settings.userGroups) {
    if ($Passwords.Contains($Group.name)) {
      $Group.password = $Passwords[$Group.name]
    }
  }

  if (-not (Test-Path -Path $Server.ConfigFolder)) {
    New-Item -ItemType Directory -Path $Server.ConfigFolder -Force | Out-Null
  }
  Set-Content -Path $ConfigFile -Value ($Settings | ConvertTo-Json -Depth 10)

  Write-ScriptMsg "Port Forward : $($Server.Port) in TCP and UDP to $($Global.InternalIP)"
}

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server", "Backups", "Warnings")
