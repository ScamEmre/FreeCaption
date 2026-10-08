@echo off
setlocal EnableExtensions
title FreeCaption - Sunucu
cd /d "%~dp0"
set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"

REM KURAL: 'if' BLOKU ( ... ) kullanma; kacissiz parantez blogu bozar. goto/etiket kullan.

if not exist ".venv\Scripts\python.exe" goto :err_noinstall

REM Mod: install.bat'in yazdigi .venv\fc_mode.txt (gpu|cpu). Yoksa nvidia-smi'ye bak.
set "FC_MODE="
if exist ".venv\fc_mode.txt" set /p FC_MODE=<".venv\fc_mode.txt"
if defined FC_MODE goto :mode_set
set "FC_MODE=cpu"
where nvidia-smi >nul 2>nul && set "FC_MODE=gpu"
:mode_set
if /i not "%FC_MODE%"=="gpu" set "FC_MODE=cpu"

REM GPU'da VRAM 6 GB altindaysa large-v3 yerine medium modeli kullan (bellek yetmez).
if /i not "%FC_MODE%"=="gpu" goto :vram_done
if defined FC_MODEL goto :vram_done
set "VRAM="
for /f "tokens=1" %%M in ('nvidia-smi --query-gpu^=memory.total --format^=csv^,noheader^,nounits 2^>nul') do set "VRAM=%%M"
if not defined VRAM goto :vram_done
if %VRAM% LSS 6000 set "FC_MODEL=medium"
:vram_done

set "FC_HOST=127.0.0.1"
set "FC_PORT=7860"

REM Zaten calisiyorsa ikinci kez acma.
REM Yerel adres sutununu esler: dilden bagimsiz (LISTENING/ABHOEREN yazilisina bakmaz)
netstat -ano | findstr /r /c:"^ *TCP  *[^ ]*:%FC_PORT% " >nul 2>nul && goto :already

echo.
echo ===================================================
echo   FreeCaption sunucusu baslatiliyor   ^(mod: %FC_MODE%^)
if defined FC_MODEL echo   Model: %FC_MODEL%  ^(GPU bellegi 6 GB altinda: hafif model^)
echo   http://127.0.0.1:%FC_PORT%
echo.
echo   Bu pencereyi ACIK birak ^(kucultebilirsin^).
echo   Ilk altyazida model indirilir ^(1-3 GB^), biraz bekletebilir.
echo   Durdurmak icin bu pencereyi kapat.
echo ===================================================
echo.

cd backend
"..\.venv\Scripts\python.exe" main.py
set "RC=%errorlevel%"

echo.
echo  Sunucu durdu ^(kod %RC%^). Bir hata olduysa yukarida gorunur.
if not "%RC%"=="0" echo  Cozum: install.bat'i tekrar calistir. Sorun surerse ekran goruntusunu gonder.
if "%FREECAPTION_SILENT%"=="1" exit /b %RC%
pause
exit /b %RC%

:already
echo.
echo  FreeCaption zaten calisiyor ^(port %FC_PORT% dolu^). Yeni pencere acmaya gerek yok.
echo  Premiere'de Window ^> Extensions ^> FreeCaption panelini ac.
echo  Calismiyor gibiyse bilgisayari yeniden baslat ya da Gorev Yoneticisi'nden
echo  "python.exe" islemini sonlandir.
if "%FREECAPTION_SILENT%"=="1" exit /b 0
echo.
pause
exit /b 0

:err_noinstall
echo.
echo  HATA: Sunucu kurulmamis ^(.venv bulunamadi^).
echo  Once KUR.bat ^(ya da install.bat^) dosyasini calistir.
echo.
if "%FREECAPTION_SILENT%"=="1" exit /b 1
pause
exit /b 1
