@echo off
rem --- Launch the PS1 with a bypass so you can double-click ---
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0parse_mods_both.ps1"
pause