function Install-SteamCMD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Application
    )
    Write-Verbose "Downloading SteamCMD"
    Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile ".\downloads\steamcmd.zip" -ErrorAction SilentlyContinue
    Expand-Archive -Path ".\downloads\steamcmd.zip" -DestinationPath (Split-Path -Path $Application) -Force
}

Export-ModuleMember -Function Install-SteamCMD -Verbose:$false