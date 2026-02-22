# PixelBatch

HEIC/HEIF dosyalarını yüksek kaliteli JPEG'e toplu dönüştüren masaüstü uygulaması.

**Kurulum gerektirmez.** Node.js, FFmpeg veya herhangi bir bağımlılık yüklemenize gerek yok — çift tıklayın, kullanın.

---

## Özellikler

- Toplu dönüştürme — birden fazla HEIC/HEIF dosyasını aynı anda işler
- Yüksek kalite — FFmpeg `q:v 2`, `yuvj444p` renk alanı
- Sürükle & bırak veya dosya seçici ile kolay kullanım
- Dönüştürülen dosyalar tek ZIP olarak indirilir
- FFmpeg gömülü — harici kurulum gerekmez
- Windows (.exe) ve macOS (.dmg) desteği
- Temiz, minimal arayüz

---

## Kullanım

1. Uygulamayı açın
2. HEIC/HEIF dosyalarını sürükleyip bırakın veya **Dosya Seç** butonuna tıklayın
3. **Dönüştür** butonuna tıklayın
4. Dönüştürme tamamlandığında **ZIP İndir** ile kaydedin

---

## Geliştirici Kurulumu

Projeyi yerel ortamda çalıştırmak için:

```bash
git clone https://github.com/atakanbiyikoglu/pixel-batch.git
cd pixel-batch
npm install
npm start
```

### Build

```bash
# Windows
npm run build:win

# macOS
npm run build:mac
```

Çıktılar `dist/` klasörüne oluşturulur.

---

## Teknik Detaylar

### Architecture

## Teknik Detaylar

| Parametre     | Değer                              |
| ------------- | ---------------------------------- |
| Girdi         | HEIC, HEIF                         |
| Çıktı         | JPEG (.jpg)                        |
| Kalite         | q:v 2 (en yüksek)                 |
| Piksel Format  | yuvj444p (4:4:4 chroma)           |
| FFmpeg Komutu  | `ffmpeg -i input -q:v 2 -pix_fmt yuvj444p -y output.jpg` |

### Mimari

- **Electron** — Ana süreç dosya dönüştürme ve IPC yönetimi
- **ffmpeg-static** — Gömülü FFmpeg binary, harici kurulum gerektirmez
- **archiver** — Dönüştürülen dosyaları ZIP olarak paketler
- **contextIsolation + sandbox** — Güvenli renderer süreci

### Proje Yapısı

```
pixel-batch/
├── main.js          # Electron ana süreç
├── preload.js       # contextBridge API
├── package.json
├── src/
│   ├── index.html   # Arayüz
│   ├── styles.css   # Apple-inspired tasarım
│   └── renderer.js  # Arayüz mantığı
└── dist/            # Build çıktıları
```

---

## Lisans

MIT

## Geliştirici

**Atakan Bıyıkoğlu**
[github.com/atakanbiyikoglu](https://github.com/atakanbiyikoglu)
