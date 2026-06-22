@echo off
setlocal
title FreeCaption - Sunucu Kurulumu (Python + bagimliliklar)
cd /d "%~dp0"

echo.
echo ===================================================
echo   FreeCaption - Yerel Sunucu Kurulumu
echo   Python venv + Whisper/WhisperX (+ GPU varsa CUDA)
echo ===================================================
echo.

REM ---- 1) Python 3.10-3.12 bul ----
echo [1/5] Python kontrol ediliyor...
set "PYEXE="
for %%V in (3.12 3.11 3.10) do (
    if not defined PYEXE (
        py -%%V -V >nul 2>nul && set "PYEXE=py -%%V"
    )
)
if not defined PYEXE (
    where python >nul 2>nul && set "PYEXE=python"
)
if not defined PYEXE (
    echo.
    echo  HATA: Python 3.10-3.12 bulunamadi.
    echo  Indir: https://www.python.org/downloads/
    echo  Kurulum sirasinda "Add Python to PATH" kutusunu ISARETLE.
    echo.
    pause
    exit /b 1
)
echo       OK ^(%PYEXE%^)
echo.

REM ---- 2) Sanal ortam (.venv) ----
echo [2/5] Sanal ortam (.venv) hazirlaniyor...
if not exist ".venv\Scripts\python.exe" (
    %PYEXE% -m venv .venv
    if errorlevel 1 (
        echo  HATA: venv olusturulamadi.
        pause
        exit /b 1
    )
)
set "VPY=.venv\Scripts\python.exe"
set "VPIP=.venv\Scripts\pip.exe"
"%VPY%" -m pip install --upgrade pip wheel
echo       OK
echo.

REM ---- 3) GPU tespiti + PyTorch ----
echo [3/5] GPU tespiti ve PyTorch kurulumu...
set "HASGPU=0"
where nvidia-smi >nul 2>nul && set "HASGPU=1"
if "%HASGPU%"=="1" (
    echo       NVIDIA GPU bulundu  -^>  CUDA 12.8 PyTorch
    "%VPIP%" install torch==2.7.1 torchaudio==2.7.1 --index-url https://download.pytorch.org/whl/cu128
) else (
    echo       GPU yok  -^>  CPU PyTorch
    "%VPIP%" install torch==2.7.1+cpu torchaudio==2.7.1+cpu --index-url https://download.pytorch.org/whl/cpu
)
if errorlevel 1 (
    echo  HATA: PyTorch kurulamadi. Internet/proxy kontrol et.
    pause
    exit /b 1
)
echo.

REM ---- 4) Backend bagimliliklari ----
echo [4/5] Whisper / WhisperX / FastAPI kuruluyor (ilk seferde 5-10 dk)...
"%VPIP%" install -r backend\requirements.txt
if errorlevel 1 (
    echo  HATA: requirements kurulamadi.
    pause
    exit /b 1
)
if "%HASGPU%"=="0" (
    REM Windows CPU: ctranslate2 4.5+ DLL hatasi veriyor -> 4.4.0 stabil
    echo       CPU modu: ctranslate2 4.4.0 stabil surume sabitleniyor...
    "%VPIP%" install "ctranslate2==4.4.0" --force-reinstall --no-deps
    "%VPIP%" install intel-openmp
)
echo       OK
echo.

REM ---- 5) FFmpeg ----
echo [5/5] FFmpeg kontrol ediliyor...
where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo       FFmpeg yok. winget ile kuruluyor...
    winget install -e --id Gyan.FFmpeg --accept-package-agreements --accept-source-agreements
    echo       NOT: Kurulumdan sonra terminali/Premiere'i yeniden ac (PATH yenilensin).
) else (
    echo       OK ^(sistemde mevcut^)
)
echo.

echo ===================================================
echo   KURULUM TAMAM.
echo.
echo   Sirada:
echo     1^) cep_kur.bat   -- paneli Premiere'e kur
echo     2^) start.bat     -- sunucuyu baslat (acik birak)
echo ===================================================
echo.
pause
