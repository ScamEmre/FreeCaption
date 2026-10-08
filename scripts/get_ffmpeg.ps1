# FreeCaption - install.bat yardimcisi: winget olmadan FFmpeg'i proje klasorune indirir.
# Sonuc: <FreeCaption>\ffmpeg\bin\ffmpeg.exe (+ ffprobe.exe). backend/audio.py burayi otomatik bulur.
$ErrorActionPreference = 'Stop'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
$ProgressPreference = 'SilentlyContinue'

$root = Split-Path -Parent $PSScriptRoot
$dest = Join-Path $root 'ffmpeg\bin'
if (Test-Path (Join-Path $dest 'ffmpeg.exe')) { exit 0 }

$urls = @(
    'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip',
    'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip'
)
$zip = Join-Path $env:TEMP 'fc_ffmpeg.zip'
$tmp = Join-Path $env:TEMP 'fc_ffmpeg_x'
$ok = $false
foreach ($u in $urls) {
    try {
        Write-Host "      Indiriliyor: $u"
        Invoke-WebRequest -Uri $u -OutFile $zip -UseBasicParsing
        if ((Get-Item $zip).Length -gt 20MB) { $ok = $true; break }
    } catch {
        Write-Host "      Olmadi, siradaki kaynak deneniyor..."
    }
}
if (-not $ok) { Write-Host '      FFmpeg indirilemedi.'; exit 1 }

try {
    if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
    Expand-Archive -Path $zip -DestinationPath $tmp -Force
    $exe = Get-ChildItem -Path $tmp -Recurse -Filter 'ffmpeg.exe' | Select-Object -First 1
    if (-not $exe) { throw 'ffmpeg.exe zip icinde bulunamadi' }
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Copy-Item $exe.FullName (Join-Path $dest 'ffmpeg.exe') -Force
    $probe = Join-Path $exe.DirectoryName 'ffprobe.exe'
    if (Test-Path $probe) { Copy-Item $probe (Join-Path $dest 'ffprobe.exe') -Force }
    Remove-Item -Recurse -Force $tmp, $zip -ErrorAction SilentlyContinue
    Write-Host '      FFmpeg kuruldu.'
    exit 0
} catch {
    Write-Host "      FFmpeg acilamadi: $($_.Exception.Message)"
    exit 1
}
