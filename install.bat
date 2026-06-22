@echo off
setlocal
title FreeCaption - Sunucu Kurulumu (Python + bagimliliklar)
cd /d "%~dp0"

echo.
echo ===================================================
echo   FreeCaption - Yerel Sunucu Kurulumu
echo   Python venv + Whisper/WhisperX (+ GPU varsa CUDA)
echo.
echo   NOT: Buyuk indirme var (GPU'da ~3 GB). Internet
echo   baglantisi kesilmesin, "KURULUM TAMAM" yazisini bekle.
echo ===================================================
echo.

REM ---- 1) Python 3.10-3.12 bul ----
echo [1/6] Python kontrol ediliyor...
set "PYEXE="
for %%V in (3.12 3.11 3.10) do (
    if not defined PYEXE (
        py -%%V -V >nul 2>nul && set "PYEXE=py -%%V"
    )
)
if not defined PYEXE (
    REM 3.10-3.12 yok. Yeni Python'larda (3.13+) whisper yiginin wheel'i
    REM olmayabildigi icin winget ile Python 3.12 kur.
    echo       Uygun Python 3.10-3.12 yok. Python 3.12 winget ile kuruluyor...
    winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
    py -3.12 -V >nul 2>nul && set "PYEXE=py -3.12"
)
if not defined PYEXE (
    echo.
    echo  HATA: Python 3.10-3.12 kurulamadi.
    echo  Elle kur: https://www.python.org/downloads/  ("Add Python to PATH" isaretle)
    echo.
    pause
    exit /b 1
)
echo       OK ^(%PYEXE%^)
echo.

REM ---- 2) Sanal ortam (.venv) -- uyumsuz Python ile kurulduysa yeniden olustur ----
echo [2/6] Sanal ortam (.venv) hazirlaniyor...
set "VENV_OK=0"
if exist ".venv\Scripts\python.exe" (
    ".venv\Scripts\python.exe" -c "import sys; sys.exit(0 if (3,10)<=sys.version_info[:2]<=(3,12) else 1)" && set "VENV_OK=1"
)
if "%VENV_OK%"=="0" (
    if exist ".venv" (
        echo       Mevcut .venv uyumsuz Python ile kurulmus - siliniyor...
        rmdir /s /q ".venv"
    )
    %PYEXE% -m venv .venv
    if errorlevel 1 (
        echo  HATA: venv olusturulamadi.
        pause
        exit /b 1
    )
)
set "VPY=.venv\Scripts\python.exe"
set "VPIP=.venv\Scripts\pip.exe"
"%VPY%" -m pip install --upgrade pip wheel || "%VPY%" -m pip install --upgrade pip wheel
echo       OK
echo.

REM ---- 3) GPU tespiti + PyTorch (kesintide bir kez yeniden dener) ----
echo [3/6] GPU tespiti ve PyTorch kurulumu...
set "HASGPU=0"
where nvidia-smi >nul 2>nul && set "HASGPU=1"
REM Surum ARALIGI: torchaudio>=2.9 'AudioMetaData'yi kaldirdi, whisperx 3.3.1'in
REM cektigi pyannote.audio 3.3.2 ise hala onu kullaniyor -> 2.9+ ile import cokuyor.
REM Bu yuzden 2.7-2.8 araligi (pyannote uyumlu). Bu araligin cu128 wheel'i sadece
REM Python 3.10-3.12'de var (3.13'te yok); o yuzden yukarida 3.12 sart kosuldu.
if "%HASGPU%"=="1" (
    echo       NVIDIA GPU bulundu  -^>  CUDA 12.8 PyTorch
    "%VPIP%" install "torch>=2.7,<2.9" "torchaudio>=2.7,<2.9" --index-url https://download.pytorch.org/whl/cu128 || "%VPIP%" install "torch>=2.7,<2.9" "torchaudio>=2.7,<2.9" --index-url https://download.pytorch.org/whl/cu128
) else (
    echo       GPU yok  -^>  CPU PyTorch
    "%VPIP%" install "torch>=2.7,<2.9" "torchaudio>=2.7,<2.9" --index-url https://download.pytorch.org/whl/cpu || "%VPIP%" install "torch>=2.7,<2.9" "torchaudio>=2.7,<2.9" --index-url https://download.pytorch.org/whl/cpu
)
if errorlevel 1 (
    echo.
    echo  HATA: PyTorch kurulamadi (internet kesildi ya da Python surumu uyumsuz).
    echo  install.bat'i tekrar calistir; takilirsa Python 3.12 kur (3.13+ bazi
    echo  paketlerde wheel sorunu cikarabilir).
    echo.
    pause
    exit /b 1
)
echo.

REM ---- 4) Backend bagimliliklari (kesintide bir kez yeniden dener) ----
echo [4/6] Whisper / WhisperX / FastAPI kuruluyor (ilk seferde 5-10 dk)...
"%VPIP%" install -r backend\requirements.txt || "%VPIP%" install -r backend\requirements.txt
if "%HASGPU%"=="1" (
    REM GPU: requirements ctranslate2 4.4.0'i (cuDNN 8) cekiyor, ama torch cu128
    REM cuDNN 9 getiriyor -> "cudnn_ops_infer64_8.dll bulunamadi" cokmesi.
    REM 4.5+ cuDNN 9 kullanir, torch'un DLL'leriyle uyumlu (RTX 50 sm_120'de dogrulandi).
    echo       GPU modu: ctranslate2 4.5+ (cuDNN 9 - torch cu128 ile uyumlu)...
    "%VPIP%" install "ctranslate2>=4.5,<5" --force-reinstall --no-deps
) else (
    REM Windows CPU: ctranslate2 4.5+ libomp DLL hatasi veriyor -> 4.4.0 stabil
    echo       CPU modu: ctranslate2 4.4.0 stabil surume sabitleniyor...
    "%VPIP%" install "ctranslate2==4.4.0" --force-reinstall --no-deps
    "%VPIP%" install intel-openmp
)
echo.

REM ---- 5) FFmpeg ----
echo [5/6] FFmpeg kontrol ediliyor...
where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo       FFmpeg yok. winget ile kuruluyor...
    winget install -e --id Gyan.FFmpeg --accept-package-agreements --accept-source-agreements
    echo       NOT: Kurulumdan sonra terminali/Premiere'i yeniden ac (PATH yenilensin).
) else (
    echo       OK ^(sistemde mevcut^)
)
echo.

REM ---- 6) Dogrulama + eksik varsa otomatik tamamla ----
echo [6/6] Kurulum dogrulaniyor...
"%VPY%" -c "import importlib.util as u, sys; need=['fastapi','uvicorn','aiofiles','pysrt','multipart','ffmpeg','torch','torchaudio','whisperx']; miss=[m for m in need if u.find_spec(m) is None]; print('  EKSIK: '+', '.join(miss)) if miss else print('  Tum paketler kurulu.'); sys.exit(1 if miss else 0)"
if errorlevel 1 (
    echo.
    echo   Eksik paket var - tamamlaniyor (internet gerekli)...
    "%VPIP%" install -r backend\requirements.txt
    "%VPY%" -c "import importlib.util as u, sys; need=['fastapi','uvicorn','aiofiles','pysrt','multipart','ffmpeg','torch','torchaudio','whisperx']; miss=[m for m in need if u.find_spec(m) is None]; sys.exit(1 if miss else 0)" && (echo   Tamam: tum paketler kurulu.) || (echo   UYARI: Hala eksik paket var. install.bat'i tekrar calistir, indirme bitene kadar bekle.)
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
