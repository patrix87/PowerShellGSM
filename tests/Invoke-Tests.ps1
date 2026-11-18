<#
  Run PowerShellGSM's Pester tests in the PowerShell running this script.

  Pester is pinned below and installed to tools\Pester\<version> from its PowerShell Gallery package,
  checked against its SHA256, so every run (local or CI) uses the same version.

  Run them on both PowerShell versions PowerShellGSM uses:
    Windows PowerShell 5.1 : powershell -File .\tests\Invoke-Tests.ps1
    Pinned PowerShell 7    : .\tools\pwsh\<PwshVersion>\pwsh -File .\tests\Invoke-Tests.ps1
  Tests tagged "Windows" are skipped elsewhere.

  Exits with the number of failed tests.
#>
[CmdletBinding()]
param (
  #Write an NUnit XML report to this path.
  [string]$ResultPath = ""
)

$ErrorActionPreference = "Stop"
$PesterVersion = "6.2.0"
$PesterSha256 = "E6AC7418D4F12500269AACA58AE56CF1CAAFBBF1AFA2CEC334E289D1CF50A239"

$Root = Split-Path -Path $PSScriptRoot
$PesterRoot = [System.IO.Path]::Combine($Root, "tools", "Pester")
$PesterDirectory = [System.IO.Path]::Combine($PesterRoot, $PesterVersion)
$PesterManifest = [System.IO.Path]::Combine($PesterDirectory, "Pester.psd1")

if (-not (Test-Path -Path $PesterManifest -PathType "Leaf")) {
  Write-Host "Installing Pester $PesterVersion..."
  $null = New-Item -Path $PesterRoot -ItemType "directory" -Force
  #Expand-Archive in Windows PowerShell only accepts the .zip extension.
  $Package = [System.IO.Path]::Combine($PesterRoot, "Pester.$PesterVersion.zip")
  $ProgressPreference = "SilentlyContinue"
  Invoke-WebRequest -Uri "https://www.powershellgallery.com/api/v2/package/Pester/$PesterVersion" -OutFile $Package -UseBasicParsing
  $Hash = (Get-FileHash -Path $Package -Algorithm "SHA256").Hash
  if ($Hash -ne $PesterSha256) {
    Remove-Item -Path $Package -Force
    throw "The Pester $PesterVersion package does not match its SHA256 (got $Hash)."
  }
  $Staging = "$PesterDirectory.partial"
  Remove-Item -Path $Staging -Recurse -Force -ErrorAction SilentlyContinue
  Expand-Archive -Path $Package -DestinationPath $Staging -Force
  Move-Item -Path $Staging -Destination $PesterDirectory
  Remove-Item -Path $Package -Force
}

#Windows PowerShell ships an old Pester, so import the pinned one by path.
Get-Module -Name "Pester" | Remove-Module -Force
Import-Module -Name $PesterManifest -Force

$OnWindows = ($PSVersionTable.PSEdition -eq "Desktop") -or $IsWindows
Write-Host "Running the tests on PowerShell $($PSVersionTable.PSVersion) ($($PSVersionTable.PSEdition)) with Pester $PesterVersion."

$Config = New-PesterConfiguration
$Config.Run.Path = $PSScriptRoot
$Config.Run.PassThru = $true
$Config.Output.Verbosity = "Detailed"
if (-not $OnWindows) {
  $Config.Filter.ExcludeTag = @("Windows")
}
if ($ResultPath) {
  $Config.TestResult.Enabled = $true
  $Config.TestResult.OutputFormat = "NUnitXml"
  $Config.TestResult.OutputPath = $ResultPath
}
$Result = Invoke-Pester -Configuration $Config
exit $Result.FailedCount
