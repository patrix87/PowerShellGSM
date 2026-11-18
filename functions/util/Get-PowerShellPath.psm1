function Get-PowerShellPath {
  [CmdletBinding()]
  [OutputType([string])]
  param (
  )
  <#
    Full path of the pinned PowerShell 7 (PwshVersion) that runs PowerShellGSM. Every PowerShell
    process PowerShellGSM starts uses it. Installed first when missing, under a lock so that the
    tasks of several servers starting at the same minute do not install it at the same time.
  #>
  $Directory = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine((Get-Location).Path, $Global.PwshDirectory, $Global.PwshVersion))
  $Pwsh = Join-Path -Path $Directory -ChildPath "pwsh.exe"
  if (Test-Path -Path $Pwsh -PathType "Leaf") {
    return $Pwsh
  }
  $Mutex = New-Object System.Threading.Mutex($false, "Global\PowerShellGSM-Pwsh")
  try {
    try {
      $null = $Mutex.WaitOne()
    }
    catch [System.Threading.AbandonedMutexException] {
      #The previous holder exited without releasing it, the lock is ours now.
    }
    if (-not (Test-Path -Path $Pwsh -PathType "Leaf")) {
      Install-Pwsh -Destination $Directory
    }
  }
  finally {
    $Mutex.ReleaseMutex()
    $Mutex.Dispose()
  }
  return $Pwsh
}
Export-ModuleMember -Function Get-PowerShellPath
