$tomlPath = "C:\Users\guilh\OneDrive\Área de Trabalho\Packwiz Modpack\mods\.index"
$clientFile = "client_only_mods.txt"
$serverFile = "server_allowed_mods.txt"

Remove-Item $clientFile, $serverFile -ErrorAction SilentlyContinue

Write-Host "🔍 Scanning $tomlPath"

Get-ChildItem "$tomlPath\*.toml" | ForEach-Object {
    $filename = ""
    $side = ""

    $lines = Get-Content $_.FullName
    foreach ($line in $lines) {
        if ($line -match '^\s*filename\s*=\s*"(.*?)"') {
            $filename = $matches[1]
        }
        elseif ($line -match '^\s*side\s*=\s*"(.*?)"') {
            $side = $matches[1]
        }
    }

    if ($filename) {
        switch ($side) {
            "client" {
                Write-Host "🔴 [client] $filename"
                Add-Content $clientFile $filename
            }
            "server" {
                Write-Host "🟢 [server] $filename"
                Add-Content $serverFile $filename
            }
            "both" {
                Write-Host "⚪ [ignored] $filename"
            }
            default {
                Write-Host "🟢 [unspecified] $filename"
                Add-Content $serverFile $filename
            }
        }
    }
}

Write-Host "`n✅ Done!"
pause
