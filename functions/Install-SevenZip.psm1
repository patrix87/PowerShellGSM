function Install-SevenZip {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Application
    )
    Write-ServerMsg "Installing 7Zip Portable."
    Write-ServerMsg "Downloading 7zip 9.20 to extract 7zip 19.00"
    Invoke-WebRequest -Uri "https://www.7-zip.org/a/7za920.zip" -OutFile ".\downloads\7za920.zip"
    Expand-Archive -Path ".\downloads\7za920.zip" -DestinationPath ".\downloads\7z920\" -Force
    Write-ServerMsg "Downloading 7zip 19.00"
    Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z1900-extra.7z" -OutFile ".\downloads\7z1900-extra.7z" -ErrorAction SilentlyContinue
    & ".\downloads\7z920\7za.exe" x ".\downloads\7z1900-extra.7z" -o".\downloads\7z1900\" -y
    Copy-Item -Path ".\downloads\7z1900\x64\" -Destination (Split-Path -Path $Application) -Recurse -Force
    Write-ServerMsg "7Zip Installed."
}

Export-ModuleMember -Function Install-SevenZip
