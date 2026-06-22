@echo off
title FreeCaption - CEP Eklenti Kurulumu
cd /d "%~dp0"

echo.
echo ===================================================
echo   FreeCaption - CEP Eklenti Kurulumu
echo.
echo   Bu islem CEP debug modunu aktif eder ve
echo   plugin'i Adobe extensions klasorune kopyalar.
echo ===================================================
echo.

REM CEP Debug Mode aktive et (CSXS 9, 10, 11, 12)
echo [1/3] CEP debug mode kayit defterine yaziliyor...
reg add "HKCU\Software\Adobe\CSXS.9" /v PlayerDebugMode /t REG_SZ /d 1 /f >nul 2>nul
reg add "HKCU\Software\Adobe\CSXS.10" /v PlayerDebugMode /t REG_SZ /d 1 /f >nul 2>nul
reg add "HKCU\Software\Adobe\CSXS.11" /v PlayerDebugMode /t REG_SZ /d 1 /f >nul 2>nul
reg add "HKCU\Software\Adobe\CSXS.12" /v PlayerDebugMode /t REG_SZ /d 1 /f >nul 2>nul
echo       OK
echo.

REM CEP extensions klasoru
set "TARGET=%APPDATA%\Adobe\CEP\extensions\FreeCaption"
set "SOURCE=%~dp0cep-plugin"

if not exist "%SOURCE%" (
    echo  HATA: cep-plugin klasoru bulunamadi.
    echo  Konum: %SOURCE%
    pause
    exit /b 1
)

echo [2/3] Eski kurulum varsa siliniyor...
if exist "%TARGET%" rmdir /s /q "%TARGET%"
echo       OK
echo.

echo [3/3] Plugin kopyalaniyor...
if not exist "%APPDATA%\Adobe\CEP\extensions" mkdir "%APPDATA%\Adobe\CEP\extensions"
xcopy /e /i /q /y "%SOURCE%" "%TARGET%" >nul
if errorlevel 1 (
    echo  HATA: Kopyalama basarisiz.
    pause
    exit /b 1
)
echo       OK
echo.

REM ExtendScript ES3'te JSON.stringify yok - polyfill (json2.js) main.jsx basina eklenir
echo [3.5/3] JSON polyfill main.jsx ile birlestiriliyor...
powershell -NoProfile -Command "$j = [System.IO.File]::ReadAllBytes('%TARGET%\jsx\json2.js'); $m = [System.IO.File]::ReadAllBytes('%TARGET%\jsx\main.jsx'); $sep = [System.Text.Encoding]::UTF8.GetBytes([Environment]::NewLine + [Environment]::NewLine + '// ===== main.jsx (concat) =====' + [Environment]::NewLine + [Environment]::NewLine); [System.IO.File]::WriteAllBytes('%TARGET%\jsx\main.jsx', $j + $sep + $m)" >nul 2>nul
if errorlevel 1 (
    echo  UYARI: Polyfill birlestirme basarisiz. ExtendScript hata verebilir.
) else (
    echo       OK
)
echo.

REM Panel'deki "Sunucu Baslat" butonu start.bat'i bulabilsin diye yolu yaz
echo [3.6/3] Sunucu yolu panele kaydediliyor...
> "%TARGET%\server_path.txt" echo %~dp0start.bat
echo       OK (%~dp0start.bat)
echo.

REM FFmpeg kurulum kontrolu
echo [4/3] FFmpeg kontrol ediliyor...
set "FFMPEG_OK=0"
where ffmpeg >nul 2>nul
if %errorlevel% equ 0 set "FFMPEG_OK=1"
if exist "%LOCALAPPDATA%\Microsoft\WinGet\Links\ffmpeg.exe" set "FFMPEG_OK=1"
if exist "C:\ffmpeg\bin\ffmpeg.exe" set "FFMPEG_OK=1"
if exist "C:\Program Files\ffmpeg\bin\ffmpeg.exe" set "FFMPEG_OK=1"

if "%FFMPEG_OK%"=="0" (
    echo.
    echo UYARI: FFmpeg sisteminizde bulunamadi!
    echo Uzak sunucu (VDS) modu icin yerel FFmpeg kurulumu zorunludur.
    set "install_ff="
    set /p install_ff="FFmpeg'i winget ile otomatik kurmak ister misiniz? (E/H): "
    if /i "%install_ff%"=="E" (
        echo [!] FFmpeg kuruluyor (winget)...
        winget install ffmpeg
        if %errorlevel% equ 0 (
            echo [+] FFmpeg basariyla kuruldu!
            echo UYARI: Kurulum bittikten sonra degisikliklerin aktif olmasi icin 
            echo yeni bir komut istemi veya Premiere acmaniz gerekebilir.
        ) else (
            echo [-] HATA: winget ile FFmpeg kurulumu basarisiz oldu.
            echo Lutfen manuel olarak https://ffmpeg.org/ adresinden kurun.
        )
    )
) else (
    echo       OK (Sistemde FFmpeg mevcut)
)
echo.

echo ===================================================
echo   PANEL KURULUMU TAMAM.
echo.
echo   1^) Sunucu kurulmadiysa once: install.bat
echo   2^) Sunucuyu baslat:          start.bat   (acik birak)
echo      ^(veya panel icindeki  Sunucu Baslat  tusu^)
echo   3^) Premiere Pro'yu yeniden baslat
echo      Window ^> Extensions ^> FreeCaption menusunden ac
echo.
echo   Istersen autostart_kur.bat ile her acilista otomatik baslat.
echo ===================================================
echo.
pause
