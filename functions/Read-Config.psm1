function Optimize-ArgumentList {
    [CmdletBinding()]
    [OutputType([System.Collections.ArrayList])]
    param (
        [Parameter(Mandatory)]
        [array] $ArgumentList
    )
    #Create Server.Arguments from cleaned ArgumentList.
    [System.Collections.ArrayList]$CleanedArguments=@()

    foreach($Argument in $ArgumentList){
        if (-not ($Argument.EndsWith('=""') -or $Argument.EndsWith('=') -or $Argument.EndsWith('  '))){
            $CleanedArguments.Add($Argument)
        }
    }
    return ($CleanedArguments -join "")
}

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

function Read-Config {
    #Read configuration data and improve it by parsing full paths and cleaning arguments

    #Create Long Paths
	$Server.Exec = (Resolve-CompletePath -Path $Server.Exec -ParentPath ".\servers\")
	$Server.Path = (Resolve-CompletePath -Path $Server.Path -ParentPath ".\servers\")
	$Server.ConfigFolder = (Resolve-CompletePath -Path $Server.ConfigFolder -ParentPath ".\servers\")
	$Backups.Path = (Resolve-CompletePath -Path $Backups.Path -ParentPath ".\backups\")
	$Backups.Saves = (Resolve-CompletePath -Path $Backups.Saves -ParentPath ".\servers\")
	$Global.SevenZip = (Resolve-CompletePath -Path $Global.SevenZip -ParentPath ".\tools\")
	$Global.Mcrcon = (Resolve-CompletePath -Path $Global.Mcrcon -ParentPath ".\tools\")
	$Global.SteamCMD = (Resolve-CompletePath -Path $Global.SteamCMD -ParentPath ".\tools\")
	$Global.LogFolder = (Resolve-CompletePath -Path $Global.LogFolder -ParentPath ".\")

    #Create Arguments
    Add-Member -InputObject $Server -Name "Arguments" -Type NoteProperty -Value (Optimize-ArgumentList -ArgumentList $Server.ArgumentList)
}
Export-ModuleMember -Function Read-Config, Resolve-CompletePath