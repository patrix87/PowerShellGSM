# PowerShellGSM

![PowerShellGSM Banner](https://github.com/patrix87/PowerShellGSM/blob/main/logo.png?raw=true)

A Comprehensive PowerShell Tool for Simple Automated Game Server Management.

[![GitHub release](https://img.shields.io/github/v/release/patrix87/PowerShellGSM?include_prereleases&sort=date&display_name=release&style=flat)](https://github.com/patrix87/PowerShellGSM/releases)
[![GitHub issues](https://img.shields.io/github/issues/patrix87/PowerShellGSM)](https://github.com/patrix87/PowerShellGSM/issues)

## Features

1. Hassle-free "setup and forget" experience
2. Automated installation of game servers
3. Streamlined single-file configuration
4. Automatic server updates upon new version releases
5. Monitoring for detecting server crashes and available updates
6. Built-in thread isolation and priority management
7. Automatic start after a system reboot
8. Daily server restarts with in-game broadcasts for supported games
9. Automated, lightweight backups with archiving for 7 days and 4 weeks
10. Full configurability, allowing customization according to your preferences
11. Open-Source with a great community supporting the tool.

## Supported Games

- 7 Days to Die
- Ark: Survival Ascended
- Astroneer
- Conan Exiles
- Enshrouded
- Icarus
- Insurgency Sandstorm
- Killing Floor 2
- Left 4 Dead 2
- Mordhau
- Minecraft (Paperclip)
- Necesse
- Palworld
- PixArk
- Project Zomboid
- Rust
- Satisfactory
- Squad
- Starbound
- Stationeers
- Terraria
- The Forest
- Valheim
- Valheim Plus
- V Rising

## Advantages

- Faster than the other available tools
- Lighter and more targeted backups
- Modular
- Expandable
- Customizable

## Installation

### Manual Installation

Before you begin, note that this tool is not intended to run on your primary
gaming computer. Ideally, use a virtual machine on a dedicated server or a
secondary computer.

1. Install [Git](https://git-scm.com/download/win) and your preferred IDE,
   such as [VSCode](https://code.visualstudio.com/download).
2. Ensure that your File Explorer is set to display file extensions.
3. Clone this repository using Git (F1 then Git:Clone in VSCode) or extract
   the zip file anywhere.
   _(Preferably C:\, but any directory will work unless the path is too long)_
4. Copy the desired server configuration file from the `templates` folder to
   the `configs` folder.
   - Example: Copy `icarus.psm1` from `templates` to `configs`.
5. Edit the copied configuration file to customize your server settings.
6. Copy and rename `launchers/run.cmd` to match your server configuration file.
   - Example: Rename `run.cmd` to `icarus.cmd` to start `icarus.psm1`.
   - _The filename in `launchers` must match the one in `configs`._
7. Launch your server by double-clicking on your `icarus.cmd` file from the
   `launchers` folder.
8. The PowerShell window will open, install PowerShellGSM's toolchain (see
   [Toolchain](#toolchain)) and the server, and **stop the server** to allow
   you to edit the server configuration files.
9. After editing your config files, run the `icarus.cmd` file from `launchers`
   again.
10. On the second launch, it will start the server and configure the
    **scheduled task** to keep the server running and updated.
11. To disable a server, use the Windows **Task Scheduler** application to
    disable or delete the corresponding Scheduled Task.
12. Forward the server ports in your router and configure the Windows firewall.
    _You can also disable the Windows firewall entirely, but ensure that you
    still forward the ports in your router._

## Global Settings

Tool-wide settings live in `defaults.psm1`. Do not edit it: it is part of
PowerShellGSM and is overwritten by updates. To change a setting, copy
`override.example.psm1` to `override.psm1` and keep only the settings you want
to change. `override.psm1` is not tracked by git, so updates never touch it.

Upgrading from a version with `global.psm1`: move your changes to
`override.psm1`. `global.psm1` is no longer used.

## Automatic PowerShellGSM Updates

When `AutoUpdateTool` is `$true` (the default), PowerShellGSM registers a
`PowerShellGSM-Update` scheduled task that runs `update.ps1` every
`ToolUpdateFrequency` hours (24 by default). It resets the installation to the
latest upstream version, overwriting any local change to PowerShellGSM's own
files. Your configs, launchers, servers, backups, logs and `override.psm1` are
not tracked by git and are kept. This requires an installation cloned with Git.
Set `AutoUpdateTool` to `$false` to remove the task on the next run.

## Scheduled Tasks

PowerShellGSM registers a `Tasks-<server>` scheduled task for each server that
uses AutoUpdates, AutoRestartOnCrash or AutoRestart, and the
`PowerShellGSM-Update` task. The tasks run in the background with no window.
Each run checks that the tasks still match the current settings and registers
them again when they do not, so a setting change needs no manual cleanup in
the Task Scheduler.

- `TaskRunWhileLoggedOff` (off by default): run the tasks whether the user is
  logged on or not (S4U logon, no password stored), so the servers start after
  a reboot without auto-logon. Servers then run in the background with no
  window, and the tasks cannot reach network shares. Some servers need a
  logged-on desktop and will not work this way.

## Console Windows

PowerShellGSM always starts the servers, its own windows and its scheduled
tasks through Windows Console Host (`conhost.exe`), whatever default terminal
is set in Windows. With Windows Terminal as the default terminal, a server
would otherwise run inside Windows Terminal: it has no window of its own to
close for a clean shutdown, and it stops whenever Windows Terminal crashes or
updates. Use the `.cmd` files in `launchers` to start a server; they open the
PowerShellGSM window in Windows Console Host as well.

## Stopping Servers

Each template lists, in `StopMethods`, the ways its server can be stopped
cleanly, in the order to try them. PowerShellGSM gives each one up to
`SaveDelay` seconds before trying the next:

- `Command`: send `CmdSave`, wait `SaveDelay`, then send `CmdStop` through the
  template's Warnings protocol (RCON, ARRCON, Telnet, StdIn or REST API). Only
  used when Warnings are enabled and the server answers remote commands.
- `CtrlC`: send Ctrl+C to the server's console.
- `CloseWindow`: close the server's window.

When none of them worked and `AllowForceClose` is `$true`, the server is
killed. A template without `StopMethods` uses `Command` then `CloseWindow`.
Games handle these differently: a game without a Ctrl+C or window close
handler exits at once without saving, so list only the methods that save for
that game.

## Unattended Installs

By default, the first launch of a new server installs it, starts it once so it
generates its files, then stops and waits so you can edit them. Set
`StopAfterFreshInstall` to `$false` for unattended installs (for example from a
provisioning tool): PowerShellGSM then restarts the server once after its first
install, so the configuration from the server's config file is applied to the
files the server just generated, and the server keeps running.

## Toolchain

PowerShellGSM installs and updates its own tools in the `tools` folder, so
every installation runs the same versions. Nothing is installed system wide.

- **PowerShell 7**: PowerShellGSM always runs on the PowerShell version pinned
  in `defaults.psm1` (`PwshVersion`), installed from the official portable zip
  to `tools\pwsh\<version>` and checked against its SHA256 (`PwshSha256`). The
  `.cmd` launchers start Windows PowerShell 5.1, which only installs PowerShell
  7 when missing and runs PowerShellGSM again on it. When a PowerShellGSM update
  moves the pin, the new version is installed on the next run and the old one
  is removed once nothing uses it.
- **SteamCMD**, **ARRCON** and **mcrcon**: installed when missing.
- **Windows Console Host** (`conhost.exe`, part of Windows): hosts every
  PowerShellGSM and server window (see [Console Windows](#console-windows)).

## Requirements

- A Windows machine with Windows PowerShell 5.1 (Windows 10 or Server 2016+),
  used once to install PowerShellGSM's own PowerShell 7
- Internet access to GitHub and Steam for the toolchain downloads
- Some basic PowerShell knowledge.
- Some networking basics to configure port forwarding.
- The Windows user running the script should have admin privileges but should
  **not** run it with admin privileges.

## Frequent Game Server Requirements

- [DirectX End-User Runtime](https://www.microsoft.com/en-ca/download/details.aspx?id=35)
- [Microsoft Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)
- [.NET Framework 4.8.1](https://dotnet.microsoft.com/en-us/download/dotnet-framework/thank-you/net481-web-installer)
- [.NET Framework 5, 6, 7, or 8](https://dotnet.microsoft.com/en-us/download/dotnet)
- [Java JDK](https://aws.amazon.com/corretto/)
- [Microsoft XNA Redistributable](https://www.microsoft.com/en-ca/download/details.aspx?id=20914)

## Optional Additional Packages

- [7Zip4PowerShell](https://www.powershellgallery.com/packages/7Zip4Powershell/)

```ps
Install-Module -Name 7Zip4Powershell
```

## Expanding the Code

You can create pull requests for changes to this project.

Please follow the current structure and formatting.

If you want to add support for more games, copy one of the configuration files
and edit the values and launch parameters. You can then create a pull request
to include your configuration here.

## Disclaimer

I am in no way responsible for anything that this script will do; you are
responsible for reading and understanding what this script will do before
executing it.

This script will download and install third-party software like SteamCMD,
ARRCON, mcrcon, Java, Microsoft XNA, Paperclip, Terraria, and any games you
try to install.
