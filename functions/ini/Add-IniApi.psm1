function Add-IniApi {
  #Declare the kernel32 INI functions used by Get-IniValue and Set-IniValue, once per session.
  #Add-Type works in both Windows PowerShell and PowerShell 7, unlike building the P/Invoke with Reflection.Emit.
  #The Unicode (W) functions leave the conversion to the file encoding to Windows, as the ANSI ones did, so files are written the same way.
  if ("PowerShellGSM.IniApi" -as [type]) {
    return
  }
  Add-Type -Namespace "PowerShellGSM" -Name "IniApi" -MemberDefinition @"
[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
public static extern uint GetPrivateProfileString(string lpAppName, string lpKeyName, string lpDefault, System.Text.StringBuilder lpReturnedString, int nSize, string lpFileName);
[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
public static extern bool WritePrivateProfileString(string lpAppName, string lpKeyName, string lpString, string lpFileName);
"@
}
Export-ModuleMember -Function Add-IniApi
