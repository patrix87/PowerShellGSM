BeforeAll {
  . (Join-Path -Path $PSScriptRoot -ChildPath "TestSetup.ps1")
}

Describe "Pinned PowerShell 7" {
  BeforeEach {
    Push-Location -Path $TestDrive
    Get-ChildItem -Path $TestDrive -Force | Remove-Item -Recurse -Force
    Import-Module -Name ([System.IO.Path]::Combine($RepoRoot, "defaults.psm1")) -Global -Force
    #Built with the platform's separator so the path logic is tested the same way on any OS.
    $global:Global.PwshDirectory = Join-Path -Path "tools" -ChildPath "pwsh"
    $global:Global.PwshVersion = "7.9.9"
    $PwshDirectory = [System.IO.Path]::Combine($TestDrive, "tools", "pwsh")
    Mock -ModuleName "Install-Pwsh" Write-ScriptMsg {}
    Mock -ModuleName "Remove-OldPwsh" Write-ScriptMsg {}
  }

  AfterEach {
    Pop-Location
  }

  Context "Get-PowerShellPath" {
    It "Returns the installed pinned version without installing it again" {
      $Pwsh = [System.IO.Path]::Combine($PwshDirectory, "7.9.9", "pwsh.exe")
      $null = New-Item -Path $Pwsh -ItemType "file" -Force
      Mock -ModuleName "Get-PowerShellPath" Install-Pwsh {}
      Get-PowerShellPath | Should -Be $Pwsh
      Should -Invoke -ModuleName "Get-PowerShellPath" Install-Pwsh -Times 0 -Exactly
    }

    It "Installs the pinned version when it is missing" {
      Mock -ModuleName "Get-PowerShellPath" Install-Pwsh { $null = New-Item -Path (Join-Path -Path $Destination -ChildPath "pwsh.exe") -ItemType "file" -Force }
      Get-PowerShellPath | Should -Be ([System.IO.Path]::Combine($PwshDirectory, "7.9.9", "pwsh.exe"))
      Should -Invoke -ModuleName "Get-PowerShellPath" Install-Pwsh -Times 1 -Exactly
    }
  }

  Context "Install-Pwsh" {
    BeforeEach {
      #A small zip standing in for the PowerShell release.
      $Content = Join-Path -Path $TestDrive -ChildPath "content"
      $null = New-Item -Path (Join-Path -Path $Content -ChildPath "pwsh.exe") -ItemType "file" -Value "fake" -Force
      $global:FakeZip = Join-Path -Path $TestDrive -ChildPath "fake-pwsh.zip"
      Compress-Archive -Path (Join-Path -Path $Content -ChildPath "*") -DestinationPath $global:FakeZip -Force
      Mock -ModuleName "Install-Pwsh" Invoke-Download { Copy-Item -Path $global:FakeZip -Destination $OutFile }
      $Destination = [System.IO.Path]::Combine($PwshDirectory, "7.9.9")
    }

    It "Downloads the pinned version from the official release" {
      $global:Global.PwshSha256 = (Get-FileHash -Path $global:FakeZip -Algorithm "SHA256").Hash
      Install-Pwsh -Destination $Destination
      Should -Invoke -ModuleName "Install-Pwsh" Invoke-Download -Times 1 -Exactly -ParameterFilter {
        $Uri -eq "https://github.com/PowerShell/PowerShell/releases/download/v7.9.9/PowerShell-7.9.9-win-x64.zip"
      }
    }

    It "Installs a download that matches the pinned hash, and cleans up" {
      $global:Global.PwshSha256 = (Get-FileHash -Path $global:FakeZip -Algorithm "SHA256").Hash
      Install-Pwsh -Destination $Destination
      Join-Path -Path $Destination -ChildPath "pwsh.exe" | Should -Exist
      "$Destination.partial" | Should -Not -Exist
      Join-Path -Path $TestDrive -ChildPath "downloads" | Should -Not -Exist
    }

    It "Refuses a download that does not match the pinned hash" {
      $global:Global.PwshSha256 = "0" * 64
      { Install-Pwsh -Destination $Destination } | Should -Throw "*does not match PwshSha256*"
      $Destination | Should -Not -Exist
    }
  }

  Context "Remove-OldPwsh" {
    It "Removes other versions and failed installs, but not the pinned one or one still in use" {
      foreach ($Version in "7.9.9", "7.9.8", "7.9.7", "7.9.9.partial") {
        $null = New-Item -Path ([System.IO.Path]::Combine($PwshDirectory, $Version, "pwsh.exe")) -ItemType "file" -Force
      }
      $global:InUse = [System.IO.Path]::Combine($PwshDirectory, "7.9.7", "pwsh.exe")
      Mock -ModuleName "Remove-OldPwsh" Get-Process { return [PSCustomObject]@{ Path = $global:InUse } }
      Remove-OldPwsh
      (Get-ChildItem -Path $PwshDirectory -Directory).Name | Sort-Object | Should -Be @("7.9.7", "7.9.9")
    }
  }
}
