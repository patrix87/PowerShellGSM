BeforeAll {
  . (Join-Path -Path $PSScriptRoot -ChildPath "TestSetup.ps1")
  #Real SteamCMD output for Enshrouded (app 2278520) when it is up to date: local and public build 26430253.
  $UpToDate = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "Fixtures\steamcmd-enshrouded-up-to-date.txt") -Raw
}

Describe "Request-Update" {
  BeforeEach {
    Push-Location -Path $TestDrive
    $null = New-Item -Path "servers" -ItemType "directory" -Force
    $global:Server = [PSCustomObject]@{
      Name              = "enshrouded"
      Path              = (Join-Path -Path $TestDrive -ChildPath "servers")
      AppID             = 2278520
      Login             = "anonymous"
      BetaBuild         = ""
      BetaBuildPassword = ""
    }
    $global:Global.Debug = $false
    $global:SteamOutput = $UpToDate
    Mock -ModuleName "Request-Update" Write-ServerMsg {}
    #Stands in for SteamCMD: writes the output under test to the file it is redirected to.
    Mock -ModuleName "Request-Update" Start-Process {
      if ($null -ne $global:SteamOutput) {
        Set-Content -Path $RedirectStandardOutput -Value $global:SteamOutput -NoNewline
      }
      return [PSCustomObject]@{ ExitCode = 0 }
    }
  }

  AfterEach {
    Pop-Location
  }

  It "Reports no update when the local and public builds match" {
    Request-Update | Should -BeFalse
  }

  It "Reports an update when the public build is newer" {
    $global:SteamOutput = $UpToDate -replace '("buildid"\s+)"26430253"', '$1"26430999"'
    Request-Update | Should -BeTrue
  }

  It "Reports an update when SteamCMD says an update is required" {
    $global:SteamOutput = $UpToDate -replace "install state: Fully Installed", "install state: Fully Installed,Update Required"
    Request-Update | Should -BeTrue
  }

  It "Compares with the beta branch build when BetaBuild is set" {
    $global:Server.BetaBuild = "experimental"
    $global:SteamOutput = $UpToDate -replace '("branches"\s*\{)', ('$1' + "`r`n`t`t`t`"experimental`"`r`n`t`t`t{`r`n`t`t`t`t`"buildid`"`t`t`"26431111`"`r`n`t`t`t}")
    Request-Update | Should -BeTrue
  }

  It "Skips the update when SteamCMD returned nothing" {
    $global:SteamOutput = $null
    Request-Update | Should -BeFalse
  }

  It "Skips the update when the build IDs cannot be read" {
    $global:SteamOutput = "Steam Console Client`r`nERROR! Failed to connect`r`n"
    Request-Update | Should -BeFalse
  }

  It "Deletes the SteamCMD script and output files" {
    $null = Request-Update
    Get-ChildItem -Path "servers" -Filter "SteamCMD_*" | Should -BeNullOrEmpty
  }

  It "Does not run SteamCMD for servers without an AppID" {
    $global:Server.AppID = 0
    $null = Request-Update
    Should -Invoke -ModuleName "Request-Update" Start-Process -Times 0 -Exactly
  }
}
