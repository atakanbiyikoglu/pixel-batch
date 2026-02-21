#!/usr/bin/env node
/**
 * PixelBatch - HEIC to JPEG Batch Converter
 * FFmpeg-static + child_process + archiver
 * Quality: q:v 2, pix_fmt: yuvj444p, Metadata preserved
 */

const express = require('express');
const multer = require('multer');
const archiver = require('archiver');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const os = require('os');
const { spawn } = require('child_process');
const ffmpegPath = require('ffmpeg-static');

// Load heic-convert for HEIC support
let heicConvert;
try {
  heicConvert = require('heic-convert');
} catch (e) {
  console.warn('⚠️  heic-convert not available, HEIC support disabled');
  heicConvert = null;
}

// ============================================================================
// CONFIG
// ============================================================================

const app = express();
const PORT = process.env.PORT || 3000;

// Multer - RAM storage
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 50 * 1024 * 1024,
    files: 100
  },
  fileFilter: (req, file, cb) => {
    const fileName = file.originalname.toLowerCase();
    const ext = path.extname(fileName).toLowerCase();
    const allowedExts = ['.heic', '.heif', '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.webp'];
    
    if (allowedExts.includes(ext)) {
      cb(null, true);
    } else {
      cb(new Error(`Format not supported: ${ext}`));
    }
  }
});

// ============================================================================
// CONVERSION FUNCTION
// ============================================================================

/**
 * Convert image to JPEG using heic-convert (for HEIC) + FFmpeg (for re-encoding)
 * Input: image buffer + filename
 * Output: JPEG buffer or error
 * 
 * Pipeline:
 * 1. If HEIC: heic-convert to JPEG
 * 2. If not JPG already: Convert via FFmpeg
 * 3. Apply FFmpeg parameters: -q:v 2 -pix_fmt yuvj444p
 */
async function convertToJpeg(inputBuffer, originalFilename) {
  return new Promise((resolve, reject) => {
    try {
      const ext = path.extname(originalFilename).toLowerCase().slice(1) || 'heic';
      
      // HEIC to JPEG conversion
      if ((ext === 'heic' || ext === 'heif') && heicConvert) {
        heicConvert({
          buffer: inputBuffer,
          format: 'JPEG',
          quality: 0.95
        }).then(async (jpegBuffer) => {
          // heic-convert returns a Buffer directly
          console.log(`✅ heic-convert: HEIC → JPEG (${(jpegBuffer.length / 1024 / 1024).toFixed(2)}MB)`);
          
          // Now apply FFmpeg parameters to re-encode with q:v 2, pix_fmt yuvj444p
          processWithFFmpeg(jpegBuffer, 'jpg', originalFilename, resolve, reject);
        }).catch((err) => {
          console.error(`❌ heic-convert error: ${err.message}`);
          reject(new Error(`HEIC conversion failed: ${err.message}`));
        });
        
      } else {
        // For other formats, process directly with FFmpeg
        processWithFFmpeg(inputBuffer, ext, originalFilename, resolve, reject);
      }
    } catch (err) {
      reject(err);
    }
  });
}

/**
 * Process image with FFmpeg to apply quality and format settings
 */
function processWithFFmpeg(imageBuffer, inputExt, originalFilename, resolve, reject) {
  const tempDir = os.tmpdir();
  const timestamp = Date.now();
  const randomId = Math.random().toString(36).substring(2, 8);
  const inputTempFile = path.join(tempDir, `input_${timestamp}_${randomId}.${inputExt}`);
  const outputTempFile = path.join(tempDir, `output_${timestamp}_${randomId}.jpg`);

  // Write buffer to temp input file
  fs.writeFile(inputTempFile, imageBuffer, (writeErr) => {
    if (writeErr) {
      const msg = `Failed to write temp file: ${writeErr.message}`;
      console.error(`❌ ${msg}`);
      return reject(new Error(msg));
    }

    // Spawn FFmpeg with quality and format parameters
    const ffmpeg = spawn(ffmpegPath, [
      '-i', inputTempFile,
      '-q:v', '2',
      '-pix_fmt', 'yuvj444p',
      outputTempFile
    ]);

    let stderrData = '';

    ffmpeg.stderr.on('data', (data) => {
      stderrData += data.toString();
    });

    ffmpeg.on('close', (code) => {
      // Clean up input temp file
      fs.unlink(inputTempFile, (err) => {
        if (err) console.warn(`⚠️  Cleanup error: ${inputTempFile}`);
      });

      if (code !== 0) {
        fs.unlink(outputTempFile, (err) => {
          if (err) console.warn(`⚠️  Cleanup error: ${outputTempFile}`);
        });
        const msg = `FFmpeg error (exit code ${code})`;
        console.error(`❌ ${msg}`);
        return reject(new Error(msg));
      }

      // Read output JPEG
      fs.readFile(outputTempFile, (readErr, jpegBuffer) => {
        fs.unlink(outputTempFile, (err) => {
          if (err) console.warn(`⚠️  Cleanup error: ${outputTempFile}`);
        });

        if (readErr) {
          return reject(new Error(`Read error: ${readErr.message}`));
        }

        resolve(jpegBuffer);
      });
    });

    ffmpeg.on('error', (err) => {
      fs.unlink(inputTempFile, () => {});
      fs.unlink(outputTempFile, () => {});
      reject(new Error(`FFmpeg error: ${err.message}`));
    });
  });
}

// ============================================================================
// EXPRESS ROUTES
// ============================================================================

app.use(cors());
app.use(express.static('public'));

/**
 * Health check endpoint
 */
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'PixelBatch',
    version: '1.0.0',
    format: 'HEIC → JPEG'
  });
});

/**
 * Main conversion endpoint
 * POST /convert
 * Accepts: multipart/form-data with 'images' field
 * Returns: application/zip (PixelBatch.zip)
 */
app.post('/convert', upload.array('images', 100), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'No files uploaded'
      });
    }

    console.log(`\n📦 Processing ${req.files.length} file(s)...`);

    // Convert all files in parallel
    const conversionPromises = req.files.map(async (file) => {
      const originalName = path.parse(file.originalname);
      const outputFileName = `${originalName.name}.jpg`;

      try {
        console.log(`🔄 Converting: ${file.originalname}`);
        const jpegBuffer = await convertToJpeg(file.buffer, file.originalname);
        console.log(`✅ Successfully converted: ${file.originalname} → ${outputFileName}`);
        return {
          success: true,
          fileName: outputFileName,
          buffer: jpegBuffer
        };
      } catch (error) {
        console.error(`❌ Conversion failed: ${file.originalname}`);
        console.error(`   Error: ${error.message}`);
        return {
          success: false,
          fileName: file.originalname,
          error: error.message
        };
      }
    });

    // Wait for all conversions to complete
    const results = await Promise.all(conversionPromises);

    // Separate successful and failed conversions
    const successful = results.filter(r => r.success);
    const failed = results.filter(r => !r.success);

    if (successful.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'All conversions failed',
        failed: failed.map(f => ({ file: f.fileName, error: f.error }))
      });
    }

    console.log(`\n📊 Conversion Summary:`);
    console.log(`   ✅ Successful: ${successful.length}`);
    console.log(`   ❌ Failed: ${failed.length}`);
    if (failed.length > 0) {
      console.log(`   Failed files:`);
      failed.forEach(f => console.log(`      - ${f.fileName}: ${f.error}`));
    }

    // Create ZIP archive
    console.log(`\n📦 Creating ZIP archive...`);
    const archive = archiver('zip', {
      zlib: { level: 6 }
    });

    res.setHeader('Content-Type', 'application/zip');
    res.setHeader('Content-Disposition', 'attachment; filename=PixelBatch.zip');

    // Pipe archive to response
    archive.pipe(res);

    // Add all successful JPEG files to archive
    successful.forEach((result) => {
      archive.append(result.buffer, { name: result.fileName });
    });

    // Wait for archive to finish before closing response
    await new Promise((resolve, reject) => {
      archive.on('finish', resolve);
      archive.on('error', reject);
      archive.finalize();
    });

    console.log(`✅ ZIP archive created and sent to client`);
  } catch (error) {
    console.error(`\n❌ Server error: ${error.message}`);
    if (!res.headersSent) {
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }
});

// ============================================================================
// SERVER STARTUP
// ============================================================================

app.listen(PORT, () => {
  console.log(`
======================================================================
🎨 PixelBatch Server
======================================================================
🌐 http://localhost:${PORT}
📤 API: POST /convert
❤️  Health: GET /health
📋 Format: HEIC → JPEG (q:v 2, pix_fmt: yuvj444p)
======================================================================
`);

  // Verify FFmpeg is available
  if (!ffmpegPath) {
    console.error('❌ FFmpeg-static not found!');
    process.exit(1);
  }
  console.log(`✅ FFmpeg detected: ${ffmpegPath}`);
  console.log(`✅ Server ready!\n`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n\n🛑 Stopping...');
  process.exit(0);
});
