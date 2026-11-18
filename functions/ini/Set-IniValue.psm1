<#
Set-IniValue.psm1

Set an entry from an INI file.

ie:

  PS >copy C:\winnt\system32\ntfrsrep.ini c:\temp\
  PS >Set-IniValue C:\temp\ntfrsrep.ini text DEV_CTR_24_009_HELP "New Value"
  >>
  PS >Get-IniValue C:\temp\ntfrsrep.ini text DEV_CTR_24_009_HELP
  New Value
  PS >Set-IniValue C:\temp\ntfrsrep.ini NEW_SECTION NewItem "Entirely New Value"
  >>
  PS >Get-IniValue C:\temp\ntfrsrep.ini NEW_SECTION NewItem
  Entirely New Value
#>

function Set-IniValue {
  param(
    $file,
    $category,
    $key,
    $value
  )
  Add-IniApi
  [void] [PowerShellGSM.IniApi]::WritePrivateProfileString([string] $category, [string] $key, [string] $value, [string] $file)
}

Export-ModuleMember -Function Set-IniValue
