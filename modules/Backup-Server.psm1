function Backup-Server {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [string]$BackupPath,
        [string]$ServerSaves,
        [string]$7Zip,
        [Parameter(Mandatory=$False)]
        [int32]$BackupDays=7,
        [int32]$BackupWeeks=4
    )
    Write-Output "Creating Backup"
    #Create backup name from date and time
    $BackupName=Get-TimeStamp
    #Check if it's friday (Sunday is 0)
    if ((Get-Date -UFormat %u) -eq 5){
        #Weekly backup
        #Check / Create Path
        New-Item -ItemType directory -Path $BackupPath\Weekly -ErrorAction SilentlyContinue
        & $7Zip a -tzip -mx=1 $BackupPath\Weekly\$BackupName.zip $ServerSaves
    }else {
        #Daily backup
        #Check / Create Path
        New-Item -ItemType directory -Path $BackupPath\Daily -ErrorAction SilentlyContinue
        & $7Zip a -tzip -mx=1 $BackupPath\Daily\$BackupName.zip $ServerSaves
    }
    Write-Output "Backup Created : $BackupName.zip"

    #Delete old Daily backup
    Write-Output "Deleting daily backup older than $BackupDays"
    $Limit=(Get-Date).AddDays(-$BackupDays)
    Get-ChildItem -Path $BackupPath\Daily -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $Limit } | Remove-Item -Force

    #Delete old Weekly backup
    Write-Output "Deleting weekly backup older than $BackupWeeks"
    $Limit=(Get-Date).AddDays(-($BackupWeeks)*7)
    Get-ChildItem -Path $BackupPath\Weekly -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $Limit } | Remove-Item -Force
}

Export-ModuleMember -Function Backup-Server