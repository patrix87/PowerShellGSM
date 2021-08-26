function Install-SevenZip {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Application
    )
    Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Installing 7Zip Portable."
    Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Downloading 7zip 9.20 to extract 7zip 19.00"
    Invoke-WebRequest -Uri "https://www.7-zip.org/a/7za920.zip" -OutFile ".\downloads\7za920.zip"
    Expand-Archive -Path ".\downloads\7za920.zip" -DestinationPath ".\downloads\7z920\" -Force
    Write-Host -ForegroundColor $FgColor -BackgroundColor $BgColor -Object "Downloading 7zip 19.00"
    Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z1900-extra.7z" -OutFile ".\downloads\7z1900-extra.7z" -ErrorAction SilentlyContinue
    $7z920=Resolve-Path -Path ".\downloads\7z920\7za.exe"
    & $7z920 x ".\downloads\7z1900-extra.7z" -o".\downloads\7z1900\" -y
    Copy-Item -Path ".\downloads\7z1900\x64\" -Destination (Split-Path -Path $Application) -Recurse -Force
}

Export-ModuleMember -Function Install-SevenZip
