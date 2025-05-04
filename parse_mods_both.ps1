# parse_mods_both.ps1

# 1) Path to the folder containing your .pw.toml files
$indexPath     = ".\mods\.index"

# 2) Names of the output files
$serverOutput  = "only_server_mods.txt"
$clientOutput  = "only_client_mods.txt"

# Remove old output if it exists
if (Test-Path $serverOutput) { Remove-Item $serverOutput }
if (Test-Path $clientOutput) { Remove-Item $clientOutput }

Write-Host ""
Write-Host "Scanning TOML files in $indexPath"
Write-Host ""

Get-ChildItem -Path $indexPath -Filter *.toml | ForEach-Object {
    $filename = ""
    $side     = ""

    # Read each line looking for the two keys
    Get-Content $_.FullName | ForEach-Object {
        $line = $_.Trim()
        if ($line -like "filename = '*'") {
            # split on single-quote, the second element is the name
            $parts = $line -split "'"
            if ($parts.Length -ge 2) { $filename = $parts[1] }
        }
        if ($line -like "side = '*'") {
            $parts = $line -split "'"
            if ($parts.Length -ge 2) { $side = $parts[1] }
        }
    }

    # Sort into the proper list
    if ($side -eq "server") {
        Write-Host "Server-only: $filename"
        $filename | Out-File -FilePath $serverOutput -Encoding UTF8 -Append
    }
    elseif ($side -eq "client") {
        Write-Host "Client-only: $filename"
        $filename | Out-File -FilePath $clientOutput -Encoding UTF8 -Append
    }
    else {
        Write-Host "Skipped '$filename' (side=$side)"
    }
}

Write-Host ""
Write-Host "Done!"
Write-Host "  • Server list: $serverOutput"
Write-Host "  • Client list: $clientOutput"
Write-Host "Press any key to exit..."
[System.Console]::ReadKey() > $null
