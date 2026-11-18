BeforeAll {
  . (Join-Path -Path $PSScriptRoot -ChildPath "TestSetup.ps1")

  #A stand-in for the server's System.Diagnostics.Process. It exits when one of the methods in
  #ExitsOn is used on it. $global so that the mocks below can reach it.
  function New-FakeProcess {
    param (
      [string[]]$ExitsOn = @(),
      [bool]$HasWindow = $true,
      [string]$Name = "gameserver"
    )
    $Process = [PSCustomObject]@{
      ProcessName = $Name
      Id          = 4242
      HasExited   = $false
      HasWindow   = $HasWindow
      ExitsOn     = $ExitsOn
    }
    $Process | Add-Member -MemberType ScriptMethod -Name "CloseMainWindow" -Value {
      if (-not $this.HasWindow) {
        return $false
      }
      if ($this.ExitsOn -contains "CloseWindow") {
        $this.HasExited = $true
      }
      return $true
    }
    $Process | Add-Member -MemberType ScriptMethod -Name "WaitForExit" -Value { param($Milliseconds) return $this.HasExited }
    $global:FakeProcess = $Process
    return $Process
  }
}

Describe "Stop-ServerProcess" {
  BeforeEach {
    $global:Server = [PSCustomObject]@{ Name = "test"; ProcessName = "gameserver"; AllowForceClose = $true }
    $global:Warnings = [PSCustomObject]@{ CmdSave = "save"; CmdStop = "quit"; SaveDelay = 5 }
    Mock -ModuleName "Stop-ServerProcess" Start-Sleep {}
    Mock -ModuleName "Stop-ServerProcess" Write-ServerMsg {}
    Mock -ModuleName "Stop-ServerProcess" Write-Warning {}
    Mock -ModuleName "Stop-ServerProcess" Send-Command {
      if (($Command -eq "quit") -and ($global:FakeProcess.ExitsOn -contains "Command")) {
        $global:FakeProcess.HasExited = $true
      }
      return $true
    }
    Mock -ModuleName "Stop-ServerProcess" Invoke-ConsoleControl {
      if ($global:FakeProcess.ExitsOn -contains "CtrlC") {
        $global:FakeProcess.HasExited = $true
      }
      return $true
    }
    Mock -ModuleName "Stop-ServerProcess" Stop-Process { $global:FakeProcess.HasExited = $true }
  }

  It "Returns -1 and does nothing when the process is not the server" {
    $Process = New-FakeProcess -Name "notepad"
    Stop-ServerProcess -ServerProcess $Process -CommandAvailable $true | Should -Be -1
    Should -Invoke -ModuleName "Stop-ServerProcess" Send-Command -Times 0 -Exactly
    Should -Invoke -ModuleName "Stop-ServerProcess" Stop-Process -Times 0 -Exactly
  }

  It "By default, saves then stops with the stop command when the server answers" {
    $Process = New-FakeProcess -ExitsOn "Command"
    Stop-ServerProcess -ServerProcess $Process -CommandAvailable $true | Should -Be 1
    Should -Invoke -ModuleName "Stop-ServerProcess" Send-Command -Times 1 -Exactly -ParameterFilter { $Command -eq "save" }
    Should -Invoke -ModuleName "Stop-ServerProcess" Send-Command -Times 1 -Exactly -ParameterFilter { $Command -eq "quit" }
    Should -Invoke -ModuleName "Stop-ServerProcess" Stop-Process -Times 0 -Exactly
  }

  It "By default, closes the window when the server does not answer commands" {
    $Process = New-FakeProcess -ExitsOn "CloseWindow"
    Stop-ServerProcess -ServerProcess $Process -CommandAvailable $false | Should -Be 1
    Should -Invoke -ModuleName "Stop-ServerProcess" Send-Command -Times 0 -Exactly
    Should -Invoke -ModuleName "Stop-ServerProcess" Stop-Process -Times 0 -Exactly
  }

  It "Sends only the stop command when the template has no save command" {
    $global:Warnings.CmdSave = ""
    $Process = New-FakeProcess -ExitsOn "Command"
    Stop-ServerProcess -ServerProcess $Process -CommandAvailable $true | Should -Be 1
    Should -Invoke -ModuleName "Stop-ServerProcess" Send-Command -Times 1 -Exactly
  }

  It "Follows the template's StopMethods order" {
    $global:Server | Add-Member -NotePropertyName "StopMethods" -NotePropertyValue @("CtrlC", "CloseWindow")
    $Process = New-FakeProcess -ExitsOn "CtrlC", "CloseWindow"
    Stop-ServerProcess -ServerProcess $Process -CommandAvailable $true | Should -Be 1
    Should -Invoke -ModuleName "Stop-ServerProcess" Invoke-ConsoleControl -Times 1 -Exactly -ParameterFilter { $CtrlC -and ($TargetPid -eq 4242) }
    Should -Invoke -ModuleName "Stop-ServerProcess" Send-Command -Times 0 -Exactly
  }

  It "Moves to the next method when one fails" {
    $global:Server | Add-Member -NotePropertyName "StopMethods" -NotePropertyValue @("CtrlC", "CloseWindow")
    Mock -ModuleName "Stop-ServerProcess" Invoke-ConsoleControl { return $false }
    $Process = New-FakeProcess -ExitsOn "CloseWindow"
    Stop-ServerProcess -ServerProcess $Process | Should -Be 1
    Should -Invoke -ModuleName "Stop-ServerProcess" Stop-Process -Times 0 -Exactly
  }

  It "Skips unknown methods with a warning" {
    $global:Server | Add-Member -NotePropertyName "StopMethods" -NotePropertyValue @("NoSuchMethod", "CloseWindow")
    $Process = New-FakeProcess -ExitsOn "CloseWindow"
    Stop-ServerProcess -ServerProcess $Process | Should -Be 1
    Should -Invoke -ModuleName "Stop-ServerProcess" Write-Warning -ParameterFilter { $Message -like "*NoSuchMethod*" }
  }

  It "Kills the server when no method worked and AllowForceClose is set" {
    $Process = New-FakeProcess -HasWindow $false
    Stop-ServerProcess -ServerProcess $Process | Should -Be 1
    Should -Invoke -ModuleName "Stop-ServerProcess" Stop-Process -Times 1 -Exactly -ParameterFilter { ($Id -eq 4242) -and $Force }
  }

  It "Leaves the server running when no method worked and AllowForceClose is off" {
    $global:Server.AllowForceClose = $false
    $Process = New-FakeProcess -HasWindow $false
    Stop-ServerProcess -ServerProcess $Process | Should -Be 0
    Should -Invoke -ModuleName "Stop-ServerProcess" Stop-Process -Times 0 -Exactly
  }
}
