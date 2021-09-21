function Exit-WithError
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ErrorMsg
    )
    #Write error in red on black, stop logging, pause, exit.
    Write-Host -ForegroundColor "Red" -BackgroundColor "Black" -Object $ErrorMsg
    Stop-Transcript
    Read-Host
    exit
}

Export-ModuleMember -Function Exit-WithError