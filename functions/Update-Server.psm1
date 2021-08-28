function Update-Server {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $UpdateType
    )

    if (-not(Test-Path -Path $Server.Path)){
        New-Item -ItemType "directory" -Path $Server.Path -ErrorAction SilentlyContinue
    }
    $Server.Path = Resolve-Path -Path $Server.Path
    if($Server.Beta){
        Write-ServerMsg "$UpdateType Beta Build."
        try {
            $Task = Start-Process $Global.SteamCMD -ArgumentList "+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $($Server.Path) `"+app_update $($Server.AppID) -beta $($Server.BetaBuild) -betapassword $($Server.BetaBuildPassword)`" -validate +quit" -Wait -PassThru -NoNewWindow
        } catch {
            Exit-WithError -ErrorMsg "SteamCMD failed to complete."
        }
    } else {
        Write-ServerMsg "$UpdateType Regular Build."
        try {
            $Task = Start-Process $Global.SteamCMD -ArgumentList "+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $($Server.Path) +app_update $($Server.AppID) -validate +quit" -Wait -PassThru -NoNewWindow
        } catch {
            Exit-WithError -ErrorMsg "SteamCMD failed to complete."
        }
    }
    $Server.Exec = Resolve-Path -Path $Server.Exec
}
Export-ModuleMember -Function Update-Server