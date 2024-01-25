function Install-ARRCON {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$Application
  )
  Write-ServerMsg "Downloading ARRCON."
  #Create Install Directory.
  $null = New-Item -Path (Split-Path -Path $Application) -ItemType "directory"
  #Download zip file.
  $null = Invoke-Download -Uri "https://github.com/radj307/ARRCON/releases/download/3.3.7/ARRCON-3.3.7-Windows.zip" -OutFile ".\downloads\ARRCON.zip" -ErrorAction SilentlyContinue
  #Unzip file.
  $null = Expand-Archive -Path ".\downloads\ARRCON.zip" -DestinationPath ".\downloads\ARRCON\" -Force
  #Copy executable to install directory.
  $null = Copy-Item -Path ".\downloads\ARRCON\ARRCON.exe" -Destination $Application -Force
  Write-ServerMsg "ARRCON Installed."
}

Export-ModuleMember -Function Install-ARRCON