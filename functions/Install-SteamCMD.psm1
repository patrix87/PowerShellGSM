function Install-SteamCMD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Application
    )
    Write-ServerMsg "Downloading SteamCMD."
    Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile ".\downloads\steamcmd.zip" -ErrorAction SilentlyContinue
    Expand-Archive -Path ".\downloads\steamcmd.zip" -DestinationPath (Split-Path -Path $Application) -Force
    Write-ServerMsg "SteamCMD Installed."
}

Export-ModuleMember -Function Install-SteamCMD