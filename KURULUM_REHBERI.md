# PixelBatch - Kurulum Rehberi

## Nedir?

HEIC fotoğraflarını JPEG'e çeveren, tek tıklayla çalışan uygulama.

Teknik bilgi gerekmez. Sadece tıkla ve bitti!

## Dosyalar

**Kullanıcı Dosyaları:**
- PixelBatch.bat (Windows - çift tıkla)
- PixelBatch.command (macOS - çift tıkla)
- !BENİ_ÖNCE_OKU.txt (İlk oku)
- BURADAN_BAŞLA.txt (Hızlı start)
- KULLANICI_REHBERI.md (Detaylı rehber)

**Uygulama Dosyaları:**
- server.js (Express sunucu)
- package.json (Bağımlılıklar)
- public/index.html (Web arayüzü)

**Otomatik İndirilecekler:**
- node_modules/ (npm paketleri)
- package-lock.json (Versiyon kilit)

**Silme/değiştirme:** node_modules/

## İş Akışı

`
PixelBatch.bat/command tıkla
  
Node.js kontrol (yoksa otomatik indir-kur)
  
npm install --production (bağımlılıklar)
  
Tarayıcı: http://localhost:3000
  
Fotoğraf yükle
  
ZIP indir
  
Bitti! 
`

## Kalite Ayarları

- **FFmpeg q:v 2:** Maksimum kalite (en iyi)
- **pix_fmt yuvj444p:** Tam renk (en iyi)
- **heic-convert:** Profesyonel dönüştürme

## Kurulum (İlk Kez)

1. Klasörü indir
2. PixelBatch.bat (Windows) veya PixelBatch.command (macOS) tıkla
3. Yönetici izni ver
4. Bekle 1-2 dakika
5. Tarayıcı açılacak - kurulum bitti!

## Kullanım (Her Deferinde)

1. PixelBatch.bat/command tıkla
2. Tarayıcı açılacak
3. Fotoğraf yükle
4. ZIP indir
5. Bitti!

Sorun mu var? KULLANICI_REHBERI.md'ye bak.
