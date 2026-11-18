$GlobalDetails = @{
  #mcrcon
  Mcrcon               = ".\tools\mcrcon\mcrcon.exe"

  #ARRCON
  ARRCON               = ".\tools\ARRCON\ARRCON.exe"

  #SteamCMD
  SteamCMD             = ".\tools\SteamCMD\steamcmd.exe"

  #PowerShell 7 that runs PowerShellGSM, installed by PowerShellGSM in PwshDirectory\PwshVersion from the official portable zip.
  #Pinned to the version PowerShellGSM is tested with: a PowerShellGSM update that moves the pin installs the new version on the next run.
  PwshDirectory        = ".\tools\pwsh"
  PwshVersion          = "7.6.10"
  PwshSha256           = "7D871531806EB1646264E4BBABD9F0C30C23355591BC756BB9909448C29AE166"

  #Java Directory
  JavaDirectory        = ".\tools\java"

  #Path of the logs folder.
  LogFolder            = ".\logs"

  #File extensions to exclude from backups
  Exclusions           = @(".tmp", ".bak", ".log", ".old", ".temp", ".backup")

  #Number of days to keep server logs
  Days                 = 30

  #Console Output Text Color
  FgColor              = "Green"

  #Console Output Background Color
  BgColor              = "Black"

  #Console Output Text Color for errors
  ErrorColor           = "Black"

  #Console Output Background Color for errors
  ErrorBgColor         = "Red"

  #Console Output Text Color for sections
  SectionColor         = "Blue"

  #Console Output Background Color for sections
  SectionBgColor       = "Black"

  #Pause on errors
  PauseOnErrors        = $false

  #Backup Frequency in Minutes
  BackupCheckFrequency = 60

  #Check for Update Frequency in Minutes
  UpdateCheckFrequency = 15

  #Check if the server is alive Frequency in Minutes
  AliveCheckFrequency  = 5

  #Should be lower or equal to the two above. The scheduled tasks are registered again on the next run after a change.
  TaskCheckFrequency   = 5

  #Set to $true to keep PowerShellGSM up to date with git pull.
  AutoUpdateTool       = $true

  #Check for PowerShellGSM updates Frequency in Hours. The PowerShellGSM-Update task is registered again on the next run after a change.
  ToolUpdateFrequency  = 24

  #Run the scheduled tasks whether the user is logged on or not (S4U logon, no password stored), so no auto-logon is needed.
  #Servers then run in the background without a window, and the tasks cannot use network shares.
  #The scheduled tasks are registered again on the next run after a change.
  TaskRunWhileLoggedOff = $false

  #After installing a new server, stop it and wait so you can edit the configuration files it generated.
  #Set to $false for unattended installs: the server is restarted once instead, so the configuration is applied to the files it generated.
  StopAfterFreshInstall = $true

  #Lock Timeout in minutes
  LockTimeout          = 120

  #Max download retries
  MaxDownloadRetries   = 10

  # Define the DateTimeFormat (Change at your own risk, used for filenames)
  DateTimeFormat       = "yyyy-MM-dd_HH-mm-ss"

  # Debug Mode (will not delete any logs or script files and will ignore script locks)
  # !!! DO NOT ENABLE IN PRODUCTION !!!
  Debug                = $false
}

#Create the object
$Global = New-Object -TypeName PsObject -Property $GlobalDetails

Export-ModuleMember -Variable "Global"
