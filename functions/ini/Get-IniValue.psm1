<#
Get-IniValue.psm1

Get an entry from an INI file.

ie: PS >Get-IniValue C:\winnt\system32\ntfrsrep.ini text DEV_CTR_24_009_HELP
#>

function Get-IniValue {
  param(
    $file,
    $category,
    $key
  )
  Add-IniApi
  $returnValue = New-Object System.Text.StringBuilder 500
  [void] [PowerShellGSM.IniApi]::GetPrivateProfileString([string] $category, [string] $key, "", $returnValue, $returnValue.Capacity, [string] $file)
  $returnValue.ToString()
}

Export-ModuleMember -Function Get-IniValue
