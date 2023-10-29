function Install-Mcrcon {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$Application
  )
  Write-ServerMsg "Downloading mcrcon."
  #Create Install Directory.
  $null = New-Item -Path (Split-Path -Path $Application) -ItemType "directory"
  #Download zip file.
  $null = Invoke-Download -Uri "https://github.com/Tiiffi/mcrcon/releases/download/v0.7.2/mcrcon-0.7.2-windows-x86-64.zip" -OutFile ".\downloads\mcrcon.zip" -ErrorAction SilentlyContinue
  #Unzip file.
  $null = Expand-Archive -Path ".\downloads\mcrcon.zip" -DestinationPath ".\downloads\mcrcon\" -Force
  #Copy executable to install directory.
  $null = Copy-Item -Path ".\downloads\mcrcon\mcrcon-0.7.2-windows-x86-64\mcrcon.exe" -Destination $Application -Force
  Write-ServerMsg "Mcrcon Installed."
}

Export-ModuleMember -Function Install-Mcrcon