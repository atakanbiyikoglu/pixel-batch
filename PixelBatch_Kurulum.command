#!/bin/bash

# PixelBatch - macOS Kurulum Betiği
# Bunu çift tıklamanız yeterli!

clear

echo ""
echo "========================================"
echo "  PixelBatch Kurulumu - macOS"
echo "========================================"
echo ""

# Node.js kontrol et
if ! command -v node &> /dev/null; then
    echo "❌ HATA: Node.js yüklü değil!"
    echo ""
    echo "Çözüm:"
    echo "-----"
    echo ""
    echo "1. Aşağıdaki linkten Node.js indir:"
    echo "   https://nodejs.org/"
    echo ""
    echo "2. LTS sürümünü seç (yeşil buton)"
    echo ""
    echo "3. Kurulum dosyasını çalıştır"
    echo "   (Tüm ayarlar varsayılan kalsın)"
    echo ""
    echo "4. Mac'i yeniden başlat"
    echo ""
    echo "5. Bu betiği (PixelBatch_Kurulum.command) tekrar çalıştır"
    echo ""
    
    # Tarayıcıyı aç
    open "https://nodejs.org/"
    
    echo "Tarayıcı açılacak... Node.js sayfasına git ve kur."
    exit 1
fi

# Versyon göster
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)

echo "✓ Node.js bulundu: $NODE_VERSION"
echo "✓ npm bulundu: $NPM_VERSION"
echo ""

# Betik dizinini al
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Zaten yüklü mü kontrol et
if [ -d "node_modules" ]; then
    echo "✓ Bağımlılıklar zaten yüklü!"
    echo ""
    osascript -e 'display dialog "✓ Kurulum Tamamlandı!\n\nArtık PixelBatch.command dosyasını\nçift tıkla ile başlayabilirsin!" buttons {"Tamam"} default button 1'
    exit 0
fi

# Kurulum yap
echo "Bağımlılıklar kuruluyor..."
echo "Bu 30-60 saniye sürebilir..."
echo ""

npm install --production

if [ $? -ne 0 ]; then
    osascript -e 'display dialog "❌ HATA: Kurulum başarısız oldu\n\nLütfen tekrar deneyin." buttons {"Tamam"} default button 1 with icon caution'
    exit 1
fi

echo ""
echo "========================================"
echo "  ✓ Kurulum Tamamlandı!"
echo "========================================"
echo ""

osascript -e 'display dialog "✓ Kurulum Başarılı!\n\nArtık PixelBatch.command dosyasını\nçift tıkla ile başlayabilirsin!\n\nFotoğraflarını dönüştürmeye başla!" buttons {"Tamam"} default button 1'
