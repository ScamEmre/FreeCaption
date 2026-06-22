@echo off
title FreeCaption - Sunucu
cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
    echo.
    echo  HATA: .venv bulunamadi.
    echo  Once install.bat dosyasini calistir.
    echo.
    pause
    exit /b 1
)

REM GPU varsa large-v3 + alignment (gpu), yoksa CPU medium
set "FC_MODE=cpu"
where nvidia-smi >nul 2>nul && set "FC_MODE=gpu"

set "FC_HOST=127.0.0.1"
set "FC_PORT=7860"

echo.
echo ===================================================
echo   FreeCaption sunucusu baslatiliyor   (mod: %FC_MODE%)
echo   http://127.0.0.1:7860
echo.
echo   Bu pencereyi ACIK birak. Durdurmak icin Ctrl+C.
echo ===================================================
echo.

cd backend
"..\.venv\Scripts\python.exe" main.py

echo.
echo  Sunucu durdu. (Bir hata olduysa yukarida gorunur.)
pause
