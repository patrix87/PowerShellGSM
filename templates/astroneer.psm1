<#
    Edit your configuration in .\servers\Astroneer\Astro\Saved\Config\WindowsServer

    https://blog.astroneer.space/p/astroneer-dedicated-server-details/
#>

#Server Name, Always Match the Launcher and config file name.
$Name = $ServerCfg

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

    #Login username used by SteamCMD
    Login = "anonymous"

    #Server Name
    SessionName = "My Astroneer Server"

    #Server Owner Username
    OwnerName = "user"

    #Server Password
    Password = "CHANGEME"

    #Game Port
    Port = 7777

    #Auto Save Interval in Seconds
    AutoSaveGameInterval = 300

    #Save Backups Interval in Seconds
    BackupSaveGamesInterval = 7200

    #Server Max Framerate
    MaxServerFramerate = 120

    #Server Max Framerate when empty
    MaxServerIdleFramerate = 3

    #Inactive Player Timeout
    PlayerActivityTimeout = 0

    #Rcon IP (not supported by astroneer yet.)
    ManagementIP = "127.0.0.1"

    #Rcon Port
    ManagementPort = 7778

    #Rcon Password
    ManagementPassword = "CHANGEMETOO"

#---------------------------------------------------------
# Server Installation Details
#---------------------------------------------------------

    #Name of the Server Instance
    Name = $Name

    #Server Installation Path
    Path = ".\servers\$Name"

    #Server configuration folder
    ConfigFolder = ".\servers\$Name\Astro\Saved\Config\WindowsServer"

    #Steam Server App Id
    AppID = 728470

    #Name of the Beta Build
    BetaBuild = ""

    #Beta Build Password
    BetaBuildPassword = ""

    #Set to $true if you want this server to automatically update.
    AutoUpdates = $true

	#Set to $true if you want this server to automatically restart on crash.
	AutoRestartOnCrash = $true

	#Set to $true if you want this server to automatically restart at set hour.
	AutoRestart = $true

	#The time at which the server will restart daily.
	#(Hour, Minute, Seconds)
	AutoRestartTime = @(3,0,0)

    #Process name in the task manager
    ProcessName = "AstroServer-Win64-Shipping"

    #Use PID instead of Process Name.
    UsePID = $true

    #Server Executable
    Exec = ".\servers\$Name\AstroServer.exe"

    #Allow force close, usefull for server without RCON and Multiple instances.
    AllowForceClose = $true

    #Process Priority Realtime, High, Above normal, Normal, Below normal, Low
    UsePriority = $true
    AppPriority = "High"

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

    UseAffinity = $false
    AppAffinity = 15

    #Should the server validate install after installation or update *(recommended)
    Validate = $true

    #How long should it wait to check if the server is stable
    StartupWaitTime = 10
}
#Create the object
$Server = New-Object -TypeName PsObject -Property $ServerDetails

#---------------------------------------------------------
# Backups
#---------------------------------------------------------

$BackupsDetails = @{
    #Do Backups
    Use = $true

    #Backup Folder
    Path = ".\backups\$($Server.Name)"

    #Number of days of backups to keep.
    Days = 7

    #Number of weeks of weekly backups to keep.
    Weeks = 4

    #Folder to include in backup
    Saves = ".\servers\$($Server.Name)\Astro\Saved"

}
#Create the object
$Backups = New-Object -TypeName PsObject -Property $BackupsDetails

#---------------------------------------------------------
# Restart Warnings (Require RCON, Telnet or WebSocket API)
#---------------------------------------------------------

$WarningsDetails = @{
    #I can't get that to work correctly...
    #Use Rcon to restart server softly.
    Use = $false

    #What protocol to use : Rcon, Telnet, Websocket
    Protocol = "Rcon"

    #Times at which the servers will warn the players that it is about to restart. (in seconds between each timers)
    Timers = [System.Collections.ArrayList]@(15) #Total wait time is 240+50+10 = 300 seconds or 5 minutes

    #message that will be sent. % is a wildcard for the timer.
    MessageMin = " "

    #message that will be sent. % is a wildcard for the timer.
    MessageSec = " "

    #command to send a message.
    CmdMessage = "DSListPlayers"

    #command to save the server
    CmdSave = "DSSaveGame"

    #How long to wait in seconds after the save command is sent.
    SaveDelay = 15

    #command to stop the server
    CmdStop = "DSServerShutdown"
}
#Create the object
$Warnings = New-Object -TypeName PsObject -Property $WarningsDetails

#---------------------------------------------------------
# Launch Arguments
#---------------------------------------------------------

#Launch Arguments
$ArgumentList = @()
Add-Member -InputObject $Server -Name "ArgumentList" -Type NoteProperty -Value $ArgumentList
Add-Member -InputObject $Server -Name "Launcher" -Type NoteProperty -Value "$($Server.Exec)"
Add-Member -InputObject $Server -Name "WorkingDirectory" -Type NoteProperty -Value "$($Server.Path)"

#---------------------------------------------------------
# Function that runs just before the server starts.
#---------------------------------------------------------

function Start-ServerPrep {

    Set-IniValue -file "$($Server.ConfigFolder)\Engine.ini" -category "URL" -key "Port" -value $Server.Port
    Set-IniValue -file "$($Server.ConfigFolder)\AstroServerSettings.ini" -category "/Script/Astro.AstroServerSettings" -key "PublicIP" -value $Global.ExternalIP
    Set-IniValue -file "$($Server.ConfigFolder)\AstroServerSettings.ini" -category "/Script/Astro.AstroServerSettings" -key "ServerName" -value $Server.SessionName
    Set-IniValue -file "$($Server.ConfigFolder)\AstroServerSettings.ini" -category "/Script/Astro.AstroServerSettings" -key "OwnerName" -value $Server.OwnerName
    Set-IniValue -file "$($Server.ConfigFolder)\AstroServerSettings.ini" -category "/Script/Astro.AstroServerSettings" -key "ServerPassword" -value $Server.Password
    Set-IniValue -file "$($Server.ConfigFolder)\AstroServerSettings.ini" -category "/Script/Astro.AstroServerSettings" -key "AutoSaveGameInterval" -value $Server.AutoSaveGameInterval
    Set-IniValue -file "$($Server.ConfigFolder)\AstroServerSettings.ini" -category "/Script/Astro.AstroServerSettings" -key "BackupSaveGamesInterval" -value $Server.BackupSaveGamesInterval
    Set-IniValue -file "$($Server.ConfigFolder)\AstroServerSettings.ini" -category "/Script/Astro.AstroServerSettings" -key "MaxServerFramerate" -value $Server.MaxServerFramerate
    Set-IniValue -file "$($Server.ConfigFolder)\AstroServerSettings.ini" -category "/Script/Astro.AstroServerSettings" -key "MaxServerIdleFramerate" -value $Server.MaxServerIdleFramerate
    Set-IniValue -file "$($Server.ConfigFolder)\AstroServerSettings.ini" -category "/Script/Astro.AstroServerSettings" -key "PlayerActivityTimeout" -value $Server.PlayerActivityTimeout
    Set-IniValue -file "$($Server.ConfigFolder)\AstroServerSettings.ini" -category "/Script/Astro.AstroServerSettings" -key "ConsolePort" -value $Server.ManagementPort
    Set-IniValue -file "$($Server.ConfigFolder)\AstroServerSettings.ini" -category "/Script/Astro.AstroServerSettings" -key "ConsolePassword" -value $Server.ManagementPassword

    Write-ScriptMsg "Port Forward : $($Server.Port) in TCP and UDP to $($Global.InternalIP)"

}

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server","Backups","Warnings")
