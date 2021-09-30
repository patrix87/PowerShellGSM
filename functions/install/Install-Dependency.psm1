function Install-Dependency {
    #Define variables
    Write-ScriptMsg "Verifying Dependencies..."
    $Dependencies = @{
        SevenZip = $Global.SevenZip
        Mcrcon = $Global.Mcrcon
        SteamCMD = $Global.SteamCMD
    }

    [System.Collections.ArrayList]$MissingDependencies = @()

    #For each dependency check if the excutable exist, if not, add the key of the dependency to the MissingDependencies list.
    foreach ($Key in $Dependencies.keys) {
        if (-not (Test-Path -Path $Dependencies[$Key] -ErrorAction SilentlyContinue)) {
            $null = $MissingDependencies.Add($Key)
        }
    }

    #If there is missing dependencies, create the download folder and for each missing dependency, run the installation script.
    if ($MissingDependencies.Count -gt 0){
        #Create Temporary Download Folder
        $null = New-Item -Path ".\downloads" -ItemType "directory" -ErrorAction SilentlyContinue

        foreach ($Item in $MissingDependencies) {
            $Cmd = "Install-$Item"
            &$Cmd -Application $Dependencies[$Item]
        }

        #Cleanup
        $null = Remove-Item -Path ".\downloads" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Export-ModuleMember -Function Install-Dependency