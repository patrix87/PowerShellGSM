BeforeAll {
  . (Join-Path -Path $PSScriptRoot -ChildPath "TestSetup.ps1")

  function New-FakeTask {
    param (
      [string]$Arguments = "--headless `"C:\PowerShellGSM\tools\pwsh\7.6.10\pwsh.exe`" -File `"C:\PowerShellGSM\main.ps1`"",
      [string]$LogonType = "Interactive",
      [string]$Interval = "PT5M"
    )
    return [PSCustomObject]@{
      Actions   = @([PSCustomObject]@{ Execute = "conhost.exe"; Arguments = $Arguments; WorkingDirectory = "C:\PowerShellGSM" })
      Principal = [PSCustomObject]@{ LogonType = $LogonType }
      Triggers  = @([PSCustomObject]@{ Repetition = [PSCustomObject]@{ Interval = $Interval } })
    }
  }
}

Describe "Test-TaskCurrent" {
  BeforeEach {
    $global:Global.TaskRunWhileLoggedOff = $false
    $global:RegisteredTask = New-FakeTask
    Mock -ModuleName "Test-TaskCurrent" Get-ScheduledTask { return $global:RegisteredTask }
  }

  It "Is current when the action, logon type and interval match" {
    Test-TaskCurrent -TaskName "Tasks-test" -Task (New-FakeTask) -Interval (New-TimeSpan -Minutes 5) | Should -BeTrue
  }

  It "Is not current when the task does not exist" {
    $global:RegisteredTask = $null
    Test-TaskCurrent -TaskName "Tasks-test" -Task (New-FakeTask) -Interval (New-TimeSpan -Minutes 5) | Should -BeFalse
  }

  It "Is not current when the action changed (an older PowerShellGSM or PowerShell)" {
    $global:RegisteredTask = New-FakeTask -Arguments "-WindowStyle Hidden -File `"C:\PowerShellGSM\main.ps1`""
    Test-TaskCurrent -TaskName "Tasks-test" -Task (New-FakeTask) -Interval (New-TimeSpan -Minutes 5) | Should -BeFalse
  }

  It "Is not current when TaskRunWhileLoggedOff changed" {
    $global:Global.TaskRunWhileLoggedOff = $true
    Test-TaskCurrent -TaskName "Tasks-test" -Task (New-FakeTask) -Interval (New-TimeSpan -Minutes 5) | Should -BeFalse
    $global:RegisteredTask = New-FakeTask -LogonType "S4U"
    Test-TaskCurrent -TaskName "Tasks-test" -Task (New-FakeTask) -Interval (New-TimeSpan -Minutes 5) | Should -BeTrue
  }

  It "Is not current when the interval changed" {
    Test-TaskCurrent -TaskName "Tasks-test" -Task (New-FakeTask) -Interval (New-TimeSpan -Minutes 10) | Should -BeFalse
  }

  It "Compares intervals by duration, not by text (P1D is 24 hours)" {
    $global:RegisteredTask = New-FakeTask -Interval "P1D"
    Test-TaskCurrent -TaskName "PowerShellGSM-Update" -Task (New-FakeTask) -Interval (New-TimeSpan -Hours 24) | Should -BeTrue
  }

  It "Is not current when the task has no repetition" {
    $global:RegisteredTask = New-FakeTask -Interval ""
    Test-TaskCurrent -TaskName "Tasks-test" -Task (New-FakeTask) -Interval (New-TimeSpan -Minutes 5) | Should -BeFalse
  }
}
