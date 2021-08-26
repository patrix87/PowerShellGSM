#7zip
[string]$SevenZip=".\tools\7z\7za.exe"

#mcrcon
[string]$Mcrcon=".\tools\mcrcon\mcrcon.exe"

#SteamCMD
[string]$SteamCMD=".\tools\SteamCMD\steamcmd.exe"

#Path of the logs folder.
[string]$LogFolder=".\logs"

Export-ModuleMember -Variable * -Verbose:$false
