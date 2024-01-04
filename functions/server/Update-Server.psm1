function Update-Server {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$UpdateType
  )
  #Create server directory if not found.
  if (-not (Test-Path -Path $Server.Path -ErrorAction SilentlyContinue)) {
    $null = New-Item -ItemType "directory" -Path $Server.Path -ErrorAction SilentlyContinue
  }
  #Skip install if AppID is 0
  if ($Server.AppID -eq 0) {
    return
  }
  [System.Collections.ArrayList]$ArgumentList = @()
  #Server Directory
  $null = $ArgumentList.Add("force_install_dir `"$($Server.Path)`"")
  #Login
  if ($Server.Login -eq "anonymous") {
    $null = $ArgumentList.Add("@ShutdownOnFailedCommand 1`n@NoPromptForPassword 1`n@sSteamCmdForcePlatformType windows`nlogin anonymous")
  }
  else {
    $null = $ArgumentList.Add("@sSteamCmdForcePlatformType windows`nlogin $($Server.Login)")
  }
  #Action String Construction
  [System.Collections.ArrayList]$ActionList = @()
  $null = $ActionList.Add("app_update $($Server.AppID)")
  $VersionString = "Regular"
  if ($Server.BetaBuild -ne "") {
    $VersionString = "Beta"
    $null = $ActionList.Add("-beta $($Server.BetaBuild)")
  }
  if ($Server.BetaBuildPassword -ne "") {
    $null = $ActionList.Add("-betapassword $($Server.BetaBuildPassword)")
  }
  if ($Server.Validate) {
    $ValidatingString = "and Validating"
    $null = $ActionList.Add("validate")
  }
  #join each part of the string and add it to the list
  $null = $ArgumentList.Add($ActionList -join " ")
  #Quit to close the script once it is done.
  $null = $ArgumentList.Add("quit")
  #Join each item of the list with an LF
  $FileContent = $ArgumentList -join "`n"
  #Define the Script file name
  $ScriptFile = "SteamCMD_$($Server.Name).txt"
  #Define the full path.
  $ScriptPath = (Resolve-CompletePath -Path ".\servers\$ScriptFile" -ParentPath ".\servers\")
  #Create the script.
  $null = New-Item -Path ".\servers" -Name $ScriptFile -ItemType "file" -Value $FileContent -Force
  #Run the update String
  Write-ServerMsg "$UpdateType $ValidatingString $VersionString Build."
  try {
    $ExitCode = -1
    $Retries = 0
    while ($ExitCode -ne 0 -and $Retries -lt $Global.MaxDownloadRetries) {
      $Task = Start-Process $Global.SteamCMD -ArgumentList "+runscript `"$ScriptPath`"" -Wait -PassThru -NoNewWindow
      $ExitCode = $Task.ExitCode
      if ($ExitCode -ne 0) {
        Write-ServerMsg "SteamCMD failed to complete. Retrying..."
        $Retries++
      }
      else {
        Write-ServerMsg "SteamCMD completed successfully."
      }
    }
    if ($Retries -eq $Global.MaxDownloadRetries) {
      Exit-WithError -ErrorMsg "SteamCMD failed to complete after $Global.MaxDownloadRetries retries."
    }
  }
  catch {
    Exit-WithError -ErrorMsg "SteamCMD failed to complete."
  }
  #Delete the script.
  if (-not $Global.Debug){
    $null = Remove-Item -Path $ScriptPath -Confirm:$false -ErrorAction SilentlyContinue
  }
}
Export-ModuleMember -Function Update-Server