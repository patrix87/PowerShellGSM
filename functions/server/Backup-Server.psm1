function Backup-Server {
  Write-ServerMsg "Creating Backup."
  #Create backup name from date and time
  $BackupName = Get-TimeStamp
  $BackupStart = Get-Date

  #Check if it's friday (Sunday is 0)
  if ((Get-Date -UFormat %u) -eq 5) {
    $Type = "Weekly"
    $Limit = (Get-Date).AddDays( - ($Backups.Weeks * 7))
  }
  else {
    $Type = "Daily"
    $Limit = (Get-Date).AddDays(-$Backups.Days)
  }

  #Check if Backups Destination directory exist and create it.
  if (-not (Test-Path -Path "$($Backups.Path)\$Type" -PathType "Container" -ErrorAction SilentlyContinue)) {
    $null = New-Item -Path "$($Backups.Path)\$Type" -ItemType "directory" -ErrorAction SilentlyContinue
  }
  #Check if Backups Source directory exist and create it.
  if (-not (Test-Path -Path $Backups.Saves -PathType "Container" -ErrorAction SilentlyContinue)) {
    $null = New-Item -Path $Backups.Saves -ItemType "directory" -ErrorAction SilentlyContinue
  }

#Run Backup
try {
  if ($Backups.Exclusions -ne "") {
    Write-ServerMsg "Server Backup Exclusions: $($Backups.Exclusions)"
  }
  if ($Global.Exclusions.Count -gt 0) {
    Write-ServerMsg "Global Backup Exclusions: $($Global.Exclusions)"
  }
  # Return true if the file should be included in the backup, otherwise return false
  $IncludeFilter = {

    if($Global.Debug) {
      Write-ServerMsg "File: $($_.FullName) Extension: $($_.Extension)"
    }

    # If the file is a directory, include it in the backup
    if ($_.PSIsContainer) {
      if($Global.Debug) {Write-ServerMsg "Is a Folder"}
      return $true
    }

    # If the file extension is in the global exclusions list, exclude it from the backup
    if ($Global.Exclusions.Count -gt 0) {
      if ($_.Extension -in $Global.Exclusions) {
        if($Global.Debug) {Write-ServerMsg "Excluded: Global Extension Exclusions"}
        return $false
      }
    }

    # If the filename match the backups Regex Exclusions, exclude it from the backup
    if ($Backups.Exclusions -ne "") {
      if ($_.Name -match $Backups.Exclusions) {
        if($Global.Debug) {Write-ServerMsg "Excluded: REGEX"}
        return $false
      }
    }

    # else include it in the backup
    if ($Global.Debug) {Write-ServerMsg "Included"}
    return $true
  }

  # Get all files that should be included in the backup
  $FilesToBackup = Get-ChildItem -Path $Backups.Saves -Recurse | Where-Object $IncludeFilter

  # Add debug messages if $Global.Debug is true
  if ($Global.Debug) {
    Write-ServerMsg "Files to Backup:"
    $FilesToBackup | ForEach-Object {
      Write-ServerMsg $_.FullName
    }
  }

  # Remove any existing temporary directory
  if (Test-Path -Path "$($Backups.Path)\$Type\$((Get-Item $Backups.Saves).Name)" -PathType "Container" -ErrorAction SilentlyContinue) {
    Remove-Item -Path "$($Backups.Path)\$Type\$((Get-Item $Backups.Saves).Name)" -Force -Recurse
  }

  # Create a temporary directory
  $TempDirectory = New-Item -ItemType Directory -Path "$($Backups.Path)\$Type\$((Get-Item $Backups.Saves).Name)"

  # Copy each file to the temporary directory while preserving the directory structure
  foreach ($File in $FilesToBackup) {
    $Destination = $File.FullName.Replace($Backups.Saves, "$($TempDirectory)\")
    $DestinationDirectory = Split-Path -Path $Destination -Parent
    if (-not (Test-Path -Path $DestinationDirectory)) {
      New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null
    }
    Copy-Item -Path $File.FullName -Destination $Destination
  }

  # Compress the temporary directory into a zip archive using the specified compression options
  if (Get-Module -ListAvailable -Name 7Zip4PowerShell) {
    Compress-7Zip -Path $TempDirectory -ArchiveFileName "$($Backups.Path)\$Type\$BackupName.zip" -CompressionLevel 'Fast' -Format Zip
  } else {
    Compress-Archive -Path $TempDirectory -DestinationPath "$($Backups.Path)\$Type\$BackupName.zip" -CompressionLevel 'Fastest'
  }

  # Remove the temporary directory
  Remove-Item -Path $TempDirectory -Force -Recurse
}
catch {
  Exit-WithError -ErrorMsg "Unable to backup server."
}

  $zipFile = Get-Item "$($Backups.Path)\$Type\$BackupName.zip"
  Write-ServerMsg "Backup Created : $BackupName.zip [$(Format-FileSize $zipFile.Length)][$((New-TimeSpan -Start $BackupStart).toString("g"))]"

  #Delete old backups
  Write-ServerMsg "Deleting old backups."
  $null = Get-ChildItem -Path "$($Backups.Path)\$Type" -Recurse -Force |
  Where-Object { -not ($_.PSIsContainer) -and $_.LastWriteTime -lt $Limit } |
  Remove-Item -Force
}

Export-ModuleMember -Function Backup-Server