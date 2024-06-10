<p align="center">
  <img src="https://github.com/patrix87/PowerShellGSM/blob/main/logo.png?raw=true" alt="PowerShellGSM Banner"/>
</p>  
<p align="center">
A Comprehensive PowerShell Tool for Simple Automated Game Server Management.<br/>
</p>
<p align="center">
  <nobr>
    <a href="https://github.com/patrix87/PowerShellGSM/releases"><img alt="GitHub release (latest by date including pre-release)" src="https://img.shields.io/github/v/release/patrix87/PowerShellGSM?include_prereleases&sort=date&display_name=release&style=flat"></a>
  </nobr>
  <nobr>
    <a href="https://github.com/patrix87/PowerShellGSM/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues/patrix87/PowerShellGSM"></a>
  </nobr>
</p>

# Features

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

# Supported Games

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

# Advantages

- Faster than the other available tools
- Lighter and more targeted backups
- Modular
- Expandable
- Customizable

# Installation

## Manual Installation (Recommended)

Before you begin, note that this tool is not intended to run on your primary gaming computer. Ideally, use a virtual machine on a dedicated server or a secondary computer. If you still want to use this tool on your main computer, you should consider disabling the monitoring features. Otherwise, the Task Scheduler will briefly open a cmd window for a tenth of a second every 5 minutes. You can disable this by turning off the monitoring features (AutoUpdates, AutoRestartOnCrash, AutoRestart) in the game server configuration file or by disabling the game server monitoring task created in the Windows Task Scheduler after the second launch of the server.

01. Install [Git](https://git-scm.com/download/win) and your preferred IDE, such as [VSCode](https://code.visualstudio.com/download).
02. Ensure that your File Explorer is set to display file extensions.
03. Clone this repository using Git (F1 then Git:Clone in VSCode) or extract the zip file anywhere.
    _(Preferably C:\, but any directory will work unless the path is excessively long)_
04. Copy the desired server configuration file from the `templates` folder to the `configs` folder.

    Example: Copy `icarus.psm1` from the `templates` folder to the `configs` folder.
05. Edit the copied configuration file to customize your server settings.
06. Copy and rename `launchers/run.cmd` to match your server configuration file.

    Example: Copy and rename `run.cmd` to `icarus.cmd` to start the `icarus.psm1` Icarus server.

    _The filename in the `launchers` folder must match the one in the `configs` folder._
07. Launch your server by double-clicking on your `icarus.cmd` file from the `launchers` folder.
08. The PowerShell window will open, install the server, and **stop the server** to allow you to edit the server configuration files.
09. After editing your config files, run the `icarus.cmd` file from the `launchers` folder again.
10. On the second launch, it will start the server and configure the **scheduled task** to keep the server running and updated.
11. To disable a server, use the Windows **Task Scheduler** application to disable or delete the corresponding Scheduled Task.
12. Forward the server ports in your router and configure the Windows firewall accordingly.
    _You can also disable the Windows firewall entirely, but ensure that you still forward the ports in your router._

## Automated Installation Script

By [@BananaAcid](https://github.com/BananaAcid/)

[https://gist.github.com/BananaAcid/1dc9117571967b26ceabc972009137ae](https://gist.github.com/BananaAcid/1dc9117571967b26ceabc972009137ae)

# Requirements

- A Windows machine with at least PowerShell 5.1 installed (Windows 10 or Windows Server 2016 or newer)
- Some basic PowerShell knowledge.
- Some networking basics to configure port forwarding.
- The Windows user running the script should have admin privileges but should **not** run it with admin privileges.

# Frequent Game Server Requirements

- [DirectX End-User Runtime](https://www.microsoft.com/en-ca/download/details.aspx?id=35)
- [Microsoft Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)
- [.NET Framework 4.8.1](https://dotnet.microsoft.com/en-us/download/dotnet-framework/thank-you/net481-web-installer)
- [.NET Framework 5, 6, 7, or 8](https://dotnet.microsoft.com/en-us/download/dotnet)
- [Java JDK](https://aws.amazon.com/corretto/?filtered-posts.sort-by=item.additionalFields.createdDate&filtered-posts.sort-order=desc)
- [Microsoft XNA Redistributable](https://www.microsoft.com/en-ca/download/details.aspx?id=20914)

# Optional Additional Packages

- [7Zip4PowerShell](https://www.powershellgallery.com/packages/7Zip4Powershell/)

```ps
Install-Module -Name 7Zip4Powershell
```

# Expanding the Code

You can create pull requests for changes to this project.

Please follow the current structure and formatting.

If you want to add support for more games, copy one of the configuration files and edit the values and launch parameters. You can then create a pull request to include your configuration here.

# Disclaimer

I am in no way responsible for anything that this script will do; you are responsible for reading and understanding what this script will do before executing it.

This script will download and install third-party software like SteamCMD, ARRCON, mcrcon, Java, Microsoft XNA, Paperclip, Terraria, and any games you try to install.
