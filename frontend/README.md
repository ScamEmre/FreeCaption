# 🖥️ Web Arayüzü (Premiere'siz kullanım)

Bu klasör, FreeCaption sunucusunun tarayıcıdaki arayüzünü içerir. **Premiere Pro kurulu olmasa da** video ya da ses dosyasından altyazı (SRT) üretebilirsin.

## Nasıl açılır?

1. Sunucuyu başlat: kök klasördeki **`start.bat`** (siyah pencere açık kalsın).
2. Tarayıcıda **http://127.0.0.1:7860** adresini aç.
3. Dosyayı sürükle bırak, dili seç, SRT'yi indir.

Sunucu kurulu değilse önce kök klasördeki **`KUR.bat`** dosyasını çalıştır. Ayrıntı: [Kurulum Rehberi](../KURULUM_REHBERI.md).

## Dosyalar

| Dosya | İşi |
|---|---|
| `index.html` | Sayfa |
| `style.css` | Görünüm |
| `app.js` | Dosya yükleme, ilerleme ve SRT indirme |

Bu arayüzü sunucu kendisi yayınlar (`backend/main.py`), ayrıca bir web sunucusu gerekmez.

☕ FreeCaption ücretsiz ve açık kaynak: [Buy Me a Coffee](https://buymeacoffee.com/emrekazak)
