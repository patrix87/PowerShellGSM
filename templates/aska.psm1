#---------------------------------------------------------
# ASKA Dedicated Server Template for PowerShellGSM
#---------------------------------------------------------
#
# IMPORTANT - PLEASE READ BEFORE FIRST LAUNCH:
#
# ASKA handles its configuration differently from most other
# game servers supported by PowerShellGSM. The game stores
# all server settings in a file called "server properties.txt".
#
# The ASKA developers require moving this file
# OUT of the server installation directory because SteamCMD
# will overwrite it with defaults whenever the server is
# updated. This is a common source of confusion and lost
# configurations for ASKA server operators.
#
# To protect your settings, this template stores the
# "server properties.txt" in the PowerShellGSM configs
# folder (.\configs\aska\) instead of the server install
# folder (.\servers\aska\). The AskaServer.exe is launched
# with the -propertiesPath argument pointing to this safe
# location.
#
# FIRST LAUNCH WALKTHROUGH:
#
#   1. SteamCMD installs the server to .\servers\aska\
#   2. The default "server properties.txt" is automatically
#      copied from .\servers\aska\ into .\configs\aska\
#   3. Your settings from this template (ports, name, token,
#      etc.) are written into that copy.
#   4. The server starts briefly, then stops and opens
#      .\configs\aska\ in Explorer so you can review the
#      "server properties.txt" file.
#   5. Set your Authentication Token in this template (or
#      directly in the properties file), then relaunch.
#
# AFTER FIRST LAUNCH:
#
#   - To change server settings, edit THIS template file
#     (.\configs\aska.psm1). Your changes are written into
#     "server properties.txt" automatically on each launch.
#   - You can also edit .\configs\aska\server properties.txt
#     directly, but be aware that values managed by this
#     template will be overwritten on the next launch.
#   - The copy in .\servers\aska\ is NOT used and can be
#     safely ignored. SteamCMD may overwrite it at any time.
#
# AUTHENTICATION TOKEN (REQUIRED):
#
#   ASKA requires a Steam Game Server Login Token (GSLT).
#   Generate one at:
#     https://steamcommunity.com/dev/managegameservers
#   Use App ID: 1898300
#   Paste the token into the AuthenticationToken field below.
#
#---------------------------------------------------------

#Server Name, Always Match the Launcher and config file name.
$Name = $ServerCfg

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

  #Login username used by SteamCMD
  Login              = "anonymous"

  #Server Display Name (shown in server browser)
  DisplayName        = "My ASKA Server"

  #Server Name (internal identifier)
  ServerName         = "MyASKAServer"

  #Save ID (leave empty to auto-generate on first launch)
  SaveID             = ""

  #World Seed (leave empty for random)
  Seed               = ""

  #Password to join the server (leave empty for no password)
  Password           = ""

  #Steam Game Server Login Token (GSLT)
  #Generate at https://steamcommunity.com/dev/managegameservers using App ID 1898300
  AuthenticationToken = "CHANGEME"

  #Server Region
  #Options: default, asia, japan, europe, south america, south korea,
  #         usa east, usa west, australia, canada east, hong kong,
  #         india, turkey, united arab emirates, usa south central
  Region             = "default"

  #Steam Game Port
  Port               = 27015

  #Steam Query Port
  QueryPort          = 27016

  #Keep Server World Alive when no players are connected
  KeepWorldAlive     = "false"

  #Autosave Style
  #Options: every morning, disabled, every 5 minutes, every 10 minutes,
  #         every 15 minutes, every 20 minutes
  AutosaveStyle      = "every morning"

  #Game Mode: normal or custom
  Mode               = "normal"

  #---------------------------------------------------------
  # Custom Mode Settings (only applied when Mode = "custom")
  #---------------------------------------------------------

  #Terrain Aspect: smooth, normal, rocky
  TerrainAspect        = "normal"

  #Terrain Height: flat, normal, varied
  TerrainHeight        = "normal"

  #Starting Season: spring, summer, autumn, winter
  StartingSeason       = "spring"

  #Year Length: minimum, reduced, default, extended, maximum
  YearLength           = "normal"

  #Precipitation: 0 (sunny) through 6 (soggy)
  Precipitation        = 3

  #Day Length: minimum, reduced, default, extended, maximum
  DayLength            = "normal"

  #Structure Decay: off, easy, normal, hard
  StructureDecay       = "medium"

  #Invasion Difficulty: off, easy, normal, hard
  InvasionDifficulty   = "normal"

  #Monster Density: low, medium, high
  MonsterDensity       = "medium"

  #Monster Population: low, medium, high
  MonsterPopulation    = "medium"

  #Wulfar Population: low, medium, high
  WulfarPopulation     = "medium"

  #Herbivore Population: low, medium, high
  HerbivorePopulation  = "medium"

  #Bear Population: low, medium, high
  BearPopulation       = "medium"

  #---------------------------------------------------------
  # Server Installation Details
  #---------------------------------------------------------

  #Name of the Server Instance
  Name               = $Name

  #Server Installation Path
  Path               = ".\servers\$Name"

  #Server configuration folder.
  #ASKA-SPECIFIC: This is set to .\configs\aska\ instead of the server
  #install directory (.\servers\aska\) because SteamCMD overwrites the
  #"server properties.txt" file during updates. Storing it here keeps
  #your configuration safe. See the header of this file for details.
  ConfigFolder       = ".\configs\$Name"

  #Steam Server App Id *Dedicated Server*
  AppID              = 3246670

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
  AutoRestartTime    = @(4, 0, 0)

  #Process name in the task manager
  ProcessName        = "AskaServer"

  #Use PID instead of Process Name.
  UsePID             = $true

  #Server Executable
  Exec               = ".\servers\$Name\AskaServer.exe"

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
  StartupWaitTime    = 15
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
  #ASKA saves are stored in the user's AppData folder.
  #Update the SaveID below to match your server's save id from "server properties.txt"
  Saves = "$Env:userprofile\AppData\LocalLow\Sand Sailor Studio\Aska\data\server"

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
  #ASKA does not currently support RCON.
  Use        = $false

  #What protocol to use : RCON, ARRCON, Telnet, Websocket
  Protocol   = "ARRCON"

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
$PropertiesPath = Resolve-Path -Path "$($Server.ConfigFolder)" -ErrorAction SilentlyContinue
if (-not $PropertiesPath) {
  $PropertiesPath = "$($Server.ConfigFolder)"
}
$ArgumentList = @(
  "-propertiesPath `"$PropertiesPath\server properties.txt`""
)
Add-Member -InputObject $Server -Name "ArgumentList" -Type NoteProperty -Value $ArgumentList
Add-Member -InputObject $Server -Name "Launcher" -Type NoteProperty -Value "$($Server.Exec)"
Add-Member -InputObject $Server -Name "WorkingDirectory" -Type NoteProperty -Value "$($Server.Path)"

#---------------------------------------------------------
# Function that runs just before the server starts.
#---------------------------------------------------------

function Start-ServerPrep {

  #Set SteamAppId environment variable (required by ASKA)
  $env:SteamAppId = "1898300"

  #Ensure the config folder exists
  if (-not (Test-Path $Server.ConfigFolder)) {
    $null = New-Item -ItemType Directory -Path $Server.ConfigFolder -Force
    Write-ScriptMsg "Created configuration folder: $($Server.ConfigFolder)"
  }

  #Path to the server properties file (in the safe config folder)
  $PropertiesFile = "$($Server.ConfigFolder)\server properties.txt"

  #Path to the default server properties file (in the server install directory)
  $DefaultPropertiesFile = "$($Server.Path)\server properties.txt"

  # If the properties file doesn't exist in the config folder, copy the default from the install directory.
  if (-not (Test-Path $PropertiesFile)) {
    if (Test-Path $DefaultPropertiesFile) {
      Copy-Item -Path $DefaultPropertiesFile -Destination $PropertiesFile -Force
      Write-ScriptMsg "================================================================"
      Write-ScriptMsg "ASKA SETUP: Copied 'server properties.txt' from the server"
      Write-ScriptMsg "install directory to the PowerShellGSM configs folder."
      Write-ScriptMsg "  From : $DefaultPropertiesFile"
      Write-ScriptMsg "  To   : $PropertiesFile"
      Write-ScriptMsg "This is required because SteamCMD overwrites the original file"
      Write-ScriptMsg "during server updates. Your configuration is now stored safely"
      Write-ScriptMsg "in the configs folder and will not be lost."
      Write-ScriptMsg "To change server settings, edit the PowerShellGSM template at:"
      Write-ScriptMsg "  .\configs\$($Server.Name).psm1"
      Write-ScriptMsg "================================================================"
    }
    else {
      Write-ScriptMsg "Server properties file not found in install directory."
      Write-ScriptMsg "This is expected on first install. The file will be generated"
      Write-ScriptMsg "when AskaServer.exe runs for the first time."
      Write-ScriptMsg "Port Forward : $($Server.Port) and $($Server.QueryPort) in TCP and UDP to $($Global.InternalIP)"
      return
    }
  }

  # Read the current properties file
  $Properties = Get-Content $PropertiesFile

  # Helper function to update or add a property
  function Set-ServerProperty {
    param (
      [string]$PropertyName,
      [string]$PropertyValue,
      [ref]$PropertiesRef
    )
    $Pattern = "^$([regex]::Escape($PropertyName))\s*=.*"
    $Replacement = "$PropertyName = $PropertyValue"
    if ($PropertiesRef.Value -match $Pattern) {
      $PropertiesRef.Value = $PropertiesRef.Value -replace $Pattern, $Replacement
    }
    else {
      $PropertiesRef.Value += $Replacement
    }
  }

  # Update server properties from the PowerShellGSM configuration
  Set-ServerProperty -PropertyName "display name" -PropertyValue $Server.DisplayName -PropertiesRef ([ref]$Properties)
  Set-ServerProperty -PropertyName "server name" -PropertyValue $Server.ServerName -PropertiesRef ([ref]$Properties)
  Set-ServerProperty -PropertyName "password" -PropertyValue $Server.Password -PropertiesRef ([ref]$Properties)
  Set-ServerProperty -PropertyName "steam game port" -PropertyValue $Server.Port -PropertiesRef ([ref]$Properties)
  Set-ServerProperty -PropertyName "steam query port" -PropertyValue $Server.QueryPort -PropertiesRef ([ref]$Properties)
  Set-ServerProperty -PropertyName "authentication token" -PropertyValue $Server.AuthenticationToken -PropertiesRef ([ref]$Properties)
  Set-ServerProperty -PropertyName "region" -PropertyValue $Server.Region -PropertiesRef ([ref]$Properties)
  Set-ServerProperty -PropertyName "keep server world alive" -PropertyValue $Server.KeepWorldAlive -PropertiesRef ([ref]$Properties)
  Set-ServerProperty -PropertyName "autosave style" -PropertyValue $Server.AutosaveStyle -PropertiesRef ([ref]$Properties)
  Set-ServerProperty -PropertyName "mode" -PropertyValue $Server.Mode -PropertiesRef ([ref]$Properties)

  if ($Server.SaveID -ne "") {
    Set-ServerProperty -PropertyName "save id" -PropertyValue $Server.SaveID -PropertiesRef ([ref]$Properties)
  }

  if ($Server.Seed -ne "") {
    Set-ServerProperty -PropertyName "seed" -PropertyValue $Server.Seed -PropertiesRef ([ref]$Properties)
  }

  # Apply custom mode settings only if mode is set to custom
  if ($Server.Mode -eq "custom") {
    Set-ServerProperty -PropertyName "terrain aspect" -PropertyValue $Server.TerrainAspect -PropertiesRef ([ref]$Properties)
    Set-ServerProperty -PropertyName "terrain height" -PropertyValue $Server.TerrainHeight -PropertiesRef ([ref]$Properties)
    Set-ServerProperty -PropertyName "starting season" -PropertyValue $Server.StartingSeason -PropertiesRef ([ref]$Properties)
    Set-ServerProperty -PropertyName "year length" -PropertyValue $Server.YearLength -PropertiesRef ([ref]$Properties)
    Set-ServerProperty -PropertyName "precipitation" -PropertyValue $Server.Precipitation -PropertiesRef ([ref]$Properties)
    Set-ServerProperty -PropertyName "day length" -PropertyValue $Server.DayLength -PropertiesRef ([ref]$Properties)
    Set-ServerProperty -PropertyName "structure decay" -PropertyValue $Server.StructureDecay -PropertiesRef ([ref]$Properties)
    Set-ServerProperty -PropertyName "invasion dificulty" -PropertyValue $Server.InvasionDifficulty -PropertiesRef ([ref]$Properties)
    Set-ServerProperty -PropertyName "monster density" -PropertyValue $Server.MonsterDensity -PropertiesRef ([ref]$Properties)
    Set-ServerProperty -PropertyName "monster population" -PropertyValue $Server.MonsterPopulation -PropertiesRef ([ref]$Properties)
    Set-ServerProperty -PropertyName "wulfar population" -PropertyValue $Server.WulfarPopulation -PropertiesRef ([ref]$Properties)
    Set-ServerProperty -PropertyName "herbivore population" -PropertyValue $Server.HerbivorePopulation -PropertiesRef ([ref]$Properties)
    Set-ServerProperty -PropertyName "bear population" -PropertyValue $Server.BearPopulation -PropertiesRef ([ref]$Properties)
  }

  # Write updated properties back to file
  Write-ScriptMsg "Writing configuration to $PropertiesFile"
  Set-Content -Path $PropertiesFile -Value $Properties

  Write-ScriptMsg "Port Forward : $($Server.Port) and $($Server.QueryPort) in TCP and UDP to $($Global.InternalIP)"
  Write-ScriptMsg "IMPORTANT: ASKA requires a Steam Game Server Login Token (GSLT)."
  Write-ScriptMsg "Generate one at https://steamcommunity.com/dev/managegameservers using App ID 1898300"
}

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server", "Backups", "Warnings")