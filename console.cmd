:: Attach a console to a running server. Double click to pick from the servers currently
:: running, or pass a name directly: console.cmd necesse
@echo off
cd /d "%~dp0"
start "" conhost.exe powershell.exe -noprofile -executionpolicy bypass -file ".\console.ps1" %*
