"""
Whisper + WhisperX ile transkripsiyon.

Akış:
1. faster-whisper (large-v3) ile segment-level transkript çıkar.
2. WhisperX'in wav2vec2 forced alignment'ı ile word-level timestamp'leri hizala.
3. Hizalanmış kelimeler senkronu kaymayan altyazılar için kullanılır.
"""
from pathlib import Path
from typing import Optional, Callable
import gc
import torch

# PyTorch 2.6+ torch.load default'u weights_only=True yapti.
# pyannote/whisperx alignment modelleri omegaconf objeleri iceriyor.
# Iki katmanli cozum:
#   1) torch.serialization.add_safe_globals ile omegaconf classlari allowlist
#   2) torch.load monkey-patch ile weights_only=False zorla
try:
    import torch.serialization as _ts
    _safe_classes = []
    try:
        from omegaconf.listconfig import ListConfig
        from omegaconf.dictconfig import DictConfig
        from omegaconf.base import ContainerMetadata, Metadata
        from omegaconf.nodes import AnyNode
        _safe_classes += [ListConfig, DictConfig, ContainerMetadata, Metadata, AnyNode]
    except Exception:
        pass
    try:
        import collections
        _safe_classes += [
            collections.defaultdict, collections.OrderedDict,
            dict, list, tuple, set, int, float, bool, str, type(None),
        ]
    except Exception:
        pass
    if _safe_classes and hasattr(_ts, "add_safe_globals"):
        _ts.add_safe_globals(_safe_classes)
        print(f"[FreeCaption] {len(_safe_classes)} class safe_globals'a eklendi")
except Exception as _e:
    print(f"[FreeCaption] add_safe_globals atlandi: {_e}")

# Monkey-patch torch.load — modul import edildiginde her cagrida calisir
_original_torch_load = torch.load
def _patched_torch_load(*args, **kwargs):
    kwargs["weights_only"] = False
    return _original_torch_load(*args, **kwargs)
torch.load = _patched_torch_load

# pyannote ve diger modullerin cache'lenmis torch.load referanslarini da degistir
try:
    import sys
    for mod_name, mod in list(sys.modules.items()):
        if mod and any(p in mod_name for p in ("pyannote", "whisperx", "torch")):
            for attr in dir(mod):
                if attr == "load" or attr.endswith("_load"):
                    try:
                        if getattr(mod, attr, None) is _original_torch_load:
                            setattr(mod, attr, _patched_torch_load)
                    except Exception:
                        pass
except Exception:
    pass

from config import (
    WHISPER_MODEL, COMPUTE_TYPE_GPU, COMPUTE_TYPE_CPU,
    BATCH_SIZE, MODEL_CACHE_DIR, FORCE_DEVICE, DISABLE_ALIGNMENT,
)


def _device_and_compute():
    if FORCE_DEVICE == "cpu":
        return "cpu", COMPUTE_TYPE_CPU
    if torch.cuda.is_available():
        return "cuda", COMPUTE_TYPE_GPU
    return "cpu", COMPUTE_TYPE_CPU


class Transcriber:
    """Modelleri tek sefer yükler, ardışık çağrılarda yeniden kullanır."""

    def __init__(self):
        self.device, self.compute_type = _device_and_compute()
        self._whisper = None
        self._align_model = None
        self._align_metadata = None
        self._align_language: Optional[str] = None

    def _build_whisper(self, device: str, compute_type: str):
        if DISABLE_ALIGNMENT:
            # CPU/VDS mode: faster_whisper'i dogrudan kullan (whisperx -> torchaudio
            # DLL bagimligindan kacin)
            from faster_whisper import WhisperModel
            return WhisperModel(
                WHISPER_MODEL,
                device=device,
                compute_type=compute_type,
                download_root=str(MODEL_CACHE_DIR),
            )
        import whisperx
        return whisperx.load_model(
            WHISPER_MODEL,
            device=device,
            compute_type=compute_type,
            download_root=str(MODEL_CACHE_DIR),
        )

    def _load_whisper(self):
        if self._whisper is None:
            try:
                self._whisper = self._build_whisper(self.device, self.compute_type)
            except Exception as e:
                # GPU yuklenemezse (ornek: yeni GPU mimarisi <-> eski ctranslate2,
                # CUDA/cuDNN eksigi) sunucuyu cokertme -> CPU'ya dus.
                if self.device == "cuda":
                    print(
                        f"[FreeCaption] GPU model yuklenemedi ({e}). CPU'ya geciliyor "
                        f"(daha yavas ama calisir).",
                        flush=True,
                    )
                    self.device = "cpu"
                    self.compute_type = COMPUTE_TYPE_CPU
                    self._whisper = self._build_whisper(self.device, self.compute_type)
                else:
                    raise
        return self._whisper

    def _load_aligner(self, language_code: str):
        if self._align_language != language_code:
            import whisperx
            self._align_model, self._align_metadata = whisperx.load_align_model(
                language_code=language_code, device=self.device,
            )
            self._align_language = language_code
        return self._align_model, self._align_metadata

    def transcribe(
        self,
        audio_path: Path,
        language: Optional[str] = None,
        progress: Optional[Callable[[str, float], None]] = None,
    ) -> dict:
        def report(stage: str, pct: float):
            if progress:
                progress(stage, pct)

        # ============ CPU MODE: faster_whisper dogrudan ============
        if DISABLE_ALIGNMENT:
            report("Model yukleniyor", 0.05)
            model = self._load_whisper()  # faster_whisper.WhisperModel
            report(f"Transkripsiyon ({WHISPER_MODEL})", 0.15)
            # word_timestamps=True: max_chars'a gore bolme yapabilmek icin
            # word-level timing'lere ihtiyac var (subtitle._group_words icin)
            segments_iter, info = model.transcribe(
                str(audio_path),
                language=language,
                beam_size=5,
                vad_filter=False,
                word_timestamps=True,
            )
            detected_language = info.language or language or "en"
            segments_list = []
            for s in segments_iter:
                words = []
                if s.words:
                    for w in s.words:
                        words.append({
                            "start": float(w.start),
                            "end": float(w.end),
                            "word": w.word,
                        })
                segments_list.append({
                    "start": float(s.start),
                    "end": float(s.end),
                    "text": s.text.strip(),
                    "words": words,
                })
            report("Tamamlandi", 1.0)
            return {
                "language": detected_language,
                "segments": segments_list,
                "word_segments": [],
            }

        # ============ GPU MODE: whisperx + alignment ============
        import whisperx

        report("Ses yükleniyor", 0.05)
        audio = whisperx.load_audio(str(audio_path))

        report(f"Transkripsiyon ({WHISPER_MODEL})", 0.15)
        model = self._load_whisper()
        result = model.transcribe(
            audio,
            batch_size=BATCH_SIZE,
            language=language,
        )
        detected_language = result.get("language") or language or "en"

        report(f"Hizalama ({detected_language})", 0.65)
        try:
            align_model, metadata = self._load_aligner(detected_language)
            result = whisperx.align(
                result["segments"], align_model, metadata, audio,
                self.device, return_char_alignments=False,
            )
        except Exception as e:
            print(f"[uyari] Hizalama atlandi ({e}). Segment-level timestamp kullanilacak.")

        report("Tamamlandı", 1.0)

        return {
            "language": detected_language,
            "segments": result.get("segments", []),
            "word_segments": result.get("word_segments", []),
        }

    def unload(self):
        self._whisper = None
        self._align_model = None
        self._align_metadata = None
        self._align_language = None
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()


_transcriber: Optional[Transcriber] = None


def get_transcriber() -> Transcriber:
    global _transcriber
    if _transcriber is None:
        _transcriber = Transcriber()
    return _transcriber
