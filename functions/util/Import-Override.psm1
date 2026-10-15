function Import-Override {
  #Apply the settings from override.psm1 over the ones from defaults.psm1.
  if (-not (Test-Path -Path ".\override.psm1" -PathType "Leaf")) {
    return
  }
  Import-Module -Name ".\override.psm1"
  foreach ($Key in $OverrideDetails.Keys) {
    if ($Global.PSObject.Properties.Name -contains $Key) {
      $Global.$Key = $OverrideDetails[$Key]
    }
    else {
      Write-Warning -Message "Unknown setting '$Key' in override.psm1, ignoring it."
    }
  }
}
Export-ModuleMember -Function Import-Override
