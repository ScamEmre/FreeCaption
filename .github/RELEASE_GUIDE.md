# 📦 Sürüm Yayınlama Kılavuzu

FreeCaption'ın yeni sürümünü yayınlama adımları. Örnekler **v1.1.3** içindir; kendi sürüm numaranla değiştir.

> 💡 **Önemli:** Panelin içindeki **Güncelle** düğmesi release zip'ini kullanmaz. `main` dalının son commit'ini GitHub'dan indirir. Yani `main`'e push ettiğin her düzeltme, kullanıcıların panelinde güncelleme olarak çıkar. Release zip'i, **yeni kurulum yapacaklar** ve siteden indirenler içindir.

## ✅ Önkoşullar

- Tüm değişiklikler `main`'e push edildi
- `CHANGELOG.md` yeni sürümü anlatıyor (kullanıcının anlayacağı dille)
- Kurulum betikleri (`install.bat`, `start.bat`, `cep_kur.bat`, `KUR.bat`) **boşluk ve Türkçe karakter içeren bir klasörde** denendi
- Betikler CRLF (`.gitattributes` zorlar)

## 1) Zip'i oluştur

Repo kökünde PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\make_release_zip.ps1 -Version 1.1.3
```

Çıktı: `dist\FreeCaption-v1.1.3.zip` (yaklaşık 1,5 MB, zip içinde üst klasör `FreeCaption\`).

Betik şunları zip'e **koymaz**: `.venv`, `.git`, `.github`, `output`, `dist`, `ffmpeg`, `backend\.models`, `backend\.temp`, `__pycache__`, `install_log.txt`.

`dist\` klasörü `.gitignore`'da, repoya girmez. Sadece release dosyası olarak kullanılır.

## 2) Zip'i dene

Zip'i **temiz, boşluklu bir klasöre** çıkar (örn. `C:\Test Klasörü (1)`) ve `KUR.bat`'ı çalıştır. "HER SEY HAZIR!" yazısını görmeden yayınlama.

## 3) Etiket (tag) oluştur

```bash
git tag -a v1.1.3 -m "v1.1.3: sade anlatım, autostart düzeltmesi"
git push origin v1.1.3
```

GitHub Desktop kullanıyorsan: **History** sekmesinde son commit'e sağ tık, **Create Tag…**, sonra **Push origin**.

## 4) GitHub'da release yayınla

1. [Releases > Draft a new release](https://github.com/ScamEmre/FreeCaption/releases/new) sayfasını aç
2. **Choose a tag:** `v1.1.3`
3. **Release title:** örn. `v1.1.3: Daha sade anlatım ve küçük düzeltmeler`
4. **Description:** hazır metin için `dist\RELEASE_NOTES_v1.1.3.md` dosyasını kullan (CHANGELOG'dan kullanıcı diline çevrilmiş hali)
5. **Attach binaries:** `dist\FreeCaption-v1.1.3.zip` dosyasını sürükle bırak
6. **Set as the latest release** kutusunu işaretle
7. **Publish release**

## 5) Yayından sonra

- [ ] Release sayfasında zip'in indiğini kontrol et
- [ ] Sitede indirme bağlantısını yeni zip'e çevir
- [ ] VDS kullanıyorsan sunucuyu güncelle: [RUNBOOK, Güncelleme](../RUNBOOK.md#guncelleme)
- [ ] README'deki sürüm rozetini ve `CHANGELOG.md`'yi kontrol et

## 🔢 Sürüm numarası

[Semantic Versioning](https://semver.org/lang/tr/):

| Değişiklik | Örnek |
|---|---|
| Hata düzeltmesi, kurulum iyileştirmesi | 1.1.2 → **1.1.3** |
| Geriye uyumlu yeni özellik | 1.1.3 → **1.2.0** |
| Uyumsuzluk getiren değişiklik | 1.2.0 → **2.0.0** |

## 🔁 Yanlış yayınladıysan

- **Zip'te hata var:** release sayfasında **Edit**, eski zip'i sil, yenisini yükle. Tag'e dokunma.
- **Tag yanlış commit'te:** release'i **Draft**'a al, `git tag -d v1.1.3` ve `git push origin :refs/tags/v1.1.3` ile etiketi sil, doğru commit'te yeniden oluştur.

☕ FreeCaption ücretsiz ve açık kaynak: [Buy Me a Coffee](https://buymeacoffee.com/emrekazak)
