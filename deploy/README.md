# 🌐 Uzak Sunucu (VDS) Kurulum Dosyaları

Bu klasör, FreeCaption sunucusunu **ekip için merkezi bir makineye** kurmak isteyenler içindir. Kendi bilgisayarında kullanacaksan buraya ihtiyacın yok: kök klasördeki **`KUR.bat`** yeter.

| Klasör | İşletim sistemi | İçindekiler |
|---|---|---|
| `windows/` | Windows Server 2019/2022, Windows 11 | `install_windows.ps1` (tek tuşla kurulum), `setup_services.ps1` (Windows servisleri), `.env.example` |
| `linux/` | Ubuntu/Debian | `install_vds.sh`, `freecaption.service` (systemd), `nginx.conf`, `.env.example` |

## Windows: tek tuşla kurulum

Yönetici PowerShell'de:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
$u = "https://raw.githubusercontent.com/ScamEmre/FreeCaption/main/deploy/windows/install_windows.ps1"
Invoke-WebRequest $u -OutFile "$env:TEMP\install.ps1" -UseBasicParsing
& "$env:TEMP\install.ps1"
```

Kurulum yaklaşık 15 dakika sürer. Sonunda ekrana bir **API Key** yazar, bunu kaydet: Premiere panelinde **⚙ Sunucu Ayarları**'na girilecek.

## Notlar

- VDS'de ekran kartı olmadığı için **CPU modu** (`medium` model) kullanılır.
- API Key'i ve `.env` dosyalarını kimseyle paylaşma, repoya ekleme.
- Adım adım anlatım, sorun giderme ve güncelleme için: [RUNBOOK.md](../RUNBOOK.md)

☕ FreeCaption ücretsiz ve açık kaynak: [Buy Me a Coffee](https://buymeacoffee.com/emrekazak)
