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
    #Login String
    $LoginString = "+@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous "
    if ($Server.Login -ne "anonymous") {
        $LoginString = "+login $($Server.Login) "
    }
    #Validation String
    $ValidateString = "  "
    $ValidatingString = ""
    if ($Server.Validate -ne $false){
        $ValidateString = "validate "
        $ValidatingString = "and Validating"
    }
    #Beta Build String
    $BetaBuildString = "  "
    $VersionString = "Regular"
    if ($Server.BetaBuild -ne ""){
        $BetaBuildString = "-beta $($Server.BetaBuild) "
        $VersionString = "Beta"
    }
    #Beta Password String
    $BetaPasswordString = "  "
    if ($Server.BetaBuildPassword -ne ""){
        $BetaPasswordString = "-betapassword $($Server.BetaBuildPassword)"
    }
    #Generate String
    $ArgumentList = @(
        "$LoginString",
        "+force_install_dir `"$($Server.Path)`" ",
        "+app_update $($Server.AppID)",
        "$BetaBuildString",
        "$BetaPasswordString",
        " $ValidateString",
        "+quit"
    )
    $Arguments = Optimize-ArgumentList -Arguments $ArgumentList
    #Run the update String
    Write-ServerMsg "$UpdateType $ValidatingString $VersionString Build."
    try {
        $Task = Start-Process $Global.SteamCMD -ArgumentList $Arguments -Wait -PassThru -NoNewWindow
    }
    catch {
        Exit-WithError -ErrorMsg "SteamCMD failed to complete."
    }
}
Export-ModuleMember -Function Update-Server