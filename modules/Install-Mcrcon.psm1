function Install-mcrcon {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Application
    )
    Write-Verbose "Downloading mcrcon"
    New-Item -Path (Split-Path -Path $Application) -ItemType "directory"
    Invoke-WebRequest -Uri "https://github.com/Tiiffi/mcrcon/releases/download/v0.7.1/mcrcon-0.7.1-windows-x86-32.zip" -OutFile ".\downloads\mcrcon.zip" -ErrorAction SilentlyContinue
    Expand-Archive -Path ".\downloads\mcrcon.zip" -DestinationPath ".\downloads\mcrcon\" -Force
    $McrconPath=Resolve-Path -Path ".\downloads\mcrcon\mcrcon-0.7.1-windows-x86-32\mcrcon.exe"
    Copy-Item -Path $McrconPath -Destination $Application -Force
}

Export-ModuleMember -Function Install-mcrcon -Verbose:$false