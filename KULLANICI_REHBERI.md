# PixelBatch Kullanıcı Rehberi

HEIC JPEG. Tek tıkla hepsi olur!

## Kurulum (İlk Açılış)

**WINDOWS:**

1. PixelBatch.bat'ı çift tıkla
2. Yönetici izni iste
3. Bekle (Node.js kuracak, bağımlılıklar yüklenecek)
4. Tarayıcı otomatik açılacak

**macOS:**

1. PixelBatch.command'ı çift tıkla
2. Terminal açılacak (normal)
3. Tarayıcı otomatik açılacak

**Linux:**
`\ash
cd ~/Downloads/pixel-batch
npm install --production
npm run dev
`\

---

## Kullanım (Her Deferinde)

### WINDOWS & macOS

1. PixelBatch.bat (Windows) veya PixelBatch.command (macOS) tıkla
2. Tarayıcı açılır: http://localhost:3000
3. HEIC/JPG/PNG dosyaları sürükle-bırak et
4. ZIP indir ve aç

### LINUX

`\ash
npm run dev
`\

Tarayıcıda: http://localhost:3000

---

## Sorun Giderme

**Tarayıcı açılmıyorsa:** http://localhost:3000 adresine git

**Node.js kurulmuyorsa:** İnternet bağlantısını kontrol et, bilgisayarı yeniden başlat

**Sunucu başlamıyorsa:** PixelBatch'i kapat, yeniden aç

**Port 3000 kullanımda:** Başka PixelBatch penceresini kapat veya bilgisayarı yeniden başlat

---

## Sık Sorulan Sorular

- **Kaç dosya dönüştürebilirim?** En fazla 100 aynı anda
- **Dosya boyutu?** Her dosya max 50 MB
- **Kalite?** Maksimum (FFmpeg q:v 2)
- **Orijinal dosyalar değişir mi?** Hayır, ZIP'te yeni kopya
- **Başka format?** Sadece HEIC JPEG
- **Teknik bilgi gerekli mi?** Hayır

---

Fotoğrafları dönüştürmeye hazırsan!
