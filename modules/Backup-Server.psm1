function Backup-Server {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [string]$BackupPath,
        [string]$ServerSaves,
        [string]$SevenZip,
        [Parameter(Mandatory=$False)]
        [int32]$BackupDays=7,
        [int32]$BackupWeeks=4
    )
    $SevenZip = Resolve-Path -Path $SevenZip
    Write-Verbose "Creating Backup"
    #Create backup name from date and time
    $BackupName=Get-TimeStamp
    #Check if it's friday (Sunday is 0)
    if ((Get-Date -UFormat %u) -eq 5){
        $Type = "Weekly"
        $Limit=(Get-Date).AddDays(-$BackupWeeks)
    } else {
        $Type = "Daily"
        $Limit=(Get-Date).AddDays(-$BackupDays)
    }
    #Check if directory exist and create it.
    if (!(Test-Path "$BackupPath\$Type" -PathType "Container")){
        New-Item -Path $BackupPath\$Type -ItemType "directory" -ErrorAction SilentlyContinue
    }
    #Run Backup
    try {
        & $SevenZip a -tzip -mx=1 $BackupPath\$Type\$BackupName.zip $ServerSaves
    }
    catch {
        Exit-WithCode -ErrorMsg "Unable to backup server." -ErrorObj $_ -ExitCode 500
    }

    Write-Verbose "Backup Created : $BackupName.zip"

    #Delete old backups
    Write-Verbose "Deleting backup old backups"
    Get-ChildItem -Path $BackupPath\$Type -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $Limit } | Remove-Item -Force
}

Export-ModuleMember -Function Backup-Server -Verbose:$false