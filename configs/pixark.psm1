<#
#Change your servers settings in ".\servers\PixArk\ShooterGame\Saved\Config\WindowsServer\GameUserSettings.ini"

Under : [ServerSettings]
Add/Set one of those settings :

Pioneering :

CanPVPAttack=False
ServerPVPCanAttack=False

Fury :

ServerPVE=False
CanPVPAttack=True
ServerPVPCanAttack=False

Chaos:

ServerPVE=False
CanPVPAttack=False
ServerPVPCanAttack=True

#>

$Name = "PixArk"

#---------------------------------------------------------
# Server Configuration
#---------------------------------------------------------

$ServerDetails = @{

    #Name of the server in the Server Browser
    SessionName = "My Pixark Server"

    #Maximum Number of Players
    MaxPlayers = 20

    #Password to join the World *NO SPACES*
    Password = "CHANGEME"

    #Server Port
    Port = 7797

    #World Seed
    Seed = 32399

    #Query Port
    QueryPort = 27515

    #Cube Port
    CubePort = 27518

    #World Name *NO SPACES*
    WorldName = "World"

    #World Type : "SkyPiea_Light" for Skyward or "CubeWorld_Light" for regular
    WorldType = "CubeWorld_Light"

    #Show Floating Damage Text "True" or "False"
    ShowFloatingDamageText = "True"

    #Server Language
    Language = "en"

    #Enable Rcon "True" or "False"
    EnableRcon = "True"

    #Rcon IP, usually localhost
    ManagementIP = "127.0.0.1"

    #Rcon Port
    ManagementPort = 27520

    #Rcon Password *NO SPACES*
    ManagementPassword = "CHANGEME2"

#---------------------------------------------------------
# Server Installation Details
#---------------------------------------------------------

    #Name of the Server Instance
    Name = $Name

    #Server Installation Path
    Path = ".\servers\$Name"

    #Steam Server App Id
    AppID = 824360

    #Use Beta builds $true or $false
    Beta = $false

    #Name of the Beta Build
    BetaBuild = ""

    #Beta Build Password
    BetaBuildPassword = ""

    #Process name in the task manager
    ProcessName = "PixArkServer"

    #ProjectZomboid64.exe
    Exec = ".\servers\$Name\ShooterGame\Binaries\Win64\PixARKServer.exe"

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
    Saves = ".\servers\$($Server.Name)\ShooterGame\Saved"
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
    CmdMessage = "broadcast"

    #command to save the server
    CmdSave = "saveworld"

    #How long to wait in seconds after the save command is sent.
    SaveDelay = 15

    #command to stop the server
    CmdStop = "quit"
}
#Create the object
$Warnings = New-Object -TypeName PsObject -Property $WarningsDetails

#---------------------------------------------------------
# Launch Arguments
#---------------------------------------------------------

#Launch Arguments
$Arguments = @(
    "$($Server.WorldType)",
    "?listen",
    "?Multihome=$($Server.InternalIP)",
    "?RCONEnabled=$($Server.EnableRcon)",
    "?MaxPlayers=$($Server.MaxPlayers)",
    "?Port=$($Server.Port)",
    "?RCONPort=$($Server.ManagementPort)",
    "?QueryPort=$($Server.QueryPort)",
    "?ServerAdminPassword=$($Server.ManagementPassword)",
    "?SessionName=`"$($Server.SessionName)`"",
    "?ServerPassword=$($Server.Password)",
    "?ShowFloatingDamageText=$($Server.ShowFloatingDamageText)",
    "?CULTUREFORCOOKING=$($Server.Language)",
    " -CubePort=$($Server.CubePort)",
    " -CubeWorld=$($Server.WorldName)",
    " -Seed=$($Server.Seed)",
    " -forcerespawndinos"
    " -NoHangDetection",
    " -nosteamclient",
    " -game",
    " -server",
    " -log"
)

$ArgumentList = $Arguments -join ""

#Server Launcher
$Launcher = $Server.Exec

#---------------------------------------------------------
# Launch Function
#---------------------------------------------------------

function Start-Server {

    Write-ScriptMsg "Port Forward : $($server.Port), $($server.QueryPort) And $($server.CubePort) in TCP and UDP to $($Global.InternalIP)"

    #Start Server
    $App = Start-Process -FilePath $Launcher -WorkingDirectory $Server.Path -ArgumentList $ArgumentList -PassThru

    #Wait to see if the server is stable.
    Start-Sleep -Seconds 10
    if (-not ($App) -or $App.HasExited){
        Write-Warning "Server Failed to launch."
    } else {
        Write-ServerMsg "Server Started."
            # Set the priority and affinity
        if ($Server.UsePriority) {
            $App.PriorityClass = $Server.AppPriority
        }
        if ($Server.UseAffinity){
            $App.ProcessorAffinity = $Server.AppAffinity
        }
    }
}

Export-ModuleMember -Function Start-Server -Variable @("Server","Backups","Warnings")