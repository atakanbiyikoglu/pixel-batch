#!/bin/bash

# PixelBatch - macOS Başlatıcı
# Bunu çift tıklamanız yeterli!

# Betik dizinini al
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Node.js kontrol et
if ! command -v node &> /dev/null; then
    osascript -e 'display dialog "❌ HATA: Node.js yüklü değil\n\nLütfen şu adresten indirin:\nhttps://nodejs.org/" buttons {"Tamam"} default button 1 with icon caution'
    exit 1
fi

# Bağımlılıklar kontrol et
if [ ! -d "node_modules" ]; then
    osascript -e 'display dialog "❌ Bağımlılıklar yüklü değil\n\nLütfen önce PixelBatch_Kurulum.command çalıştırın" buttons {"Tamam"} default button 1 with icon caution'
    exit 1
fi

# Node sürümü göster
NODE_VERSION=$(node --version)

# Tarayıcı aç
sleep 2 &
open "http://localhost:3000" 2>/dev/null &

# Sunucuyu başlat (Terminal arka planda çalışacak ve kapanacak)
node server.js

# Sunucu kapandığında pencerenin kapanmasını ve kapat
sleep 1
