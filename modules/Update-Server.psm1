function Update-Server {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [string]$ServerPath,
        [string]$SteamCMD,
        [int32]$SteamAppID,
        [boolean]$Beta,

        [Parameter(Mandatory=$False)]
        [string]$BetaBuild,
        [securestring]$BetaBuildPassword
    )

    if (!(Test-Path $ServerPath)){
        New-Item -ItemType directory -Path $ServerPath -ErrorAction SilentlyContinue
    }
    $ServerPath = Resolve-Path -Path $ServerPath
    if($Beta){
        Write-Output "Updating / Installing Beta Build"
        try {
            $Task=Start-Process $SteamCMD -ArgumentList "+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $ServerPath `"+app_update $SteamAppID -beta $BetaBuild -betapassword $BetaBuildPassword`" -validate +quit" -Wait -PassThru -NoNewWindow
        } catch {
            Exit-WithCode -ErrorMsg "SteamCMD failed to complete." -ErrorObj $_ -ExitCode 400
        }
    } else {
        Write-Output "Updating / Installing Regular Build"
        try {
            $Task=Start-Process $SteamCMD -ArgumentList "+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $ServerPath +app_update $SteamAppID -validate +quit" -Wait -PassThru -NoNewWindow
        } catch {
            Exit-WithCode -ErrorMsg "SteamCMD failed to complete." -ErrorObj $_ -ExitCode 400
        }
    }
    return $Task.ExitCode
}
Export-ModuleMember -Function Update-Server