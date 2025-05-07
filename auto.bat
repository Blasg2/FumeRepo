@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ─── CONFIG ─────────────────────────────────────────────────────────────
set "REPO_DIR=C:\Users\guilh\OneDrive\Área de Trabalho\Packwiz Modpack"
set "SOURCE=C:\Users\guilh\AppData\Roaming\PrismLauncher\instances\Fume\minecraft\mods"
set "DEST=%REPO_DIR%\mods"

:: ─── CLEAR OUT OLD MODS (but keep .index) ────────────────────────────────
echo Cleaning mods folder at "%DEST%", preserving .index...
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

:: ─── COPY NEW MODS ──────────────────────────────────────────────────────
echo.
echo Copying mods from:
echo   %SOURCE%
echo to:
echo   %DEST%
xcopy "%SOURCE%\*" "%DEST%\" /E /I /Y

:: ─── PACKWIZ REFRESH & GIT ──────────────────────────────────────────────
echo.
echo === Running packwiz refresh and Git operations in repo ===
pushd "%REPO_DIR%"

echo.
echo 1) packwiz refresh
packwiz refresh

:: timestamp
for /f %%i in ('powershell -nologo -command "Get-Date -Format ''yyyy-MM-dd HH:mm:ss''"') do set "datetime=%%i"

echo.
echo 2) git status (before)
git status

echo.
echo 3) git add all changes (including deletions)
git add -A

echo.
echo 4) git status (staged)
git status

echo.
echo 5) git commit
git commit -m "Auto update on %datetime%" 2>git_error.log

if %ERRORLEVEL% EQU 0 (
    echo Commit succeeded.
    echo 6) git push
    git push
) else (
    echo No changes to commit or commit failed. See git_error.log for details.
)

popd

:: ─── DONE ────────────────────────────────────────────────────────────────
echo.
echo ✅ All done!
endlocal
pause
cmd /k pause >nul
