function Update-Server {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$UpdateType
    )
    #Create server directory if not found.
    if (-not (Test-Path -Path $Server.Path -ErrorAction SilentlyContinue)){
        $null = New-Item -ItemType "directory" -Path $Server.Path -ErrorAction SilentlyContinue
    }
    #Skip install if AppID is 0
    if ($Server.AppID -eq 0){
        return
    }
    <#
    String Part if value is null or false or empty string
    if () {
        String Part if value is defined
    }
    #>
    [System.Collections.ArrayList]$ArgumentList=@()
    #Login
    if ($Server.Login -eq "anonymous") {
        $null = $ArgumentList.Add("@ShutdownOnFailedCommand 1`n@NoPromptForPassword 1`n@sSteamCmdForcePlatformType windows`nlogin anonymous")
    } else {
        $null = $ArgumentList.Add("@sSteamCmdForcePlatformType windows`nlogin $($Server.Login)")
    }
    $null = $ArgumentList.Add("force_install_dir `"$($Server.Path)`"")
    #Install String Building
    [System.Collections.ArrayList]$InstallList=@()
    $null = $InstallList.Add("app_update $($Server.AppID)")
    $VersionString = "Regular"
    if ($Server.BetaBuild -ne ""){
        $VersionString = "Beta"
        $null = $InstallList.Add("-beta $($Server.BetaBuild)")
    }
    if ($Server.BetaBuildPassword -ne ""){
        $null = $InstallList.Add("-betapassword $($Server.BetaBuildPassword)")
    }
    if ($Server.Validate){
        $ValidatingString = "and Validating"
        $null = $InstallList.Add("validate")
    }
    #join each part of the string and add it to the list
    $null = $ArgumentList.Add($InstallList -join " ")
    $null = $ArgumentList.Add("quit")
    #Join each item of the list with an LF
    $FileContent = $ArgumentList -join "`n"
    #Define the Script file name
    $ScriptFile = "SteamCMD_$($Server.UID).txt"
    #Define the full path.
    $ScriptPath = (Resolve-CompletePath -Path ".\servers\$ScriptFile" -ParentPath ".\servers\")
    #Create the script.
    $null = New-Item -Path ".\servers" -Name $ScriptFile -ItemType "file" -Value $FileContent -Force
    #Run the update String
    Write-ServerMsg "$UpdateType $ValidatingString $VersionString Build."
    try {
        $Task = Start-Process $Global.SteamCMD -ArgumentList "+runscript `"$ScriptPath`"" -Wait -PassThru -NoNewWindow
    }
    catch {
        Exit-WithError -ErrorMsg "SteamCMD failed to complete."
    }
    #Delete the script.
    $null = Remove-Item -Path $ScriptPath -Confirm:$false -ErrorAction SilentlyContinue
}
Export-ModuleMember -Function Update-Server