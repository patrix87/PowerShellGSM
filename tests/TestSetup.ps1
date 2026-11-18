<#
  Dot-sourced in the BeforeAll of every test file: imports PowerShellGSM's settings and functions
  globally, as main.ps1 does, so the functions find $Global, $Server, $Backups and $Warnings.
#>
$RepoRoot = Split-Path -Path $PSScriptRoot
Import-Module -Name ([System.IO.Path]::Combine($RepoRoot, "defaults.psm1")) -Global -Force
Get-ChildItem -Path ([System.IO.Path]::Combine($RepoRoot, "functions")) -Include "*.psm1" -Recurse | Import-Module -Global -Force
$OnWindows = ($PSVersionTable.PSEdition -eq "Desktop") -or $IsWindows

#Stand-ins for Windows-only commands, so they can be mocked on any OS.
foreach ($Command in "Get-ScheduledTask") {
  if (-not (Get-Command -Name $Command -ErrorAction SilentlyContinue)) {
    $null = New-Item -Path "Function:\global:$Command" -Value { param($TaskName, $ErrorAction) }
  }
}
