# August 2021
# Created by and Patrix87 of https://bucherons.ca
# Run this script to Stop->Backup->Update->Start your server.

[CmdletBinding()]
param (
  [Parameter(Mandatory = $true)]
  [string]$ServerCfg,
  [Parameter(Mandatory = $false)]
  [switch]$Task
)

#---------------------------------------------------------
# Importing functions and variables.
#---------------------------------------------------------

# import global config, all functions. Exit if fails.
try {
  Import-Module -Name ".\global.psm1"
  Get-ChildItem -Path ".\functions" -Include "*.psm1" -Recurse | Import-Module
}
catch {
  Exit-WithError -ErrorMsg "Unable to import modules."
  Exit
}

#---------------------------------------------------------
# Start Logging
#---------------------------------------------------------

#Define Logfile by TimeStamp-ServerCfg.
$LogFile = "$($Global.LogFolder)\$(Get-TimeStamp)-$($ServerCfg).txt"
# Start Logging
Start-Transcript -Path $LogFile -IncludeInvocationHeader
if($Global.Debug) {
  [Console]::ForegroundColor = $Global.ErrorColor
  [Console]::BackgroundColor = $Global.ErrorBgColor
  Write-Host "DEBUG MODE ENABLED"
  [Console]::ResetColor()
}
$NoLogs = $false

#---------------------------------------------------------
# Set Script Directory as Working Directory
#---------------------------------------------------------

#Find the location of the current invocation of main.ps1, remove the filename, set the working directory to that path.
Write-ScriptMsg "Setting Script Directory as Working Directory..."
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path -Path $scriptpath
$dir = Resolve-Path -Path $dir
$null = Set-Location -Path $dir
Write-ScriptMsg "Working Directory : $(Get-Location)"

#---------------------------------------------------------
# Get server IPs
#---------------------------------------------------------

Set-IP

#---------------------------------------------------------
# Install Dependencies
#---------------------------------------------------------

Install-Dependency

#---------------------------------------------------------
# Importing server configuration.
#---------------------------------------------------------

Write-ScriptMsg "Importing Server Configuration..."
#Check if requested config exist in the config folder, if not, copy it from the templates. Exit if fails.
#In the case of an update check or alive check, remove the check if the configuration is deleted.
if (-not (Test-Path -Path ".\configs\$ServerCfg.psm1" -PathType "Leaf" -ErrorAction SilentlyContinue)) {
  $Server = New-Object -TypeName PsObject -Property @{Name = $ServerCfg }
  if ($Task) {
    Write-ScriptMsg "Server Configuration no longer exists, unregistering Tasks..."
    Unregister-Task
    Exit
  }
  if (Test-Path -Path ".\templates\$ServerCfg.psm1" -PathType "Leaf" -ErrorAction SilentlyContinue) {
    $null = Copy-Item -Path ".\templates\$ServerCfg.psm1" -Destination ".\configs\$ServerCfg.psm1" -ErrorAction SilentlyContinue
  }
  else {
    Exit-WithError -ErrorMsg "Unable to find configuration file."
  }
}

# import the current server config file. Exit if fails.
try {
  Import-Module -Name ".\configs\$ServerCfg.psm1"
}
catch {
  Exit-WithError -ErrorMsg "Unable to import server configuration."
}

#Parse configuration
Read-Config

#Check if script is already running
if (Get-Lock) {
  Write-ScriptMsg "Process is locked, exiting."
  Exit
}

#Locking Script to avoid double run
$null = Lock-Process

#---------------------------------------------------------
# Checking Scheduled Task
#---------------------------------------------------------
if ($Task) {
  $FullRunRequired = $false
  Write-ScriptMsg "Running Tasks for $($ServerCfg) ..."
  $TasksSchedule = (Get-TaskConfig)
  if (-not ($Server.AutoRestartOnCrash) -and (-not ($Server.AutoUpdates)) -and (-not ($Server.AutoRestart))) {
    Write-ScriptMsg "No Tasks to run, unregistering Tasks..."
    Unregister-Task
    Exit
  } else {
    $taskName = "Tasks-$($server.Name)"
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if (-not $existingTask) {
      Write-ScriptMsg "Task '$taskName' does not exist, Registering-Task..."
      Register-Task
    }
  }

  if ($Server.AutoRestartOnCrash) {
    if ((($TasksSchedule.NextAlive) -le (Get-Date)) -or ($Global.AliveCheckFrequency -le $Global.TaskCheckFrequency)) {
      Write-ScriptMsg "Checking Alive State"
      if (-not (Get-ServerProcess)) {
        Write-ScriptMsg "Server is Dead, Restarting..."
        $FullRunRequired = $true
      }
      else {
        Write-ScriptMsg "Server is Alive"
      }
      Update-TaskConfig -Alive
    }
    else {
      Write-ScriptMsg "Too soon for Alive check"
    }
  }
  else {
    Write-ScriptMsg "Alive check is disabled"
  }

  if ($Server.AutoUpdates) {
    if ((($TasksSchedule.NextUpdate) -le (Get-Date)) -or ($Global.UpdateCheckFrequency -le $Global.TaskCheckFrequency)) {
      Write-ScriptMsg "Checking on steamCMD if updates are available for $($Server.Name)..."
      if (Request-Update) {
        Write-ScriptMsg "Updates are available for $($Server.Name), Proceeding with update process..."
        $FullRunRequired = $true
      }
      else {
        Write-ScriptMsg "No updates are available for $($Server.Name)"
      }
      Update-TaskConfig -Update
    }
    else {
      Write-ScriptMsg "Too soon for Update check"
    }
  }
  else {
    Write-ScriptMsg "Auto-updates are disabled"
  }

  if ($Server.AutoRestart) {
    if (($TasksSchedule.NextRestart) -le (Get-Date)) {
      Write-ScriptMsg "Server is due for Restart"
      $FullRunRequired = $true
      Update-TaskConfig -Restart
    }
    else {
      Write-ScriptMsg "Too soon for Restart"
    }
  }
  else {
    Write-ScriptMsg "Auto-restart is disabled"
  }

  if (-not $FullRunRequired) {
    $null = Unlock-Process
    Write-ScriptMsg "No tasks ready, exiting."
    #Close the log.
    $null = Stop-Transcript
    if (-not ($Global.Debug)) {
      $null = Remove-Item -Path $LogFile -Force -ErrorAction SilentlyContinue
    }
    exit
  }
  #Run Launcher as usual
}

#---------------------------------------------------------
# Install Server
#---------------------------------------------------------

Write-ScriptMsg "Verifying Server installation..."
#Flag of a fresh installation in the current instance.
$FreshInstall = $false
#If the server executable is missing, run SteamCMD and install the server.
if (-not (Test-Path -Path $Server.Exec -ErrorAction SilentlyContinue)) {
  Write-ServerMsg "Server is not installed : Installing $($Server.Name) Server."
  Update-Server -UpdateType "Installing"
  Write-ServerMsg "Server successfully installed."
  $FreshInstall = $true
}

#---------------------------------------------------------
# If Server is running warn players then stop server
#---------------------------------------------------------
Write-ScriptMsg "Verifying Server State..."
#If the server is not freshly installed.
if (-not $FreshInstall) {
  Stop-Server
}

#---------------------------------------------------------
# Backup
#---------------------------------------------------------

#If not a fresh install and Backups are enabled, run backups.
if ($Backups.Use -and -not $FreshInstall) {
  Write-ScriptMsg "Verifying Backups..."
  Backup-Server
}

#---------------------------------------------------------
# Update
#---------------------------------------------------------

#If not a fresh install, update and/or validate server.
if (-not $FreshInstall -and $Server.AutoUpdates) {
  Write-ScriptMsg "Updating Server..."
  Update-Server -UpdateType "Updating"
  Write-ServerMsg "Server successfully updated and/or validated."
}

#---------------------------------------------------------
# Register Scheduled Task
#---------------------------------------------------------

if (($Server.AutoUpdates -or $Server.AutoRestartOnCrash -or $Server.AutoRestart) -and -not (Get-ScheduledTask -TaskName "Tasks-$($server.Name)" -ErrorAction SilentlyContinue)) {
  Write-ScriptMsg "Registering Scheduled Tasks Check for $($Server.Name)..."
  Register-Task
}

#---------------------------------------------------------
# Start Server
#---------------------------------------------------------

#Try to start the server, then if it's stable, set the priority and affinity then register the PID. Exit with Error if it fails.
Start-Server

#---------------------------------------------------------
# Open FreshInstall Configuration folder
#---------------------------------------------------------

if ($FreshInstall -and (Test-Path -Path $Server.ConfigFolder -PathType "Container" -ErrorAction SilentlyContinue)) {
  Write-Warning -Message "Stopping the Server to let you edit the configurations files."
  #Stop Server because configuration is probably bad anyway
  Stop-Server
  $null = Unlock-Process
  & explorer.exe $Server.ConfigFolder
  Write-Warning -Message "Launch again when the server configurations files are edited."
  Read-Host "Press Enter to close this windows."
}

#---------------------------------------------------------
# Cleanup
#---------------------------------------------------------

#Remove old log files.
try {
  Write-ScriptMsg "Deleting logs older than $($Global.Days) days."
  Remove-OldLog
}
catch {
  Exit-WithError -ErrorMsg "Unable clean old logs."
}


#---------------------------------------------------------
# Unlock Process
#---------------------------------------------------------

$null = Unlock-Process

Write-ServerMsg "Script successfully completed."

#---------------------------------------------------------
# Stop Logging
#---------------------------------------------------------

$null = Stop-Transcript
if ($NoLogs -and -not ($Global.Debug)) {
  $null = Remove-Item -Path $LogFile -Force -ErrorAction SilentlyContinue
}
