function Backup-Server {
    Write-ServerMsg "Creating Backup."
    #Create backup name from date and time
    $BackupName = Get-TimeStamp
    #Check if Backups Destination directory exist and create it.
    if (-not(Test-Path -Path "$($Backups.Path)\$Type" -PathType "Container")){
        New-Item -Path "$($Backups.Path)\$Type" -ItemType "directory" -ErrorAction SilentlyContinue
    }
    #Check if Backups Source directory exist and create it.
    if (-not(Test-Path -Path $Backups.Saves -PathType "Container")){
        New-Item -Path $Backups.Saves -ItemType "directory" -ErrorAction SilentlyContinue
    }
    #Resolve Server Saves Path
    $Backups.Saves = Resolve-Path -Path $Backups.Saves -ErrorAction SilentlyContinue
    #Resolve Backup Path
    $Backups.Path = Resolve-Path -Path $Backups.Path -ErrorAction SilentlyContinue
    #Check if it's friday (Sunday is 0)
    if ((Get-Date -UFormat %u) -eq 5){
        $Type = "Weekly"
        $Limit = (Get-Date).AddDays(-($Backups.Weeks * 7))
    } else {
        $Type = "Daily"
        $Limit = (Get-Date).AddDays(-$Backups.Days)
    }

    #Run Backup
    try {
        & $Global.SevenZip a -tzip -mx=1 "$($Backups.Path)\$Type\$BackupName.zip" $Backups.Saves
    }
    catch {
        Exit-WithError -ErrorMsg "Unable to backup server."
    }

    Write-ServerMsg "Backup Created : $BackupName.zip"

    #Delete old backups
    Write-ServerMsg "Deleting old backups."
    Get-ChildItem -Path "$($Backups.Path)\$Type" -Recurse -Force |
        Where-Object { -not ($_.PSIsContainer) -and $_.LastWriteTime -lt $Limit } |
        Remove-Item -Force
}

Export-ModuleMember -Function Backup-Server