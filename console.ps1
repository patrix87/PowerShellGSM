# Stand-in for the server's own console window, for servers using the StdIn protocol.
# Shows the server's output, sends what you type to the server's console, and stops the
# server if you close the window. Opened automatically when the server starts; run it
# again by hand to re-attach after detaching with Ctrl+C.

[CmdletBinding()]
param (
  #Leave empty to pick from the servers currently running.
  [Parameter(Mandatory = $false)]
  [string]$ServerCfg = "",
  #PID of the StdIn host, so this window can close itself when the server goes away.
  [Parameter(Mandatory = $false)]
  [int]$WatchPID = 0
)

#---------------------------------------------------------
# Set Script Directory as Working Directory
#---------------------------------------------------------

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path -Path $scriptpath
$dir = Resolve-Path -Path $dir
$null = Set-Location -Path $dir

#---------------------------------------------------------
# Importing functions and variables.
#---------------------------------------------------------

try {
  Import-Module -Name ".\defaults.psm1"
  Get-ChildItem -Path ".\functions" -Include "*.psm1" -Recurse | Import-Module
  Import-Override
}
catch {
  Write-Error "Unable to import modules."
  Read-Host "Press Enter to close this window."
  exit 1
}

#---------------------------------------------------------
# Pick a server when none was given.
#---------------------------------------------------------

if ([string]::IsNullOrWhiteSpace($ServerCfg)) {
  #@() keeps a single result an array, so .Count and indexing behave in Windows PowerShell.
  $Available = @(Get-AttachableServer)
  if ($Available.Count -eq 0) {
    Write-Warning "No running server to attach to."
    Write-Host "Only servers started by PowerShellGSM with the StdIn protocol have a console to attach to."
    Read-Host "Press Enter to close this window."
    exit 1
  }
  if (($Available.Count -eq 1) -and (-not $Available[0].Attached)) {
    $ServerCfg = $Available[0].Name
    Write-Host "Attaching to the only running server: $ServerCfg" -ForegroundColor $Global.SectionColor
  }
  else {
    Write-Host ""
    Write-Host "Servers you can attach to:" -ForegroundColor $Global.SectionColor
    for ($i = 0; $i -lt $Available.Count; $i++) {
      $Note = if ($Available[$i].Attached) { " (a console window is already attached)" } else { "" }
      Write-Host ("  [{0}] {1}{2}" -f ($i + 1), $Available[$i].Name, $Note)
    }
    Write-Host ""
    while ([string]::IsNullOrWhiteSpace($ServerCfg)) {
      $Choice = Read-Host "Select a server (1-$($Available.Count)), or Q to quit"
      if ($Choice -eq "Q") {
        exit
      }
      $Index = 0
      if ([int]::TryParse($Choice, [ref]$Index) -and ($Index -ge 1) -and ($Index -le $Available.Count)) {
        $ServerCfg = $Available[$Index - 1].Name
      }
      else {
        Write-Warning "Pick a number between 1 and $($Available.Count), or Q to quit."
      }
    }
  }
}

#---------------------------------------------------------
# Importing server configuration.
#---------------------------------------------------------

if (-not (Test-Path -Path ".\configs\$ServerCfg.psm1" -PathType "Leaf" -ErrorAction SilentlyContinue)) {
  Write-Error "No configuration found for '$ServerCfg'. Start the server at least once first."
  Read-Host "Press Enter to close this window."
  exit 1
}
try {
  Import-Module -Name ".\configs\$ServerCfg.psm1"
}
catch {
  Write-Error "Unable to import server configuration."
  Read-Host "Press Enter to close this window."
  exit 1
}
Read-Config

if (-not ($Warnings.Use -and $Warnings.Protocol -eq "StdIn")) {
  Write-Error "'$ServerCfg' is not configured to use the StdIn protocol, there is no console to attach to."
  Read-Host "Press Enter to close this window."
  exit 1
}

$LogFile = ".\servers\$($Server.Name).console.log"
$ConsolePidFile = ".\servers\$($Server.Name).console.pid"
$HostPidFile = ".\servers\$($Server.Name).stdinhost.pid"

#Two console windows sharing one attachment file would confuse each other and the host.
$AttachedPID = Get-LivePID -Path $ConsolePidFile
if (($AttachedPID -gt 0) -and ($AttachedPID -ne $PID)) {
  Write-Error "A console window is already attached to '$ServerCfg' (PID $AttachedPID). Close or detach it first."
  Read-Host "Press Enter to close this window."
  exit 1
}

#Started by hand rather than by Start-StdInHost, so find the running server ourselves.
if ($WatchPID -le 0) {
  $WatchPID = Get-LivePID -Path $HostPidFile
  if ($WatchPID -le 0) {
    Write-Error "'$ServerCfg' is not running, there is no console to attach to."
    Read-Host "Press Enter to close this window."
    exit 1
  }
}

#---------------------------------------------------------
# Attach to the server console.
#---------------------------------------------------------

$Host.UI.RawUI.WindowTitle = "$ServerCfg - Server Console"

Write-Host "--------------------------------------------------------------" -ForegroundColor $Global.SectionColor
Write-Host " $ServerCfg server console" -ForegroundColor $Global.SectionColor
Write-Host " Type a command and press Enter to send it to the server." -ForegroundColor $Global.SectionColor
Write-Host " Closing this window stops the server ($($Warnings.CmdStop))." -ForegroundColor $Global.SectionColor
Write-Host " Press Ctrl+C to detach and leave the server running." -ForegroundColor $Global.SectionColor
Write-Host "--------------------------------------------------------------" -ForegroundColor $Global.SectionColor

#Claiming attachment: while this file holds a live PID the host keeps the server tied to
#this window, and stops the server if the window disappears without removing the file.
Set-Content -Path $ConsolePidFile -Value $PID -Encoding UTF8

#Wait for the host to create the log, so a freshly started server doesn't race us.
$Waited = 0
while ((-not (Test-Path -Path $LogFile -PathType "Leaf" -ErrorAction SilentlyContinue)) -and ($Waited -lt 30)) {
  Start-Sleep -Seconds 1
  $Waited++
}
if (-not (Test-Path -Path $LogFile -PathType "Leaf" -ErrorAction SilentlyContinue)) {
  Write-Error "No server output found at $LogFile."
  Remove-Item -Path $ConsolePidFile -Force -ErrorAction SilentlyContinue
  Read-Host "Press Enter to close this window."
  exit 1
}

#Opened with FileShare.ReadWrite so this keeps working while the host appends to it.
$LogStream = [System.IO.FileStream]::new(
  (Resolve-Path -Path $LogFile).Path,
  [System.IO.FileMode]::Open,
  [System.IO.FileAccess]::Read,
  ([System.IO.FileShare]::ReadWrite -bor [System.IO.FileShare]::Delete))
#Show a little recent context on attach without replaying a huge log.
$Skipped = $false
if ($LogStream.Length -gt 65536) {
  $null = $LogStream.Seek(-65536, [System.IO.SeekOrigin]::End)
  $Skipped = $true
}
$LogReader = [System.IO.StreamReader]::new($LogStream)
if ($Skipped) {
  $null = $LogReader.ReadLine() #discard the partial line we landed in the middle of
}

#Handle Ctrl+C as a keystroke instead of a signal, so detaching can clean up after itself.
[Console]::TreatControlCAsInput = $true

$InputBuffer = ""
$Ticks = 0
$Detaching = $false

try {
  while ($true) {

    #-----------------------------------------------------
    # Server output
    #-----------------------------------------------------
    $NewLines = @()
    while ($null -ne ($Line = $LogReader.ReadLine())) {
      $NewLines += $Line
    }
    if ($NewLines.Count -gt 0) {
      #Lift whatever is half-typed out of the way, print the output, then put it back.
      if ($InputBuffer.Length -gt 0) {
        Write-Host -NoNewline ("`r" + (" " * $InputBuffer.Length) + "`r")
      }
      foreach ($Line in $NewLines) {
        Write-Host $Line
      }
      if ($InputBuffer.Length -gt 0) {
        Write-Host -NoNewline $InputBuffer
      }
    }

    #-----------------------------------------------------
    # Typed commands
    #-----------------------------------------------------
    while ([Console]::KeyAvailable) {
      $Key = [Console]::ReadKey($true)
      if ((($Key.Modifiers -band [ConsoleModifiers]::Control) -ne 0) -and ($Key.Key -eq [ConsoleKey]::C)) {
        $Detaching = $true
        break
      }
      elseif ($Key.Key -eq [ConsoleKey]::Enter) {
        Write-Host ""
        if (-not [string]::IsNullOrWhiteSpace($InputBuffer)) {
          if (-not (Send-StdIn -Command $InputBuffer -PipeName $Server.PipeName)) {
            Write-Warning "Failed to deliver command - the server may have stopped."
          }
        }
        $InputBuffer = ""
      }
      elseif ($Key.Key -eq [ConsoleKey]::Backspace) {
        if ($InputBuffer.Length -gt 0) {
          $InputBuffer = $InputBuffer.Substring(0, $InputBuffer.Length - 1)
          Write-Host -NoNewline "`b `b"
        }
      }
      elseif (-not [char]::IsControl($Key.KeyChar)) {
        $InputBuffer += $Key.KeyChar
        Write-Host -NoNewline $Key.KeyChar
      }
    }
    if ($Detaching) {
      break
    }

    #-----------------------------------------------------
    # Close this window once the server is gone
    #-----------------------------------------------------
    $Ticks++
    if (($WatchPID -gt 0) -and (($Ticks % 20) -eq 0)) {
      if (-not (Get-Process -Id $WatchPID -ErrorAction SilentlyContinue)) {
        Start-Sleep -Seconds 1
        while ($null -ne ($Line = $LogReader.ReadLine())) {
          Write-Host $Line
        }
        Write-Host ""
        Write-Host "[console] Server has stopped. Closing in 5 seconds..." -ForegroundColor $Global.SectionColor
        Start-Sleep -Seconds 5
        break
      }
    }

    Start-Sleep -Milliseconds 100
  }
}
finally {
  [Console]::TreatControlCAsInput = $false
  $LogReader.Dispose()
  #Removing the file first tells the host this was a deliberate detach, not a closed window.
  Remove-Item -Path $ConsolePidFile -Force -ErrorAction SilentlyContinue
  if ($Detaching) {
    Write-Host ""
    Write-Host "[console] Detached. The server is still running." -ForegroundColor $Global.SectionColor
    Write-Host "[console] Re-attach with: .\console.ps1 -ServerCfg $ServerCfg" -ForegroundColor $Global.SectionColor
    Start-Sleep -Seconds 5
  }
}
