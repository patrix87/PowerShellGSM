BeforeAll {
  . (Join-Path -Path $PSScriptRoot -ChildPath "TestSetup.ps1")
}

#Get-IniValue and Set-IniValue call kernel32, so these only run on Windows.
Describe "INI files" -Tag "Windows" {
  BeforeEach {
    $File = Join-Path -Path $TestDrive -ChildPath "test.ini"
    Remove-Item -Path $File -ErrorAction SilentlyContinue
  }

  It "Reads back what it writes, and creates the file" {
    Set-IniValue -file $File -category "Schedule" -key "NextAlive" -value "2026-11-18_11-00-00"
    Get-IniValue -file $File -category "Schedule" -key "NextAlive" | Should -Be "2026-11-18_11-00-00"
  }

  It "Replaces an existing value" {
    Set-IniValue -file $File -category "Schedule" -key "NextAlive" -value "first"
    Set-IniValue -file $File -category "Schedule" -key "NextAlive" -value "second"
    Get-IniValue -file $File -category "Schedule" -key "NextAlive" | Should -Be "second"
  }

  It "Returns an empty string for a missing key or file" {
    Get-IniValue -file $File -category "Schedule" -key "Nope" | Should -BeExactly ""
  }

  #Same bytes as the Reflection.Emit version this replaced wrote in Windows PowerShell: the
  #system ANSI code page (Windows-1252 here), CRLF line endings.
  It "Writes the same bytes as before, accents included" {
    Set-IniValue -file $File -category "/Script/Astro.AstroServerSettings" -key "ServerName" -value "B$([char]0xFB)cherons Caf$([char]0xE9)"
    Set-IniValue -file $File -category "URL" -key "Port" -value 7777
    $Expected = "[/Script/Astro.AstroServerSettings]`r`nServerName=B" + [char]0xFB + "cherons Caf" + [char]0xE9 + "`r`n[URL]`r`nPort=7777`r`n"
    $Ansi = [System.Text.Encoding]::GetEncoding([System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ANSICodePage)
    [System.IO.File]::ReadAllBytes($File) | Should -Be $Ansi.GetBytes($Expected)
  }
}
