@echo off
chcp 65001 >nul

:: Set source mods folder
set "SOURCE=C:\Users\guilh\AppData\Roaming\PrismLauncher\instances\Fume\minecraft\mods"

:: Get correct OneDrive Desktop path for destination
for /f "delims=" %%D in ('powershell -nologo -command "[Environment]::GetFolderPath('Desktop')"') do set "DESKTOP=%%D"

:: Set destination mods folder
set "DEST=%DESKTOP%\Packwiz Modpack\mods"

echo Deleting all contents from: %DEST%
rd /s /q "%DEST%"
mkdir "%DEST%"

echo Copying all files from %SOURCE% to %DEST%
xcopy "%SOURCE%\*" "%DEST%\" /E /I /H /Y

echo Running packwiz refresh...
packwiz refresh

:: Get current datetime for commit message
for /f %%i in ('powershell -nologo -command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"') do set "datetime=%%i"

echo Staging changes with git...
git add .

echo Creating git commit...
git commit -m "Auto update on %datetime%"

echo.
echo ✅ All done!
pause
