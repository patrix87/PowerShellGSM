<#
Configure server in .\servers\$Name\Saved\Config\WindowsServer\ServerSettings.ini
#>
#Server Name, use the same name to share game files.
$Name = "Icarus"

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

    #Unique Identifier used to track processes. Must be unique to each servers.
    UID = "Icarus_1"

    #Login username used by SteamCMD
    Login = "anonymous"

	#Session Name
	SessionName = "My Icarus Server"

    #Max number of Players
    MaxPlayers = 8

	#Password
	Password = "CHANGEME"

	#When the server starts up, if no players join within this time, the server will shutdown and return to lobby. During this window the game will be paused.
	# Values of < 0 will cause the server to run indefinitely.
	# A value of 0 will cause the server to shutdown immediately.
	# Values of > 0 will wait that time in seconds.
	# Default value is 300 seconds (5 minutes).
	# NOTE: Only use low values if you want to use the lobby to start prospects each time.
	ShutdownIfNotJoinedFor = "300"

	#When the server becomes empty the server will shutdown and return to lobby after this time (in seconds). During this window the game will be paused.
	# Values of < 0 will cause the server to run indefinitely.
	# A value of 0 will cause the server to shutdown immediately.
	# Values of > 0 will wait that time in seconds.
	ShutdownIfEmptyFor = "300"

	#If true anyone who joins the lobby can create a new prospect or load an existing one.
	AllowNonAdminsToLaunchProspects = "false"

	#If true anyone who joins the lobby can delete prospects from the server.
	AllowNonAdminsToDeleteProspects = "false"

	#If true, automatically resume the last prospect on startup.
	ResumeProspect = "true"

    #Server Port
    Port = 17777

    #Query Port
    QueryPort = 27015

    #Rcon IP
    ManagementIP = "127.0.0.1"

    #Rcon Port ???
    ManagementPort = 27015

    #Rcon Password
    ManagementPassword = "CHANGEME"

#---------------------------------------------------------
# Server Installation Details
#---------------------------------------------------------

    #Name of the Server Instance
    Name = $Name

    #Server Installation Path
    Path = ".\servers\$Name"

    #Server configuration folder
    ConfigFolder = ".\servers\$Name\Saved\Config\WindowsServer\"

    #Steam Server App Id
    AppID = 2089300

    #Name of the Beta Build
    BetaBuild = ""

    #Beta Build Password
    BetaBuildPassword = ""

    #Set to $true if you want this server to automatically update.
    AutoUpdates = $true

    #Process name in the task manager
    ProcessName = "IcarusDedicatedServer"

    #Use PID instead of Process Name.
    UsePID = $true

    #Server Executable
    Exec = ".\servers\$Name\IcarusDedicatedServer.exe"

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
    Saves = ".\servers\$($Server.Name)\Saved\PlayerData\DedicatedServer\"

}
#Create the object
$Backups = New-Object -TypeName PsObject -Property $BackupsDetails

#---------------------------------------------------------
# Restart Warnings (Require RCON, Telnet or WebSocket API)
#---------------------------------------------------------

$WarningsDetails = @{
    #Use Rcon to restart server softly.
    Use = $false

    #What protocol to use : Rcon, Telnet, Websocket
    Protocol = "Rcon"

    #Times at which the servers will warn the players that it is about to restart. (in seconds between each timers)
    Timers = [System.Collections.ArrayList]@(240,50,10) #Total wait time is 240+50+10 = 300 seconds or 5 minutes

    #message that will be sent. % is a wildcard for the timer.
    MessageMin = "The server will restart in % minutes !"

    #message that will be sent. % is a wildcard for the timer.
    MessageSec = "The server will restart in % seconds !"

    #command to send a message.
    CmdMessage = "AdminBroadcast"

    #command to save the server
    CmdSave = "AdminEndMatch"

    #How long to wait in seconds after the save command is sent.
    SaveDelay = 15

    #command to stop the server
    CmdStop = "exit"
}
#Create the object
$Warnings = New-Object -TypeName PsObject -Property $WarningsDetails

#---------------------------------------------------------
# Launch Arguments
#---------------------------------------------------------

#Launch Arguments
$ArgumentList = @(
    "-MULTIHOME=$($Global.InternalIP) ",
    "-PORT=$($Server.Port) ",
    "-QueryPort=$($Server.QueryPort) ",
	"-SteamServerName=$($Server.SessionName) "
)
Add-Member -InputObject $Server -Name "ArgumentList" -Type NoteProperty -Value $ArgumentList
Add-Member -InputObject $Server -Name "Launcher" -Type NoteProperty -Value "$($Server.Exec)"
Add-Member -InputObject $Server -Name "WorkingDirectory" -Type NoteProperty -Value "$($Server.Path)"

#---------------------------------------------------------
# Function that runs just before the server starts.
#---------------------------------------------------------

function Start-ServerPrep {

    Write-ScriptMsg "Port Forward : $($Server.Port) and $($Server.QueryPort) in TCP and UDP to $($Global.InternalIP)"

}

function Start-ServerPrep {

    Set-IniValue -file "$($Server.ConfigFolder)ServerSettings.ini" -category "/Script/Icarus.DedicatedServerSettings" -key "SessionName" -value $Global.ExternalIP
    Set-IniValue -file "$($Server.ConfigFolder)ServerSettings.ini" -category "/Script/Icarus.DedicatedServerSettings" -key "JoinPassword" -value $Server.Password
    Set-IniValue -file "$($Server.ConfigFolder)ServerSettings.ini" -category "/Script/Icarus.DedicatedServerSettings" -key "MaxPlayers" -value $Server.MaxPlayers
    Set-IniValue -file "$($Server.ConfigFolder)ServerSettings.ini" -category "/Script/Icarus.DedicatedServerSettings" -key "AdminPassword" -value $Server.ManagementPassword
    Set-IniValue -file "$($Server.ConfigFolder)ServerSettings.ini" -category "/Script/Icarus.DedicatedServerSettings" -key "ShutdownIfNotJoinedFor" -value $Server.ShutdownIfNotJoinedFor
    Set-IniValue -file "$($Server.ConfigFolder)ServerSettings.ini" -category "/Script/Icarus.DedicatedServerSettings" -key "ShutdownIfEmptyFor" -value $Server.ShutdownIfEmptyFor
    Set-IniValue -file "$($Server.ConfigFolder)ServerSettings.ini" -category "/Script/Icarus.DedicatedServerSettings" -key "AllowNonAdminsToLaunchProspects" -value $Server.AllowNonAdminsToLaunchProspects
    Set-IniValue -file "$($Server.ConfigFolder)ServerSettings.ini" -category "/Script/Icarus.DedicatedServerSettings" -key "AllowNonAdminsToDeleteProspects" -value $Server.AllowNonAdminsToDeleteProspects
    Set-IniValue -file "$($Server.ConfigFolder)ServerSettings.ini" -category "/Script/Icarus.DedicatedServerSettings" -key "ResumeProspect" -value $Server.ResumeProspect

    Write-ScriptMsg "Port Forward : $($Server.Port) and $($Server.QueryPort) in TCP and UDP to $($Global.InternalIP)"

}


Export-ModuleMember -Function Start-ServerPrep -Variable @("Server","Backups","Warnings")