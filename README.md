<p align="center">
  <img
       src="https://github.com/patrix87/PowerShellGSM/blob/main/logo.png?raw=true"
       alt="PowerShellGSM Banner"
  />
</p>  
<p align="center">
  A modular PowerShell tool to manage game servers.<br/>
</p>
<p align="center">
  <a href="https://github.com/patrix87/PowerShellGSM/releases"><img alt="GitHub release (latest by date including pre-release)" src="https://img.shields.io/github/v/release/patrix87/PowerShellGSM?include_prereleases&sort=date&display_name=release&style=flat"></a>
  </nobr>
  <a href="https://github.com/patrix87/PowerShellGSM/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues/patrix87/PowerShellGSM"></a>
</p>

## Features:

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

Once started it registers a schedule task to check on your server status.

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

## Manual

1. Git clone (or extract the zip of) this repository in any directory. _(Ideally C:\ but it will work anywhere unless the path is too long)_
2. Copy your server configuration file you want from the `templates` folder to `configs` folder

   EG: copy `icarus.psm1` from the `templates` folder to the `configs` folder.
3. Then edit this configuration file with Notepad++ or VSCode or whatever you like.
4. Then Copy and rename `launchers/run.cmd` to select your server configuration file.

   EG: copy and rename `run.cmd` to `icarus.cmd` to start the `icarus.psm1` Icarus server.

   _The `launchers` filename from the must match the `configs` filename._
5. Launch your server by double clikcing on your `icarus.cmd` file from the `launchers` folder.
6. The powershell window will open, install the server then **stop the server** to let you edit server files.
7. Once you have edited your config files, run the `icarus.cmd` file from the `launchers` folder once again.
8. On the second launch it will start the server and configure the **scheduled task** to keep the server running and updated.
9. To disable a server, disable the Scheduled Task from the Windows **Task Scheduler**.

## Automated Installation Script

By [@BananaAcid](https://github.com/BananaAcid/)

https://gist.github.com/BananaAcid/1dc9117571967b26ceabc972009137ae

# Requirements

A windows machine with at least PowerShell 5.1 installed (Windows 10 or Windows Server 2016 or newer)

Some basic PowerShell knowledge.

Some networking basics to configure port forwarding.

The user running the script should have admin privileges but should **not** run it with admin privileges.
They are only required for installing third parties like Java and Microsoft XNA.

# Expanding the code

You can create pull requests for changes to this project.

Please follow the current structure and formating.

If you want to add support for more games, copy one of the configuration files and edit the values and launch parameters.
You can then create a pull request to include your configuration here.

# Disclaimer

I'm am in no way responsible for anything that this script will do, you are responsible for reading and understanding what this script will do before executing it.

This script will download and install third party softwares like 7Zip, SteamCMD, mcrcon, Java, Microsoft XNA, Paperclip, Terraria and any games you try to install.
