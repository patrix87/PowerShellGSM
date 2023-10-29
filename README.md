# PowerShellGSM - PowerShell Game Server Manager

A Modular PowerShell tool to manage game servers.

This PowerShell script will take care of:

- Installation
- Backups
- Updates
- Monitoring
- Restarts

Once started it registers a schedule task to check on your server status.

# Supported Games

- 7 Days to Die
- Ark: Survival Ascended
- Astroneer
- Icarus
- Insurgency Sandstorm
- Killing Floor 2
- Left 4 Dead 2
- Mordhau
- Minecraft (Paperclip)
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
