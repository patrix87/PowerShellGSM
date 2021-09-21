
function Resolve-CompletePath {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [string] $Path,
        [string] $ParentPath
    )
    #Add the full path to the path from the config file.
    if ($Path.StartsWith($ParentPath)){
        return "$(Get-Location)$($Path.substring(1))"
    }
    $ReturnPath = Resolve-Path -LiteralPath $Path -ErrorAction SilentlyContinue
    if ($null -eq $ReturnPath) {
        $ReturnPath = $Path
    }
    return $ReturnPath
}

Export-ModuleMember -Function Resolve-CompletePath