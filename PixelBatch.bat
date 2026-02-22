@echo off
REM PixelBatch - HEIC'den JPEG'e Dönüştürücü
chcp 65001 >nul
setlocal enabledelayedexpansion

REM Yönetici kontrolü (Node.js kurulumu için gerekli)
net session >nul 2>&1
if %errorlevel% neq 0 (
    cls
    color 0C
    echo.
    echo ⚠️  UYARI: Yönetici İzni Gerekli
    echo.
    echo PixelBatch'i çalıştırmak için yönetici izni gereklidir.
    echo.
    echo Lütfen bunu yap:
    echo   1. PixelBatch.bat dosyasına SAĞ TIKLA
    echo   2. "Yönetici olarak çalıştır" seçeneğini seç
    echo.
    echo Sonrasında otomatik olarak kurulacak ve açılacak.
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
    echo   ⬇️  Node.js İndiriliyor ve Kuruluyor...
    echo.
    echo ===============================================
    echo.
    echo Lütfen bekle - bu 2-3 dakika sürebilir
    echo.
    
    REM İndirme dizini
    set TEMP_DIR=%USERPROFILE%\AppData\Local\Temp\PixelBatch
    if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
    
    set NODE_URL=https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi
    set NODE_INSTALLER=%TEMP_DIR%\node-setup.msi
    
    echo İndiriliyor...
    echo.
    
    REM PowerShell ile indir
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('%NODE_URL%', '%NODE_INSTALLER%')} ; if ($?) { echo 'OK' } else { echo 'HATA'; exit 1 }" >nul 2>&1
    
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo ✗ HATA: Node.js indirilenemedi!
        echo.
        echo Çözüm:
        echo   - İnternet bağlantısını kontrol et
        echo   - Firewall/Antivirus engeli olmadığını kontrol et
        echo   - Tekrar dene
        echo.
        pause
        exit /b 1
    )
    
    echo ✓ İndirme tamam!
    echo.
    echo Kuruluyor...
    echo.
    
    REM Node.js'i sessizce kur
    msiexec /i "%NODE_INSTALLER%" /quiet /norestart >nul 2>&1
    
    echo ✓ Node.js kuruldu!
    echo.
    
    REM Geçici dosyaları sil
    del "%NODE_INSTALLER%" /Q >nul 2>&1
    
    REM Cache yenile
    timeout /t 2 /nobreak >nul 2>&1
    
    REM Node.js PATH'te mi kontrol et
    where node >nul 2>nul
    if %ERRORLEVEL% NEQ 0 (
        color 0E
        cls
        echo.
        echo ===============================================
        echo.
        echo   ⚠️  BİLGİSAYAR YENİDEN BAŞLATILACAK
        echo.
        echo ===============================================
        echo.
        echo Node.js PATH'e eklenmesi için bilgisayarın
        echo yeniden başlatılması gerekiyor.
        echo.
        echo Lütfen tüm çalışmalarını KAY­DET!
        echo.
        echo Yeniden başlatma: 10 saniye sonra
        echo Durdurmak için: Ctrl+C tuşlarına bas
        echo.
        
        timeout /t 10 /nobreak
        shutdown /r /t 30 /c "PixelBatch Node.js Kurulumu - Yeniden Başlatıyor" >nul 2>&1
        
        echo.
        echo Bilgisayar yeniden başlatılıyor...
        echo Başladıktan sonra PixelBatch.bat'ı tekrar açabilirsin.
        echo.
        pause
        exit /b 0
    )
)

color 0A
cls

echo.
echo ===============================================
echo.
echo   🎉 PixelBatch Hazır!
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
    echo (1-2 dakika sürebilir)
    echo.
    call npm install --production >nul 2>&1
    
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo ✗ HATA: Bağımlılıklar kurulamadı
        echo.
        echo Çözüm:
        echo   - İnternet bağlantısını kontrol et
        echo   - PixelBatch.bat'ı yeniden sakla ve aç
        echo.
        pause
        exit /b 1
    )
    
    echo ✓ Kurulum tamamlandı!
    echo.
)

echo Sunucu başlatılıyor...
echo Tarayıcı otomatik açılacak...
echo.
echo Durdur: Ctrl+C tuşlarına bas
echo.

REM Server'ı başlat
start "" node server.js

REM Tarayıcıyı aç (3 saniye sonra)
timeout /t 3 /nobreak >nul 2>&1
powershell -NoProfile -WindowStyle Hidden -Command "Start-Process 'http://localhost:3000'" >nul 2>&1

REM Server'ı ön planda çalış
waitfor /t 999 serverRunning 2>nul
