#!/bin/bash

# PixelBatch - macOS Başlatıcı ve Kurulum
# Bunu çift tıklamanız yeterli!

# Betik dizinini al
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Türkçe karakter desteği
export LANG=en_US.UTF-8

# Node.js kontrol et
if ! command -v node &> /dev/null; then
    osascript -e 'display dialog "❌ HATA: Node.js yüklü değil\n\nLütfen şu adresten indirin:\nhttps://nodejs.org/ (LTS sürümü)\n\nMac'i yeniden başlat ve bunu tekrar çalıştır" buttons {"Tamam"} default button 1 with icon caution'
    exit 1
fi

# Bağımlılıklar kontrol et ve otomatik kur
if [ ! -d "node_modules" ]; then
    echo "Bağımlılıklar kuruluyor... (≈30-60 saniye)"
    npm install --production 2>&1 | grep -v "npm WARN"
    
    if [ $? -ne 0 ]; then
        osascript -e 'display dialog "❌ HATA: npm install başarısız\n\nLütfen tekrar deneyin." buttons {"Tamam"} default button 1 with icon caution'
        exit 1
    fi
    
    echo "✓ Kurulum tamam!"
    
    # Desktop kısayolu otomatik oluştur (ilk kurulumda)
    DESKTOP="$HOME/Desktop"
    SHORTCUT="$DESKTOP/PixelBatch.command"
    
    if [ ! -L "$SHORTCUT" ] && [ ! -f "$SHORTCUT" ]; then
        echo "Masaüstü kısayolu oluşturuluyor..."
        ln -s "$SCRIPT_DIR/PixelBatch.command" "$SHORTCUT" 2>/dev/null
        chmod +x "$SHORTCUT" 2>/dev/null
        echo "✓ Masaüstü kısayolu oluşturuldu!"
    fi
    
    echo ""
fi

# Node sürümü göster
NODE_VERSION=$(node --version)

# Tarayıcıyı arka planda aç (2 saniye sonra)
(sleep 2; open "http://localhost:3000" 2>/dev/null) &

# Sunucuyu başlat
echo "Server başlatılıyor... (http://localhost:3000)"
echo "Tarayıcı otomatik açılacak"
echo ""
echo "Durdurmak için: CTRL+C"
echo ""

node server.js
