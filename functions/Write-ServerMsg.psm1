function Write-ServerMsg {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )
    Write-Host -ForegroundColor $Global.FGColor -BackgroundColor $Global.BgColor -Object $Message
}

Export-ModuleMember -Function Write-ServerMsg