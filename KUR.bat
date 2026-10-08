@echo off
setlocal EnableExtensions
title FreeCaption - Tek Tikla Kurulum
cd /d "%~dp0"

REM Teknik bilgisi olmayanlar icin: tek dosya, tum kurulum.
REM 1) install.bat  : Python + yapay zeka bilesenleri + FFmpeg
REM 2) cep_kur.bat  : Premiere paneli
REM 3) start.bat    : sunucuyu baslatir

set "FC_NOPAUSE=1"

echo.
echo ===================================================
echo   FreeCaption - TEK TIKLA KURULUM
echo.
echo   3 adim, otomatik ilerler. Toplam 10-25 dakika.
echo   Pencereleri KAPATMA, internet kesilmesin.
echo ===================================================
echo.

echo ADIM 1/3 - Sunucu kuruluyor...
call "%~dp0install.bat"
if errorlevel 1 goto :fail

echo.
echo ADIM 2/3 - Premiere paneli kuruluyor...
call "%~dp0cep_kur.bat"
if errorlevel 1 goto :fail

echo.
echo ADIM 3/3 - Sunucu baslatiliyor...
start "FreeCaption Sunucu" "%~dp0start.bat"

echo.
echo ===================================================
echo   HER SEY HAZIR!
echo.
echo   - Acilan siyah "FreeCaption - Sunucu" penceresini KAPATMA
echo     ^(kucultebilirsin^).
echo   - Premiere Pro'yu KAPATIP yeniden ac.
echo   - Window ^> Extensions ^> FreeCaption.
echo.
echo   Bundan sonra her kullanimda sadece start.bat'a cift tikla.
echo ===================================================
echo.
pause
exit /b 0

:fail
echo.
echo  Kurulum tamamlanamadi. Yukaridaki kirmizi/HATA satirlarini oku.
echo  Cozemezsen ekran goruntusu + install_log.txt dosyasini gonder.
echo.
pause
exit /b 1
