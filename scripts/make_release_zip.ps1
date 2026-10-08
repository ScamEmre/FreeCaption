# FreeCaption - release zip'i uretir: dist\FreeCaption-v<surum>.zip
# Kullanim (repo kokunden):  powershell -ExecutionPolicy Bypass -File scripts\make_release_zip.ps1 -Version 1.1.3
# Zip icinde ust klasor "FreeCaption\" olur; kisisel/buyuk klasorler hari tutulur.
param([Parameter(Mandatory = $true)][string]$Version)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$out = Join-Path $dist "FreeCaption-v$Version.zip"
if (Test-Path $out) { Remove-Item $out -Force }

$excludeDirs = @('.venv', '.git', '.github', 'output', 'dist', '__pycache__', '.models', '.temp', 'ffmpeg', 'node_modules', '.vscode', '.idea')
$excludeFiles = @('install_log.txt', 'Thumbs.db', '.DS_Store', 'desktop.ini')

$zip = [System.IO.Compression.ZipFile]::Open($out, 'Create')
$count = 0
try {
    Get-ChildItem -Path $root -Recurse -File -Force | ForEach-Object {
        $rel = $_.FullName.Substring($root.Length).TrimStart('\', '/')
        $parts = $rel -split '[\\/]'
        $skip = $false
        foreach ($d in $parts[0..([Math]::Max(0, $parts.Length - 2))]) {
            if ($parts.Length -gt 1 -and $excludeDirs -contains $d) { $skip = $true; break }
        }
        if ($excludeFiles -contains $_.Name -or $_.Extension -in '.pyc', '.swp') { $skip = $true }
        if (-not $skip) {
            $entry = 'FreeCaption/' + ($rel -replace '\\', '/')
            [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $entry, 'Optimal')
            $count++
        }
    }
}
finally { $zip.Dispose() }

$mb = [math]::Round((Get-Item $out).Length / 1MB, 2)
Write-Host "$count dosya, $mb MB -> $out"
