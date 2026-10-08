@echo off
setlocal EnableExtensions
title FreeCaption - Otomatik Baslatma Kurulumu
cd /d "%~dp0"

REM KURAL: 'if' BLOKU ( ... ) kullanma; kacissiz parantez blogu bozar. goto/etiket kullan.

echo.
echo ===================================================
echo   FreeCaption - Bilgisayar acilisinda otomatik baslat
echo ===================================================
echo.

set "VBS=%~dp0start_hidden.vbs"
if not exist "%VBS%" goto :err_vbs

set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "LNK=%STARTUP%\FreeCaption.lnk"
if not exist "%STARTUP%" mkdir "%STARTUP%" >nul 2>nul

REM Yollar ortam degiskeniyle gecer: apostrof/bosluk/Turkce karakter sorun cikarmaz
set "FC_LNK=%LNK%"
set "FC_VBS=%VBS%"
set "FC_DIR=%~dp0"

echo  Baslangic kisayolu olusturuluyor...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut($env:FC_LNK); $s.TargetPath='wscript.exe'; $s.Arguments='\"'+$env:FC_VBS+'\"'; $s.WorkingDirectory=$env:FC_DIR; $s.WindowStyle=7; $s.Save()"
if errorlevel 1 goto :err_lnk
if not exist "%LNK%" goto :err_lnk

echo.
echo  OK - FreeCaption sunucusu artik her acilista ^(gizli^) baslayacak.
echo  Kaldirmak icin su dosyayi sil:
echo    %LNK%
echo  ^(Ya da: Win+R, shell:startup, FreeCaption kisayolunu sil.^)
echo.
if not defined FC_NOPAUSE pause
exit /b 0

:err_vbs
echo  HATA: start_hidden.vbs bulunamadi.
echo  Bu dosya autostart_kur.bat ile ayni klasorde olmali. Zip'i klasore
echo  tamamen cikardigindan emin ol.
goto :fail_end

:err_lnk
echo  HATA: Kisayol olusturulamadi.
echo  Antivirus engelliyor olabilir. Kisayolu elle olusturmak icin Win+R,
echo  shell:startup, acilan klasore start_hidden.vbs dosyasinin kisayolunu koy.
goto :fail_end

:fail_end
echo.
pause
exit /b 1
