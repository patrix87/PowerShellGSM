<#
Set-IniValue.psm1

Set an entry from an INI file.

ie:

  PS >copy C:\winnt\system32\ntfrsrep.ini c:\temp\
  PS >Set-IniValue.psm1 C:\temp\ntfrsrep.ini text DEV_CTR_24_009_HELP "New Value"
  >>
  PS >Get-IniValue.psm1 C:\temp\ntfrsrep.ini text DEV_CTR_24_009_HELP
  New Value
  PS >Set-IniValue.psm1 C:\temp\ntfrsrep.ini NEW_SECTION NewItem "Entirely New Value"
  >>
  PS >Get-IniValue.psm1 C:\temp\ntfrsrep.ini NEW_SECTION NewItem
  Entirely New Value
#>

function Set-IniValue {
  param(
    $file,
    $category,
    $key,
    $value
  )

  # Prepare the parameter types and parameter values for the Invoke-WindowsApi script
  $parameterTypes = [string], [string], [string], [string]
  $parameters = [string] $category, [string] $key, [string] $value, [string] $file

  # Invoke the API
  [void] (Invoke-WindowsApi "kernel32.dll" ([UInt32]) "WritePrivateProfileString" $parameterTypes $parameters)
}

Export-ModuleMember -Function Set-IniValue