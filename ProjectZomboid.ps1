# August 2021
# Created by and Patrix87 of https://bucherons.ca

# Run this script to Stop->Backup->Update->Start your server.

#---------------------------------------------------------
# Variables
#---------------------------------------------------------

#Change settings in C:\Users\Administrator\Zomboid\Server\servertest.ini

#Variables      
$ProcessName="java"                                                             #Process name in the task manager
$serverExec="C:\ProjectZomboidServer\ProjectZomboid64.exe"                      #ProjectZomboid64.exe
$7zExec="C:\7z\7za.exe"                                                         #7zip
$mcrconExec="C:\mcrcon\mcrcon.exe"                                              #mcrcon
$serverSaves="C:\Users\Administrator\Zomboid"                                   #Folder to include in backup
$backupPath="C:\ProjectZomboidServerBackups"                                    #Backup Folder
$backupDays="7"                                                                 #Number of days of backups to keep.
$backupWeeks="4"                                                                #Number of weeks of weekly backups to keep.
$rconIP="127.0.0.1"                                                             #Rcon IP, usually localhost
$rconPort="27015"                                                               #Rcon Port in servertest.ini
$rconPassword="CHANGEME"                                                        #Rcon Password as set in servertest.ini (Do not use " " in servertest.ini
$steamCMDExec="C:\SteamCMD\steamcmd.exe"                                        #SteamCMD executable
$serverPath="C:\ProjectZomboidServer"                                           #Server Files Location
$steamAppID="380870"                                                            #Steam Server App Id

#Do not modify below this line
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#---------------------------------------------------------
#Config Check
#---------------------------------------------------------
Write-Host Checking config

if (!(Test-Path $serverPath)){
    Write-Host "Server path : $serverPath not found"
    Write-Host "Creating $serverPath"
    New-Item -ItemType directory -Path $serverPath -ErrorAction SilentlyContinue
}
if (!(Test-Path $steamCMDExec)){
    Write-Host "SteamCMD.exe not found at : $steamCMDExec"
    pause
    exit
}
if (!(Test-Path $7zExec)){
    Write-Host "7za.exe not found at : $7zExec"
    pause
    exit
}
if (!(Test-Path $mcrconExec)){
    Write-Host "mcrcon.exe not found at : $mcrconExec"
    pause
    exit
}

#---------------------------------------------------------
#Install if not installed
#---------------------------------------------------------
if (!(Test-Path $serverExec)){
    Write-Host "Server is not installed : Installing $serverName ..."
    & $steamcmdExec +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $serverPath +app_update $steamAppID +validate +quit
}else{

#---------------------------------------------------------
#If Server is running warn players then stop server
#---------------------------------------------------------

    Write-Host "Checking if server is running"
    $server=Get-Process $ProcessName -ErrorAction SilentlyContinue
    if ($server) {
        Write-Host "Server is running... Warning users about restart..."
        & $mcrconExec -c -H $rconIP -P $rconPort -p $rconPassword "servermsg THE SERVER WILL REBOOT IN 5 MINUTES !"
        Start-Sleep -s 240
        & $mcrconExec -c -H $rconIP -P $rconPort -p $rconPassword "servermsg THE SERVER WILL REBOOT IN 1 MINUTE !"
        Start-Sleep -s 60
        & $mcrconExec -c -H $rconIP -P $rconPort -p $rconPassword "servermsg THE SERVER IS REBOOTING !"
        Start-Sleep -s 5
        Write-Host "Saving and shutting down server."
        & $mcrconExec -c -H $rconIP -P $rconPort -p $rconPassword "quit"
        Start-Sleep -s 30
        Write-Host "Closing Main Windows..."
        $server.CloseMainWindow()
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

    & $steamcmdExec +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $serverPath +app_update $steamAppID +quit

}

#---------------------------------------------------------
#Start Server
#---------------------------------------------------------

Write-Host "Starting Server..."

$PZ_CLASSPATH="java/jinput.jar;java/lwjgl.jar;java/lwjgl_util.jar;java/sqlite-jdbc-3.8.10.1.jar;java/trove-3.0.3.jar;java/uncommons-maths-1.2.3.jar;java/javacord-2.0.17-shaded.jar;java/guava-23.0.jar;java/"

Set-Location -Path $serverPath

$app = Start-Process -FilePath ".\jre64\bin\java.exe" -WorkingDirectory "C:\ProjectZomboidServer" -ArgumentList "-Dzomboid.steam=1 -Dzomboid.znetlog=1 -XX:+UseConcMarkSweepGC -XX:-CreateMinidumpOnCrash -XX:-OmitStackTraceInFastThrow -Xms2048m -Xmx2048m -Djava.library.path=natives/;. -cp $PZ_CLASSPATH zombie.network.GameServer" -PassThru

# Set the priority and affinity
$app.PriorityClass = "High"
#$app.ProcessorAffinity=15

Start-Sleep -s 5

