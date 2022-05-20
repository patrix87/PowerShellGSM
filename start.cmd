setlocal
cd /d %~dp0
start powershell.exe -noprofile -executionpolicy bypass -file ".\main.ps1"