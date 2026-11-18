BeforeDiscovery {
  $RepoRoot = Split-Path -Path $PSScriptRoot
  $Templates = Get-ChildItem -Path ([System.IO.Path]::Combine($RepoRoot, "templates")) -Filter "*.psm1" |
  ForEach-Object { @{ Name = $_.BaseName; Path = $_.FullName } }
}

BeforeAll {
  . (Join-Path -Path $PSScriptRoot -ChildPath "TestSetup.ps1")
  $Protocols = @("RCON", "ARRCON", "Telnet", "StdIn", "RestAPI")
  $StopMethods = @("Command", "CtrlC", "CloseWindow")
}

Describe "Template <Name>" -ForEach $Templates {
  BeforeAll {
    #Load the template from a scratch install, as main.ps1 does from the install folder: templates
    #may read files from it, like the ASA cluster template reads configs\shared\asa_shared.json.
    $Install = Join-Path -Path $TestDrive -ChildPath $Name
    $null = New-Item -Path ([System.IO.Path]::Combine($Install, "configs")) -ItemType "directory" -Force
    Copy-Item -Path ([System.IO.Path]::Combine($RepoRoot, "templates", "shared")) -Destination ([System.IO.Path]::Combine($Install, "configs")) -Recurse
    Push-Location -Path $Install
    #Fresh settings for each template: Read-Config rewrites some of them.
    Import-Module -Name ([System.IO.Path]::Combine($RepoRoot, "defaults.psm1")) -Global -Force
    #Templates name their server after the config file, through the $ServerCfg set by main.ps1.
    $global:ServerCfg = $Name
    $Module = Import-Module -Name $Path -PassThru -Force -DisableNameChecking
    $TemplateServer = & $Module { $Server }
    $TemplateBackups = & $Module { $Backups }
    $TemplateWarnings = & $Module { $Warnings }
  }

  AfterAll {
    if ($Module) {
      Remove-Module -ModuleInfo $Module -Force
    }
    Pop-Location
  }

  It "Defines Server, Backups, Warnings and Start-ServerPrep" {
    $TemplateServer | Should -Not -BeNullOrEmpty
    $TemplateBackups | Should -Not -BeNullOrEmpty
    $TemplateWarnings | Should -Not -BeNullOrEmpty
    $Module.ExportedFunctions.Keys | Should -Contain "Start-ServerPrep"
  }

  It "Names the server after its config file" {
    $TemplateServer.Name | Should -Be $Name
  }

  It "Sets the <_> setting" -ForEach @("Path", "ConfigFolder", "Exec", "ProcessName", "Launcher", "WorkingDirectory") {
    $TemplateServer.$_ | Should -Not -BeNullOrEmpty
  }

  It "Sets AppID, AllowForceClose, UsePID and StartupWaitTime" {
    $TemplateServer.AppID | Should -BeOfType [int]
    $TemplateServer.AllowForceClose | Should -BeOfType [bool]
    $TemplateServer.UsePID | Should -BeOfType [bool]
    $TemplateServer.StartupWaitTime | Should -BeGreaterOrEqual 0
  }

  It "Keeps backups for a positive number of days and weeks" {
    $TemplateBackups.Path | Should -Not -BeNullOrEmpty
    $TemplateBackups.Saves | Should -Not -BeNullOrEmpty
    $TemplateBackups.Days | Should -BeGreaterThan 0
    $TemplateBackups.Weeks | Should -BeGreaterThan 0
  }

  It "Uses a known Warnings protocol and a positive SaveDelay" {
    $TemplateWarnings.Protocol | Should -BeIn $Protocols
    $TemplateWarnings.SaveDelay | Should -BeGreaterThan 0
  }

  It "Lists only known stop methods" {
    foreach ($Method in @($TemplateServer.StopMethods)) {
      if ($null -ne $Method) {
        $Method | Should -BeIn $StopMethods
      }
    }
  }

  It "Has a stop command when warnings are on and the Command stop method is used" {
    $Methods = @("Command", "CloseWindow")
    if ($TemplateServer.StopMethods) {
      $Methods = @($TemplateServer.StopMethods)
    }
    if ($TemplateWarnings.Use -and ($Methods -contains "Command")) {
      $TemplateWarnings.CmdStop | Should -Not -BeNullOrEmpty
      #The name of the setting, left in place of the game's command.
      $TemplateWarnings.CmdStop | Should -Not -Be "CmdStop"
    }
  }

  It "Maps the commands to API routes when it uses the RestAPI protocol" {
    if ($TemplateWarnings.Protocol -eq "RestAPI") {
      $TemplateWarnings.Api.BaseUrl | Should -Not -BeNullOrEmpty
      foreach ($Command in @($TemplateWarnings.CmdMessage, $TemplateWarnings.CmdSave, $TemplateWarnings.CmdStop)) {
        if ($Command) {
          $TemplateWarnings.Api.Routes.Keys | Should -Contain $Command
        }
      }
    }
  }

  It "Is read by Read-Config" {
    $global:Server = $TemplateServer
    $global:Backups = $TemplateBackups
    $global:Warnings = $TemplateWarnings
    { Read-Config } | Should -Not -Throw
    $global:Server.PipeName | Should -Be "PowerShellGSM_$Name"
    if ($global:Server.ArgumentList.Count -gt 0) {
      $global:Server.Arguments | Should -BeOfType [string]
    }
  }
}
