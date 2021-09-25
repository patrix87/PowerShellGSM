:: This cmd file will start all servers in a sequence, waiting for each to complete startup.
:: It is not a loop for sake of customizability.
cd C:\PowerShellGSM
start "valheim" /wait powershell.exe -noprofile -executionpolicy bypass -file ".\main.ps1" -ServerCfg "valheim"
PING -n 10 127.0.0.1>nul
start "terraria" /wait powershell.exe -noprofile -executionpolicy bypass -file ".\main.ps1" -ServerCfg "terraria"
PING -n 10 127.0.0.1>nul
start "astroneer" /wait powershell.exe -noprofile -executionpolicy bypass -file ".\main.ps1" -ServerCfg "astroneer"
