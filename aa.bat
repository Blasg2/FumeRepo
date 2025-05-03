@echo off
chcp 65001 >nul

:: === CONFIG ===
set "TOML_DIR=C:\Users\guilh\OneDrive\Área de Trabalho\Packwiz Modpack\mods\.index"
set "CLIENT_LIST=client_only_mods.txt"
set "SERVER_LIST=server_allowed_mods.txt"

:: Clear output files
del "%CLIENT_LIST%" >nul 2>&1
del "%SERVER_LIST%" >nul 2>&1

echo 🔍 Scanning .toml files in:
echo %TOML_DIR%
echo.

:: Loop over every .toml file
for %%F in ("%TOML_DIR%\*.toml") do (
    echo 📄 Processing: %%~nxF

    set "FILENAME="
    set "SIDE="

    :: Use a temporary file to read content safely
    >temp_scan.txt (
        findstr /i "filename =" "%%F"
        findstr /i "side =" "%%F"
    )

    for /f "tokens=1,* delims==" %%A in (temp_scan.txt) do (
        set "key=%%A"
        set "val=%%B"

        call set "key=%%key: =%%"
        call set "val=%%val:~1,-1%%"

        if /i "%%key%%"=="filename" set "FILENAME=%%val%%"
        if /i "%%key%%"=="side" set "SIDE=%%val%%"
    )

    if defined FILENAME (
        if /i "!SIDE!"=="client" (
            echo 🔴 [client] !FILENAME!
            >> "%CLIENT_LIST%" echo !FILENAME!
        ) else if /i "!SIDE!"=="server" (
            echo 🟢 [server] !FILENAME!
            >> "%SERVER_LIST%" echo !FILENAME!
        ) else if not /i "!SIDE!"=="both" (
            echo 🟢 [unspecified] !FILENAME!
            >> "%SERVER_LIST%" echo !FILENAME!
        ) else (
            echo ⚪ Ignoring !FILENAME! (side = both)
        )
    ) else (
        echo ⚠️ Could not extract filename from %%~nxF
    )

    del temp_scan.txt >nul 2>&1
)

echo.
echo ✅ Finished!
echo 🔴 Client-only mods in: %CLIENT_LIST%
echo 🟢 Server-allowed mods in: %SERVER_LIST%
pause
