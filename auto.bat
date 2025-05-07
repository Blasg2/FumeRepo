@echo off
chcp 65001 >nul
setlocal

:: ─── Run from this script’s folder ─────────────────────────────────────
cd /d "%~dp0"

:: ─── Config: where Prism keeps its mods ─────────────────────────────────
set "SOURCE=%USERPROFILE%\AppData\Roaming\PrismLauncher\instances\Fume\minecraft\mods"
set "DEST=%~dp0mods"

:: ─── 1) Clean old mods but keep .index ──────────────────────────────────
echo Cleaning "%DEST%", preserving .index...
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

:: ─── 2) Copy new mods ─────────────────────────────────────────────────
echo.
echo Copying mods from:
echo   %SOURCE%
echo to:
echo   %DEST%
xcopy "%SOURCE%\*" "%DEST%\" /E /I /Y

:: ─── 3) Refresh packwiz indexes ────────────────────────────────────────
echo.
echo === Running packwiz refresh ===
pushd "%~dp0"
packwiz refresh
popd

:: ─── 4) Pull remote first (avoids fetch-first errors) ─────────────────
echo.
echo === Pulling any remote commits (rebase) ===
git pull --rebase origin main

:: ─── 5) Stage everything ───────────────────────────────────────────────
echo.
echo === Staging all changes ===
git add -A

:: ─── 6) Commit only if there are changes ──────────────────────────────
echo.
for /f %%i in ('powershell -nologo -command "Get-Date -Format yyyy-MM-dd_HH:mm:ss"') do set "ts=%%i"
git diff-index --quiet HEAD || (
  echo Changes detected; committing...
  git commit -m "Auto update on %ts%"
)

:: ─── 7) Push if commit was made ────────────────────────────────────────
echo.
git diff-index --quiet HEAD || (
  echo Pushing to remote...
  git push
) || (
  echo ❌ Push failed. Check the above errors.
)

:: ─── 8) Done (pause so window stays open) ──────────────────────────────
echo.
echo ✅ All done! Press any key to exit…
pause >nul

endlocal
