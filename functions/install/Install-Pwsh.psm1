function Install-Pwsh {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$Destination
  )
  #Install the pinned PowerShell 7 from its official portable zip, checked against PwshSha256. Throws on failure.
  $Version = $Global.PwshVersion
  Write-ScriptMsg "Downloading PowerShell $Version."
  $null = New-Item -Path ".\downloads" -ItemType "directory" -Force
  $Zip = ".\downloads\PowerShell-$Version-win-x64.zip"
  $null = Invoke-Download -Uri "https://github.com/PowerShell/PowerShell/releases/download/v$Version/PowerShell-$Version-win-x64.zip" -OutFile $Zip
  $Hash = (Get-FileHash -Path $Zip -Algorithm "SHA256").Hash
  if ($Hash -ne $Global.PwshSha256) {
    $null = Remove-Item -Path $Zip -Force -ErrorAction SilentlyContinue
    throw "The PowerShell $Version download does not match PwshSha256 (got $Hash)."
  }
  #Extracted next to its final location then renamed, so an interrupted install is never used.
  $Staging = "$Destination.partial"
  $null = New-Item -Path (Split-Path -Path $Destination) -ItemType "directory" -Force
  $null = Remove-Item -Path $Staging -Recurse -Force -ErrorAction SilentlyContinue
  Expand-Archive -Path $Zip -DestinationPath $Staging -Force
  Move-Item -Path $Staging -Destination $Destination
  $null = Remove-Item -Path $Zip -Force -ErrorAction SilentlyContinue
  if (-not (Get-ChildItem -Path ".\downloads" -Force -ErrorAction SilentlyContinue)) {
    $null = Remove-Item -Path ".\downloads" -Force -ErrorAction SilentlyContinue
  }
  Write-ScriptMsg "PowerShell $Version Installed."
}
Export-ModuleMember -Function Install-Pwsh
