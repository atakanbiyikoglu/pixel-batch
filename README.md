# 🎨 PixelBatch - HEIC to JPEG Batch Converter

Professional batch image converter for HEIC and other formats to high-quality JPEG using FFmpeg with optimal compression settings.

## ✨ Features

- **Batch Processing**: Convert up to 100 images simultaneously
- **HEIC Support**: Direct HEIC → JPEG conversion with FFmpeg
- **High Quality**: Quality setting q:v 2, pix_fmt: yuvj444p, Metadata preserved
- **ZIP Download**: All converted images automatically packaged
- **Zero System Dependencies**: FFmpeg bundled (ffmpeg-static)
- **Cross-Platform**: Windows & macOS compatible
- **Memory Efficient**: Processes in RAM, no permanent temporary files
- **Drag & Drop**: Simple intuitive web interface
- **Parallel Processing**: Promise.all for optimal performance
- **Error Resilience**: Individual file failures don't crash the batch

## 🚀 Quick Start for End Users

### 📥 Installation (First Time Only)

#### Windows

1. **Install Node.js** from https://nodejs.org/ (LTS version)
2. **Run `Install.bat`** and wait for completion
3. Done!

#### macOS

1. **Install Node.js** from https://nodejs.org/ (LTS version, Mac version)
2. **Open Terminal** (Cmd+Space → Terminal)
3. **Navigate to folder:**
   ```bash
   cd ~/Downloads/pixel-batch
   ```
4. **Make executable and setup:**
   ```bash
   chmod +x Install.sh
   ./Install.sh
   ```
5. Done!

#### Linux

1. **Install Node.js via package manager:**
   ```bash
   sudo apt install nodejs npm    # Debian/Ubuntu
   sudo dnf install nodejs npm    # Fedora
   ```
2. **Setup:**
   ```bash
   cd pixel-batch
   npm install --production
   ```

### ▶️ Starting PixelBatch

**Windows:**

- Double-click `PixelBatch.bat`

**macOS:**

- Double-click `PixelBatch.sh`
- Or: `./PixelBatch.sh` in Terminal

**Linux:**

- Terminal: `npm run dev`

Browser opens automatically → drag photos → download ZIP

## 📖 Usage

1. **Select Images** - Click or drag-drop HEIC, JPG, PNG, GIF, BMP, TIFF, WebP files
2. **Convert** - Click the Convert button
3. **Download** - ZIP file automatically downloads with converted JPEG images

## 🛠️ Technical Details

### Architecture

```
Browser (Upload)
    ↓
Express Server
    ├─ Multer (RAM storage)
    ├─ FFmpeg spawn (file-based pipeline)
    ├─ Temp file management
    ├─ Promise.all (parallel)
    ├─ Archiver (ZIP creation)
    └─ Stream response
    ↓
Browser (Download ZIP)
```

### FFmpeg Command

```bash
ffmpeg -i input.heic -q:v 2 -pix_fmt yuvj444p output.jpg
```

### Conversion Settings

| Parameter     | Value                                            |
| ------------- | ------------------------------------------------ |
| Input Formats | HEIC, HEIF, JPG, JPEG, PNG, GIF, BMP, TIFF, WebP |
| Output Format | JPEG (.jpg)                                      |
| Quality       | q:v 2 (highest quality)                          |
| Pixel Format  | yuvj444p (maximum color precision)               |
| Metadata      | Preserved                                        |
| Codec         | MJPEG (Motion JPEG compatible)                   |
| Max File Size | 50MB                                             |
| Max Files     | 100                                              |

### Key Implementation Details

1. **FFmpeg**: child_process.spawn with ffmpeg-static (bundled binary)
2. **Pipeline**: Temp file-based (write buffer → execute FFmpeg → read result → cleanup)
3. **Parallelization**: Promise.all for simultaneous conversions
4. **Archive**: archiver with 'finish' event await (prevents empty ZIP)
5. **Error Handling**: Individual file failures don't crash the batch
6. **Quality**: q:v 2 provides best possible JPEG quality
7. **Color Space**: yuvj444p ensures full 4:4:4 chroma sampling

## 📁 Project Structure

```
pixel-batch/
├── server.js           # Express server + FFmpeg pipeline (HEIC→JPEG)
├── package.json        # Dependencies (express, multer, archiver, ffmpeg-static, cors)
├── public/
│   └── index.html      # Upload UI (drag-drop, progress tracking)
└── README.md          # This file
```

## 📦 Dependencies

```json
{
  "express": "^4.18.2",
  "multer": "^1.4.5-lts.1",
  "archiver": "^6.0.0",
  "cors": "^2.8.5",
  "ffmpeg-static": "^5.2.0"
}
```

## 🔧 Scripts

```bash
npm run dev    # Start server (development)
npm start      # Start server (production)
```

## 🌐 API

### POST /convert

Convert images to WebP and download as ZIP.

**Request**:

```bash
curl -X POST http://localhost:3000/convert \
  -F "images=@photo1.heic" \
  -F "images=@photo2.jpg" \
  -o PixelBatch.zip
```

**Response**: ZIP file (binary/application-zip)

### GET /health

Health check endpoint.

**Response**: `{"status":"ok","service":"PixelBatch"}`

## ⚙️ Configuration

### Environment Variables

```bash
PORT=3000              # Server port (default: 3000)
NODE_ENV=development   # development or production
```

### File Limits

- **Max file size**: 50MB per file
- **Max files**: 100 per request
- **Supported formats**: HEIC, HEIF, JPG, JPEG, PNG, GIF, BMP, TIFF, WebP

## 🚨 Troubleshooting

### Issue: Empty ZIP downloaded

**Solution**: Ensure archive finalize event is awaited

- Check server logs for "Archive finished" message
- Verify files converted successfully

### Issue: FFmpeg error

**Solution**: Reinstall dependencies

```bash
npm install
```

### Issue: Port already in use

**Solution**: Use different port

```bash
PORT=3001 npm run dev
```

### Issue: Out of memory

**Solution**: Reduce batch size or increase Node memory

```bash
node --max-old-space-size=2048 server.js
```

## 📊 Performance

| Scenario      | Files | Size  | Time   |
| ------------- | ----- | ----- | ------ |
| Single HEIC   | 1     | 5MB   | 2-3s   |
| Multiple JPGs | 10    | 50MB  | 5-8s   |
| Large batch   | 100   | 200MB | 30-45s |

## 🔐 Security

- Files stored in RAM (not disk)
- No server-side persistence
- CORS enabled for local development
- Input validation on file types
- Error handling prevents information leakage

## 🐛 Debugging

Server logs all conversions:

```
✅ Success: 5, ❌ Failed: 0
📦 Creating ZIP...
  [1/5] photo1.webp appended
  [2/5] photo2.webp appended
  ...
✓ Archive finished
✅ ZIP sent successfully
```

## 📝 License

MIT

## 👤 Author

**Atakan Bıyıkoğlu**  
GitHub: [@atakanbiyikoglu](https://github.com/atakanbiyikoglu)

## 🤝 Support

For issues and questions:

- GitHub Issues: [PixelBatch Issues](https://github.com/atakanbiyikoglu/pixel-batch/issues)
- Email: contact@atakanbiyikoglu.com

---

**Note**: This application is optimized for local development and small-scale use. For production deployment, consider:

- Load balancing
- Worker processes
- Cloud storage
- Advanced error monitoring
