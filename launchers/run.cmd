cd ..
start "" conhost.exe powershell.exe -noprofile -executionpolicy bypass -file ".\main.ps1" -ServerCfg "%~n0"
