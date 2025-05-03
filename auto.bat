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

:: Check if Git is available
git --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Git is not installed or not in PATH.
    goto end
)

:: Check if inside a Git repo
if not exist ".git" (
    echo ❌ This folder is not a Git repository.
    goto end
)

:: Check for changes
git status --porcelain > git-diff-check.tmp
for /f %%i in ('type git-diff-check.tmp ^| find /v /c ""') do set CHANGES=%%i
del git-diff-check.tmp

if "%CHANGES%"=="0" (
    echo No changes to commit or push.
) else (
    for /f %%i in ('powershell -nologo -command "Get-Date -Format ''yyyy-MM-dd HH:mm:ss''"') do set "datetime=%%i"
    echo Staging and committing changes...
    git add .
    git commit -m "Auto update on %datetime%"

    echo Pushing to GitHub...
    git push
)

:end
echo.
echo ✅ Script completed.

