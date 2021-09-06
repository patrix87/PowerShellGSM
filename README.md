# Powershell SteamCMD Server Manager

Powershell script to automatically manage most SteamCMD servers

This powershell script will install, backup, update and reboot your server when executed.

You can create a Scheduled Task to execute the run.cmd file daily to backup, update and reboot your server.

# Installation

- Extract the release code in any directory.
- Copy your server configuration file from /templates to /configs
- Copy and edit launchers/run.cmd to select your server configuration file.
- Edit your server configuration file in the configs folder.
- Exectute your version of run.cmd

# Expanding the code

You can create Pull Requests for changes to this project.

Please follow the current structure and formating.

If you want to add support for more games, copy one of the configuration files in /configs and edit the values and launch parameters.

# Requirements

A windows machine with at least Powershell 5.1 installed (Windows 10 or Windows Server 2016 or newer)

Some basic powershell knowledge.

Some networking basics to configure port forwarding.

# Disclaimer

I'm am in no way responsible for anything that this script will do, you are responsible for reading and understanding what this script will do before executing it.

7zip, mcrcon and SteamCMD are not developed or supported by me.

7zip : https://www.7-zip.org/

mcrcon : https://github.com/Tiiffi/mcrcon

SteamCMD : https://developer.valvesoftware.com/wiki/SteamCMD
