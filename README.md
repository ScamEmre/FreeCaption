<div align="center">

<img src="landing/og-image.png" alt="FreeCaption — Premiere Pro için Türkçe Whisper Altyazı" width="780"/>

# FreeCaption

**Adobe Premiere Pro için açık kaynak, yerel, sınırsız Türkçe & İngilizce otomatik altyazı eklentisi**

[![Sürüm](https://img.shields.io/badge/s%C3%BCr%C3%BCm-1.1.2-2ea44f)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)
[![Premiere Pro](https://img.shields.io/badge/Premiere%20Pro-23%E2%80%9327-9999ff)](#kurulum)
[![GPU](https://img.shields.io/badge/CUDA-NVIDIA%20RTX-76b900)](#sistem-gereksinimleri)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS-555555)](#kurulum)
[![Windows VDS](https://img.shields.io/badge/VDS-Windows%20Ready-06b6d4)](#-uzak-sunucu-vds-kurulumu--opsiyonel)
[![Made in Türkiye](https://img.shields.io/badge/Made%20in-T%C3%BCrkiye-e30a17)](#)
[![Kahve ısmarla](https://img.shields.io/badge/Kahve%20%C4%B1smarla-destek-FFDD00?logo=buymeacoffee&logoColor=000000)](https://buymeacoffee.com/emrekazak)

*Konuşmayı kelime kelime altyazıya çevirir. Bilgisayarında çalışır, videon dışarı çıkmaz.*

[🌐 Tanıtım](landing/index.html) · [🚀 Kurulum Rehberi](KURULUM_REHBERI.md) · [Kurulum özeti](#kurulum) · [Nasıl Çalışır](#nasıl-çalışır) · [VDS Kurulumu](#-uzak-sunucu-vds-kurulumu--opsiyonel) · [🛠 Runbook (Sorun Giderme)](RUNBOOK.md) · [SSS](#sss) · [Geliştirici](#geliştirici)

</div>

---

> ☕ FreeCaption ücretsiz ve açık kaynak. İşine yaradıysa bir [kahve ısmarlayabilirsin](https://buymeacoffee.com/emrekazak). Zorunlu değil, geliştirmeye ayrılan zamanı destekler.

> 🆕 **v1.1.2 (8 Ekim 2026):** Kurulum bazı bilgisayarlarda "Python kontrol ediliyor" satırında sessizce duruyordu. Düzeltildi. Artık tek dosya yetiyor: **`KUR.bat`**. [Ayrıntılar](CHANGELOG.md)

## Neden FreeCaption?

Premiere Pro'da Türkçe altyazıyı elle yazmak saatler alır. Premiere'in kendi konuşma-metin özelliği Türkçede işe yaramıyor, ücretli eklentiler ise aylık abonelik ister ve videonu internete yükler.

FreeCaption bu işi **ücretsiz, açık kaynak ve tamamen kendi bilgisayarında** yapar.

| | FreeCaption | Ücretli bulut eklentileri | Premiere yerleşik |
|---|:---:|:---:|:---:|
| Türkçe destek | ✅ | ✅ | ❌ |
| Açık kaynak | ✅ | ❌ | ❌ |
| Videon bilgisayarında kalır | ✅ | ❌ | ❌ |
| Ücret | **Ücretsiz** | Abonelik | Creative Cloud içinde |
| Dosya boyutu limiti | Yok | Var | Var |
| Kelime kelime senkron | ✅ | Değişir | ❌ |
| Aylık kullanım limiti | Yok | Kotalı | Sınırlı |

---

## Özellikler

- 🎯 **Word-level alignment** — Whisper large-v3 + WhisperX forced alignment ile ±20ms hassasiyet
- 🇹🇷 **Türkçe & İngilizce** + otomatik dil tespit (97 dil destekli teknoloji)
- 🚀 **GPU hızlandırma** — NVIDIA RTX 20/30/40/50 serisi (CUDA 12.8). GPU yoksa CPU ile de çalışır
- 🔒 **Tamamen yerel** — videolarınız sunucuya gönderilmez, gizliliğiniz korunur
- ♾️ **Sınırsız kullanım** — hiçbir API kotası, aylık limit, dosya boyutu sınırı yok
- 🎨 **Tek satır altyazı** — karakter sınırı + akıllı tolerans, Premiere'de 2 satıra wrap olmaz
- 📥 **Otomatik timeline entegrasyonu** — caption track yoksa oluşturur, SRT'yi yerleştirir
- ⚡ **İstersen sessiz arka plan** — `autostart_kur.bat` ile bilgisayar açılınca kendiliğinden başlar, pencere açılmaz
- 🧰 **Tek tık kurulum** — `KUR.bat` Python'u, bileşenleri, FFmpeg'i ve paneli kendisi kurar

---

## Kurulum

> **Teknik bilgin yoksa:** adım adım, ekran mesajlarıyla birlikte hazırlanmış **[Kurulum Rehberi](KURULUM_REHBERI.md)** dosyasını izle. Aşağıdaki özet, rehberin kısa halidir.

### Sistem Gereksinimleri

- **Windows 10/11, 64 bit** (yerel sunucu) **veya macOS** (panel istemcisi — uzak VDS sunucusuna bağlanır)
- **Adobe Premiere Pro 2023 (23.0) ve üstü** — 2026 (26.x) dahil. Windows ve macOS
- **En az 8 GB boş disk alanı** ve kurulum sırasında internet
- **Python 3.10-3.12** — yoksa `install.bat` Python 3.12'yi kendisi kurar, elle kurman gerekmez
- **FFmpeg** — kurulum sırasında otomatik yüklenir
- **NVIDIA GPU (opsiyonel ama önerilen)** — RTX 20/30/40/50 serisi
  - GPU varsa **GPU modu**: hızlı, `large-v3` modeli, kelime kelime senkron
  - GPU yoksa (ya da sürücü eskiyse) **CPU modu**: 5-10x daha yavaş, `medium` modeli; yine de çalışır. Mod kurulumda otomatik seçilir.

### En kolay yol: KUR.bat

1. Zip'i **önce klasöre çıkar** (sağ tık → *Tümünü ayıkla*). Klasör `C:\FreeCaption` gibi sade olsun: yolda Türkçe karakter ve OneDrive olmasın. Zip'in içinden çalıştırma.
2. **`KUR.bat`** dosyasına çift tıkla. Windows "Bilinmeyen yayımcı" ekranı çıkarırsa *Ek bilgi → Yine de çalıştır*.
3. Sunucu kurulumu, Premiere paneli ve sunucu başlatma sırayla otomatik yapılır (10-25 dk). **"HER SEY HAZIR!"** yazısını bekle.
4. Premiere Pro'yu kapatıp yeniden aç → **Window → Extensions → FreeCaption**. Premiere 2026'da paneller **Extensions (Legacy)** başlığı altında da görünebilir, orada ara.

Ayrıntılar ve ekranda görülen hata mesajlarının çözümleri: **[KURULUM_REHBERI.md](KURULUM_REHBERI.md)** (tarayıcıda okumak için `KURULUM_REHBERI.html`).

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

> **🍎 macOS notu:** Yerel Python sunucusu şu an yalnız **Windows/Linux**'ta çalışır. macOS'ta paneli kurduktan sonra **Uzak Sunucu (VDS)** moduyla bir Windows/Linux sunucusuna bağlanın (aşağıdaki [VDS Kurulumu](#-uzak-sunucu-vds-kurulumu--opsiyonel)).

---

## 🌐 Uzak Sunucu (VDS) Kurulumu — Opsiyonel

Birden fazla kişi kullanacaksa veya ekibin için merkezi bir Whisper sunucusu istiyorsan: VDS'ye **tek tuşla** kur, panelden URL + API Key ile bağlan.

### VDS Önkoşulları

- Windows Server 2019/2022 (Türk VDS sağlayıcı + dedicated CPU önerilir)
- 4+ dedicated core, 8 GB RAM, 25 GB disk
- RDP + admin PowerShell erişimi

### Tek Tuşla Kurulum (PowerShell ADMIN)

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

### Premiere Panel'i Sunucuya Bağla

Panel'de **⚙ Sunucu Ayarları** butonu:
- URL: `http://<VDS_IP>` veya `https://api.YOURDOMAIN.com`
- API Key: install script'in verdiği random key (kayıtlı: `C:\FreeCaption\.env`)

Health badge yeşil olunca tamam — transcribe artık sunucuda çalışır.

> Detaylı VDS kılavuzu: [01_Rehberler_ve_Raporlar/VDS_DEPLOYMENT.md](../../01_Rehberler_ve_Raporlar/VDS_DEPLOYMENT.md)

---

## Nasıl Çalışır?

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

### Bileşenler

- **`backend/`** — Python FastAPI sunucusu, Whisper + WhisperX motoru
- **`cep-plugin/`** — Premiere CEP eklentisi, ExtendScript ile timeline entegrasyonu
- **`frontend/`** — Standalone web UI (Premiere kurulu olmasa da çalışır)

---

## Kullanım

### Premiere içinden (önerilen)

1. **Window → Extensions → FreeCaption** panelini aç
2. Timeline'da bir klibe tıkla (ses ya da video, fark etmez)
3. Panelin üstündeki durum yazısına bak: **"GPU: NVIDIA ..."** ya da **"CPU modu"** görüyorsan sunucu hazır. **"Sunucu kapalı"** yazıyorsa panelden **Sunucu Başlat**'a bas ya da `start.bat`'ı çalıştır
4. **Karakter sınırı** seç:
   - **20** — TikTok/Reels tarzı çok kısa altyazılar (tek satır kesin)
   - **25** — Dengeli (önerilen, tek satır)
   - **30+** — Geniş, ama büyük font'ta 2 satıra wrap olabilir
5. **Altyazı Üret** tuşuna bas
6. GPU'da 10-30 saniye sonra altyazı **otomatik olarak caption track'e** düşer

### Premiere'siz (standalone web UI)

`start_hidden.vbs` çalışırken tarayıcıda **http://127.0.0.1:7860** aç. Drag&drop ile video/ses dosyası, SRT indir.

---

## Performans

| Senaryo | RTX 4060+ | RTX 3060 | CPU (i5-12400) |
|---|:---:|:---:|:---:|
| 10 saniye ses | ~3 sn | ~5 sn | ~30 sn |
| 1 dakika ses | ~8 sn | ~15 sn | ~3 dk |
| 10 dakika ses | ~45 sn | ~90 sn | ~25 dk |

İlk altyazıda Whisper modeli indirilir (GPU modunda yaklaşık 3 GB, CPU modunda daha küçük). Bu **bir kerelik**. Süreler yaklaşıktır, bilgisayarına göre değişir.

---

## SSS

**S: Videolarım bir yere upload mu ediliyor?**
A: Hayır. Tüm işlem bilgisayarında yapılır. İnternet bağlantısı yalnızca ilk Whisper modelini indirmek için gerekir.

**S: Aylık kullanım limiti var mı?**
A: Yok. Tamamen sınırsız.

**S: Premiere kapalıyken çalışır mı?**
A: Evet, `http://127.0.0.1:7860` adresinde web UI var. Drag&drop ile SRT üret.

**S: Hangi Premiere sürümleri desteklenir?**
A: Premiere Pro 2023 (23.0) ve sonrası, 2026 (26.x) dahil. Panel, Premiere 2026'da Window → Extensions (Legacy) altında da çıkabilir.

**S: AMD/Intel GPU desteği?**
A: Şu an sadece NVIDIA CUDA. AMD ROCm desteği yol haritasında.

**S: Adobe bu tür panelleri (CEP) kaldırmıyor mu?**
A: Adobe, CEP'i Premiere 25.6'dan beri "eski" olarak işaretliyor ama 2026 sürümlerinde paneller hâlâ yükleniyor. Yerine gelen UXP olgunlaşınca FreeCaption'ın UXP sürümü de gelecek. Yol haritasında.

**S: Başka diller?**
A: Whisper 99 dil biliyor. Panelde dil seçimi var; ayrıca API'ye `language` parametresiyle istediğin dili verebilirsin.

**S: Kurulum takılırsa ne yapmalıyım?**
A: [Kurulum Rehberi](KURULUM_REHBERI.md)'ndeki **Sorun giderme** tablosuna bak: ekranda gördüğün mesajın çözümü orada. Çözülmezse ekran görüntüsü ve `install_log.txt` dosyasıyla [issue aç](https://github.com/ScamEmre/FreeCaption/issues).

---

## Geliştirici

**Emre Kazak** — [emrekazak.com](https://emrekazak.com) · [GitHub](https://github.com/emrekazak)

Premiere'de Türkçe altyazı için ücretli ve kapalı kaynak çözümler Türk video editörlerine pahalıya geliyordu. FreeCaption, bunun yerine **açık kaynak, yerel ve sınırsız** bir seçenek olsun diye başladı.

### Katkıda Bulunanlar

Projeyi daha iyi hale getiren herkese teşekkürler 🙏

- **[@CeroWalker](https://github.com/CeroWalker)** — Projeyi forklayıp **macOS desteği**, UTF-8 encoding düzeltmesi (CEP ↔ ExtendScript, Türkçe karakter sorunu), FFmpeg otomatik kurulum (winget / Homebrew) ve Linux VDS script iyileştirmelerini ekledi. ([v1.1.0](https://github.com/ScamEmre/FreeCaption/releases/tag/v1.1.0))

---

## Katkıda Bulun

Pull request'ler memnuniyetle karşılanır. Büyük değişiklikler için önce bir [issue](https://github.com/ScamEmre/FreeCaption/issues) açıp konuşalım.

Detaylı rehber: [CONTRIBUTING.md](CONTRIBUTING.md) · Değişiklik geçmişi: [CHANGELOG.md](CHANGELOG.md) · Sorun giderme + yeni VDS kurulum: [RUNBOOK.md](RUNBOOK.md)

### Roadmap

- [x] **macOS Premiere desteği** (CEP panel + VDS modu) — [@CeroWalker](https://github.com/CeroWalker) katkısı 🎉
- [ ] AMD GPU (ROCm) desteği
- [ ] macOS yerel sunucu (native binary)
- [ ] Otomatik altyazı stilleri (font, renk, konum) — Premiere caption preset
- [ ] Çoklu konuşmacı ayrımı (diarization, WhisperX `--diarize`)
- [ ] Konfigürasyon paneli (özel modeller, custom prompts)
- [ ] UXP sürümü (Adobe'nin UXP caption API'si olgunlaşınca)

---

## Teşekkürler

Bu proje şu açık kaynak araçlar üzerine inşa edildi:

- [OpenAI Whisper](https://github.com/openai/whisper) — temel ASR modeli
- [WhisperX (m-bain)](https://github.com/m-bain/whisperX) — word-level forced alignment
- [faster-whisper (SYSTRAN)](https://github.com/SYSTRAN/faster-whisper) — 4x hızlı Whisper
- [Adobe-CEP/Samples](https://github.com/Adobe-CEP/Samples) — `createCaptionTrack` referans implementasyonu
- [PyTorch](https://pytorch.org/) — model çalıştırma motoru
- [FastAPI](https://fastapi.tiangolo.com/) — Python web framework

---

## Lisans

[MIT](LICENSE.md) — özgürce kullan, değiştir, dağıt. Sadece telif bildirimini koru.

---

<div align="center">

**Beğendiysen ⭐ ver, işine yaradıysa paylaş. ☕ [Bir kahve de ısmarlayabilirsin.](https://buymeacoffee.com/emrekazak)**

[emrekazak.com](https://emrekazak.com) · Made with ❤️ in Türkiye

</div>
