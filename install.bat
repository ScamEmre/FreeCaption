@echo off
setlocal EnableExtensions
title FreeCaption - Sunucu Kurulumu
cd /d "%~dp0"

REM ====================================================================
REM  FreeCaption - yerel sunucu kurulumu (Windows)
REM  KURAL: Bu dosyada 'if/for' BLOKLARI ( ... ) KULLANMA. Blok icindeki tek
REM  bir kacissiz kapatma parantezi blogu erken kapatir ve kurulum sessizce
REM  durur (v1.1.1 hatasi). Her sey goto/call etiketleriyle yazildi.
REM ====================================================================

set "ROOT=%~dp0"
set "FC_ROOT=%~dp0"
set "LOG=%~dp0install_log.txt"
set "VPY=%~dp0.venv\Scripts\python.exe"
set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"
set "PIP_DISABLE_PIP_VERSION_CHECK=1"
set "PIP_RETRIES=10"
set "PIP_TIMEOUT=60"
set "PIP_NO_INPUT=1"
set "PYCHK=import sys,struct; sys.exit(0 if (3,10)<=sys.version_info[:2]<=(3,12) and struct.calcsize('P')==8 else 1)"
set "PYEXE="
set "MODE=cpu"

>"%LOG%" echo FreeCaption kurulum kaydi - %date% %time%
>>"%LOG%" ver
>>"%LOG%" echo Klasor: %ROOT%

echo.
echo ===================================================
echo   FreeCaption - Yerel Sunucu Kurulumu
echo   Python + Whisper/WhisperX ^(+ NVIDIA GPU varsa CUDA^)
echo.
echo   NOT: Buyuk indirme var ^(GPU'da yaklasik 3 GB^).
echo   Internet baglantisi kesilmesin. Pencereyi KAPATMA,
echo   "KURULUM TAMAM" yazisini bekle. Toplam 10-25 dakika.
echo ===================================================
echo.

REM ---- 0) Ortam kontrolleri ------------------------------------------
if not exist "backend\requirements.txt" goto :err_extract

call :precheck
if errorlevel 3 goto :err_running
if errorlevel 1 goto :err_disk

REM ---- 1) Python 3.10-3.12 ^(64-bit^) ----------------------------------
echo [1/6] Python kontrol ediliyor...
call :findpy
if defined PYEXE goto :py_ok
echo       Uygun Python 3.10-3.12 bulunamadi. Otomatik kuruluyor...
call :installpy
call :findpy
if not defined PYEXE goto :err_python
:py_ok
echo       OK: %PYEXE%
>>"%LOG%" echo Python: %PYEXE%
echo.

REM ---- 2) Sanal ortam ------------------------------------------------
echo [2/6] Sanal ortam hazirlaniyor...
if not exist "%VPY%" goto :mkvenv
"%VPY%" -c "%PYCHK%" >nul 2>nul
if errorlevel 1 goto :rmvenv
goto :venv_ready
:rmvenv
echo       Mevcut .venv uyumsuz veya bozuk, yenileniyor...
rmdir /s /q ".venv" >nul 2>nul
if exist ".venv\Scripts\python.exe" goto :err_venvlock
:mkvenv
"%PYEXE%" -m venv --clear ".venv"
if errorlevel 1 goto :err_venv
if not exist "%VPY%" goto :err_venv
:venv_ready
call :pipretry install --upgrade pip wheel "setuptools<81"
if errorlevel 1 goto :err_pip
echo       OK
echo.

REM ---- 3) Visual C++ calisma zamani + GPU tespiti + PyTorch ----------
echo [3/6] GPU tespiti ve PyTorch kurulumu...
call :vcredist
call :detectgpu
if "%HASGPU%"=="1" goto :torch_gpu
:torch_cpu
echo       CPU PyTorch kuruluyor...
call :pipretry install --force-reinstall "torch>=2.7,<2.9" "torchaudio>=2.7,<2.9" --index-url https://download.pytorch.org/whl/cpu
if errorlevel 1 goto :err_torch
set "MODE=cpu"
goto :torch_done
:torch_gpu
echo       NVIDIA GPU bulundu: CUDA 12.8 PyTorch kuruluyor. Buyuk indirme, sabret...
call :pipretry install "torch>=2.7,<2.9" "torchaudio>=2.7,<2.9" --index-url https://download.pytorch.org/whl/cu128
if errorlevel 1 goto :err_torch
echo       GPU testi yapiliyor...
call :cudatest
if not errorlevel 1 goto :torch_gpu_ok
echo       CUDA 12.8 bu GPU'da calismadi. Eski GPU icin CUDA 12.6 deneniyor...
call :pipretry install --force-reinstall --no-deps "torch>=2.7,<2.9" "torchaudio>=2.7,<2.9" --index-url https://download.pytorch.org/whl/cu126
if errorlevel 1 goto :torch_cpu
call :cudatest
if not errorlevel 1 goto :torch_gpu_ok
echo       GPU kullanilamadi. CPU moduna geciliyor ^(daha yavas ama calisir^).
goto :torch_cpu
:torch_gpu_ok
echo       GPU testi basarili.
set "MODE=gpu"
:torch_done
>>"%LOG%" echo Mod: %MODE%
echo.

REM ---- 4) Backend bagimliliklari ---------------------------------------
echo [4/6] Whisper / WhisperX / FastAPI kuruluyor. Ilk seferde 5-10 dakika surer...
call :pipretry install -r "backend\requirements.txt"
if errorlevel 1 goto :err_pip
call :pinct2
if errorlevel 1 goto :err_pip
echo.

REM ---- 5) FFmpeg --------------------------------------------------------
echo [5/6] FFmpeg kontrol ediliyor...
call :findffmpeg
if defined FFOK goto :ff_ok
echo       FFmpeg yok. Kuruluyor...
where winget >nul 2>nul
if errorlevel 1 goto :ff_direct
winget install -e --id Gyan.FFmpeg --silent --accept-package-agreements --accept-source-agreements
call :findffmpeg
if defined FFOK goto :ff_ok
:ff_direct
echo       Dogrudan indiriliyor ^(yaklasik 80-150 MB^)...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\get_ffmpeg.ps1"
call :findffmpeg
if defined FFOK goto :ff_ok
echo       UYARI: FFmpeg otomatik kurulamadi. Kurulum bitti ama altyazi icin FFmpeg gerekir.
echo       Elle kur: https://www.gyan.dev/ffmpeg/builds/  ^(ffmpeg-release-essentials.zip^)
echo       Icindeki bin\ffmpeg.exe dosyasini  %~dp0ffmpeg\bin\  klasorune koy.
>>"%LOG%" echo UYARI: FFmpeg kurulamadi
goto :ff_done
:ff_ok
echo       OK
:ff_done
echo.

REM ---- 6) Dogrulama -----------------------------------------------------
echo [6/6] Kurulum dogrulaniyor...
call :verify
if not errorlevel 1 goto :verify_ok
echo       Eksik veya bozuk paket var - onariliyor ^(internet gerekli^)...
call :pipretry install -r "backend\requirements.txt"
REM requirements ctranslate2'yi 4.4'e dusurur: moda gore yeniden sabitle
call :pinct2
call :verify
if errorlevel 1 goto :err_verify
:verify_ok
>"%~dp0.venv\fc_mode.txt" echo %MODE%
>"%~dp0.venv\fc_install_ok.txt" echo ok
>>"%LOG%" echo KURULUM TAMAM - mod %MODE%
echo       Tum paketler calisiyor.
echo.

echo ===================================================
echo   KURULUM TAMAM.   Mod: %MODE%
if "%MODE%"=="gpu" echo   ^(GPU hizlandirma aktif^)
if "%MODE%"=="cpu" echo   ^(GPU yok ya da kullanilamadi: CPU modu, daha yavas^)
echo.
echo   Sirada:
echo     1^) cep_kur.bat   -- paneli Premiere'e kur
echo     2^) start.bat     -- sunucuyu baslat ^(acik birak^)
echo   ^(Ya da tek seferde: KUR.bat^)
echo ===================================================
echo.
if not defined FC_NOPAUSE pause
exit /b 0


REM ====================================================================
REM  HATA EKRANLARI
REM ====================================================================
:err_extract
echo.
echo  HATA: Gerekli dosyalar bulunamadi ^(backend klasoru yok^).
echo.
echo  Buyuk ihtimalle zip'i KLASORE CIKARMADAN, zip'in icinden calistirdin.
echo   1^) FreeCaption.zip'e sag tikla  -^>  "Tumunu ayikla" / "Extract All"
echo   2^) Cikan klasorun icine gir
echo   3^) install.bat'i oradan calistir
goto :fail_end

:err_python
echo.
echo  HATA: Uygun Python bulunamadi ve otomatik kurulamadi.
echo.
echo  Elle kur ^(3 adim^):
echo   1^) Tarayicida ac: https://www.python.org/downloads/release/python-31210/
echo   2^) En alttaki "Windows installer 64-bit" dosyasini indir ve ac
echo   3^) Acilan pencerede en alttaki "Add python.exe to PATH" kutusunu ISARETLE,
echo      sonra "Install Now" de.
echo  Bittikten sonra install.bat'i TEKRAR calistir.
echo  ^(Python 3.13 / 3.14 uyumsuz. 3.12 kur, digerleri yaninda durabilir.^)
goto :fail_end

:err_running
echo.
echo  HATA: FreeCaption sunucusu su an ACIK ^(dosyalar kilitli, kurulum bozulur^).
echo  Acik siyah "FreeCaption - Sunucu" penceresini kapat ^(ya da bilgisayari yeniden
echo  baslat^), sonra install.bat / KUR.bat'i tekrar calistir.
goto :fail_end

:err_venvlock
echo.
echo  HATA: Eski .venv klasoru silinemedi. FreeCaption sunucusu acik olabilir.
echo  Acik "FreeCaption - Sunucu" penceresini kapat ya da bilgisayari yeniden
echo  baslat, sonra install.bat'i tekrar calistir.
goto :fail_end

:err_venv
echo.
echo  HATA: Sanal ortam ^(.venv^) olusturulamadi.
echo  Klasor yolunda Turkce karakter / OneDrive varsa C:\FreeCaption gibi sade
echo  bir klasore tasi, sonra tekrar dene. Antivirus engelliyor olabilir.
goto :fail_end

:err_torch
echo.
echo  HATA: PyTorch kurulamadi. Genelde internet kesildi, disk doldu ya da
echo  guvenlik duvari/antivirus indirmeyi engelledi.
echo  Internetini kontrol edip install.bat'i TEKRAR calistir ^(kaldigi yerden devam eder^).
goto :fail_end

:err_pip
echo.
echo  HATA: Paket kurulumu basarisiz oldu ^(internet kesintisi olabilir^).
echo  install.bat'i TEKRAR calistir; kaldigi yerden devam eder. Sorun surerse
echo  ekran goruntusunu ve install_log.txt dosyasini gonder.
>>"%LOG%" echo --- pip list ---
"%VPY%" -m pip list >>"%LOG%" 2>&1
goto :fail_end

:err_disk
echo.
echo  HATA: Diskte yeterli bos yer yok ^(su an yaklasik %FREEGB% GB, en az 8 GB gerekir^).
echo  Yer ac ya da FreeCaption klasorunu daha bos bir diske tasi.
goto :fail_end

:err_verify
echo.
echo  HATA: Kurulum bitti ama paketler dogru calismiyor. Asagidaki satirlar
echo  sorunu gosterir:
echo.
type "%TEMP%\fc_verify.txt"
>>"%LOG%" echo --- dogrulama hatasi ---
type "%TEMP%\fc_verify.txt" >>"%LOG%"
echo.
echo  "WinError 126" / "DLL" hatasi gordiysen: Microsoft Visual C++ Redistributable
echo  eksik. Su adresten x64 surumunu kur, bilgisayari yeniden baslat, tekrar dene:
echo  https://aka.ms/vs/17/release/vc_redist.x64.exe
goto :fail_end

:fail_end
echo.
echo  Kayit dosyasi: %LOG%
echo  ^(Yardim isterken bu dosyayi ve bu ekranin goruntusunu gonder.^)
echo.
pause
exit /b 1


REM ====================================================================
REM  ALT RUTINLER
REM ====================================================================

:pinct2
if "%MODE%"=="gpu" goto :pinct2_gpu
echo       CPU modu: ctranslate2 4.4.0 stabil surume sabitleniyor...
call :pipretry install "ctranslate2==4.4.0" --force-reinstall --no-deps
if errorlevel 1 exit /b 1
call :pipretry install intel-openmp
exit /b %errorlevel%
:pinct2_gpu
echo       GPU modu: ctranslate2 4.5+ ^(cuDNN 9, torch cu128 ile uyumlu^)...
call :pipretry install "ctranslate2>=4.5,<5" --force-reinstall --no-deps
exit /b %errorlevel%

:precheck
REM Klasor yolunda ASCII-disi karakter ^(Turkce vb.^)
powershell -NoProfile -Command "if ($env:FC_ROOT -match '[^\x00-\x7F]') { exit 7 } else { exit 0 }" >nul 2>nul
if "%errorlevel%"=="7" call :warn_path "Klasor yolunda Turkce/ozel karakter var."
REM OneDrive icinde ^(senkron + kilit sorunu^)
if not "%ROOT:OneDrive=%"=="%ROOT%" call :warn_path "Klasor OneDrive icinde."
REM Sunucu acik mi ^(venv python.exe calisiyorsa dosyalar kilitli^)
powershell -NoProfile -Command "$r=$env:FC_ROOT+'.venv'; if (Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ExecutablePath -and $_.ExecutablePath.StartsWith($r, [StringComparison]::OrdinalIgnoreCase) }) { exit 7 } else { exit 0 }" >nul 2>nul
if "%errorlevel%"=="7" exit /b 3
REM Bos disk alani
set "FREEGB=99"
for /f %%A in ('powershell -NoProfile -Command "[math]::Floor((New-Object System.IO.DriveInfo((Split-Path -Qualifier $env:FC_ROOT))).AvailableFreeSpace/1GB)" 2^>nul') do set "FREEGB=%%A"
>>"%LOG%" echo Bos disk GB: %FREEGB%
if %FREEGB% LSS 8 exit /b 2
REM Internet
powershell -NoProfile -Command "try{[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;$null=Invoke-WebRequest -Uri 'https://pypi.org/simple/pip/' -UseBasicParsing -TimeoutSec 20;exit 0}catch{exit 7}" >nul 2>nul
if "%errorlevel%"=="7" call :warn_net
exit /b 0

:warn_path
echo.
echo  UYARI: %~1
echo  Sorunsuz kurulum icin FreeCaption klasorunu  C:\FreeCaption  gibi sade bir
echo  yola tasimaniz onerilir. Yine de devam etmek icin bir tusa bas.
echo  ^(Vazgecmek icin pencereyi kapat.^)
pause >nul
echo.
exit /b 0

:warn_net
echo.
echo  UYARI: Internete ^(pypi.org^) ulasilamadi. Baglantini ya da VPN/proxy
echo  ayarini kontrol et. Yine de denemek icin bir tusa bas.
pause >nul
echo.
exit /b 0

:findpy
set "PYEXE="
for %%V in (3.12 3.11 3.10) do call :trypy %%V
for /f "delims=" %%P in ('where python 2^>nul') do call :checkcand "%%P"
for %%V in (312 311 310) do call :checkcand "%LOCALAPPDATA%\Programs\Python\Python%%V\python.exe"
for %%V in (312 311 310) do call :checkcand "%ProgramFiles%\Python%%V\python.exe"
exit /b 0

:trypy
if defined PYEXE exit /b 0
set "CAND="
for /f "usebackq delims=" %%P in (`py -%1 -c "import sys;print(sys.executable)" 2^>nul`) do set "CAND=%%P"
if defined CAND call :checkcand "%CAND%"
exit /b 0

:checkcand
if defined PYEXE exit /b 0
if not exist "%~1" exit /b 0
set "CT=%~1"
if not "%CT:\WindowsApps\=%"=="%CT%" exit /b 0
REM .bat/.cmd shim'leri (pyenv vb.) calistirilirsa betigin akisini bozar: yalniz .exe
if /i not "%~x1"==".exe" exit /b 0
"%~1" -c "%PYCHK%" >nul 2>nul
if errorlevel 1 exit /b 0
set "PYEXE=%~1"
exit /b 0

:installpy
where winget >nul 2>nul
if errorlevel 1 goto :installpy_direct
echo       winget ile Python 3.12 kuruluyor, bekle...
>>"%LOG%" echo winget ile python kurulumu
winget install -e --id Python.Python.3.12 --scope user --silent --accept-package-agreements --accept-source-agreements
call :findpy
if defined PYEXE exit /b 0
:installpy_direct
echo       python.org uzerinden Python 3.12 indiriliyor ve kuruluyor, bekle...
>>"%LOG%" echo python.org dogrudan kurulum
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\get_python.ps1"
exit /b 0

:pipretry
set "TRY=0"
:pipretry_loop
set /a TRY+=1
"%VPY%" -m pip %*
if not errorlevel 1 exit /b 0
>>"%LOG%" echo pip basarisiz, deneme %TRY%/3
if %TRY% GEQ 3 exit /b 1
echo       Hata. 5 saniye sonra yeniden deneniyor ^(%TRY%/3^)...
ping -n 6 127.0.0.1 >nul
goto :pipretry_loop

:vcredist
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" /v Installed 2>nul | "%SystemRoot%\System32\find.exe" "0x1" >nul
if not errorlevel 1 exit /b 0
echo       Microsoft Visual C++ bilesenleri kuruluyor ^(yonetici izni sorabilir^)...
>>"%LOG%" echo vcredist kuruluyor
where winget >nul 2>nul
if errorlevel 1 goto :vc_direct
winget install -e --id Microsoft.VCRedist.2015+.x64 --silent --accept-package-agreements --accept-source-agreements
exit /b 0
:vc_direct
powershell -NoProfile -ExecutionPolicy Bypass -Command "try{[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;$ProgressPreference='SilentlyContinue';Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile $env:TEMP\fc_vc.exe -UseBasicParsing;Start-Process $env:TEMP\fc_vc.exe -ArgumentList '/install','/quiet','/norestart' -Wait}catch{}" >nul 2>nul
exit /b 0

:detectgpu
set "HASGPU=0"
where nvidia-smi >nul 2>nul && goto :nv_found
if exist "%ProgramFiles%\NVIDIA Corporation\NVSMI\nvidia-smi.exe" set "PATH=%PATH%;%ProgramFiles%\NVIDIA Corporation\NVSMI"
where nvidia-smi >nul 2>nul || goto :nv_none
:nv_found
nvidia-smi >nul 2>nul
if errorlevel 1 goto :nv_none
nvidia-smi -L >>"%LOG%" 2>&1
set "DRVMAJOR=999"
for /f "tokens=1 delims=." %%D in ('nvidia-smi --query-gpu^=driver_version --format^=csv^,noheader 2^>nul') do set "DRVMAJOR=%%D"
>>"%LOG%" echo NVIDIA surucu: %DRVMAJOR%
if %DRVMAJOR% LSS 527 goto :nv_old
set "HASGPU=1"
exit /b 0
:nv_old
echo       NVIDIA suruculerin cok eski ^(%DRVMAJOR%^). GPU icin guncelle: nvidia.com/drivers
echo       Simdilik CPU modunda kurulacak ^(daha yavas^).
exit /b 0
:nv_none
echo       NVIDIA GPU bulunamadi, CPU modunda kurulacak ^(daha yavas ama calisir^).
exit /b 0

:cudatest
"%VPY%" -c "import torch,sys; x=torch.zeros(4,device='cuda'); y=(x+1).sum().item(); torch.cuda.synchronize(); sys.exit(0 if (y==4 and torch.cuda.get_device_capability()[0]>=7) else 1)" >>"%LOG%" 2>&1
exit /b %errorlevel%

:findffmpeg
set "FFOK="
where ffmpeg >nul 2>nul && set "FFOK=1"
if exist "%~dp0ffmpeg\bin\ffmpeg.exe" set "FFOK=1"
if exist "%LOCALAPPDATA%\Microsoft\WinGet\Links\ffmpeg.exe" set "FFOK=1"
if exist "C:\ffmpeg\bin\ffmpeg.exe" set "FFOK=1"
if exist "%ProgramFiles%\ffmpeg\bin\ffmpeg.exe" set "FFOK=1"
if exist "C:\ProgramData\chocolatey\bin\ffmpeg.exe" set "FFOK=1"
if defined FFOK exit /b 0
if not exist "%LOCALAPPDATA%\Microsoft\WinGet\Packages" exit /b 0
dir /s /b "%LOCALAPPDATA%\Microsoft\WinGet\Packages\ffmpeg.exe" >nul 2>nul && set "FFOK=1"
exit /b 0

:verify
"%VPY%" -c "import fastapi,uvicorn,aiofiles,pysrt,multipart,ffmpeg,torch,torchaudio,ctranslate2,whisperx" >"%TEMP%\fc_verify.txt" 2>&1
exit /b %errorlevel%
