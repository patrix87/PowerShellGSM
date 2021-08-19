# Project Zomboid Server Manager

Powershell script to automatically manage a Project Zomboid Server.

This powershell script will install, backup, update and reboot your Project Zomboid server when executed.

To install simply extract the content of the zip file to any folder and edit the variables section of ProjectZomboid.ps1 in order to configure your Server.

You can create a Scheduled Task to run the ProjectZomboid.cmd file daily to backup, update and reboot your Project Zomboid server.

To run the script run the ProjectZomboid.cmd

To configure your server settings you need to edit the files in "C:\Users\\%username%\Zomboid\Server\"

Options to look for when setting your server in servertest.ini (Suggested values)
```
DefaultPort=16261
MaxPlayers=64
Open=true
PVP=true
Password=My server password
PauseEmpty=true
PingFrequency=10
PingLimit=200
Public=true
PublicDescription=My server Description
PublicName=My server name
RCONPassword=RCONPassword from ProjectZomboid.ps1 without "
RCONPort=27015
SteamPort1=8766
SteamPort2=8767
```

You need to port forward the following Ports on your router, both in TCP and UDP

```
DefaultPort=16261
SteamPort1=8766
SteamPort2=8767
```
You do not need to forward RCON.

# Disclaimer : 

I'm am in no way responsible for anything that this script will do, you are responsible for reading and understanding what this script will do before executing it.

7zip, mcrcon and SteamCMD are not developed or supported by me.

7zip : https://www.7-zip.org/

mcrcon : https://github.com/Tiiffi/mcrcon

SteamCMD : https://developer.valvesoftware.com/wiki/SteamCMD