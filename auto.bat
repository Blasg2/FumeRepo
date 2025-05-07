@echo off
chcp 65001 >nul
setlocal

:: ─── Run in script folder ───────────────────────────────────────────────
cd /d "%~dp0"
echo =============== Running auto.bat ===============
echo Current folder: %cd%

:: ─── Config ─────────────────────────────────────────────────────────────
set "SOURCE=%USERPROFILE%\AppData\Roaming\PrismLauncher\instances\Fume\minecraft\mods"
set "DEST=%~dp0mods"

:: ─── 1) Clean mods but keep .index ──────────────────────────────────────
echo.
echo [1/7] Cleaning mods folder (preserving .index)...
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
echo [2/7] Copying mods from:
echo     %SOURCE%
echo to:
echo     %DEST%
xcopy "%SOURCE%\*" "%DEST%\" /E /I /Y

:: ─── 3) Refresh packwiz ─────────────────────────────────────────────────
echo.
echo [3/7] Running packwiz refresh...
pushd "%~dp0"
packwiz refresh
popd

:: ─── 4) Show Git status *before* ────────────────────────────────────────
echo.
echo [4/7] Git status before pulling:
git branch --show-current
git status --short

:: ─── 5) Pull remote (rebase) ────────────────────────────────────────────
echo.
echo [5/7] Pulling latest from origin (rebase)...
git pull --rebase origin HEAD

:: ─── 6) Stage all changes ───────────────────────────────────────────────
echo.
echo [6/7] Staging all changes…
git add -A
echo [6/7] Git status *after* staging:
git status --short

:: ─── 7) Commit & push if needed ────────────────────────────────────────
echo.
echo [7/7] Committing & pushing…
for /f %%i in ('powershell -nologo -command "Get-Date -Format yyyy-MM-dd_HH:mm:ss"') do set "ts=%%i"
git diff-index --quiet HEAD || (
  echo → Changes detected, creating commit...
  git commit -m "Auto-update %ts%"
  echo → Pushing to remote…
  git push origin HEAD
) && (
  echo → No changes to commit; skipping push.
)

echo.
echo ✅ Done! Press any key to close…
pause >nul
endlocal
