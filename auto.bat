@echo off
chcp 65001 >nul
rem ─── go to script’s own folder ──────────────────────────────────────
cd /d "%~dp0"

rem ─── config ─────────────────────────────────────────────────────────
set "SOURCE=%USERPROFILE%\AppData\Roaming\PrismLauncher\instances\Fume\minecraft\mods"
set "DEST=%~dp0mods"

rem ─── clean mods but keep .index ────────────────────────────────────
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

rem ─── copy new mods ─────────────────────────────────────────────────
echo Copying mods from:
echo   %SOURCE%
echo to:
echo   %DEST%
xcopy "%SOURCE%\*" "%DEST%\" /E /I /Y

rem ─── packwiz refresh ───────────────────────────────────────────────
echo.
echo === Running packwiz refresh ===
pushd "%~dp0"
packwiz refresh
popd

rem ─── git add/commit/push ────────────────────────────────────────────
echo.
echo === Staging all changes ===
git add -A

echo Checking for unstaged changes…
git diff --cached --quiet
if ERRORLEVEL 1 (
  echo Changes detected. Committing and pushing…
  for /f %%i in ('powershell -nologo -command "Get-Date -Format yyyy-MM-dd_HH:mm:ss"') do set "ts=%%i"
  git commit -m "Auto-update %ts%"
  git push
) else (
  echo No changes to commit.
)

rem ─── done ──────────────────────────────────────────────────────────
echo.
echo ✅ All done! Press any key to exit…
pause >nul
