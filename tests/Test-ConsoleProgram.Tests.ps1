BeforeAll {
  . (Join-Path -Path $PSScriptRoot -ChildPath "TestSetup.ps1")

  #Write the smallest PE header Test-ConsoleProgram reads: "MZ", the PE header offset, "PE\0\0" and the Subsystem field.
  function New-PeFile {
    param (
      [string]$Path,
      [uint16]$Subsystem,
      [switch]$NoPeSignature
    )
    $Bytes = New-Object byte[] 512
    $Bytes[0] = 0x4D
    $Bytes[1] = 0x5A
    [System.BitConverter]::GetBytes([int]0x80).CopyTo($Bytes, 0x3C)
    if (-not $NoPeSignature) {
      [System.BitConverter]::GetBytes([uint32]0x00004550).CopyTo($Bytes, 0x80)
    }
    [System.BitConverter]::GetBytes($Subsystem).CopyTo($Bytes, 0x80 + 4 + 20 + 68)
    [System.IO.File]::WriteAllBytes($Path, $Bytes)
  }
}

Describe "Test-ConsoleProgram" {
  It "Is true for a console program (subsystem 3)" {
    New-PeFile -Path (Join-Path -Path $TestDrive -ChildPath "console.exe") -Subsystem 3
    Test-ConsoleProgram -Path (Join-Path -Path $TestDrive -ChildPath "console.exe") | Should -BeTrue
  }

  It "Is false for a GUI program (subsystem 2)" {
    New-PeFile -Path (Join-Path -Path $TestDrive -ChildPath "gui.exe") -Subsystem 2
    Test-ConsoleProgram -Path (Join-Path -Path $TestDrive -ChildPath "gui.exe") | Should -BeFalse
  }

  It "Is false for a file with an MZ header but no PE signature" {
    New-PeFile -Path (Join-Path -Path $TestDrive -ChildPath "dos.exe") -Subsystem 3 -NoPeSignature
    Test-ConsoleProgram -Path (Join-Path -Path $TestDrive -ChildPath "dos.exe") | Should -BeFalse
  }

  It "Is false for a file that is not a program, or does not exist" {
    Set-Content -Path (Join-Path -Path $TestDrive -ChildPath "run.cmd") -Value "@echo off"
    Test-ConsoleProgram -Path (Join-Path -Path $TestDrive -ChildPath "run.cmd") | Should -BeFalse
    Test-ConsoleProgram -Path (Join-Path -Path $TestDrive -ChildPath "missing.exe") | Should -BeFalse
  }

  It "Reads real Windows programs correctly" -Tag "Windows" {
    Test-ConsoleProgram -Path "$env:SystemRoot\System32\cmd.exe" | Should -BeTrue
    Test-ConsoleProgram -Path "$env:SystemRoot\System32\conhost.exe" | Should -BeFalse
    Test-ConsoleProgram -Path "$env:SystemRoot\explorer.exe" | Should -BeFalse
  }
}
