function Remove-OldPwsh {
  [CmdletBinding()]
  param (
  )
  #Remove the PowerShell versions other than PwshVersion from PwshDirectory, once no running process uses them.
  $Root = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine((Get-Location).Path, $Global.PwshDirectory))
  $OldVersions = Get-ChildItem -Path $Root -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne $Global.PwshVersion }
  foreach ($Folder in $OldVersions) {
    $Prefix = "$($Folder.FullName)\"
    $InUse = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Path -and $_.Path.StartsWith($Prefix, [System.StringComparison]::OrdinalIgnoreCase) }
    if (-not $InUse) {
      Write-ScriptMsg "Removing PowerShell $($Folder.Name)."
      $null = Remove-Item -Path $Folder.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
  }
}
Export-ModuleMember -Function Remove-OldPwsh
