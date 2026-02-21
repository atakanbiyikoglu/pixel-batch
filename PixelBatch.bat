@echo off
REM PixelBatch - HEIC'den JPEG'e Dönüştürücü
REM Bunu çift tıkla - Node.js kendiliğinden kurulacak ve açılacak

setlocal enabledelayedexpansion

REM Yönetici kontrolü (Node.js kurulumu için gerekli)
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo UYARI: Node.js'i kurmak için yönetici izin gerekiyor!
    echo.
    echo Lütfen bunu yap:
    echo 1. PixelBatch.bat üzerine sağ tıkla
    echo 2. "Yönetici olarak çalıştır" seçeneğini seç
    echo.
    pause
    exit /b 1
)

REM Node.js kontrol et
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    color 0C
    cls
    echo.
    echo ===============================================
    echo.
    echo   PixelBatch - Node.js Kuruluyor...
    echo.
    echo ===============================================
    echo.
    
    REM İndirme dizini
    set TEMP_DIR=%USERPROFILE%\AppData\Local\Temp\PixelBatch
    if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
    
    set NODE_URL=https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi
    set NODE_INSTALLER=%TEMP_DIR%\node-setup.msi
    
    echo Node.js indiriliyor...
    echo.
    
    REM PowerShell ile indir
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('%NODE_URL%', '%NODE_INSTALLER%')} ; if ($?) { echo 'ok' } else { echo 'hata'; exit 1 }" >nul 2>&1
    
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo ✗ HATA: Node.js indirilenemedi!
        echo.
        echo İnternet bağlantını kontrol et v tekrar dene.
        echo.
        pause
        exit /b 1
    )
    
    echo ✓ İndirme tamam!
    echo.
    echo Node.js kuruluyor (1-2 dakika)...
    echo.
    
    REM Node.js'i sessizce kur
    msiexec /i "%NODE_INSTALLER%" /quiet /norestart >nul 2>&1
    
    echo ✓ Kurulum tamam!
    echo.
    
    REM Geçici dosyaları sil
    del "%NODE_INSTALLER%" /Q >nul 2>&1
    
    REM Cache yenile
    timeout /t 2 /nobreak >nul 2>&1
    
    REM Node.js PATH'te mi kontrol et
    where node >nul 2>nul
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo ✓ Node.js kuruldu ama PATH güncellemesi gerekiyor.
        echo.
        echo Bilgisayarı yeniden başlatıyor...
        echo (Başladıktan sonra PixelBatch.bat'ı tekrar aç)
        echo.
        
        timeout /t 5 /nobreak
        shutdown /r /t 30 /c "PixelBatch Node.js kurulumu" >nul 2>&1
        exit /b 0
    )
)

color 0A
cls

echo.
echo ===============================================
echo.
echo   PixelBatch - HEIC'den JPEG'e Dönüştürücü
echo.
echo ===============================================
echo.

REM Node.js ve npm versiyonlarını göster
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i

echo ✓ Node.js: %NODE_VERSION%
echo ✓ npm: %NPM_VERSION%
echo.

REM node_modules kontrol et
cd /d "%~dp0"
if not exist node_modules (
    echo Bağımlılıklar yükleniyor...
    echo.
    call npm install --production >nul 2>&1
    
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo ✗ HATA: Bağımlılıklar kurulamadı
        echo.
        pause
        exit /b 1
    )
    
    echo ✓ Kurulum tamamlandı!
    echo.
)

echo Sunucu http://localhost:3000'da çalışıyor...
echo.
echo Tarayıcı otomatik açılıyor...
echo Açılmazsa: http://localhost:3000 adresine git
echo.

REM Server'ı başlat
start node server.js

REM Tarayıcıyı aç
timeout /t 3 /nobreak >nul 2>&1
powershell -NoProfile -WindowStyle Hidden -Command "Start-Process 'http://localhost:3000'" >nul 2>&1

echo.
echo Durdur: Ctrl+C
echo.

REM Server'ı çalıştırmaya devam et
node server.js
