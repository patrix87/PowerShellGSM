function Update-Server {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$UpdateType
    )
    #Create server directory if not found.
    if (-not (Test-Path -Path $Server.Path)){
        New-Item -ItemType "directory" -Path $Server.Path -ErrorAction SilentlyContinue
    }
    #Resolve complete path of the server folder.
    $Server.Path = Resolve-Path -Path $Server.Path
    #Run steam the correct steam command based on context.
    if($Server.Beta){
        Write-ServerMsg "$UpdateType Beta Build."
        try {
            if ($Server.Validate) {
                $Task = Start-Process $Global.SteamCMD -ArgumentList "+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $($Server.Path) `"+app_update $($Server.AppID) -beta $($Server.BetaBuild) -betapassword $($Server.BetaBuildPassword)`" -validate +quit" -Wait -PassThru -NoNewWindow
            } else {
                $Task = Start-Process $Global.SteamCMD -ArgumentList "+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $($Server.Path) `"+app_update $($Server.AppID) -beta $($Server.BetaBuild) -betapassword $($Server.BetaBuildPassword)`" +quit" -Wait -PassThru -NoNewWindow
            }
        } catch {
            Exit-WithError -ErrorMsg "SteamCMD failed to complete."
        }
    } else {
        Write-ServerMsg "$UpdateType Regular Build."
        try {
            if ($Server.Validate){
                $Task = Start-Process $Global.SteamCMD -ArgumentList "+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $($Server.Path) +app_update $($Server.AppID) -validate +quit" -Wait -PassThru -NoNewWindow
            } else {
                $Task = Start-Process $Global.SteamCMD -ArgumentList "+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $($Server.Path) +app_update $($Server.AppID) +quit" -Wait -PassThru -NoNewWindow
            }
        } catch {
            Exit-WithError -ErrorMsg "SteamCMD failed to complete."
        }
    }
    #Update Server.Exec value with the full path.
    $Server.Exec = Resolve-Path -Path $Server.Exec
}
Export-ModuleMember -Function Update-Server