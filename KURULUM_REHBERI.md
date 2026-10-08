# FreeCaption Kurulum Rehberi

Bu rehber, Premiere Pro'da Türkçe otomatik altyazı yapan FreeCaption eklentisini **sıfırdan, tek başına** kurmanız içindir. Teknik bilgi gerekmez. Adımları sırayla izleyin; her adımın sonunda "Ne görmelisin" satırı var. Gördüğünüz şey farklıysa en alttaki [Sorun giderme](#sorun-giderme) tablosuna bakın.

Toplam süre: 10-25 dakika. Bunun çoğu beklemektir.

## Başlamadan önce

| Gereken | Ayrıntı |
|---|---|
| Bilgisayar | Windows 10 veya Windows 11 (64 bit) |
| Premiere Pro | 2023 (sürüm 23.0) ve üstü, en çok 2027 (sürüm 27.0) |
| Boş disk alanı | En az 8 GB |
| İnternet | Kurulum sırasında gerekli, kesilmemeli |
| Ekran kartı | NVIDIA kartı **olması şart değil** |

Ekran kartına göre iki çalışma biçimi vardır. Kurulum bunu sizin yerinize kendisi seçer:

- **NVIDIA ekran kartı varsa (GPU modu):** Hızlıdır. Daha büyük ve daha doğru bir model kullanılır. Kelimeler ses ile tam eşleşir.
- **NVIDIA ekran kartı yoksa (CPU modu):** Daha yavaştır, daha küçük bir model kullanılır. Yine de çalışır.

Mac kullanıyorsanız bu rehber size göre değil. Mac'te yerel sunucu çalışmaz. Ana sayfadaki [README](README.md) dosyasında "Uzak Sunucu (VDS)" bölümüne bakın.

## Adım 0: Zip dosyasını klasöre çıkarın

Bu adım en sık yapılan hatadır. Zip dosyasını **çıkarmadan** içinden çalıştırırsanız kurulum başlamaz.

1. İndirdiğiniz `FreeCaption.zip` dosyasına sağ tıklayın.
2. **Tümünü ayıkla** (İngilizce Windows'ta **Extract All**) seçeneğine tıklayın.
3. Açılan pencerede **Gözat** düğmesine basın ve diskinizin ana klasörünü (`C:`) seçin. Klasör adı `FreeCaption` olsun. Sonuç şu olmalı: `C:\FreeCaption`
4. **Ayıkla** düğmesine basın.

Klasör yolu için üç kural:

- Yolda Türkçe karakter olmasın (ş, ğ, ı, ö, ü, ç gibi).
- Yol çok uzun olmasın.
- OneDrive veya Masaüstü gibi senkronize edilen bir klasör olmasın.

**Ne görmelisin:** `C:\FreeCaption` klasörünü açınca içinde `KUR.bat`, `install.bat`, `start.bat` gibi dosyalar ve `backend`, `cep-plugin` gibi klasörler görünür.

## Adım 1: KUR.bat dosyasını çalıştırın

1. `C:\FreeCaption` klasöründe **KUR.bat** dosyasına çift tıklayın.
2. Mavi bir pencere çıkıp **"Windows korumalı"** veya **"Bilinmeyen yayımcı"** yazarsa, pencerede **Ek bilgi** yazısına, sonra **Yine de çalıştır** düğmesine tıklayın.

> Bu mavi ekran, internetten inen her `.bat` dosyasında çıkar. Dosyalar açık kaynaktır. Merak ederseniz dosyaya sağ tıklayıp **Birlikte aç, Not Defteri** seçerek içeriğini okuyabilirsiniz.

3. Siyah bir pencere açılır ve yazılar akmaya başlar. Bu normaldir. Kurulum üç aşamada ilerler: **ADIM 1/3, ADIM 2/3, ADIM 3/3**.

Bekleme sırasında dikkat edin:

- Pencereyi **kapatmayın**.
- Bilgisayarı **uyutmayın**. Dizüstü bilgisayarsa şarja takın.
- İndirme çubukları uzun süre kıpırdamıyor gibi görünebilir. Bu normaldir, bekleyin.
- Mavi bir izin penceresi (**Kullanıcı Hesabı Denetimi**) çıkıp değişiklik yapmak için izin isterse **Evet** deyin. Bu sırada Microsoft'un Visual C++ bileşeni kuruluyor olabilir.

### ADIM 1/3: Sunucu kurulumu (en uzun aşama)

Bu aşamada `install.bat` çalışır ve 10-25 dakika sürer. Sırayla şunları yapar:

1. Python 3.12'yi gerekirse **kendisi kurar**. Siz bir şey indirmezsiniz.
2. Programa ait ayrı bir çalışma alanı hazırlar.
3. Ekran kartınıza bakar ve GPU veya CPU modunu seçer. NVIDIA kartta yaklaşık 3 GB'lık büyük bir indirme yapılır.
4. Yapay zeka bileşenlerini yükler.
5. FFmpeg'i (ses ve video okuyan yardımcı program) yükler.
6. Her şeyin çalıştığını kontrol eder.

**Ne görmelisin:** Ekranda `[1/6]`, `[2/6]` ... `[6/6]` satırları sırayla çıkar. Sonunda şu çerçeve görünür:

```
KURULUM TAMAM.   Mod: gpu
```

veya `Mod: cpu`. İkisi de doğrudur.

### ADIM 2/3: Premiere paneli

Bu aşama `cep_kur.bat` ile yapılır, yaklaşık bir dakika sürer. Panel dosyalarını Premiere'in eklenti klasörüne kopyalar ve Adobe'nin eklenti iznini açar. Yönetici izni gerekmez.

**Ne görmelisin:** `[1/4]` ile `[4/4]` arası satırlar ve sonunda `PANEL KURULUMU TAMAM.` yazısı.

### ADIM 3/3: Sunucu otomatik açılır

`start.bat` kendiliğinden **yeni bir siyah pencerede** açılır. Başlığında "FreeCaption sunucusu baslatiliyor" yazar.

- Bu pencereyi **kapatmayın**. Kapanırsa altyazı üretilemez. İsterseniz alt çubuğa **küçültebilirsiniz**.
- İlk altyazıyı üretirken yapay zeka modeli indirilir (1-3 GB). İlk seferde beklemek normaldir.

**Ne görmelisin:** İlk pencerede büyük harflerle **HER SEY HAZIR!** yazısı çıkar.

Şimdi **Premiere Pro'yu tamamen kapatın** (açıksa) ve **yeniden açın**. Premiere paneli ancak yeniden açılınca görür.

## Adım 2: Paneli Premiere'de açın

1. Premiere Pro'yu açın ve herhangi bir proje açın.
2. Üst menüden **Window** (Türkçe Premiere'de **Pencere**) menüsüne tıklayın.
3. **Extensions** (Türkçe: **Uzantılar**) satırına gelin.
4. **FreeCaption** seçeneğine tıklayın.

**Ne görmelisin:** FreeCaption paneli açılır. Panelin sağ üstünde küçük bir durum etiketi vardır:

- **"GPU: ..." (ekran kartı adıyla) veya "CPU modu":** Sunucu çalışıyor, her şey tamam.
- **"Sunucu kapalı":** Siyah pencere kapanmış demektir. Aşağıdaki "Sonraki kullanımlar" kısmına bakın.

## Adım 3: İlk altyazınızı üretin

İlk denemeyi **kısa (yaklaşık 30 saniyelik)** bir klipte yapın.

1. Zaman çizelgesinde (timeline) altyazısını istediğiniz klibe tıklayarak seçin.
2. FreeCaption panelinde **Oluştur** sekmesinde olun.
3. **Konuşma Dili** kutusundan **Türkçe** seçin.
4. **Altyazı Üret** düğmesine basın.
5. Bekleyin. İlk seferde model indirileceği için uzun sürebilir.

**Ne görmelisin:** Birkaç saniye ile birkaç dakika içinde altyazılar zaman çizelgesinde altyazı kanalına (caption track) kendiliğinden yerleşir.

Süre ekran kartına göre değişir. GPU ile 1 dakikalık ses yaklaşık 10-15 saniyede, CPU ile birkaç dakikada işlenir.

## Sonraki kullanımlar

Kurulum **bir kerelik** yapılır. Sonraki günlerde yapacağınız tek şey:

1. Bilgisayarı açın.
2. `C:\FreeCaption` klasöründe **start.bat** dosyasına çift tıklayın.
3. Açılan siyah pencereyi **açık bırakın** (küçültebilirsiniz).
4. Premiere Pro'yu açın.

**Ne görmelisin:** Siyah pencerede "FreeCaption sunucusu baslatiliyor" yazısı. Paneli açınca durum etiketi "GPU" veya "CPU modu" olur.

### Kendiliğinden başlasın istiyorum

Her seferinde `start.bat` açmak istemezseniz `autostart_kur.bat` dosyasına bir kez çift tıklayın. Sunucu bundan sonra bilgisayar her açıldığında arka planda, pencere göstermeden başlar.

Bunu geri almak için: klavyede **Windows tuşu + R** tuşlarına basın, kutuya `shell:startup` yazıp **Tamam** deyin. Açılan klasörde **FreeCaption** kısayolunu silin.

## Kaldırma

1. Klavyede **Windows tuşu + R** tuşlarına basın.
2. Kutuya `%APPDATA%\Adobe\CEP\extensions` yazın ve **Tamam** deyin.
3. Açılan klasördeki **FreeCaption** klasörünü silin (Premiere kapalıyken).
4. `C:\FreeCaption` klasörünü silin.
5. Kendiliğinden başlatmayı açtıysanız yukarıdaki "Kendiliğinden başlasın istiyorum" kısmındaki gibi kısayolu da silin.

## Dosyalar ne işe yarar?

| Dosya | İşi |
|---|---|
| `KUR.bat` | Her şeyi tek tıkla kurar (çoğu kişi yalnızca bunu kullanır) |
| `install.bat` | Yalnızca sunucuyu kurar |
| `cep_kur.bat` | Yalnızca Premiere panelini kurar |
| `start.bat` | Sunucuyu başlatır |
| `autostart_kur.bat` | Sunucuyu bilgisayar açılışında kendiliğinden başlatır |
| `install_log.txt` | Kurulum kaydı. Yardım isterken bunu gönderin |

## Sorun giderme

Ekranda gördüğünüz mesajı aşağıdaki tabloda bulun. Mesajlar ekranda Türkçe karakter olmadan çıkar, tabloda da aynen öyle yazılmıştır.

| Ekranda gördüğünüz | Anlamı ve çözüm |
|---|---|
| `Gerekli dosyalar bulunamadi (backend klasoru yok)` | Zip klasöre çıkarılmamış. Yukarıdaki **Adım 0**'ı uygulayın, sonra KUR.bat'ı klasörün içinden açın. |
| `Uygun Python bulunamadi ve otomatik kurulamadi` | Python elle kurulacak. (1) Tarayıcıda `https://www.python.org/downloads/release/python-31210/` adresini açın. (2) En alttaki **Windows installer (64-bit)** dosyasını indirip açın. (3) Açılan pencerede en alttaki **Add python.exe to PATH** kutusunu işaretleyin, sonra **Install Now** deyin. Bitince KUR.bat'ı yeniden çalıştırın. Python 3.13 veya 3.14 uyumlu değildir ama bilgisayarınızda kalabilir. |
| `FreeCaption sunucusu su an ACIK` | Kurulum, sunucu çalışırken dosyaları değiştiremez. Açık siyah "FreeCaption - Sunucu" penceresini kapatın (ya da bilgisayarı yeniden başlatın), sonra KUR.bat'ı yeniden çalıştırın. |
| `Eski .venv klasoru silinemedi` | FreeCaption sunucu penceresi açık. O siyah pencereyi kapatın veya bilgisayarı yeniden başlatın, sonra KUR.bat'ı yeniden çalıştırın. |
| `Sanal ortam (.venv) olusturulamadi` | Klasör yolu uygun değil, OneDrive içinde ya da antivirüs engelliyor. Klasörü `C:\FreeCaption` konumuna taşıyın, KUR.bat'ı yeniden çalıştırın. |
| `PyTorch kurulamadi` veya `Paket kurulumu basarisiz oldu` | İnternet kesilmiş, disk dolmuş ya da antivirüs/güvenlik duvarı indirmeyi engellemiş olabilir. İnterneti kontrol edip KUR.bat'ı **tekrar** çalıştırın. Kaldığı yerden devam eder. |
| `Diskte yeterli bos yer yok` | En az 8 GB boş yer açın veya klasörü daha boş bir diske taşıyın. Sonra KUR.bat'ı yeniden çalıştırın. |
| `UYARI: Klasor yolunda Turkce/ozel karakter var` veya `Klasor OneDrive icinde` | Bu bir uyarıdır, bir tuşa basarsanız devam eder. Ama sorun çıkmaması için pencereyi kapatın, klasörü `C:\FreeCaption` konumuna taşıyın ve KUR.bat'ı yeniden çalıştırın. |
| `UYARI: Internete (pypi.org) ulasilamadi` | İnternet bağlantınızı, VPN veya proxy ayarınızı kontrol edin. |
| `NVIDIA suruculerin cok eski` | Ekran kartı sürücünüz eski. `nvidia.com/drivers` adresinden güncelleyin. Güncelleyene kadar program CPU modunda çalışır. Güncelledikten sonra KUR.bat'ı yeniden çalıştırırsanız GPU modu açılır. |
| `GPU kullanilamadi. CPU moduna geciliyor` | Sorun değil. Program daha yavaş ama çalışır. Sürücüyü güncelleyip KUR.bat'ı tekrar çalıştırmak GPU modunu açabilir. |
| `FFmpeg otomatik kurulamadi` | (1) `https://www.gyan.dev/ffmpeg/builds/` adresinden `ffmpeg-release-essentials.zip` dosyasını indirin ve açın. (2) İçindeki `bin` klasöründen `ffmpeg.exe` ve `ffprobe.exe` dosyalarını alın. (3) Bunları `C:\FreeCaption\ffmpeg\bin\` klasörüne koyun (klasör yoksa oluşturun). |
| `Kurulum bitti ama paketler dogru calismiyor` (altında `WinError 126` veya `DLL` yazıyorsa) | Microsoft Visual C++ bileşeni eksik. `https://aka.ms/vs/17/release/vc_redist.x64.exe` adresinden indirip kurun, bilgisayarı yeniden başlatın, KUR.bat'ı yeniden çalıştırın. |
| `Eski panel silinemedi` veya `Panel kopyalanamadi` | Premiere Pro'yu tamamen kapatıp tekrar deneyin. Olmazsa `cep-plugin` klasörünü elle `%APPDATA%\Adobe\CEP\extensions\FreeCaption` konumuna kopyalayın (Win+R ile bu yolu açabilirsiniz). |
| `Sunucu kurulmamis (.venv bulunamadi)` (start.bat'ta) | Kurulum yapılmamış. Önce KUR.bat'ı çalıştırın. |
| `FreeCaption zaten calisiyor (port 7860 dolu)` | Sunucu zaten açık, yeni pencere gerekmez. Panel yine de bağlanmıyorsa bilgisayarı yeniden başlatın. |
| Panelde `Sunucu kapalı` | Siyah pencere açık mı bakın. Açık değilse `start.bat` dosyasına çift tıklayın. Panelde **Sunucu Başlat** düğmesi de vardır. |
| Premiere'de Window > Extensions menüsünde FreeCaption yok | Premiere'i tamamen kapatıp yeniden açın. Olmazsa `cep_kur.bat` dosyasını tekrar çalıştırın. Premiere sürümünüz 2023'ten (23.0) eskiyse eklenti desteklenmez. |
| Panel açılıyor ama boş veya beyaz | Premiere'i yeniden başlatın. Olmazsa `cep_kur.bat` dosyasını tekrar çalıştırın. |

## Hâlâ olmuyorsa

Yardım isterken şunları gönderin:

1. Hata ekranının fotoğrafı veya ekran görüntüsü.
2. FreeCaption klasöründeki `install_log.txt` dosyası.
3. Windows sürümünüz ve ekran kartı modeliniz.

Bildirim adresi: [github.com/ScamEmre/FreeCaption/issues](https://github.com/ScamEmre/FreeCaption/issues)
