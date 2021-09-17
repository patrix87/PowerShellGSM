function Write-ScriptMsg {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )
    #Write script message with the colors defined in global.cfg
    Write-Host -ForegroundColor $Global.SectionColor -BackgroundColor $Global.SectionBgColor -Object $Message
}

Export-ModuleMember -Function Write-ScriptMsg