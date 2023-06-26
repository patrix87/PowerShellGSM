function Read-Config {
  #Read configuration data and improve it by parsing full paths and cleaning arguments

  #Create Long Paths
  $Server.Exec = (Resolve-CompletePath -Path $Server.Exec -ParentPath ".\servers\")
  $Server.Path = (Resolve-CompletePath -Path $Server.Path -ParentPath ".\servers\")
  $Server.ConfigFolder = (Resolve-CompletePath -Path $Server.ConfigFolder -ParentPath ".\servers\")
  $Backups.Path = (Resolve-CompletePath -Path $Backups.Path -ParentPath ".\backups\")
  $Backups.Saves = (Resolve-CompletePath -Path $Backups.Saves -ParentPath ".\servers\")
  $Global.SevenZip = (Resolve-CompletePath -Path $Global.SevenZip -ParentPath ".\tools\")
  $Global.Mcrcon = (Resolve-CompletePath -Path $Global.Mcrcon -ParentPath ".\tools\")
  $Global.SteamCMD = (Resolve-CompletePath -Path $Global.SteamCMD -ParentPath ".\tools\")
  $Global.JavaDirectory = (Resolve-CompletePath -Path $Global.JavaDirectory -ParentPath ".\tools\")
  $Global.LogFolder = (Resolve-CompletePath -Path $Global.LogFolder -ParentPath ".\")

  #Create Arguments
  if ($Server.ArgumentList.length -gt 0) {
    Add-Member -InputObject $Server -Name "Arguments" -Type NoteProperty -Value ((Optimize-ArgumentList -Arguments $Server.ArgumentList) -join "")
  }
}
Export-ModuleMember -Function Read-Config