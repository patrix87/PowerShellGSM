# PowerShellGSM - PowerShell Game Server Manager
A Modular PowerShell tool to manage game servers.

This PowerShell script will Install, Backup, Update and Start your server when executed.

You can create a Scheduled Task to execute run.cmd daily to execute your server maintenance.

# Supported Games

- 7 Days to Die
- Astroneer
- Insurgency Sandstorm
- Killing Floor 2
- Left 4 Dead 2
- Mordhau
- Minecraft (Paperclip)
- PixArk
- Project Zomboid
- Rust
- Squad
- Starbound
- Stationeers
- Terraria
- The Forest
- Valheim

# Advantages

- Faster than the other available tools
- Lighter and more targeted backups
- Lighter shared game servers installation
- Modular
- Expandable
- Customizable

# Installation

1. Git clone (or extract the zip) this repository in any directory. *(Ideally C:\ but it will work anywhere)*
2. Copy your server configuration file from /templates to /configs
3. Copy and edit launchers/run.cmd to select your server configuration file.
4. Edit your server configuration file in the configs folder.
5. Exectute your version of run.cmd
6. Optional: create a scheduled task to run your version of run.cmd

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
You can then create a Pull Requests to include your configuration here.

# Disclaimer

I'm am in no way responsible for anything that this script will do, you are responsible for reading and understanding what this script will do before executing it.

This script will download and install third party softwares like 7Zip, SteamCMD, mcrcon, Java, Microsoft XNA, Paperclip, Terraria and any games you try to install.
