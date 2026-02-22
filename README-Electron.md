# PixelBatch - Electron Desktop App

Professional HEIC to JPEG Batch Converter - Masaüstü Uygulaması

## Özellikler

✅ **Sürükle-Bırak**: Dosyaları arayüze sürükle halletim - seç  
✅ **Toplu Dönüştürme**: Birden fazla HEIC dosyasını aynı anda dönüştür  
✅ **Yüksek Kalite**: FFmpeg q:v 2, pix_fmt yuvj444p ile en iyi JPEG kalitesi  
✅ **ZIP İndirme**: Tüm dosyaları ZIP'e paketleyerek indir  
✅ **Progress Gösterme**: Gerçek zamanlı dönüştürme ilerleme bilgisi  
✅ **Hata Yönetimi**: Başarısız dosyaları göster, uygulamayı çökmez  
✅ **Kurulum Gerektirmez**: Çift tıkla ve çalışır  
✅ **Profesyonel UI**: Modern ve responsive arayüz  

## Sistem Gereksinimleri

- **Windows**: Windows 7 SP1 ve üzeri (64-bit)
- **macOS**: macOS 10.12 (Sierra) ve üzeri
- **CPU**: x64 işlemci
- **RAM**: En az 512 MB
- **Disk Alanı**: ~200 MB (Electron + FFmpeg başlangıç indirmesi)

## Kurulum

### Windows
1. `PixelBatch-1.0.0-win.exe` dosyasını çalıştır
2. "Install" butonuna tıkla
3. Kurulumu bitir, masaüstü kısayolundan aç

### macOS
1. `PixelBatch-1.0.0.dmg` dosyasını aç
2. PixelBatch'i Applications klasörüne sürükle
3. Applications'dan PixelBatch'i çalıştır

## Kullanım

1. **Dosya Seç**: 
   - "Dosya Seç" butonuna tıkla veya
   - HEIC/HEIF dosyalarını sürükle-bırak

2. **Dönüştür**: 
   - "Dönüştür" butonuna tıkla
   - İlerleme çubuğunda yüzdeyi takip et

3. **İndir**: 
   - Tamamlandığında "ZIP İndir" butonuna tıkla
   - Dosyaları kaydet

## Teknik Detaylar

### Stack
- **UI Framework**: Electron 27.x
- **Image Processing**: FFmpeg-static 5.2.0
- **Packaging**: Archiver 6.0.0
- **Build Tool**: Electron-Builder

### Komutlar

```bash
# Geliştirme modu (debug konsolu açık)
npm run dev

# Uygulamayı başlat (production)
npm start

# Build et (Windows + macOS)
npm run build

# Sadece Windows builder
npm run build:win

# Sadece macOS builder
npm run build:mac

# Pack (test amaçlı)
npm run pack

# Distribution (tüm platformlar)
npm run dist
```

### Dosya Yapısı

```
pixel-batch/
├── main.js              # Electron main process
├── preload.js           # IPC güvenli köprü
├── package.json         # Proje yapılandırması
├── src/
│   ├── index.html       # Arayüz HTML
│   ├── styles.css       # Stil şablonu
│   └── renderer.js      # Renderer process logic
├── assets/
│   └── icon.png         # Uygulama ikonu
├── dist/                # Build çıktısı
└── README.md           # Bu dosya
```

### HEIC → JPEG Dönüştürme

**FFmpeg Komutu**:
```bash
ffmpeg -i input.heic -q:v 2 -pix_fmt yuvj444p output.jpg
```

**Parametreler**:
- `-q:v 2`: Maksimum JPEG kalitesi (0-31, düşük = daha iyi)
- `-pix_fmt yuvj444p`: Full color sampling (en iyi kalite)

**Çıkmazlar**: Çözünürlük değişmez, orijinal görüntü özellikleri korunur

## Geliştirme

### Kurulum
```bash
npm install
```

### DevTools ile Çalıştır
```bash
npm run dev
```

### Build (İlk Kez)
```bash
# Electron + ffmpeg-static otomatik indirilir
npm install

# Build başlat
npm run build
```

## Sorun Giderme

### HEIC dosyaları seçilemiyor?
- Dosya uzantısının Sağ-Tıkla > Yeniden Adlandır ile `.heic` olduğunu doğrula
- Alternatif: `.heif` uzantısı da desteklenir

### Dönüştürme hızdır?
- Dosya boyutlatık 50 MB'dan büyükse bekleme normal
- Her dosya bağımsız olarak işlenir, paralel dönüştürme yok
- İşletim sistemi başka işler yapıyor olabilir

### macOS üzerinde "Apple, developer identity confirmed" hatası?
- İlk çalıştırmada Gatekeeper kontrolü normal
- Yapılandırma > Özel izinler kısmında izin ver

### Windows'da SmartScreen uyarısı?
- İlk çalıştırmada normal (imzasız yayıncı)
- "Yine de çalıştır"a tıkla

## Lisans

MIT License - Açık kaynak, freeware

## İletişim

Sorun bildir veya öner: [GitHub Issues](https://github.com/atakanbiyikoglu/pixel-batch)

---

**PixelBatch v1.0.0** - Profesyonel HEIC to JPEG Batch Converter
