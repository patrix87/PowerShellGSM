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
    $SevenZip=Resolve-Path -Path $SevenZip
    Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Creating Backup."
    #Create backup name from date and time
    $BackupName=Get-TimeStamp
    #Check if it's friday (Sunday is 0)
    if ((Get-Date -UFormat %u) -eq 5){
        $Type="Weekly"
        $Limit=(Get-Date).AddDays(-$BackupWeeks)
    } else {
        $Type="Daily"
        $Limit=(Get-Date).AddDays(-$BackupDays)
    }
    #Check if directory exist and create it.
    if (!(Test-Path "$BackupPath\$Type" -PathType "Container")){
        New-Item -Path $BackupPath\$Type -ItemType "directory" -ErrorAction SilentlyContinue
    }
    #Wait for server to have unlocked files
    Start-Sleep -Seconds 5
    #Run Backup
    try {
        & $SevenZip a -tzip -mx=1 $BackupPath\$Type\$BackupName.zip $ServerSaves
    }
    catch {
        Exit-WithError -ErrorMsg "Unable to backup server."
    }

    Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Backup Created : $BackupName.zip"

    #Delete old backups
    Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Deleting old backups."
    Get-ChildItem -Path $BackupPath\$Type -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $Limit } | Remove-Item -Force
}

Export-ModuleMember -Function Backup-Server