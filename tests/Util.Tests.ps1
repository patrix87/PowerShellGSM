BeforeAll {
  . (Join-Path -Path $PSScriptRoot -ChildPath "TestSetup.ps1")
}

BeforeDiscovery {
  $Root = Split-Path -Path $PSScriptRoot
  $Scripts = Get-ChildItem -Path $Root -Include "*.ps1", "*.psm1" -Recurse |
  Where-Object { $_.FullName -notmatch "[\\/]tools[\\/]" } |
  ForEach-Object { @{ Name = $_.FullName.Substring($Root.Length + 1); Path = $_.FullName } }
}

Describe "Every script" {
  It "<Name> parses without errors" -ForEach $Scripts {
    $Tokens = $null
    $Errors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$Tokens, [ref]$Errors)
    $Errors | Should -BeNullOrEmpty
  }
}

Describe "Optimize-ArgumentList" {
  It "Drops arguments left without a value and keeps the others in order" {
    $Arguments = @("-log", "-port=", "-name=`"`"", "-world=`"Dedicated`"", "-pass=`"`"`"", "-public 1")
    Optimize-ArgumentList -Arguments $Arguments | Should -Be @("-log", "-world=`"Dedicated`"", "-public 1")
  }
}

Describe "Import-Override" {
  BeforeEach {
    Push-Location -Path $TestDrive
    Import-Module -Name ([System.IO.Path]::Combine($RepoRoot, "defaults.psm1")) -Global -Force
    Mock -ModuleName "Import-Override" Write-Warning {}
  }

  AfterEach {
    Remove-Item -Path "override.psm1" -ErrorAction SilentlyContinue
    Get-Module -Name "override" | Remove-Module -Force
    Pop-Location
  }

  It "Leaves the defaults alone without an override.psm1" {
    Import-Override
    $global:Global.AutoUpdateTool | Should -BeTrue
  }

  It "Applies the settings from override.psm1" {
    Set-Content -Path "override.psm1" -Value "`$OverrideDetails = @{ AutoUpdateTool = `$false; Days = 3 }`nExport-ModuleMember -Variable 'OverrideDetails'"
    Import-Override
    $global:Global.AutoUpdateTool | Should -BeFalse
    $global:Global.Days | Should -Be 3
  }

  It "Warns about and ignores unknown settings" {
    Set-Content -Path "override.psm1" -Value "`$OverrideDetails = @{ TaskHeadless = `$true }`nExport-ModuleMember -Variable 'OverrideDetails'"
    Import-Override
    Should -Invoke -ModuleName "Import-Override" Write-Warning -Times 1 -Exactly -ParameterFilter { $Message -like "*TaskHeadless*" }
    $global:Global.PSObject.Properties.Name | Should -Not -Contain "TaskHeadless"
  }
}
