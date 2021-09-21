<#
#Change your servers settings in ".\servers\Insurgency\Saved\Config\WindowsServer"
#>

#Server Name, use the same name to share game files.
$Name = "InsurgencySandstorm"


#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

    #Unique Identifier used to track processes. Must be unique to each servers.
    UID = "InsurgencySandstorm_1"

    #Login username used by SteamCMD
    Login = "anonymous"

    #Name of the server in the Server Browser
    SessionName = "My Insurgency Server"

    #Maximum Number of Players
    MaxPlayers = 8

    #Password to join the World *NO SPACES*
    Password = "CHANGEME"

    #Server Port
    Port = 27102

    #Query Port
    QueryPort = 27131

    #Token -> https://steamcommunity.com/dev/managegameservers
    GSLTToken = "CHANGEME"

    #GameStatToken -> https://gamestats.sandstorm.game/
    GameStatsToken = "CHANGEME"

    #Scenario
    Scenario = "Scenario_Citadel_Survival"

    #Map
    Map = "Citadel"

    #Map Cycle : Create a new text document in Insurgency/Config/Server named MapCycle.txt
    MapCycle = "MapCycle"

    #Admins : Create a new text document in Insurgency/Config/Server named Admins.txt steamID64, one per line
    Admins = "Admins"

    #Motd : Create a new text document in Insurgency/Config/Server named MOTD.txt
    Motd = "MOTD"

    #Mods comma separted -> https://sandstorm-support.newworldinteractive.com/hc/en-us/articles/360049211072-Server-Admin-Guide
    Mods = ""

    #Mutators comma separted -> https://sandstorm-support.newworldinteractive.com/hc/en-us/articles/360049211072-Server-Admin-Guide
    Mutators = ""

    #Official RuleSet
    OfficialRulesSet = "OfficialRules"

    #Rcon IP, usually localhost
    ManagementIP = "127.0.0.1"

    #Rcon Port
    ManagementPort = 27015

    #Rcon Password *NO SPACES*
    ManagementPassword = "CHANGEME"

#---------------------------------------------------------
# Server Installation Details
#---------------------------------------------------------

    #Name of the Server Instance
    Name = $Name

    #Server Installation Path
    Path = ".\servers\$Name"

    #Server configuration folder
    ConfigFolder = ".\servers\$Name\Saved\Config\WindowsServer"

    #Steam Server App Id
    AppID = 581330

    #Name of the Beta Build
    BetaBuild = ""

    #Beta Build Password
    BetaBuildPassword = ""

    #Auto-Update Enable or Disable Auto-Updates, some games don't work well with SteamCMD
    AutoUpdates = $true

    #Process name in the task manager
    ProcessName = "InsurgencyServer"

    #Use PID instead of Process Name, Will still use processname if the PID fails to find anything.
    UsePID = $true

    #Server Executable
    Exec = ".\servers\$Name\InsurgencyServer.exe"

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
    Saves = ".\servers\$($Server.Name)\Insurgency\Config\Server"
}
#Create the object
$Backups = New-Object -TypeName PsObject -Property $BackupsDetails

#---------------------------------------------------------
# Restart Warnings (Require RCON, Telnet or WebSocket API)
#---------------------------------------------------------

$WarningsDetails = @{
    #Use Rcon to restart server softly.
    Use = $true

    #What protocol to use : Rcon, Telnet, Websocket
    Protocol = "Rcon"

    #Times at which the servers will warn the players that it is about to restart. (in seconds between each timers)
    Timers = [System.Collections.ArrayList]@(240,50,10) #Total wait time is 240+50+10 = 300 seconds or 5 minutes

    #message that will be sent. % is a wildcard for the timer.
    MessageMin = "The server will restart in % minutes !"

    #message that will be sent. % is a wildcard for the timer.
    MessageSec = "The server will restart in % seconds !"

    #command to send a message.
    CmdMessage = "say"

    #command to save the server
    CmdSave = "listplayers"

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

$ArgumentList = @(
    "$($Server.Map)",
    "?Scenario=$($Server.Scenario)",
    "?MaxPlayers=$($Server.MaxPlayers)",
    "?password=`"$($Server.Password)`" ",
    "-Port=$($Server.Port) ",
    "-QueryPort=$($Server.QueryPort) ",
    "-hostname=`"$($Server.SessionName)`" ",
    "-GSLTToken=`"$($Server.GSLTToken)`" ",
    "-GameStatsToken=`"$($Server.GameStatsToken)`" ",
    "-Gamestats",
    "-MapCycle=`"$($Server.MapCycle)`" ",
    "-AdminList=`"$($Server.Admins)`" ",
    "-MOTD=`"$($Server.Motd)`" ",
    "-ruleset=`"$($Server.OfficialRulesSet)`" ",
    "-CmdModList=`"$($Server.Mods)`" ",
    "-mutators=`"$($Server.Mutators)`" ",
    "-Rcon -RconListenPort=`"$($Server.ManagementPort)`" -RconPassword=`"$($Server.ManagementPassword)`" ",
    "-log"
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

Export-ModuleMember -Function Start-ServerPrep -Variable @("Server","Backups","Warnings")