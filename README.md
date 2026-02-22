# PixelBatch

Batch HEIC/HEIF to JPEG converter. A lightweight Electron desktop app with FFmpeg bundled — no installation of Node.js, FFmpeg, or any other dependency required.

## Features

- Batch convert multiple HEIC/HEIF files to high-quality JPEG
- Drag & drop or file picker
- Converted files packaged as a single ZIP download
- Bundled FFmpeg — zero external dependencies
- Windows (.exe) and macOS (.dmg) support
- Clean, minimal interface

## Download

| Platform | File | Description |
| -------- | ---- | ----------- |
| Windows  | `PixelBatch Setup.exe` | Installer with desktop shortcut |
| Windows  | `PixelBatch.exe` | Portable — no installation needed |
| macOS    | `PixelBatch.dmg` | Drag to Applications |

Pre-built binaries are available in the project root directory and under `dist/`.

> macOS builds require building on a Mac. Run `npm run build:mac` on macOS.

## Usage

1. Open the app
2. Drag & drop HEIC/HEIF files or click **Select Files**
3. Click **Convert**
4. Download the ZIP when complete

## Development

```bash
git clone https://github.com/atakanbiyikoglu/pixel-batch.git
cd pixel-batch
npm install
npm start
```

### Build

```bash
npm run build:win   # Windows — NSIS installer + portable
npm run build:mac   # macOS — DMG + ZIP
```

Output goes to `dist/`.

## Technical Details

| Parameter    | Value |
| ------------ | ----- |
| Input        | HEIC, HEIF |
| Output       | JPEG (.jpg) |
| Quality      | q:v 2 (highest) |
| Pixel Format | yuvj444p (4:4:4 chroma subsampling) |
| Command      | `ffmpeg -i input -q:v 2 -pix_fmt yuvj444p -y output.jpg` |

### Architecture

- **Electron** — main process handles file conversion and IPC
- **ffmpeg-static** — bundled FFmpeg binary, no external install
- **archiver** — packages converted files into ZIP
- **contextIsolation + sandbox** — secure renderer process

### Project Structure

```
pixel-batch/
├── main.js          # Electron main process
├── preload.js       # contextBridge API
├── package.json
├── src/
│   ├── index.html   # UI markup
│   ├── styles.css   # Apple-inspired design
│   └── renderer.js  # UI logic
└── dist/            # Build output
```

## License

MIT

## Author

**Atakan Bıyıkoğlu** — [github.com/atakanbiyikoglu](https://github.com/atakanbiyikoglu)
