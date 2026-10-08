# Değişiklik Geçmişi

Bu projede yapılan kayda değer değişiklikler bu dosyada belgelenir.

Format [Keep a Changelog](https://keepachangelog.com/tr-TR/1.1.0/) standardını takip eder.
Sürümleme [Semantic Versioning](https://semver.org/lang/tr/) kuralına uyar.

---

## [1.1.3] — 2026-10-08

Teknik bilgisi olmayanlar için sadeleştirme sürümü. Kurulum mantığı v1.1.2 ile aynı; bu sürümde anlatım, rehberler ve küçük düzeltmeler yenilendi.

### Değişenler

- `README.md` baştan düzenlendi: önce "FreeCaption nedir" ve **3 adımda kurulum**, sonra kullanım, gereksinimler ve sık sorulan sorular. Teknik bölümler (ileri düzey kurulum, uzak sunucu, çalışma şeması, katkı) en alta, "Geliştiriciler ve ileri düzey" başlığına taşındı.
- `KURULUM_REHBERI` (md/html) ve `BENI_OKU.txt`: emojili başlıklar, sürüm bilgisi, Premiere 2026 için **Extensions (Legacy)** notu, destek bölümü.
- `autostart_kur.bat`: bloksuz yapıya geçti, Başlangıç klasörü yoksa oluşturuyor, boşluk/Türkçe karakter/parantezli yollarda çalışıyor.
- `landing/index.html`: sürüm v1.1.3, "tek tıkla kurulum" (`KUR.bat`) ve gerçekçi kurulum süresi.
- `RUNBOOK.md`: yerel kurulum bölümü, betik yazım kuralları; kişisel sunucu IP'si kaldırıldı; GitHub'da çalışmayan `{#id}` bağlantıları düzeltildi.
- `CONTRIBUTING.md`, `.github/RELEASE_GUIDE.md`, issue şablonları güncellendi; olmayan `VDS_DEPLOYMENT.md` bağlantıları düzeltildi.

### Eklenenler

- `deploy/README.md` ve `frontend/README.md` — klasörlerin ne işe yaradığı
- `scripts/make_release_zip.ps1` — tek komutla release zip'i

---

## [1.1.2] — 2026-10-08

Kurulum güvenilirliği sürümü. Bir kullanıcı `install.bat`'ın "[1/6] Python kontrol ediliyor..." satırında durup kapandığını bildirdi. Sorun yalnız o kişide değil, **herkesteydi**.

### Kök neden

- `install.bat` içinde bir `if ( ... )` bloğunun içindeki yazıda kaçışsız `)` vardı (`("Add Python to PATH" isaretle)`). `cmd.exe` bloğu o noktada kapatıyor, ardından gelen `pause` ve `exit /b 1` Python bulunsa bile koşulsuz çalışıyordu. Sonuç: kurulum hiçbir hata yazmadan "Press any key to continue" ile bitiyordu. Aynı türden hatalar `cep_kur.bat` içinde de vardı (`(VDS)`, `(winget)...`, `(Sistemde FFmpeg mevcut)`; ayrıca blok içinde `%errorlevel%` yanlış okunuyordu).
- `.bat` dosyaları repoda LF satır sonuyla duruyordu; `cmd.exe` LF'li dosyalarda `goto`/`call :etiket` yapılarını yanlış ayrıştırabiliyor. `.gitattributes` ile CRLF zorunlu kılındı.

### Eklenenler

- `KUR.bat` — tek tıkla kurulum: sunucu + Premiere paneli + sunucuyu başlat
- `install_log.txt` — kurulum kaydı (yardım isterken gönderilir)
- `scripts/get_python.ps1`, `scripts/get_ffmpeg.ps1` — winget yoksa Python 3.12 ve FFmpeg'i doğrudan indirip kurar
- `.gitattributes` — `.bat`/`.vbs`/`.ps1` için CRLF
- `KURULUM_REHBERI.md` / `.html` / `BENI_OKU.txt` — teknik bilgisi olmayanlar için adım adım rehber ve ekran mesajına göre sorun giderme

### Değişenler

- `install.bat` baştan yazıldı (blok yok, etiket tabanlı): Python 3.10-3.12 64-bit'i `py` başlatıcı, PATH ve bilinen klasörlerden bulur; Microsoft Store sahte `python.exe`'sini atlar; yoksa kendi kurar. Her pip adımı 3 kez dener.
- Kurulum öncesi kontroller: zip'ten çıkarılmamış klasör, klasör yolunda Türkçe karakter / OneDrive, boş disk (en az 8 GB), internet.
- Microsoft Visual C++ bileşeni eksikse kurulur (`WinError 126` / DLL hatasının yaygın nedeni).
- GPU: NVIDIA sürücü sürümü denetlenir; CUDA 12.8 → 12.6 → CPU sırasıyla gerçek bir GPU işlemiyle sınanır (eski GPU'larda "kernel image" hatası kurulumda yakalanır). Seçilen mod `.venv/fc_mode.txt` dosyasına yazılır.
- Kurulum sonunda paketler yalnız var mı diye değil, gerçekten `import` edilerek doğrulanır; hata varsa otomatik onarım denenir.
- `start.bat` modu `fc_mode.txt`'den okur, GPU belleği 6 GB altındaysa `medium` modelini seçer, sunucu zaten çalışıyorsa ikinci kez açmaz, hata kodunu gösterir.
- `cep_kur.bat`: kaçışsız parantez hataları giderildi, Premiere açıksa uyarır, CSXS 13/14 izni eklendi, kopyalamayı doğrular, boşluklu kullanıcı adlarında panelin "Sunucu Başlat" tuşu için kısa (8.3) yol yazar.
- `backend/audio.py`: proje klasörüne indirilen `ffmpeg\bin` otomatik bulunur.

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
