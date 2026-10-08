# FreeCaption - install.bat yardimcisi: Python 3.12 (64-bit) indirip sessiz kurar.
# winget yoksa ya da basarisiz olursa devreye girer. Kullanici bazli kurulum (yonetici gerekmez).
param([string]$Version = '3.12.10')
$ErrorActionPreference = 'Stop'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
$ProgressPreference = 'SilentlyContinue'

$url = "https://www.python.org/ftp/python/$Version/python-$Version-amd64.exe"
$out = Join-Path $env:TEMP 'fc_python_setup.exe'

try {
    Write-Host "      Indiriliyor: $url"
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
    if ((Get-Item $out).Length -lt 20MB) { throw 'Indirilen dosya eksik' }
    Write-Host '      Kuruluyor (1-2 dakika, pencere acilmayabilir)...'
    $p = Start-Process -FilePath $out -Wait -PassThru -ArgumentList @(
        '/quiet', 'InstallAllUsers=0', 'PrependPath=1', 'Include_launcher=1',
        'Include_test=0', 'Include_doc=0'
    )
    exit $p.ExitCode
} catch {
    Write-Host "      Python indirilemedi/kurulamadi: $($_.Exception.Message)"
    exit 1
}
