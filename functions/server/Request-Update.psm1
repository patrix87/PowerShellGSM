function Request-Update {
    #Create server directory if not found.
    if (-not (Test-Path -Path $Server.Path -ErrorAction SilentlyContinue)){
        $null = New-Item -ItemType "directory" -Path $Server.Path -ErrorAction SilentlyContinue
    }
    #Skip install if AppID is 0
    if ($Server.AppID -eq 0){
        return
    }
    [System.Collections.ArrayList]$ArgumentList=@()
    #Login
    if ($Server.Login -eq "anonymous") {
        $null = $ArgumentList.Add("@ShutdownOnFailedCommand 1`n@NoPromptForPassword 1`n@sSteamCmdForcePlatformType windows`nlogin anonymous")
    } else {
        $null = $ArgumentList.Add("@sSteamCmdForcePlatformType windows`nlogin $($Server.Login)")
    }
    $null = $ArgumentList.Add("force_install_dir `"$($Server.Path)`"")
    $null = $ArgumentList.Add("app_info_update 1")
    $null = $ArgumentList.Add("app_status $($Server.AppID)")
    #join each part of the string and add it to the list
    $null = $ArgumentList.Add("quit")
    #Join each item of the list with an LF
    $FileContent = $ArgumentList -join "`n"
    #Define the Script file name
    $ScriptFile = "SteamCMD_Update_$($Server.UID).txt"
    #Define the Script file name
    $UpdateReturnFile = "SteamCMD_Update_$($Server.UID)_Return.txt"
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
    #Parse the file for the update status
    $State = Select-String -Path ".\servers\$UpdateReturnFile" -Pattern " - install state:"
    #Delete the script and update return file.
    $null = Remove-Item -Path $ScriptPath -Confirm:$false -ErrorAction SilentlyContinue
    $null = Remove-Item -Path ".\servers\$UpdateReturnFile" -Confirm:$false -ErrorAction SilentlyContinue
    if ($State.Line -match "Update Required"){
        return $true
    }
    return $false
}
Export-ModuleMember -Function Request-Update