@echo off
REM PixelBatch - Tüm Hazırlıkları Otomatik Yap
REM Bunu açıp çift tıkla - gerisi her şey kendiliğinden olacak

setlocal enabledelayedexpansion

REM İzin kontrolü - admin yöneticisi gerek
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo Yönetici olarak çalıştır gerekiyor!
    echo.
    echo Lütfen bunu yap:
    echo 1. Bu dosyaya sağ tıkla
    echo 2. "Yönetici olarak çalıştır" seçeneğini seç
    echo.
    pause
    exit /b 1
)

color 0A
cls

echo.
echo ===============================================
echo.
echo   PixelBatch - Otomatik Hazırlık
echo.
echo ===============================================
echo.

REM Node.js'i kontrol et
where node >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    REM Node.js bulundu
    echo ✓ Node.js zaten yüklü!
    
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo.
    echo   Sürüm: %NODE_VERSION%
    echo.
    
    REM Kuruluma git
    goto kurulum
)

REM Node.js bulunamadı - yükle
echo ✗ Node.js bulunamadı, indiriliyor...
echo.

REM İndirme dizini
set TEMP_DIR=%USERPROFILE%\AppData\Local\Temp\PixelBatch
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

REM Node.js LTS indir (v18 stable)
set NODE_URL=https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi
set NODE_INSTALLER=%TEMP_DIR%\node-setup.msi

echo İndiriliyor: %NODE_URL%
echo Nereye: %NODE_INSTALLER%
echo.

REM PowerShell ile indir
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('%NODE_URL%', '%NODE_INSTALLER%')} ; if ($?) { echo '✓ İndirme tamam' } else { echo '✗ İndirme başarısız'; exit 1 }"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ✗ HATA: Node.js indirilenemedi!
    echo.
    echo Çözüm: İnternet bağlantısını kontrol et ve tekrar dene.
    echo.
    pause
    exit /b 1
)

echo.
echo İndirme tamam!
echo.
echo Node.js kuruluyor... (1-2 dakika sürebilir)
echo.

REM Node.js'i sessizce kur
msiexec /i "%NODE_INSTALLER%" /quiet /norestart

echo.
echo ✓ Node.js kuruldu!
echo.

REM Geçici dosyaları sil
del "%NODE_INSTALLER%" /Q

REM Node.js'i PATH'e ekle veya sistemin algılaması için bekle
timeout /t 3 /nobreak

:kurulum
REM Şimdi PixelBatch kurulumuna geç
cls
echo.
echo ===============================================
echo.
echo   PixelBatch Kurulumu
echo.
echo ===============================================
echo.

cd /d "%~dp0"

REM Node.js'i yeniden kontrol et
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ✓ Node.js kuruldu ama PATH güncellenmemiş.
    echo.
    echo Bilgisayarı yeniden başlatıyor...
    echo (Yeniden başladıktan sonra PixelBatch.bat'ı açabilirsin)
    echo.
    pause
    
    REM Yeniden başlat
    shutdown /r /t 30 /c "PixelBatch kurulumu için yeniden başlatılıyor"
    exit /b 0
)

REM Node.js ve npm versiyonlarını göster
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i

echo ✓ Node.js: %NODE_VERSION%
echo ✓ npm: %NPM_VERSION%
echo.

REM node_modules kontrol et
if exist "%~dp0node_modules" (
    echo ✓ Bağımlılıklar zaten yüklü!
    goto basarili
)

REM Bağımlılıkları yükle
echo PixelBatch bağımlılıkları kuruluyor...
echo (1-2 dakika sürebilir)
echo.

call npm install --production

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ✗ HATA: Bağımlılıklar kurulamadı
    echo.
    pause
    exit /b 1
)

:basarili
cls
color 0B
echo.
echo ===============================================
echo.
echo   ✓ HER ŞEY HAZIR!
echo.
echo ===============================================
echo.
echo Şimdi PixelBatch.bat dosyasını çalıştırabilirsin.
echo.
echo Tarayıcı otomatik açılacak ve fotoğraflarını
echo dönüştürebilirsin!
echo.
echo PixelBatch.bat dosyasını her deferinde
echo çift tıklayarak kullanabilirsin.
echo.
echo ===============================================
echo.
pause
