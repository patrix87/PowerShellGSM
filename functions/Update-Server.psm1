function Update-Server {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$UpdateType
    )
    #Create server directory if not found.
    if (-not (Test-Path -Path $Server.Path -ErrorAction SilentlyContinue)){
        New-Item -ItemType "directory" -Path $Server.Path -ErrorAction SilentlyContinue
    }
    <#
    String Part if value is null or false or empty string
    if () {
        String Part if value is defined
    }
    #>
    #Login String
    $LoginString = "+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous"
    if ($Server.Login -ne "anonymous") {
        $LoginString = "+login $($Server.Login)"
    }
    #Validation String
    $ValidateString = ""
    $ValidatingString = ""
    if ($Server.Validate -ne $false){
        $ValidateString = "-validate"
        $ValidatingString = "and validating"
    }
    #Beta Build String
    $BetaBuildString = ""
    $VersionString = "Regular"
    if ($Server.BetaBuild -ne ""){
        $BetaBuildString = "-beta $($Server.BetaBuild)"
        $VersionString = "Beta"
    }
    #Beta Password String
    $BetaPasswordString = ""
    if ($Server.BetaBuildPassword -ne ""){
        $BetaPasswordString = "-betapassword $($Server.BetaBuildPassword)"
    }

    $Arguments = "$LoginString +force_install_dir `"$($Server.Path)`" `"+app_update $($Server.AppID) $BetaBuildString $BetaPasswordString`" $ValidateString +quit"
    #Run the update String
    Write-ServerMsg "$UpdateType $ValidatingString $VersionString Build."
    try {
        Start-Process $Global.SteamCMD -ArgumentList $Arguments -Wait -PassThru -NoNewWindow
    }
    catch {
        Exit-WithError -ErrorMsg "SteamCMD failed to complete."
    }
}
Export-ModuleMember -Function Update-Server