@echo off
chcp 65001 >nul
setlocal

:: ─── Run in script’s folder ────────────────────────────────────────────
cd /d "%~dp0"
echo =============== Running auto.bat ===============
echo Current folder: %cd%

:: ─── CONFIG ─────────────────────────────────────────────────────────────
set "SOURCE=%USERPROFILE%\AppData\Roaming\PrismLauncher\instances\Fume\minecraft\mods"
set "DEST=%~dp0mods"

:: ─── 1) Clean mods but keep .index ──────────────────────────────────────
echo.
echo [1/6] Cleaning mods folder (preserving .index)...
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

:: ─── 2) Copy new mods ───────────────────────────────────────────────────
echo.
echo [2/6] Copying mods from %SOURCE% to %DEST%...
xcopy "%SOURCE%\*" "%DEST%\" /E /I /Y

:: ─── 3) packwiz refresh ─────────────────────────────────────────────────
echo.
echo [3/6] Running packwiz refresh...
pushd "%~dp0"
packwiz refresh
popd

:: ─── 4) Stage & commit local changes ────────────────────────────────────
echo.
echo [4/6] Staging all changes…
git add -A

for /f %%i in ('powershell -nologo -command "Get-Date -Format yyyy-MM-dd_HH:mm:ss"') do set "ts=%%i"
git diff-index --quiet HEAD || (
  echo → Local changes detected; committing...
  git commit -m "Auto-update %ts%"
) 

:: ─── 5) Pull remote (rebase) ────────────────────────────────────────────
echo.
echo [5/6] Pulling latest from remote (rebase)...
git pull --rebase origin main

:: ─── 6) Push to remote ─────────────────────────────────────────────────
echo.
echo [6/6] Pushing to remote…
git push origin main || echo ❌ Push failed; see errors above.

:: ─── DONE & PAUSE ───────────────────────────────────────────────────────
echo.
echo ✅ All done! Press any key to exit…
pause >nul
endlocal
