# Shared Variables for Scripts
Copy the shared file to the **config/shared** folder

## Ark Survival Ascended

```json
ark_shared.json - Duplicate this file if hosting multiple clusters.
{
  // Login username used by SteamCMD
  "Login": "anonymous",

  // Maximum number of players allowed on the server
  "MaxPlayers": 64,

  // Password to join the server *NO SPACES or Question Mark*
  "Password": "CHANGEME",

  // Enable BattlEye protection ("True" or "False")
  "BattlEye": "True",

  // Savegame folder - Leave blank for default
  "SaveFolder": "",

  // Comma-separated list of mod/project IDs - Leave blank for no mods
  "Mods": "",

  // IF isCluster is true, CusterId and CusterDirOverride are required
  "IsCluster": false,

  // Cluster ID for cross-server transfers
  "ClusterId": "",

  // Cluster directory override for cross-server transfers, uses \\ to separate folders Ex "C:\\Cluster\\Dir"
  "ClusterDirOverride": "",

  // Platforms allowed to play on the server (PC, PS5, XSX, WINGDK, ALL)
  "ServerPlatform": "ALL",

  // Enforce exclusive join (whitelist required)
  "EnableExclusiveJoin": false,

  // Exclusive join list (comma-separated EOSIDs)
  "ExclusiveJoinList": "",

  // Extra parameters - Leave blank for default
  "ExtraParams": "-NoTransferFromFiltering -ServerGameLogIncludeTribeLogs -ServerGameLog -AutoManagedMods",

  // Rcon IP, usually localhost
  "ManagementIP": "127.0.0.1",

  // Rcon / Admin password *NO SPACES or Question Mark*
  "ManagementPassword": "CHANGEME2",

  // Enable PVE mode ("True" or "False")
  "ServerPVE": "True",

  // Enable or disable UserStore - Saves Survivor and Tribe data as part of the world save
  "EnableUsesStore": false,

  // Enable Rcon "True" or "False"
  "EnableRcon": "True"
}
```