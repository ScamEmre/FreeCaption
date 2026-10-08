<div align="center">

<img src="landing/og-image.png" alt="FreeCaption — Premiere Pro için Türkçe Whisper Altyazı" width="780"/>

# FreeCaption

**Adobe Premiere Pro için açık kaynak, yerel, sınırsız Türkçe & İngilizce otomatik altyazı eklentisi**

[![Sürüm](https://img.shields.io/badge/s%C3%BCr%C3%BCm-1.1.3-2ea44f)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)
[![Premiere Pro](https://img.shields.io/badge/Premiere%20Pro-23%E2%80%9327-9999ff)](#nasil-kurulur)
[![GPU](https://img.shields.io/badge/CUDA-NVIDIA%20RTX-76b900)](#gereksinimler)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS-555555)](#nasil-kurulur)
[![Windows VDS](https://img.shields.io/badge/VDS-Windows%20Ready-06b6d4)](#uzak-sunucu)
[![Made in Türkiye](https://img.shields.io/badge/Made%20in-T%C3%BCrkiye-e30a17)](#)
[![Kahve ısmarla](https://img.shields.io/badge/Kahve%20%C4%B1smarla-destek-FFDD00?logo=buymeacoffee&logoColor=000000)](https://buymeacoffee.com/emrekazak)

*Konuşmayı kelime kelime altyazıya çevirir. Bilgisayarında çalışır, videon dışarı çıkmaz.*

[🌐 Tanıtım](landing/index.html) · [🚀 Nasıl kurulur](#nasil-kurulur) · [🎬 Nasıl kullanılır](#nasil-kullanilir) · [❓ SSS](#sss) · [🆘 Takıldım](#takildim) · [🧑‍💻 Geliştiriciler](#gelistiriciler)

</div>

---

<a id="nedir"></a>

## 👋 FreeCaption nedir?

Premiere Pro'da videodaki konuşmayı dinleyip **Türkçe altyazıyı kendisi yazan** ücretsiz bir eklenti. Tek tuşla altyazıyı zaman çizelgesine yerleştirir. Videon internete yüklenmez, her şey **kendi bilgisayarında** olur.

> ☕ FreeCaption ücretsiz ve açık kaynak. İşine yaradıysa bir [kahve ısmarlayabilirsin](https://buymeacoffee.com/emrekazak). Zorunlu değil, geliştirmeye ayrılan zamanı destekler.

> 🆕 **v1.1.3 (8 Ekim 2026):** Kurulum bazı bilgisayarlarda "Python kontrol ediliyor" satırında sessizce duruyordu, düzeltildi. Artık tek dosya yetiyor: **`KUR.bat`**. [Neler değişti?](CHANGELOG.md)

---

<a id="nasil-kurulur"></a>

## 🚀 Nasıl kurulur? (3 adım)

**⬇ [FreeCaption'ı indir (son sürüm)](https://github.com/ScamEmre/FreeCaption/releases/latest)** sayfasından `FreeCaption-v1.1.3.zip` dosyasını al.

1. **Zip'i klasöre çıkar.** Dosyaya sağ tıkla, **Tümünü ayıkla**. Klasör olarak `C:\FreeCaption` iyi bir seçim. Zip'in içinden çalıştırma, önce çıkar.
2. **`KUR.bat` dosyasına çift tıkla.** Mavi "Windows korumalı" ekranı çıkarsa **Ek bilgi**, sonra **Yine de çalıştır** de. Siyah pencere kendi kendine ilerler (10-25 dakika). Pencereyi kapatma, **"HER SEY HAZIR!"** yazısını bekle.
3. **Premiere Pro'yu kapatıp yeniden aç.** Üst menüden **Window > Extensions > FreeCaption** paneli açılır. Menüde yoksa **Extensions (Legacy)** altına bak: Adobe, bu tür paneli Premiere 2026'da oraya koyabiliyor.

Hepsi bu. Python, FFmpeg ve yapay zeka bileşenleri kurulumda **otomatik** yüklenir, senin bir şey indirmene gerek yok.

📖 Resimsiz ama adım adım, ekranda çıkan her hata mesajının çözümüyle: **[Kurulum Rehberi](KURULUM_REHBERI.md)** (tarayıcıda okumak için `KURULUM_REHBERI.html`).

---

<a id="neler-yapar"></a>

## ✨ Neler yapabiliyor?

- 🎯 **Kelime kelime senkron:** Altyazı, konuşmayla tam zamanında çıkar
- 🇹🇷 **Türkçe ve İngilizce** (ve 99 dil), dili kendisi tanıyabilir
- 🔒 **Videon bilgisayarında kalır:** Hiçbir yere yüklenmez
- ♾️ **Sınırsız ve ücretsiz:** Aylık limit, dosya boyutu sınırı, abonelik yok
- 🎨 **Tek satır altyazı:** Karakter sınırını sen seçersin, Premiere'de iki satıra taşmaz
- 📥 **Otomatik yerleştirme:** Altyazı kanalı yoksa oluşturur, altyazıyı oraya koyar
- 🚀 **Hızlı:** NVIDIA ekran kartı varsa çok hızlı. Yoksa daha yavaş ama yine çalışır
- 🧰 **Tek tık kurulum:** `KUR.bat` her şeyi kendisi halleder

| | FreeCaption | Ücretli bulut eklentileri | Premiere yerleşik |
|---|:---:|:---:|:---:|
| Türkçe destek | ✅ | ✅ | ❌ |
| Açık kaynak | ✅ | ❌ | ❌ |
| Videon bilgisayarında kalır | ✅ | ❌ | ❌ |
| Ücret | **Ücretsiz** | Abonelik | Creative Cloud içinde |
| Dosya boyutu limiti | Yok | Var | Var |
| Kelime kelime senkron | ✅ | Değişir | ❌ |

---

<a id="nasil-kullanilir"></a>

## 🎬 Nasıl kullanılır?

1. **Sunucuyu aç.** `KUR.bat` bittiğinde kendiliğinden açılır. Sonraki günlerde bilgisayarı açınca `C:\FreeCaption` içindeki **`start.bat`**'a çift tıkla. Açılan siyah pencere **açık kalsın** (küçültebilirsin).
2. Premiere'de **Window > Extensions > FreeCaption** panelini aç.
3. Panelin üstünde **"GPU: ..."** ya da **"CPU modu"** yazıyorsa her şey hazır. **"Sunucu kapalı"** yazıyorsa panelden **Sunucu Başlat**'a bas ya da `start.bat`'ı çalıştır.
4. Zaman çizelgesinde altyazısını istediğin klibe tıkla (ses ya da video).
5. **Karakter sınırını** seç. 25 dengeli, tek satırlık bir seçim. 20 kısa videolar (Reels, TikTok) için. 30 ve üstü büyük yazıda iki satıra taşabilir.
6. **Altyazı Üret** düğmesine bas. Altyazı kısa süre sonra otomatik olarak altyazı kanalına yerleşir.

> 💡 **İlk deneme için** 30 saniyelik kısa bir klip seç. İlk altyazıda yapay zeka modeli bir kereliğine indirilir, bu yüzden biraz bekleyebilir.

**Her açılışta kendiliğinden başlasın istersen:** `autostart_kur.bat` dosyasına bir kez çift tıkla. Geri almak için `Win+R` yaz, `shell:startup` yaz, açılan klasörde FreeCaption kısayolunu sil.

**Premiere olmadan da kullanabilirsin:** Sunucu açıkken tarayıcıda **http://127.0.0.1:7860** adresini aç, videoyu sürükle bırak, altyazı dosyasını (SRT) indir.

---

<a id="gereksinimler"></a>

## 📋 Bilgisayarında bunlar olmalı

- **Windows 10 veya 11** (64 bit)
- **Adobe Premiere Pro 2023 (23.0) ve üstü**, 2026 (26.x) dahil
- **En az 8 GB boş disk alanı** ve kurulum sırasında internet
- **NVIDIA ekran kartı şart değil.** Varsa altyazı çok daha hızlı üretilir (RTX 20/30/40/50 serisi). Yoksa **CPU modu** kullanılır: 5-10 kat daha yavaş ama çalışır. Hangisinin kullanılacağını kurulum kendisi seçer.
- Python ve FFmpeg'i **kendin kurmana gerek yok**, kurulum halleder.
- **Mac kullanıyorsan:** Mac'te yerel sunucu çalışmıyor. Paneli kurup uzak bir sunucuya bağlanabilirsin, ayrıntı aşağıdaki [Geliştiriciler](#gelistiriciler) bölümünde.

---

<a id="sss"></a>

## ❓ Sık sorulan sorular

**Videolarım bir yere yükleniyor mu?**
Hayır. Her şey bilgisayarında olur. İnternet yalnızca kurulumda ve ilk model indirmesinde gerekir.

**Aylık kullanım limiti var mı?**
Yok. Tamamen sınırsız ve ücretsiz.

**Ekran kartım yok, çalışır mı?**
Evet, CPU modunda çalışır. Sadece daha yavaştır. Ekran kartın varsa ve yine CPU modundaysa sürücünü [nvidia.com/drivers](https://www.nvidia.com/drivers) adresinden güncelle, sonra `KUR.bat`'ı yeniden çalıştır.

**Kurulum takılırsa ne yapmalıyım?**
[Kurulum Rehberi](KURULUM_REHBERI.md)'ndeki **Sorun giderme** tablosuna bak. Ekranda gördüğün mesajın çözümü orada. `KUR.bat`'ı **tekrar çalıştırmak** çoğu zaman yeter, kaldığı yerden devam eder.

**Premiere kapalıyken çalışır mı?**
Evet, tarayıcıda `http://127.0.0.1:7860` adresinde web arayüzü var.

**Hangi Premiere sürümleri destekleniyor?**
Premiere Pro 2023 (23.0) ve sonrası, 2026 (26.x) dahil. Panel 2026'da **Window > Extensions (Legacy)** altında da çıkabilir.

**Adobe bu tür panelleri kaldırmıyor mu?**
Adobe, bu panel türünü (CEP) Premiere 25.6'dan beri "eski" olarak işaretliyor ama 2026 sürümlerinde paneller hâlâ yükleniyor. Yerine gelen UXP olgunlaşınca FreeCaption'ın UXP sürümü de gelecek.

**Başka diller?**
Whisper 99 dil biliyor. Panelde dil seçimi var.

**AMD ya da Intel ekran kartı?**
Şimdilik yalnızca NVIDIA hızlanıyor. AMD desteği yol haritasında. Diğer kartlarda CPU modu kullanılır.

---

<a id="takildim"></a>

## 🆘 Takıldım, ne yapmalıyım?

1. [Kurulum Rehberi](KURULUM_REHBERI.md)'nde ekranda gördüğün hata mesajını ara, çözümü yazıyor.
2. Olmadıysa [yeni bir konu aç](https://github.com/ScamEmre/FreeCaption/issues/new/choose) ve şunları ekle: hata ekranının görüntüsü, FreeCaption klasöründeki **`install_log.txt`** dosyası, Windows sürümün ve ekran kartın.

---

<a id="gelistiriciler"></a>

## 🧑‍💻 Geliştiriciler ve ileri düzey

Aşağısı teknik bilgisi olanlar içindir. Sıradan kullanım için yukarıdakiler yeterli.

### İleri düzey: adım adım kurulum

`KUR.bat` aşağıdaki üç dosyayı sırayla çalıştırır. İstersen tek tek de çalıştırabilirsin.

**Kaynak kodu al:**

```bash
git clone https://github.com/ScamEmre/FreeCaption.git
cd FreeCaption
```

veya **Code → Download ZIP** olarak indir ve klasöre çıkar.

**1) `install.bat` — sunucu kurulumu (10-25 dk).** Sırayla:
1. Disk alanı, klasör yolu ve internet kontrolü yapar
2. Python 3.10-3.12 (64-bit) yoksa **Python 3.12'yi kendisi kurar** (`winget`, olmazsa python.org)
3. Sanal ortam (`.venv`) oluşturur
4. GPU'yu tespit eder: NVIDIA GPU varsa CUDA 12.8 PyTorch (~3 GB), yoksa ya da GPU test edilemezse **CPU moduna** geçer
5. Whisper + WhisperX + FastAPI bileşenlerini yükler
6. FFmpeg yoksa kurar
7. Kurulumu doğrular; sonunda `KURULUM TAMAM. Mod: gpu` (veya `cpu`) yazar

Her çalıştırmada kurulum kaydı `install_log.txt` dosyasına yazılır; sorun bildirirken bu dosyayı gönder. Hata olursa `install.bat`'ı tekrar çalıştırmak kaldığı yerden devam eder.

**2) `cep_kur.bat` — Premiere paneli (yönetici izni gerekmez).**
- **Windows:** CEP debug modunu açar ve paneli `%APPDATA%\Adobe\CEP\extensions\FreeCaption` klasörüne kopyalar.
- **macOS:** Terminal'de `chmod +x cep_kur.sh && ./cep_kur.sh` çalıştır — CEP debug modunu açar, plugin'i `~/Library/Application Support/Adobe/CEP/extensions/FreeCaption` klasörüne kopyalar ve gerekirse FFmpeg'i Homebrew ile kurar.

**3) `start.bat` — sunucuyu başlat.** Siyah bir pencerede sunucu açılır; **pencere açık kalmalı** (küçültebilirsin). İlk altyazıda Whisper modeli indirilir (1-3 GB).

Sonra Premiere'i yeniden başlat ve **Window → Extensions → FreeCaption** menüsünden paneli aç. Menüde yoksa **Extensions (Legacy)** altına bak. Adobe, eski tip paneller için 2025'ten beri bu başlığı kullanıyor.

**Sonraki kullanımlar:** bilgisayarı açınca `start.bat`'a çift tıkla. Her açılışta kendiliğinden başlasın istersen `autostart_kur.bat` çalıştır (kaldırmak için `Win+R` → `shell:startup` → FreeCaption kısayolunu sil).

> **Veya:** Panel üzerindeki **Sunucu Başlat** butonu da sunucuyu başlatır.

> **🍎 macOS notu:** Yerel Python sunucusu şu an yalnız **Windows/Linux**'ta çalışır. macOS'ta paneli kurduktan sonra **Uzak Sunucu (VDS)** moduyla bir Windows/Linux sunucusuna bağlanın (aşağıdaki [VDS Kurulumu](#uzak-sunucu)).

<a id="uzak-sunucu"></a>

### 🌐 Uzak Sunucu (VDS) Kurulumu — Opsiyonel

Birden fazla kişi kullanacaksa veya ekibin için merkezi bir Whisper sunucusu istiyorsan: VDS'ye **tek tuşla** kur, panelden URL + API Key ile bağlan.

#### VDS Önkoşulları

- Windows Server 2019/2022 (Türk VDS sağlayıcı + dedicated CPU önerilir)
- 4+ dedicated core, 8 GB RAM, 25 GB disk
- RDP + admin PowerShell erişimi

#### Tek Tuşla Kurulum (PowerShell ADMIN)

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
$u = "https://raw.githubusercontent.com/ScamEmre/FreeCaption/HEAD/deploy/windows/install_windows.ps1"
Invoke-WebRequest $u -OutFile "$env:TEMP\install.ps1" -UseBasicParsing
& "$env:TEMP\install.ps1"
```

Script otomatik:
- Python 3.12, Git, FFmpeg, NSSM, Caddy indirir
- Microsoft Visual C++ Redistributable kurar
- Venv + PyTorch CPU + faster_whisper + ctranslate2 4.4.0 + intel-openmp yükler
- Whisper medium modelini ön-yükler (1.5 GB)
- 2 Windows servisi kurar (FreeCaption API + Caddy proxy, auto-start)
- Firewall 80/443 açar
- Random API Key üretir, ekrana yazar

Toplam: ~15 dakika, sıfırdan production-ready.

#### Premiere Panel'i Sunucuya Bağla

Panel'de **⚙ Sunucu Ayarları** butonu:
- URL: `http://<VDS_IP>` veya `https://api.YOURDOMAIN.com`
- API Key: install script'in verdiği random key (kayıtlı: `C:\FreeCaption\.env`)

Health badge yeşil olunca tamam — transcribe artık sunucuda çalışır.

> Detaylı VDS kılavuzu ve sorun giderme: [RUNBOOK.md](RUNBOOK.md#yeni-windows-11-vds-kurulumu)

### Nasıl Çalışır?

```
┌──────────────────────────────────────────────┐
│  Adobe Premiere Pro                          │
│                                              │
│  Window → Extensions → FreeCaption Panel       │
│  • Klibi seç                                 │
│  • Karakter sınırı belirle (örn. 25)         │
│  • "Altyazı Üret" tuşu                       │
└────────────────────┬─────────────────────────┘
                     │
                     ▼ HTTP (localhost)
       ┌───────────────────────────────┐
       │ Python Sunucu (FastAPI)       │
       │ ↓                             │
       │ FFmpeg ses çıkar (16kHz WAV)  │
       │ ↓                             │
       │ Whisper large-v3 (GPU/CPU)    │
       │ ↓                             │
       │ WhisperX forced alignment     │
       │ ↓                             │
       │ Akıllı SRT oluştur            │
       └────────────────────┬──────────┘
                            │
                            ▼ SRT dosyası
       ┌───────────────────────────────┐
       │ ExtendScript:                 │
       │ seq.createCaptionTrack()      │
       │ → Caption track + altyazı     │
       │   timeline'a otomatik düşer   │
       └───────────────────────────────┘
```

#### Bileşenler

- **`backend/`** — Python FastAPI sunucusu, Whisper + WhisperX motoru
- **`cep-plugin/`** — Premiere CEP eklentisi, ExtendScript ile timeline entegrasyonu
- **`frontend/`** — Standalone web UI (Premiere kurulu olmasa da çalışır)

### Performans

| Senaryo | RTX 4060+ | RTX 3060 | CPU (i5-12400) |
|---|:---:|:---:|:---:|
| 10 saniye ses | ~3 sn | ~5 sn | ~30 sn |
| 1 dakika ses | ~8 sn | ~15 sn | ~3 dk |
| 10 dakika ses | ~45 sn | ~90 sn | ~25 dk |

İlk altyazıda Whisper modeli indirilir (GPU modunda yaklaşık 3 GB, CPU modunda daha küçük). Bu **bir kerelik**. Süreler yaklaşıktır, bilgisayarına göre değişir.

### Geliştirici

**Emre Kazak** — [emrekazak.com](https://emrekazak.com) · [GitHub](https://github.com/emrekazak)

Premiere'de Türkçe altyazı için ücretli ve kapalı kaynak çözümler Türk video editörlerine pahalıya geliyordu. FreeCaption, bunun yerine **açık kaynak, yerel ve sınırsız** bir seçenek olsun diye başladı.

#### Katkıda Bulunanlar

Projeyi daha iyi hale getiren herkese teşekkürler 🙏

- **[@CeroWalker](https://github.com/CeroWalker)** — Projeyi forklayıp **macOS desteği**, UTF-8 encoding düzeltmesi (CEP ↔ ExtendScript, Türkçe karakter sorunu), FFmpeg otomatik kurulum (winget / Homebrew) ve Linux VDS script iyileştirmelerini ekledi. ([v1.1.0](https://github.com/ScamEmre/FreeCaption/releases/tag/v1.1.0))

---

### Katkıda Bulun

Pull request'ler memnuniyetle karşılanır. Büyük değişiklikler için önce bir [issue](https://github.com/ScamEmre/FreeCaption/issues) açıp konuşalım.

Detaylı rehber: [CONTRIBUTING.md](CONTRIBUTING.md) · Değişiklik geçmişi: [CHANGELOG.md](CHANGELOG.md) · Sorun giderme + yeni VDS kurulum: [RUNBOOK.md](RUNBOOK.md)

#### Roadmap

- [x] **macOS Premiere desteği** (CEP panel + VDS modu) — [@CeroWalker](https://github.com/CeroWalker) katkısı 🎉
- [ ] AMD GPU (ROCm) desteği
- [ ] macOS yerel sunucu (native binary)
- [ ] Otomatik altyazı stilleri (font, renk, konum) — Premiere caption preset
- [ ] Çoklu konuşmacı ayrımı (diarization, WhisperX `--diarize`)
- [ ] Konfigürasyon paneli (özel modeller, custom prompts)
- [ ] UXP sürümü (Adobe'nin UXP caption API'si olgunlaşınca)

### Teşekkürler

Bu proje şu açık kaynak araçlar üzerine inşa edildi:

- [OpenAI Whisper](https://github.com/openai/whisper) — temel ASR modeli
- [WhisperX (m-bain)](https://github.com/m-bain/whisperX) — word-level forced alignment
- [faster-whisper (SYSTRAN)](https://github.com/SYSTRAN/faster-whisper) — 4x hızlı Whisper
- [Adobe-CEP/Samples](https://github.com/Adobe-CEP/Samples) — `createCaptionTrack` referans implementasyonu
- [PyTorch](https://pytorch.org/) — model çalıştırma motoru
- [FastAPI](https://fastapi.tiangolo.com/) — Python web framework

### Lisans

[MIT](LICENSE.md) — özgürce kullan, değiştir, dağıt. Sadece telif bildirimini koru.

---

<div align="center">

**Beğendiysen ⭐ ver, işine yaradıysa paylaş. ☕ [Bir kahve de ısmarlayabilirsin.](https://buymeacoffee.com/emrekazak)**

[emrekazak.com](https://emrekazak.com) · Made with ❤️ in Türkiye

</div>
