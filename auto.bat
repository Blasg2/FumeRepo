@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ─── SCRIPT ROOT ───────────────────────────────────────────────────────
rem Ensure we’re running in the folder where this script lives
cd /d "%~dp0"

:: ─── CONFIG ─────────────────────────────────────────────────────────────
set "SOURCE=%USERPROFILE%\AppData\Roaming\PrismLauncher\instances\Fume\minecraft\mods"
set "DEST=%~dp0mods"

:: ─── CLEAN OLD MODS (preserve .index) ───────────────────────────────────
echo Cleaning "%DEST%", preserving .index…
if exist "%DEST%" (
  for /d %%D in ("%DEST%\*") do (
    if /I not "%%~nxD"==".index" rd /s /q "%%D"
  )
  for %%F in ("%DEST%\*") do (
    if /I not "%%~nxF"==".index" del /q "%%F"
  )
) else (
  mkdir "%DEST%"
)

:: ─── COPY NEW MODS ─────────────────────────────────────────────────────
echo.
echo Copying mods from:
echo   %SOURCE%
echo to:
echo   %DEST%
xcopy "%SOURCE%\*" "%DEST%\" /E /I /Y

:: ─── PACKWIZ REFRESH ───────────────────────────────────────────────────
echo.
echo === Running packwiz refresh ===
pushd "%~dp0"
packwiz refresh
popd

:: ─── GIT OPERATIONS ─────────────────────────────────────────────────────
echo.
echo === Staging all changes ===
git add -A

echo.
echo === Pulling latest from remote (rebase) ===
git pull --rebase origin main

echo.
echo === Committing & pushing if there are new changes ===
for /f %%i in ('powershell -nologo -command "Get-Date -Format yyyy-MM-dd_HH:mm:ss"') do set "ts=%%i"
git commit -m "Auto-update %ts%" 2>nul

if NOT ERRORLEVEL 1 (
  echo Pushing to remote...
  git push
) else (
  echo No local changes to commit; skipping push.
)

:: ─── DONE & PAUSE ──────────────────────────────────────────────────────
echo.
echo ✅ All done! Press any key to exit…
pause >nul
endlocal
