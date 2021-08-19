# August 2021
# Created by and Patrix87 of https://bucherons.ca

# Run this script to Stop->Backup->Update->Start your server.

#---------------------------------------------------------
# Variables
#---------------------------------------------------------

#Change settings in C:\Users\%username%\Zomboid\Server\servertest.ini

#Variables

# All path are relative to the ps1 file location.

$serverExec="ProjectZomboidServer\ProjectZomboid64.exe"                         #ProjectZomboid64.exe
$7zExec="7z\7za.exe"                                                            #7zip
$mcrconExec="mcrcon\mcrcon.exe"                                                 #mcrcon
$steamCMDExec="SteamCMD\steamcmd.exe"                                           #SteamCMD executable
$serverPath="ProjectZomboidServer"                                              #Server Files Location
$backupPath="ProjectZomboidServerBackups"                                       #Backup Folder
$backupDays="7"                                                                 #Number of days of backups to keep.
$backupWeeks="4"                                                                #Number of weeks of weekly backups to keep.
$rconIP="127.0.0.1"                                                             #Rcon IP, usually localhost
$rconPort="27015"                                                               #Rcon Port in servertest.ini
$rconPassword="CHANGEME2"                                                        #Rcon Password as set in servertest.ini (Do not use " " in servertest.ini)
$serverSaves="$env:userprofile\Zomboid"                                         #Folder to include in backup
$steamAppID="380870"                                                            #Steam Server App Id
$beta=$false                                                                    #Use Beta builds *(currently not supported but the script is future proof) $true or $false
$betaBuild="iwillbackupmysave"                                                  #Name of the Beta Build
$betaBuildPassword="iaccepttheconsequences"                                     #Beta Build Password
$logFolder="PZLogs"                                                             #Name of the Log folder.
$ProcessName="java"                                                             #Process name in the task manager

#Do not modify below this line
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#---------------------------------------------------------
#Path reconstruction
#---------------------------------------------------------

$CurrentPath = $MyInvocation.MyCommand.Path | Split-Path
Set-Location -Path $CurrentPath

$serverExec="$CurrentPath\$serverExec"
$7zExec="$CurrentPath\$7zExec"
$mcrconExec="$CurrentPath\$mcrconExec"
$steamCMDExec="$CurrentPath\$steamCMDExec"
$serverPath="$CurrentPath\$serverPath"
$backupPath="$CurrentPath\$backupPath"
$logPath="$CurrentPath\$logFolder"

#---------------------------------------------------------
#Functions
#---------------------------------------------------------
function Update-Game {
    if($beta){
        Write-Host Updating / Installing Beta Build
        & $steamcmdExec +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $serverPath "+app_update $steamAppID -beta $betaBuild -betapassword $betaBuildPassword" +validate +quit
    } else {
        Write-Host Updating / Installing Regular Build
        & $steamcmdExec +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $serverPath +app_update $steamAppID -+validate +quit
    }
}

function Stop-Server {
    param (
        $server
    )
    if(-not $server.HasExited){
        Write-Host "Closing Main Windows..."
        $server.CloseMainWindow()
        $server.WaitForExit()
        Start-Sleep -s 10
        if ($server.HasExited) {
            Write-Host "Server succesfully shutdown"
        }else{
            Write-Host "Trying again to stop the Server..."
            #Try Again
            $server | Stop-Process
            Start-Sleep -s 10
            if ($server.HasExited) {
                Write-Host "Server succesfully shutdown on second try"
            }else{
                Write-Host "Forcing server shutdown..."
                #Force Stop
                $server | Stop-Process -Force
            }
        }
    }
}

#---------------------------------------------------------
# Logging
#---------------------------------------------------------
Function TimeStamp {
    return Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
}
$logFile="$(TimeStamp)_log.txt"
# Start Logging
Start-Transcript -Path "$logPath\$logFile"

#---------------------------------------------------------
#Config Check
#---------------------------------------------------------
Write-Host Installing components.

if (!(Test-Path $serverPath)){
    Write-Host "Server path : $serverPath not found"
    Write-Host "Creating $serverPath"
    New-Item -ItemType directory -Path $serverPath -ErrorAction SilentlyContinue
}
if (!(Test-Path $steamCMDExec)){
    Write-Host "SteamCMD.exe not found at : $steamCMDExec"
    Write-Host "Downloading SteamCMD"
    New-Item -Path ".\downloads" -ItemType "directory"
    Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile ".\downloads\steamcmd.zip" -ErrorAction SilentlyContinue
    Expand-Archive -Path ".\downloads\steamcmd.zip" -DestinationPath (Split-Path -Path $steamCMDExec) -Force
    Remove-Item -Path ".\downloads" -Recurse -Force
}
if (!(Test-Path $7zExec)){
    Write-Host "7za.exe not found at : $7zExec"
    Write-Host "Downloading 7zip 9.20 to extract 7zip 19.00"
    New-Item -Path ".\downloads" -ItemType "directory"
    Invoke-WebRequest -Uri "https://www.7-zip.org/a/7za920.zip" -OutFile ".\downloads\7za920.zip"
    Expand-Archive -Path ".\downloads\7za920.zip" -DestinationPath ".\downloads\7z920\" -Force
    Write-Host "Downloading 7zip 19.00"
    Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z1900-extra.7z" -OutFile ".\downloads\7z1900-extra.7z" -ErrorAction SilentlyContinue
    $7z920 = Resolve-Path -Path ".\downloads\7z920\7za.exe"
    & $7z920 x ".\downloads\7z1900-extra.7z" -o".\downloads\7z1900\" -y
    Copy-Item -Path ".\downloads\7z1900\x64\" -Destination (Split-Path -Path $7zExec) -Recurse -Force
    Remove-Item -Path ".\downloads" -Recurse -Force
}
if (!(Test-Path $mcrconExec)){
    Write-Host "mcrcon.exe not found at : $mcrconExec"
    Write-Host "Downloading mcrcon"
    New-Item -Path ".\downloads" -ItemType "directory"
    New-Item -Path (Split-Path -Path $mcrconExec) -ItemType "directory"
    Invoke-WebRequest -Uri "https://github.com/Tiiffi/mcrcon/releases/download/v0.7.1/mcrcon-0.7.1-windows-x86-32.zip" -OutFile ".\downloads\mcrcon.zip" -ErrorAction SilentlyContinue
    Expand-Archive -Path ".\downloads\mcrcon.zip" -DestinationPath ".\downloads\mcrcon\" -Force
    $mcrconPath = Resolve-Path -Path ".\downloads\mcrcon\mcrcon-0.7.1-windows-x86-32\mcrcon.exe"
    Copy-Item -Path $mcrconPath -Destination $mcrconExec -Force
    Remove-Item -Path ".\downloads" -Recurse -Force
}

#---------------------------------------------------------
#Install if not installed
#---------------------------------------------------------
if (!(Test-Path $serverExec)){
    Write-Host "Server is not installed : Installing $serverName ..."
    Update-Game
}else{

#---------------------------------------------------------
#If Server is running warn players then stop server
#---------------------------------------------------------

#TODO Add loop here with timers and warning list in minutes

    Write-Host "Checking if server is running"
    $server=Get-Process $ProcessName -ErrorAction SilentlyContinue
    if ($server) {
        Write-Host "Server is running... Warning users about restart..."
        $task = Start-Process $mcrconExec -ArgumentList "-c -H $rconIP -P $rconPort -p $rconPassword `"servermsg THE SERVER WILL REBOOT IN 5 MINUTES !`"" -Wait -PassThru -NoNewWindow
        if ($task.ExitCode -eq 0) {
            Write-Host "Message Sent."
            Write-Host "Waiting 4 Minutes"
            Start-Sleep -s 240
        } else {
            Write-Error "Unable to send server reboot warning."
            Write-Host "Hard Restarting now."
            Stop-Server($server)
        }
        $task = Start-Process $mcrconExec -ArgumentList "-c -H $rconIP -P $rconPort -p $rconPassword `"servermsg THE SERVER WILL REBOOT IN 1 MINUTE !`"" -Wait -PassThru -NoNewWindow
        if ($task.ExitCode -eq 0) {
            Write-Host "Message Sent."
            Write-Host "Waiting 1 Minutes"
            Start-Sleep -s 60
        } else {
            Write-Error "Unable to send server reboot warning."
            Write-Host "Hard Restarting now."
            Stop-Server($server)
        }
        $task = Start-Process $mcrconExec -ArgumentList "-c -H $rconIP -P $rconPort -p $rconPassword `"servermsg THE SERVER IS REBOOTING !`"" -Wait -PassThru -NoNewWindow
        if ($task.ExitCode -eq 0) {
            Write-Host "Message Sent."
            Write-Host "Waiting 5 Seconds"
            Start-Sleep -s 5
        } else {
            Write-Error "Unable to send server reboot warning."
            Write-Host "Hard Restarting now."
            Stop-Server($server)
        }
        $task = Start-Process $mcrconExec -ArgumentList "-c -H $rconIP -P $rconPort -p $rconPassword `"quit`"" -Wait -PassThru -NoNewWindow
        if ($task.ExitCode -eq 0) {
            Write-Host "Message Sent."
            Write-Host "Saving and shutting down server."
            Start-Sleep -s 30
        } else {
            Write-Error "Unable to send server reboot command"
            Write-Host "Hard Restarting now."
            Stop-Server($server)
        }
    }else{
        Write-Host "Server is not running"
    }

#---------------------------------------------------------
#Backup
#---------------------------------------------------------

    Write-Host "Creating Backup"
    #Create backup name from date and time
    $backupName=Get-Date -UFormat %Y-%m-%d_%H-%M-%S
    #Check if it's friday (Sunday is 0)
    if ((Get-Date -UFormat %u) -eq 5){
        #Weekly backup
        #Check / Create Path
        New-Item -ItemType directory -Path $backupPath\Weekly -ErrorAction SilentlyContinue
        & $7zExec a -tzip -mx=1 $backupPath\Weekly\$backupName.zip $serverSaves
    }else {
        #Daily backup
        #Check / Create Path
        New-Item -ItemType directory -Path $backupPath\Daily -ErrorAction SilentlyContinue
        & $7zExec a -tzip -mx=1 $backupPath\Daily\$backupName.zip $serverSaves
    }
    Write-Host "Backup Created : $backupName.zip"

    #Delete old Daily backup
    Write-Host "Deleting daily backup older than $backupDays"
    $limit = (Get-Date).AddDays(-$backupDays)
    Get-ChildItem -Path $backupPath\Daily -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $limit } | Remove-Item -Force
    
    #Delete old Weekly backup
    Write-Host "Deleting weekly backup older than $backupWeeks"
    $limit = (Get-Date).AddDays(-($backupWeeks)*7)
    Get-ChildItem -Path $backupPath\Weekly -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $limit } | Remove-Item -Force


#---------------------------------------------------------
#Update
#---------------------------------------------------------

    Write-Host "Updating Server..."
    Update-Game
}

#---------------------------------------------------------
#Start Server
#---------------------------------------------------------

Write-Host "Starting Server..."

$PZ_CLASSPATH="java/jinput.jar;java/lwjgl.jar;java/lwjgl_util.jar;java/sqlite-jdbc-3.8.10.1.jar;java/trove-3.0.3.jar;java/uncommons-maths-1.2.3.jar;java/javacord-2.0.17-shaded.jar;java/guava-23.0.jar;java/"

$app = Start-Process -FilePath "$serverPath\jre64\bin\java.exe" -WorkingDirectory $serverPath -ArgumentList "-Dzomboid.steam=1 -Dzomboid.znetlog=1 -XX:+UseConcMarkSweepGC -XX:-CreateMinidumpOnCrash -XX:-OmitStackTraceInFastThrow -Xms2048m -Xmx2048m -Djava.library.path=natives/;. -cp $PZ_CLASSPATH zombie.network.GameServer" -PassThru

# Set the priority and affinity
$app.PriorityClass = "High"
#$app.ProcessorAffinity=15

#Delete old logs
Write-Host "Deleting logs older than 30 days"
$limit = (Get-Date).AddDays(-30)
Get-ChildItem -Path $logPath -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $limit } | Remove-Item -Force

Stop-Transcript
Start-Sleep -s 5

