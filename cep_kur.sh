#!/usr/bin/env bash
# FreeCaption - macOS CEP Eklenti Kurulumu
# Kullanım: ./cep_kur.sh
set -euo pipefail

echo "==================================================="
echo "  FreeCaption - macOS CEP Eklenti Kurulumu"
echo "==================================================="
echo ""

# 1. CEP Debug Mode aktive et (CSXS 9-14)
echo "[1/3] CEP debug modu aktif ediliyor..."
defaults write com.adobe.CSXS.9 PlayerDebugMode 1 2>/dev/null || true
defaults write com.adobe.CSXS.10 PlayerDebugMode 1 2>/dev/null || true
defaults write com.adobe.CSXS.11 PlayerDebugMode 1 2>/dev/null || true
defaults write com.adobe.CSXS.12 PlayerDebugMode 1 2>/dev/null || true
defaults write com.adobe.CSXS.13 PlayerDebugMode 1 2>/dev/null || true
defaults write com.adobe.CSXS.14 PlayerDebugMode 1 2>/dev/null || true
echo "      OK"
echo ""

# 2. CEP extensions klasörü
TARGET_DIR="$HOME/Library/Application Support/Adobe/CEP/extensions/FreeCaption"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/cep-plugin"

if [ ! -d "${SOURCE_DIR}" ]; then
    echo "HATA: cep-plugin klasörü bulunamadı."
    echo "Konum: ${SOURCE_DIR}"
    exit 1
fi

echo "[2/3] Eski kurulum varsa temizleniyor..."
rm -rf "${TARGET_DIR}"
mkdir -p "$(dirname "${TARGET_DIR}")"
echo "      OK"
echo ""

echo "[3/3] Eklenti kopyalanıyor..."
cp -R "${SOURCE_DIR}" "${TARGET_DIR}"
echo "      OK"
echo ""

# ExtendScript ES3'te JSON.stringify yok - polyfill (json2.js) main.jsx başına eklenir
echo "[3.5/3] JSON polyfill main.jsx ile birleştiriliyor..."
if [ -f "${TARGET_DIR}/jsx/json2.js" ] && [ -f "${TARGET_DIR}/jsx/main.jsx" ]; then
    cat "${TARGET_DIR}/jsx/json2.js" > "${TARGET_DIR}/jsx/temp.jsx"
    echo -e "\n\n// ===== main.jsx (concat) =====\n\n" >> "${TARGET_DIR}/jsx/temp.jsx"
    cat "${TARGET_DIR}/jsx/main.jsx" >> "${TARGET_DIR}/jsx/temp.jsx"
    mv "${TARGET_DIR}/jsx/temp.jsx" "${TARGET_DIR}/jsx/main.jsx"
    echo "      OK"
else
    echo "UYARI: Polyfill birleştirme başarısız. Dosyalar bulunamadı."
fi
echo ""

# 4. FFmpeg & Homebrew check
echo "[4/3] FFmpeg kontrol ediliyor..."
set +e  # Hatalarda scriptin hemen durmasını engelle

FFMPEG_OK=0
if command -v ffmpeg >/dev/null 2>&1; then
    FFMPEG_OK=1
elif [ -f "/opt/homebrew/bin/ffmpeg" ] || [ -f "/usr/local/bin/ffmpeg" ] || [ -f "/usr/bin/ffmpeg" ]; then
    FFMPEG_OK=1
fi

if [ "${FFMPEG_OK}" -eq 0 ]; then
    echo ""
    echo "UYARI: FFmpeg sisteminizde bulunamadı!"
    echo "Uzak sunucu (VDS) modu için yerel FFmpeg kurulumu zorunludur."
    read -p "FFmpeg'i otomatik kurmak ister misiniz? (y/n): " install_ff
    if [[ "${install_ff}" =~ ^[Yy]$ ]]; then
        # Check if brew exists
        BREW_PATH=""
        if command -v brew >/dev/null 2>&1; then
            BREW_PATH="brew"
        elif [ -f "/opt/homebrew/bin/brew" ]; then
            BREW_PATH="/opt/homebrew/bin/brew"
        elif [ -f "/usr/local/bin/brew" ]; then
            BREW_PATH="/usr/local/bin/brew"
        fi

        if [ -z "${BREW_PATH}" ]; then
            echo "Homebrew bulunamadı!"
            read -p "Homebrew'i kurup ardından FFmpeg'i kurmak ister misiniz? (y/n): " install_brew
            if [[ "${install_brew}" =~ ^[Yy]$ ]]; then
                echo "[!] Homebrew kuruluyor (şifreniz istenebilir)..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Load brew in current session
                if [ -f "/opt/homebrew/bin/brew" ]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                    BREW_PATH="/opt/homebrew/bin/brew"
                elif [ -f "/usr/local/bin/brew" ]; then
                    eval "$(/usr/local/bin/brew shellenv)"
                    BREW_PATH="/usr/local/bin/brew"
                fi
            fi
        fi

        if [ -n "${BREW_PATH}" ]; then
            echo "[!] FFmpeg kuruluyor (brew)..."
            "${BREW_PATH}" install ffmpeg
            if [ $? -eq 0 ]; then
                echo "[+] FFmpeg başarıyla kuruldu!"
            else
                echo "[-] HATA: FFmpeg kurulumu başarısız oldu."
            fi
        else
            echo "[-] HATA: Homebrew olmadığı için FFmpeg kurulamadı."
            echo "Lütfen manuel olarak https://ffmpeg.org/ adresinden kurun."
        fi
    fi
else
    echo "      OK (Sistemde FFmpeg mevcut)"
fi
echo ""
set -e  # set -e'yi tekrar aktif et

echo "==================================================="
echo "  KURULUM TAMAMLANDI."
echo ""
echo "  Premiere Pro'yu yeniden başlatın."
echo "  Window > Extensions > FreeCaption menüsünden açın."
echo "==================================================="
echo ""
