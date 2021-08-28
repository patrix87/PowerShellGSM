function Write-ScriptMsg {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )
    Write-Host -ForegroundColor $Global.SectionColor -BackgroundColor $Global.BgColor -Object $Message
}

Export-ModuleMember -Function Write-ScriptMsg