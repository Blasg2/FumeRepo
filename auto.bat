@echo off
chcp 65001 >nul

:: ─── CONFIG ─────────────────────────────────────────────────────────────

:: Path to your local Packwiz Modpack repo
set "REPO_DIR=C:\Users\guilh\OneDrive\Área de Trabalho\Packwiz Modpack"

:: Source mods folder (PrismLauncher → Fume instance)
set "SOURCE=C:\Users\guilh\AppData\Roaming\PrismLauncher\instances\Fume\minecraft\mods"

:: Destination mods folder inside your repo
set "DEST=%REPO_DIR%\mods"

:: ─── CLEAR OUT OLD MODS ──────────────────────────────────────────────────

echo Cleaning mods folder at "%DEST%", preserving .index...
if exist "%DEST%" (
    rem Delete all subdirectories except ".index"
    for /d %%D in ("%DEST%\*") do (
        if /I not "%%~nxD"==".index" rd /s /q "%%D"
    )
    rem Delete all files in the root of mods\
    for %%F in ("%DEST%\*") do (
        if /I not "%%~nxF"==".index" del /q "%%F"
    )
) else (
    mkdir "%DEST%"
)
:: ─── COPY NEW MODS ──────────────────────────────────────────────────────

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

:: grab timestamp for commit message
for /f %%i in ('powershell -nologo -command "Get-Date -Format ''yyyy-MM-dd HH:mm:ss''"') do set "datetime=%%i"

echo.
echo 2) git add/commit/push
git add .
git commit -m "Auto update on %datetime%"
git push

popd

:: ─── DONE ────────────────────────────────────────────────────────────────

echo.
echo ✅ All done!
