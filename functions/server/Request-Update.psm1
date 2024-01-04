function Request-Update {
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
  $null = $ArgumentList.Add("app_info_update 1")

  #Action String Construction
  [System.Collections.ArrayList]$ActionList = @()
  $null = $ActionList.Add("app_status $($Server.AppID)")
  $VersionString = "Public"
  if ($Server.BetaBuild) {
    $VersionString = "Beta"
    $null = $ActionList.Add("-beta $($Server.BetaBuild)")
  }
  if ($Server.BetaBuildPassword) {
    $null = $ActionList.Add("-betapassword $($Server.BetaBuildPassword)")
  }
  #join each part of the string and add it to the list
  $null = $ArgumentList.Add($ActionList -join " ")

  $null = $ArgumentList.Add("app_info_print $($Server.AppID)")
  #Quit to close the script once it is done.
  $null = $ArgumentList.Add("quit")
  #Join each item of the list with an LF
  $FileContent = $ArgumentList -join "`n"

  #Define the Script file name
  $ScriptFile = "SteamCMD_Update_$($Server.Name).txt"
  #Define the Script file name
  $UpdateReturnFile = "SteamCMD_Update_$($Server.Name)_Return.txt"
  #Define the full path.
  $ScriptPath = (Resolve-CompletePath -Path ".\servers\$ScriptFile" -ParentPath ".\servers\")
  #Create the script.
  $null = New-Item -Path ".\servers" -Name $ScriptFile -ItemType "file" -Value $FileContent -Force
  #Run the update check String
  try {
    $Task = Start-Process $Global.SteamCMD -RedirectStandardOutput ".\servers\$UpdateReturnFile" -ArgumentList "+runscript `"$ScriptPath`"" -Wait -NoNewWindow -PassThru
  }
  catch {
    Exit-WithError -ErrorMsg "SteamCMD failed to complete."
  }

  #Get Branch name
  $BranchName = "public"
  if($Server.BetaBuild){
    $BranchName = $Server.BetaBuild
  }

  #Parse the file for the update status
  $SteamCMDResult = Get-Content -Path ".\servers\$UpdateReturnFile" -Raw
  $InstallState = $($SteamCMDResult | Select-String -Pattern "install state:([\w ,]*)").Matches.Groups[1].Value.Trim()
  Write-ServerMsg "Install State: $InstallState"
  $LocalBuildID = $($SteamCMDResult | Select-String -Pattern "BuildID (\d+)" -CaseSensitive).Matches.Groups[1].Value.Trim()
  Write-ServerMsg "Local Build ID: $LocalBuildID"
  $RemoteBuildID = $($SteamCMDResult | Select-String -Pattern "`"$BranchName`"\s*\{\s*`"buildid`"\s*`"(\d+)").Matches.Groups[1].Value.Trim()
  Write-ServerMsg "Remote Build ID: $RemoteBuildID"

  #Delete the script and update return file.
  if ($Global.Debug){
    $null = Rename-Item -Path $ScriptPath -NewName "$ScriptFile.$(Get-TimeStamp).txt" -ErrorAction SilentlyContinue
    $null = Rename-Item -Path ".\servers\$UpdateReturnFile" -NewName "$UpdateReturnFile.$(Get-TimeStamp).txt" -ErrorAction SilentlyContinue
  } else {
    $null = Remove-Item -Path $ScriptPath -Confirm:$false -ErrorAction SilentlyContinue
    $null = Remove-Item -Path ".\servers\$UpdateReturnFile" -Confirm:$false -ErrorAction SilentlyContinue
  }

  #Return true if the server needs to be updated.
  if ($InstallState -match "Update Required") {
    return $true
  }
  if ($LocalBuildID -ne $RemoteBuildID) {
    return $true
  }
  return $false
}
Export-ModuleMember -Function Request-Update