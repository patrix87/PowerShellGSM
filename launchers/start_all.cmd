:: This cmd file will start all servers in a sequence, waiting for each to complete startup.
:: It is not a loop for sake of customizability.
cd ..
start "valheim" /wait powershell.exe -noprofile -executionpolicy bypass -file ".\main.ps1" -ServerCfg "valheim"
SLEEP 10
start "terraria" /wait powershell.exe -noprofile -executionpolicy bypass -file ".\main.ps1" -ServerCfg "terraria"
SLEEP 10
start "astroneer" /wait powershell.exe -noprofile -executionpolicy bypass -file ".\main.ps1" -ServerCfg "astroneer"
