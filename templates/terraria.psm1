<#
  ".\servers\$Name\serverconfig.txt"
#>

#Server Name, Always Match the Launcher and config file name.
$Name = $ServerCfg

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

  #Login username used by SteamCMD
  Login              = "anonymous"

  # Specifies the configuration file to use *(relative the the game)
  ConfigFile         = "serverconfig.txt"

  # Specifies the port to listen on.
  Port               = 7777

  # Sets the max number of players
  MaxPlayers         = 8

  # Sets the server password
  Password           = "CHANGEME"

  #Choose the world to load. Do not try to save it somewhere else, it won't work.
  World              = "$Env:userprofile\Documents\My Games\Terraria\Worlds\ServerWorld.wld"

  #Should match the above world.
  WorldName          = "ServerWorld"

  #Specifies the world seed when using -autocreate
  Seed               = "1234"

  #Creates a world if none is found in the path specified by World.
  #World size is specified by: 1(small), 2(medium), and 3(large).
  AutoCreate         = 2

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
  Path               = ".\servers\$Name"

  #Server configuration folder
  ConfigFolder       = ".\servers\$Name"

  #Server Version
  Version            = "1423"

  #Steam Server App Id *0 Skip SteamCMD Installation
  AppID              = 0

  #Name of the Beta Build
  BetaBuild          = ""

  #Beta Build Password
  BetaBuildPassword  = ""

  #Set to $true if you want this server to automatically update.
  AutoUpdates        = $false

  #Process name in the task manager
  ProcessName        = "TerrariaServer"

  #Use PID instead of Process Name.
  UsePID             = $true

  #Server Executable
  Exec               = ".\servers\$Name\TerrariaServer.exe"

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
  Saves = "$Env:userprofile\Documents\My Games\Terraria\Worlds"

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
  Use        = $false

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
  "-config `"$($Server.ConfigFile)`" ",
  "-port $($Server.Port) ",
  "-maxplayers $($Server.MaxPlayers) ",
  "-password `"$($Server.Password)`" ",
  "-world `"$($Server.World)`" ",
  "-worldname `"$($Server.WorldName)`" ",
  "-seed `"$($Server.Seed)`" ",
  "-autocreate $($Server.AutoCreate) ",
  "-secure ",
  "-noupnp ",
  "-steam "
)
Add-Member -InputObject $Server -Name "ArgumentList" -Type NoteProperty -Value $ArgumentList
Add-Member -InputObject $Server -Name "Launcher" -Type NoteProperty -Value "$($Server.Exec)"
Add-Member -InputObject $Server -Name "WorkingDirectory" -Type NoteProperty -Value "$($Server.Path)"

#---------------------------------------------------------
# Function that runs just before the server starts.
#---------------------------------------------------------

function Start-ServerPrep {
  #If server is not installed, install it.
  $Version = Get-Content -Path ".\servers\$($Server.Name)\Version.txt" -ErrorAction SilentlyContinue
  if (-not (Test-Path -Path $Server.Exec -PathType "leaf" -ErrorAction SilentlyContinue) -or ($Version -ne $Server.Version)) {
    Write-ScriptMsg "Installing Server..."
    #Create Temporary Download Folder
    New-Item -Path ".\downloads" -ItemType "directory" -ErrorAction SilentlyContinue
    #Download Microsoft XNA Framework
    Invoke-Download -Uri "https://download.microsoft.com/download/5/3/A/53A804C8-EC78-43CD-A0F0-2FB4D45603D3/xnafx40_redist.msi" -OutFile ".\downloads\xna.msi" -ErrorAction SilentlyContinue
    #Install Microsoft XNA
    $Package = Resolve-Path -Path ".\downloads\xna.msi"
    Start-Process -FilePath msiexec.exe -ArgumentList "/qn /i $Package" -Verb "RunAs" -Wait
    #Download Server Zip
    Invoke-Download -Uri "https://terraria.org/api/download/pc-dedicated-server/terraria-server-$($Server.Version).zip" -OutFile ".\downloads\terraria.zip" -ErrorAction SilentlyContinue
    #Extract Server to Temporary Folder
    Expand-Archive -Path ".\downloads\terraria.zip" -DestinationPath ".\downloads\terraria\" -Force
    #Copy Server Files to Server Directory
    Copy-Item -Path ".\downloads\terraria\$($Server.Version)\Windows\TerrariaServer.exe" -Destination $Server.Path -Force
    Copy-Item -Path ".\downloads\terraria\$($Server.Version)\Windows\ReLogic.Native.dll" -Destination $Server.Path -Force
    if (-not (Test-Path -Path $Server.ConfigFile -PathType "leaf" -ErrorAction SilentlyContinue)) {
      Copy-Item -Path ".\downloads\terraria\$($Server.Version)\Windows\serverconfig.txt" -Destination $Server.Path
    }
    #Cleanup
    Remove-Item -Path ".\downloads" -Recurse -Force -ErrorAction SilentlyContinue
    #Remove old version file
    Remove-Item -Path ".\servers\$($Server.Name)\Version.txt" -Confirm:$false -ErrorAction SilentlyContinue
    #Write new Version File
    New-Item -Path ".\servers\$($Server.Name)\" -Name "Version.txt" -ItemType "file" -Value "$($Server.Version)" -Force -ErrorAction SilentlyContinue
  }
  Write-ScriptMsg "Port Forward : $($Server.Port) in TCP and UDP to $($Global.InternalIP)"
}

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server", "Backups", "Warnings")