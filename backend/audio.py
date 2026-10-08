import os
import shutil
import subprocess
from pathlib import Path
from typing import Optional


def _find_ffmpeg() -> str:
    """FFmpeg binary'sinin tam yolunu bul. PATH'te yoksa bilinen yerlere bak."""
    # 1) PATH'te
    p = shutil.which("ffmpeg")
    if p:
        return p
    # 1b) Proje klasorune install.bat'in indirdigi FFmpeg (winget'siz kurulum)
    local_ff = Path(__file__).resolve().parent.parent / "ffmpeg" / "bin" / "ffmpeg.exe"
    if local_ff.exists():
        return str(local_ff)
    # 2) WinGet kurulumu (yeni surum)
    local = os.environ.get("LOCALAPPDATA", "")
    if local:
        winget_link = os.path.join(local, "Microsoft", "WinGet", "Links", "ffmpeg.exe")
        if os.path.exists(winget_link):
            return winget_link
        # WinGet paket klasoru
        pkg_root = os.path.join(local, "Microsoft", "WinGet", "Packages")
        if os.path.isdir(pkg_root):
            for entry in os.listdir(pkg_root):
                if "FFmpeg" in entry or "ffmpeg" in entry:
                    pkg_dir = os.path.join(pkg_root, entry)
                    for root, _, files in os.walk(pkg_dir):
                        if "ffmpeg.exe" in files:
                            return os.path.join(root, "ffmpeg.exe")
    # 3) Diger yaygin yerler
    for cand in [
        r"C:\ProgramData\chocolatey\bin\ffmpeg.exe",
        r"C:\ffmpeg\bin\ffmpeg.exe",
        r"C:\Program Files\ffmpeg\bin\ffmpeg.exe",
    ]:
        if os.path.exists(cand):
            return cand
    return "ffmpeg"


def _find_ffprobe() -> str:
    p = shutil.which("ffprobe")
    if p:
        return p
    local_fp = Path(__file__).resolve().parent.parent / "ffmpeg" / "bin" / "ffprobe.exe"
    if local_fp.exists():
        return str(local_fp)
    local = os.environ.get("LOCALAPPDATA", "")
    if local:
        winget_link = os.path.join(local, "Microsoft", "WinGet", "Links", "ffprobe.exe")
        if os.path.exists(winget_link):
            return winget_link
    return "ffprobe"


FFMPEG = _find_ffmpeg()
FFPROBE = _find_ffprobe()
print(f"[FreeCaption] FFmpeg: {FFMPEG}")
print(f"[FreeCaption] FFprobe: {FFPROBE}")

# WhisperX/torchaudio/CTranslate2 kendi subprocess/DLL load mekanizmalariyla
# "ffmpeg" ve "cudnn_*.dll" arar. Process PATH'ine ekleyelim.
def _add_to_path(d: str):
    if not d or not os.path.isdir(d):
        return
    cur = os.environ.get("PATH", "")
    if d.lower() not in cur.lower():
        os.environ["PATH"] = d + os.pathsep + cur
        # Python 3.8+ DLL search path'i icin
        try:
            os.add_dll_directory(d)
        except (AttributeError, FileNotFoundError, OSError):
            pass
        print(f"[FreeCaption] PATH+DLL'e eklendi: {d}")

_ffmpeg_dir = os.path.dirname(os.path.abspath(FFMPEG)) if os.path.isabs(FFMPEG) else None
_add_to_path(_ffmpeg_dir)

# cuDNN + cuBLAS DLL'leri (nvidia-cudnn-cu12, nvidia-cublas-cu12 pip paketlerinden)
import importlib.util
for pkg_name in ("nvidia.cudnn", "nvidia.cublas", "nvidia.cuda_nvrtc", "nvidia.cuda_runtime"):
    try:
        spec = importlib.util.find_spec(pkg_name)
        if spec and spec.origin:
            pkg_dir = os.path.dirname(spec.origin)
            for sub in ("bin", "lib"):
                cand = os.path.join(pkg_dir, sub)
                _add_to_path(cand)
    except Exception as _e:
        print(f"[FreeCaption] {pkg_name} eklenmedi: {_e}")


def extract_audio(
    video_path: Path,
    output_wav: Path,
    start: Optional[float] = None,
    end: Optional[float] = None,
) -> Path:
    """Video'dan 16kHz mono WAV ses çıkarır (Whisper formatı).
    start/end verilirse sadece o aralığı kes."""
    cmd = [FFMPEG, "-y"]
    if start is not None and start > 0:
        cmd += ["-ss", f"{start:.3f}"]
    cmd += ["-i", str(video_path)]
    if end is not None and end > 0 and (start is None or end > start):
        dur = end - (start or 0)
        cmd += ["-t", f"{dur:.3f}"]
    cmd += [
        "-vn", "-acodec", "pcm_s16le",
        "-ar", "16000", "-ac", "1",
        str(output_wav),
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"FFmpeg hatası: {result.stderr[-500:]}")
    return output_wav


def get_media_duration(media_path: Path) -> Optional[float]:
    cmd = [
        FFPROBE, "-v", "error",
        "-show_entries", "format=duration",
        "-of", "default=noprint_wrappers=1:nokey=1",
        str(media_path),
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        return None
    try:
        return float(result.stdout.strip())
    except ValueError:
        return None


def is_audio_file(path: Path) -> bool:
    return path.suffix.lower() in {".mp3", ".wav", ".m4a", ".flac", ".ogg", ".aac", ".opus"}


def is_video_file(path: Path) -> bool:
    return path.suffix.lower() in {".mp4", ".mov", ".mkv", ".avi", ".webm", ".flv", ".wmv", ".m4v"}
