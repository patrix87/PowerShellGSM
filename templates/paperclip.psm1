<#
  Edit .\servers\Paperclip\server.properties
#>

#Server Name, Always Match the Launcher and config file name.
$Name = $ServerCfg

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

  #Login username used by SteamCMD
  Login                = "anonymous"

  # Server Name
  SessionName          = "PowerShellGSM Minecraft Server"

  # Message of the day, also shows in server browser
  MOTD                 = "\u00A76My Server - \u00A7AMinecraft 1.17.1"

  # Specifies the port to listen on.
  Port                 = 25565

  # Specifies the port to listen on.
  QueryPort            = 25565

  # Sets the max number of players
  MaxPlayers           = 64

  # Sets the server Game Mode
  GameMode             = "survival"

  #Level Name
  World                = "world"

  #Level Type
  LevelType            = "default"

  #Specifies the world seed when using -autocreate
  Seed                 = 1234

  #Difficulty
  Difficulty           = "normal"

  #Amount of ram dedicated to the server in Go
  Ram                  = 2

  #Rcon IP
  ManagementIP         = "127.0.0.1"

  #Rcon Port
  ManagementPort       = 25575

  #Rcon Password
  ManagementPassword   = "CHANGEME"

  #---------------------------------------------------------
  # Server Installation Details
  #---------------------------------------------------------

  #Name of the Server Instance
  Name                 = $Name

  #Server Installation Path
  Path                 = ".\servers\$Name"

  #Server configuration folder
  ConfigFolder         = ".\servers\$Name"

  #Server Version https://adoptopenjdk.net/releases.html?variant=openjdk16&jvmVariant=hotspot
  JavaVersionLink      = "https://github.com/AdoptOpenJDK/openjdk16-binaries/releases/download/jdk-16.0.1%2B9/OpenJDK16U-jre_x64_windows_hotspot_16.0.1_9.msi"

  #Server Version https://papermc.io/downloads#Paper-1.17
  PaperclipVersionLink = "https://papermc.io/api/v2/projects/paper/versions/1.17.1/builds/265/downloads/paper-1.17.1-265.jar"

  #Steam Server App Id *0 Skip SteamCMD Installation
  AppID                = 0

  #Name of the Beta Build
  BetaBuild            = ""

  #Beta Build Password
  BetaBuildPassword    = ""

  #Set to $true if you want this server to automatically update.
  AutoUpdates          = $false

  #Process name in the task manager
  ProcessName          = "java"

  #Use PID instead of Process Name.
  UsePID               = $true

  #Server Executable
  Exec                 = ".\servers\$Name\paperclip.jar"

  #Allow force close, usefull for server without RCON and Multiple instances.
  AllowForceClose      = $true

  #Process Priority Realtime, High, Above normal, Normal, Below normal, Low
  UsePriority          = $true
  AppPriority          = "High"

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

  UseAffinity          = $false
  AppAffinity          = 15

  #Should the server validate install after installation or update *(recommended)
  Validate             = $true

  #How long should it wait to check if the server is stable
  StartupWaitTime      = 10
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
  CmdMessage = "say"

  #command to save the server
  CmdSave    = "save-all"

  #How long to wait in seconds after the save command is sent.
  SaveDelay  = 15

  #command to stop the server
  CmdStop    = "stop"
}
#Create the object
$Warnings = New-Object -TypeName PsObject -Property $WarningsDetails

#---------------------------------------------------------
# Launch Arguments
#---------------------------------------------------------

#Launch Arguments
$ArgumentList = @(
  "-Xms$($Server.Ram)G ",
  "-Xmx$($Server.Ram)G ",
  "-jar paperclip.jar ",
  "--nogui"
)
Add-Member -InputObject $Server -Name "ArgumentList" -Type NoteProperty -Value $ArgumentList
Add-Member -InputObject $Server -Name "Launcher" -Type NoteProperty -Value "$($Global.JavaDirectory)\OpenJDK16\bin\java.exe"
Add-Member -InputObject $Server -Name "WorkingDirectory" -Type NoteProperty -Value "$($Server.Path)"

#---------------------------------------------------------
# server.properties
#---------------------------------------------------------

$FileContentList = @(
  "difficulty=$($Server.Difficulty)",
  "gamemode=$($Server.GameMode)",
  "level-name=$($Server.World)",
  "level-seed=$($Server.Seed)",
  "level-type=$($Server.LevelType)",
  "max-players=$($Server.MaxPlayers)",
  "motd=$($Server.MOTD)",
  "enable-rcon=true",
  "rcon.password=$($Server.ManagementPassword)",
  "rcon.port=$($Server.ManagementPort)",
  "server-name=$($Server.SessionName)",
  "server-port=$($Server.Port)",
  "query.port=$($Server.QueryPort)"
)

$FileContent = ($FileContentList -join "`n")

#---------------------------------------------------------
# Function that runs just before the server starts.
#---------------------------------------------------------

function Start-ServerPrep {

  #Create Config File if not created.
  if (-not (Test-Path -Path ".\servers\$($Server.Name)\server.properties" -ErrorAction SilentlyContinue)) {
    Write-Host "Creating Config File"
    New-Item -Path ".\servers\$($Server.Name)\" -Name "server.properties" -ItemType "file" -Value $FileContent
  }
  #Create eula File if not created.
  if (-not (Test-Path -Path ".\servers\$($Server.Name)\eula.txt" -ErrorAction SilentlyContinue)) {
    Write-Host "Creating Config File"
    New-Item -Path ".\servers\$($Server.Name)\" -Name "eula.txt" -ItemType "file" -Value "eula=true"
  }
  #If server is not installed, install it.
  $JavaVersion = Get-Content -Path ".\servers\$($Server.Name)\JavaVersion.txt" -ErrorAction SilentlyContinue
  if (-not (Test-Path -Path $Server.Exec -PathType "leaf" -ErrorAction SilentlyContinue) -or ($JavaVersion -ne $Server.JavaVersionLink)) {
    Write-ScriptMsg "Installing Java..."
    #Create Temporary Download Folder
    New-Item -Path ".\downloads" -ItemType "directory" -ErrorAction SilentlyContinue
    #Download Adopt Openjdk-16.0.2+7
    Invoke-Download -Uri $($Server.JavaVersionLink) -OutFile ".\downloads\OpenJDK16.msi" -ErrorAction SilentlyContinue
    #Install Adopt Openjdk-16.0.2+7
    $Package = Resolve-Path -Path ".\downloads\OpenJDK16.msi"
    Start-Process -FilePath msiexec.exe -ArgumentList "/qn /i $Package ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome INSTALLDIR=`"$($Global.JavaDirectory)\OpenJDK16`" /passive" -Verb "RunAs" -Wait
    #Cleanup
    Remove-Item -Path ".\downloads" -Recurse -Force -ErrorAction SilentlyContinue
    #Remove old version file
    Remove-Item -Path ".\servers\$($Server.Name)\JavaVersion.txt" -Confirm:$false -ErrorAction SilentlyContinue
    #Write new Version File
    New-Item -Path ".\servers\$($Server.Name)\" -Name "JavaVersion.txt" -ItemType "file" -Value "$($Server.JavaVersionLink)" -Force -ErrorAction SilentlyContinue
  }
  $PaperclipVersion = Get-Content -Path ".\servers\$($Server.Name)\PaperVersion.txt" -ErrorAction SilentlyContinue
  if (-not (Test-Path -Path $Server.Exec -PathType "leaf" -ErrorAction SilentlyContinue) -or ($PaperclipVersion -ne $Server.PaperclipVersionLink)) {
    Write-ScriptMsg "Installing Paperclip..."
    #Create Temporary Download Folder
    New-Item -Path ".\downloads" -ItemType "directory" -ErrorAction SilentlyContinue
    #Download Paperclip
    Invoke-Download -Uri $($Server.PaperclipVersionLink) -OutFile ".\downloads\paperclip.jar" -ErrorAction SilentlyContinue
    #Copy Server Files to Server Directory
    Copy-Item -Path ".\downloads\paperclip.jar" -Destination $Server.Path -Force
    #Cleanup
    Remove-Item -Path ".\downloads" -Recurse -Force -ErrorAction SilentlyContinue
    #Remove old version file
    Remove-Item -Path ".\servers\$($Server.Name)\PaperVersion.txt" -Confirm:$false -ErrorAction SilentlyContinue
    #Write new Version File
    New-Item -Path ".\servers\$($Server.Name)\" -Name "PaperVersion.txt" -ItemType "file" -Value "$($Server.PaperclipVersionLink)" -Force -ErrorAction SilentlyContinue
  }
  Write-ScriptMsg "Port Forward : $($Server.Port) in TCP and UDP to $($Global.InternalIP)"
}

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server", "Backups", "Warnings")