function Install-SteamCMD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Application
    )
    Write-ServerMsg "Downloading SteamCMD."
    #Download file
    Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile ".\downloads\steamcmd.zip" -ErrorAction SilentlyContinue
    #Unzip file in installation directory
    Expand-Archive -Path ".\downloads\steamcmd.zip" -DestinationPath (Split-Path -Path $Application) -Force
    Write-ServerMsg "SteamCMD Installed."
}

Export-ModuleMember -Function Install-SteamCMD