@echo off
setlocal
title FreeCaption - Otomatik Baslatma Kurulumu
cd /d "%~dp0"

echo.
echo ===================================================
echo   FreeCaption - Bilgisayar acilisinda otomatik baslat
echo ===================================================
echo.

set "VBS=%~dp0start_hidden.vbs"
if not exist "%VBS%" (
    echo  HATA: start_hidden.vbs bulunamadi.
    echo  Bu dosya start_hidden.vbs ile ayni klasorde olmali.
    pause
    exit /b 1
)

set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "LNK=%STARTUP%\FreeCaption.lnk"

echo  Baslangic kisayolu olusturuluyor...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%LNK%'); $s.TargetPath='wscript.exe'; $s.Arguments='\"%VBS%\"'; $s.WorkingDirectory='%~dp0'; $s.WindowStyle=7; $s.Save()"
if errorlevel 1 (
    echo  HATA: Kisayol olusturulamadi.
    pause
    exit /b 1
)

echo.
echo  OK - FreeCaption sunucusu artik her acilista (gizli) baslayacak.
echo  Kaldirmak icin su dosyayi sil:
echo    %LNK%
echo.
pause
