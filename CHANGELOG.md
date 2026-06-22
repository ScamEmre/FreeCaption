# Değişiklik Geçmişi

Bu projede yapılan kayda değer değişiklikler bu dosyada belgelenir.

Format [Keep a Changelog](https://keepachangelog.com/tr-TR/1.1.0/) standardını takip eder.
Sürümleme [Semantic Versioning](https://semver.org/lang/tr/) kuralına uyar.

---

## [1.1.1] — 2026-06-22

Yerel sunucuyu kuran/başlatan scriptler repoda eksikti, eklendi. README ve `cep_kur.bat` `install.bat`, `start.bat`, `start_hidden.vbs`, `autostart_kur.bat`'tan bahsediyordu ama bu dosyalar hiç eklenmemişti. Sonuçta panel kuruluyor, backend başlatılamıyor, panelde "Sunucu kapalı" görünüyordu.

### Eklenenler

- `install.bat` — `.venv` kurar, NVIDIA GPU varsa CUDA 12.8 PyTorch (RTX 50 serisi dahil) yoksa CPU sürümü, ardından Whisper/WhisperX/FastAPI ve FFmpeg
- `start.bat` — sunucuyu görünür terminalde başlatır (GPU/CPU modunu kendisi seçer)
- `start_hidden.vbs` — penceresiz başlatma
- `autostart_kur.bat` — açılışta otomatik başlatma kısayolu

### Düzeltmeler

- `cep_kur.bat` artık kuruluma `server_path.txt` bırakıyor; panelin "Sunucu Başlat" tuşu `start.bat`'i kendisi buluyor. Bu tuş eskiden yol hiç ayarlanamadığı için çalışmıyordu.
- GPU modeli yüklenemediğinde (yeni GPU ↔ eski ctranslate2) backend çökmek yerine CPU'ya düşüyor.

---

## [1.0.0] — 2026-05-17

**FreeCaption v1.0 — İlk kararlı sürüm.** Premiere Pro için Türkçe Whisper altyazı eklentisi: CEP UI + Windows VDS deploy + Adobe ExtendScript timeline entegrasyonu.

### Eklenenler — Premiere CEP Eklentisi

- **Tab 1 — Oluştur**: Klip seçimi otomatik tanıma, dil seçimi (99 dil), karakter sınırı (18/22/28/35), timeline konumu (Sekans Başı / İmleç), SRT çıktı yeri seçenekleri
- **Tab 2 — Stil Ver**: Karaoke / Fade / Pop / Type / Bounce animasyonları, font/renk/stroke/shadow/background tam kontrol, PNG sequence export
- **Sunucu kontrol kartı**: ▶ Başlat / 🗑 RAM Temizle / ⏹ Durdur butonları
- **⚙ Sunucu Ayarları**: URL + API Key configurable (lokal veya VDS modu)
- **🔄 Auto-update butonu**: GitHub'tan son sürümü çekip AppData'yı yeniler, panel otomatik reload
- **Çift önizleme**: 16:9 (YouTube) ve 9:16 (Reels/Shorts) toggle, drag handle ile pozisyon ayarı
- **Pozisyon presetleri**: 6 hızlı buton + slider ince ayar + mouse drag
- **Sistem fontları**: PowerShell `SystemFontFamilies` ile Premiere'in gördüğü TÜM yüklü fontlar (datalist + 24 saat cache)

### Eklenenler — Backend (FastAPI)

- **Whisper large-v3** + WhisperX forced alignment (GPU modu, word-level ±20ms)
- **faster-whisper + ctranslate2** doğrudan (CPU/VDS modu, torchaudio DLL bağımlılığını atlatır)
- **API endpoints**: `/api/health`, `/api/upload` (multipart), `/api/clip` (lokal media_path), `/api/job/{id}`, `/api/stream/{id}` (SSE), `/api/unload`, `/api/shutdown`, `/download/{id}/{kind}`
- **CORS preflight muafiyeti** (OPTIONS request auth gerektirmez)
- **X-API-Key auth middleware** (production VDS için)
- **Upload size limit** (`FC_MAX_UPLOAD_MB`, default 500 MB)
- **Akıllı SRT bölme**: word-level varsa `_group_words`, yoksa karakter bazlı orantılı timing dağıtımı
- **JSON output**: word-level timestamp (Tab 2 karaoke senkron için)

### Eklenenler — Windows VDS Deploy

- **install_windows.ps1** (15 adımlı tek tuş kurulum):
  - Python 3.12, Git, FFmpeg, NSSM, Caddy otomatik indirir (winget `--source winget`, msstore certifika bypass)
  - VC++ Redistributable 2015-2022 kurar
  - Venv + PyTorch CPU + faster-whisper + **ctranslate2 4.4.0** (4.5+ Windows DLL uyumsuz) + intel-openmp
  - Whisper medium modeli `.models` klasörüne explicit indirir (NSSM servis context bulabilsin)
  - FreeCaption + FreeCaptionCaddy Windows servisleri (NSSM auto-start)
  - Random API Key üretip ekrana yazar, `.env`'e kaydeder
  - Firewall 80/443 portları açar
  - Domain prompt → Caddy auto-HTTPS (Let's Encrypt) veya IP modu HTTP
- **setup_services.ps1** standalone NSSM servis kurulum
- **deploy/linux/** Ubuntu/Debian alternatifleri (test edilmedi)
- **`.env.example`** template

### Eklenenler — Dokümantasyon

- **README.md** — kapsamlı kurulum (lokal + VDS) + kullanım rehberi
- **landing/index.html** — emrekazak.com için modern dark theme tanıtım sayfası
- **landing/og-image.png** — 1200×630 social preview görseli
- **01_Rehberler_ve_Raporlar/VDS_DEPLOYMENT.md** — Windows VDS detaylı kılavuz
- **landing/README.md** — emrekazak.com + GitHub Pages deploy talimatları

### Düzeltmeler — Geliştirme Sırasında

- ASCII-safe install script (PowerShell UTF-8 BOM Türkçe karakter parse)
- winget msstore certifika hatası → `--source winget` zorlama
- Frontend StaticFiles mount opsiyonel (klasör yoksa API-only mod)
- Plugin URL otomatik `http://` prefix ekleme (file:// origin kaymasını engeller)
- PyTorch DLL search path patch (NSSM servis context'inde `ctranslate2.libs`, `intel_openmp\bin`, `torch\lib`)
- CPU modunda whisperx import edilmiyor (torchaudio `_torchaudio.dll` DLL bağımlılığını atlatır)
- `--mixed-context` CEP manifest flag (Node.js `require()` her yerde çalışsın)
- `word_timestamps=True` faster_whisper'a geçildi (segment-level uzun cümle bölünmesi)

### Bilinen Kısıtlamalar

- **CPU modu hız**: medium model + 4 vCPU = ~2x realtime (18 sn ses → ~30 sn işlem)
- **WhisperX alignment** CPU modunda devre dışı (saniyeler yerine dakikalar sürüyor)
- **Konuşmacı ayırma** (diarization) eklenmedi
- **Linux VDS install script** henüz test edilmedi
- Caddy auto-HTTPS için **port 80 dışarıdan açık** olmalı (ACME challenge)

---

## Sürüm Numaralandırma

- **MAJOR** (1.0.0 → 2.0.0): Geriye dönük uyumsuz değişiklikler
- **MINOR** (1.0.0 → 1.1.0): Yeni özellikler, geriye dönük uyumlu
- **PATCH** (1.0.0 → 1.0.1): Hata düzeltmeleri, geriye dönük uyumlu
