# 🤝 FreeCaption'a Katkı Sağlama

FreeCaption açık kaynak ve Türkçe altyazıyı Premiere'e getiriyor. Küçük bir yazım hatası düzeltmesi de, yeni bir özellik de projeyi ileri taşır. Katkın için teşekkürler!

## İçindekiler

- [🚀 Hızlı başlangıç](#hizli-baslangic)
- [🐛 Hata bildir](#hata-bildir)
- [✨ Özellik öner](#ozellik-oner)
- [🔀 Kod katkısı (Pull Request)](#pull-request)
- [💻 Geliştirme ortamı](#gelistirme-ortami)
- [🧾 Kod stili](#kod-stili)
- [📝 Commit mesajları](#commit-mesajlari)
- [🕊️ Davranış kuralları](#davranis-kurallari)

---

<a id="hizli-baslangic"></a>

## 🚀 Hızlı Başlangıç

1. Repo'yu **fork** et (sağ üst "Fork")
2. Lokal'e clone:
   ```bash
   git clone https://github.com/<senin-kullanici>/FreeCaption.git
   cd FreeCaption
   ```
3. Yeni branch aç:
   ```bash
   git checkout -b ozellik/yeni-bir-sey
   ```
4. Değişiklik yap, commit at:
   ```bash
   git commit -m "feat: yeni bir özellik açıklaması"
   ```
5. Fork'una push et + Pull Request aç:
   ```bash
   git push origin ozellik/yeni-bir-sey
   ```

---

<a id="hata-bildir"></a>

## 🐛 Hata Bildir

Hata bulduğunda, sorunu **GitHub Issues** üzerinden bildirebilirsin. Daha hızlı çözüm için şu bilgileri ver:

- **Premiere Pro sürümü** (örn. 25.1, 26.0)
- **İşletim sistemi** (Windows 10/11, sürüm numarası)
- **GPU** (NVIDIA / yok) + sürücü sürümü
- **Çalışma modu** (lokal / VDS)
- **Hatanın adım adım nasıl tetiklendiği**
- **Beklenen** ve **gerçekleşen** davranış
- **Log dosyaları** (varsa):
  - Lokal: `backend/output/error.log`
  - VDS: `C:\FreeCaption\logs\backend-stderr.log`
- **Ekran görüntüsü** veya video (tercihen panel + Premiere timeline)
- **Kurulum sorunuysa:** hata ekranının görüntüsü ve FreeCaption klasöründeki **`install_log.txt`** dosyası. Çoğu kurulum hatası bu dosyadan anlaşılır

Issue açarken **🐛 Bug Report** şablonunu kullan, alanları doldur. Kurulum için önce [Kurulum Rehberi](KURULUM_REHBERI.md)'ndeki **Sorun giderme** tablosuna bak, çözüm orada olabilir.

---

<a id="ozellik-oner"></a>

## ✨ Özellik Öner

Yeni bir özellik için:

1. Önce mevcut [issue'lara bak](https://github.com/ScamEmre/FreeCaption/issues) — benzer öneri olabilir
2. Yoksa **✨ Feature Request** şablonuyla yeni issue aç
3. Şunları açıkla:
   - **Problem**: hangi ihtiyacı karşılıyor?
   - **Çözüm önerisi**: nasıl çalışmalı?
   - **Alternatifler**: hangi başka yolları değerlendirdin?
   - **Etki**: kim faydalanır? (örn. "Reels editörleri", "haber kanalları")

---

<a id="pull-request"></a>

## 🔀 Kod Katkısı (Pull Request)

### Önce iletişim

Büyük değişiklikler (>50 satır veya yeni özellik) için **önce issue aç**, planı tartışalım. Küçük düzeltmeler (typo, dökümantasyon) doğrudan PR olabilir.

### PR Süreci

1. **Bir issue'yu hedefle**: PR açıklamasında `Fixes #123` veya `Closes #123` yaz
2. **Branch ismi**: `tip/kısa-açıklama` formatında
   - `feat/cikti-formati-vtt`
   - `fix/canvas-resize-bug`
   - `docs/readme-vds-section`
   - `refactor/subtitle-grouping`
3. **Test et** — değişiklik yaptığın alanı manuel test et:
   - Plugin değişikliği → `cep_kur.bat` çalıştır → Premiere kapat-aç → test. Premiere 2026'da paneli **Window > Extensions (Legacy)** altında ara
   - Backend değişikliği → lokal `start.bat` ile test, VDS'ye deploy etmeden önce
   - `.bat` / kurulum değişikliği → **boşluk, Türkçe karakter ve parantez içeren bir klasörde** dene (örn. `C:\Test Klasörü (1)\FreeCaption`), sonra [betik kurallarına](#betik-kurallari) uyduğundan emin ol
4. **Self-review** — PR'ı açmadan önce kendi diff'ini incele
5. **PR şablonunu doldur** — değişiklik özeti, test adımları, ekran görüntüsü
6. **Code review**'a açık ol — geri bildirim normal, kişisel değil
7. **CI yeşil olsun** (henüz yok ama eklenecek): lint, format, basic test

### PR Kabul Edilirken Beklenenler

✅ Tek odak — bir PR bir konu (büyük PR'lar bölünür)
✅ Backward compatibility (eski kullanıcılar bozulmaz)
✅ Türkçe + İngilizce destekleyici değişikliklerde her iki dile de bakılır
✅ Test edilmiş (lokal Premiere'de en az 1 manuel test)
✅ Dokümante edilmiş (README güncelleme gerekiyorsa)

---

<a id="gelistirme-ortami"></a>

## 💻 Geliştirme Ortamı

### Lokal Geliştirme (GPU önerilir)

**Önkoşullar:**
- Windows 10/11
- Python 3.12 (winget: `Python.Python.3.12`)
- FFmpeg (winget: `Gyan.FFmpeg`)
- Git, GitHub Desktop (opsiyonel)
- Adobe Premiere Pro 2023 (23.0) ve üstü, 2026 (26.x) dahil (CEP eklenti debug için)

**Kurulum (sadece geliştirme için):**

```powershell
git clone https://github.com/ScamEmre/FreeCaption.git
cd FreeCaption

# Sunucu + panel tek seferde (Python'u, PyTorch'u ve FFmpeg'i de kurar)
KUR.bat
```

`KUR.bat` içinde `install.bat` (sunucu), `cep_kur.bat` (panel + CEP debug izni, CSXS 9-14) ve `start.bat` çalışır. Sadece paneli güncellemek istersen `cep_kur.bat` yeter. Elle kurulum istersen `python -m venv .venv`, `pip install -r backend\requirements.txt` yeterli olmaz: PyTorch'un ve ctranslate2'nin sürümleri `install.bat` içinde sabitlenir, oradaki sırayı izle.

**Lokal sunucuyu çalıştır:**

```powershell
cd backend
..\.venv\Scripts\python.exe main.py
# veya:
.venv\Scripts\python.exe -m uvicorn backend.main:app --reload --port 7860
```

**Plugin DevTools:**

`cep-plugin/.debug` dosyası port 8088 atar. Chrome'dan `http://localhost:8088` → panel'i seç → DevTools açılır.

### VDS Geliştirme

VDS'de production backend var. Geliştirme sırasında VDS'yi bozma; lokal'de test et, sonra GitHub'a push, VDS raw URL'den çeker.

---

<a id="kod-stili"></a>

## 🧾 Kod Stili

### Python (backend)

- **Format**: [Black](https://github.com/psf/black) (`black backend/`)
- **Lint**: [Ruff](https://github.com/astral-sh/ruff) (`ruff check backend/`)
- **Tipler**: type hints kullan, `from typing import ...`
- **Docstrings**: kısa Türkçe açıklama, parametreler/return ne işe yarıyor
- **İmport sırası**: stdlib → 3rd party → local (Black otomatik)

### JavaScript / TypeScript (CEP plugin)

- **Format**: 2 space indent, semicolons zorunlu
- **var**: ES3 uyumluluk için `var` kullan (CEP eski Chromium destekler)
- **Yorumlar**: Türkçe, kısa, sadece WHY (not WHAT)
- **Eşleşik dosya**: `cep-plugin/js/app.js` (Tab 1), `cep-plugin/js/style/tab-style.js` (Tab 2)

### CSS

- **CSS Variables** kullan (`:root { --accent: #06b6d4 }`)
- **Dark theme öncelikli** — açık tema sonradan eklenebilir
- **Mobile-first** değil — CEP panel desktop, ama responsive bonus

### ExtendScript (Adobe)

- `cep-plugin/jsx/main.jsx` — **ES3 syntax**, modern özellik YOK
- `let`, `const`, arrow functions, template literals KULLANMA
- `var`, `function () {}`, string concatenation OK
- JSON yok, polyfill (`json2.js`) ile çözüldü
- Hata yönetimi mutlaka `try/catch` ile, return string olarak

<a id="betik-kurallari"></a>

### Windows betikleri (`.bat`, `.vbs`, `.ps1`)

v1.1.1'de `install.bat` bir `if ( ... )` bloğunda kaçışsız `)` içeriyordu ve kurulum **herkeste** sessizce duruyordu. Bu yüzden:

- `.bat` dosyalarında **parantezli `if`/`for` bloğu kullanma**, `goto` ve `call :etiket` kullan. Yazıda parantez gerekiyorsa `^(` ve `^)` yaz.
- Dosyalar **CRLF** satır sonuyla kaydedilir (`.gitattributes` bunu zorlar).
- Betikteki yazılar ASCII (Türkçe karaktersiz) kalır. Konsol kod sayfası bozabilir.
- Her yeni hata mesajı için [Kurulum Rehberi](KURULUM_REHBERI.md)'ndeki sorun giderme tablosuna bir satır ekle.

Ayrıntı: [RUNBOOK, betik yazarken kurallar](RUNBOOK.md#yerel-kurulum).

### PowerShell (deploy)

- `$ErrorActionPreference = "Continue"` (NSSM gibi non-fatal hatalar yutsun)
- ASCII safe (UTF-8 BOM'a rağmen Türkçe karakter parse sorununa girme)
- `Write-Step "N" "Açıklama"` formatı (mevcut helper)

---

<a id="commit-mesajlari"></a>

## 📝 Commit Mesajları

[Conventional Commits](https://www.conventionalcommits.org/tr/v1.0.0/) standardı:

```
<tip>(<kapsam>): <kısa açıklama>

<gövde, opsiyonel — neden bu değişiklik>

<footer, opsiyonel — issue referansı>
```

**Tipler:**

- `feat`: yeni özellik
- `fix`: hata düzeltmesi
- `docs`: sadece dokümantasyon
- `style`: kod stili (formatlama, semicolon)
- `refactor`: davranış değiştirmeyen yeniden yapılandırma
- `perf`: performans iyileştirmesi
- `test`: test ekleme/düzeltme
- `chore`: build, deploy, bağımlılık güncellemesi
- `ci`: CI/CD değişiklikleri

**Örnekler:**

```
feat(plugin): word-level karaoke animasyon eklendi

Tab 2'de yeni "Karaoke" preset'i word-by-word vurgulu animasyon
sunar. WhisperX alignment timing'i kullanarak ±20ms hassasiyetle
çalışır.

Fixes #42
```

```
fix(backend): CPU mode'da ctranslate2 DLL hatası

NSSM servis context'inde ctranslate2.libs klasörü PATH'te değildi.
os.add_dll_directory() ile explicit ekledik.
```

```
docs: VDS deployment kılavuzu eklendi
```

Türkçe / İngilizce karışık kullanılabilir, ama tek commit'te tutarlı ol.

> 💡 GitHub ana sayfasında her dosyanın yanında **o dosyaya dokunan son commit'in mesajı** görünür. Bu yüzden mesajı, repoya ilk kez bakan biri okusa anlayacağı netlikte yaz: `düzeltme` yerine `fix(install): Python bulunsa bile kurulum duruyordu`. Türkçe karakterleri (ş ğ ı ö ü ç) kullanabilirsin.

---

<a id="davranis-kurallari"></a>

## 🕊️ Davranış Kuralları

- **Saygılı ol** — herkesin farklı tecrübe seviyesi var
- **Yapıcı ol** — "yanlış yapıyorsun" yerine "şu yaklaşım daha iyi olur"
- **Spam yok** — kendi reklamı, anlamsız PR, dilenme yasak
- **Telif hakkı saygısı** — başkalarının kodunu MIT uyumlu olmadan kopyalama

Türk yazılım topluluğu küçük, herkes herkesi tanır. Profesyonel ol.

---

## Lisans

Katkın MIT lisansı altında, FreeCaption'ın bir parçası olur. Detay: [LICENSE.md](LICENSE.md)

## ☕ Destek

FreeCaption ücretsiz ve açık kaynak. Katkı yapamıyorsan ama işine yaradıysa [bir kahve ısmarlayabilirsin](https://buymeacoffee.com/emrekazak). Zorunlu değil.

## İletişim

- **Issues**: hata + özellik tartışması için ana kanal
- **Discussions**: GitHub Discussions (açılırsa)
- **E-posta**: emrekazak.com üzerinden
