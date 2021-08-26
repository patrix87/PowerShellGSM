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
        [string]$BetaBuildPassword,
        [string]$UpdateType
    )

    if (!(Test-Path $ServerPath)){
        New-Item -ItemType "directory" -Path $ServerPath -ErrorAction SilentlyContinue
    }
    $ServerPath=Resolve-Path -Path $ServerPath
    if($Beta){
        Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "$UpdateType Beta Build."
        try {
            $Task=Start-Process $SteamCMD -ArgumentList "+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $ServerPath `"+app_update $SteamAppID -beta $BetaBuild -betapassword $BetaBuildPassword`" -validate +quit" -Wait -PassThru -NoNewWindow
        } catch {
            Exit-WithError -ErrorMsg "SteamCMD failed to complete."
        }
    } else {
        Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "$UpdateType Regular Build."
        try {
            $Task=Start-Process $SteamCMD -ArgumentList "+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $ServerPath +app_update $SteamAppID -validate +quit" -Wait -PassThru -NoNewWindow
        } catch {
            Exit-WithError -ErrorMsg "SteamCMD failed to complete."
        }
    }
}
Export-ModuleMember -Function Update-Server