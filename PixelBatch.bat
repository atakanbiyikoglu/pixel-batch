@echo off
REM PixelBatch - HEIC'den JPEG'e Dönüştürücü - NO RESTART!
chcp 65001 >nul
setlocal enabledelayedexpansion

REM Yönetici kontrolü
net session >nul 2>&1
if %errorlevel% neq 0 (
    cls
    color 0C
    echo.
    echo ⚠️  UYARI: Yönetici İzni Gerekli
    echo.
    echo Lütfen bunu yap:
    echo   1. PixelBatch.bat'a SAĞ TIKLA
    echo   2. "Yönetici olarak çalıştır" seçeneğini seç
    echo.
    pause
    exit /b 1
)

REM Node.js kontrol et
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    cls
    color 0E
    echo.
    echo ===============================================
    echo   Node.js İndiriliyor ve Kuruluyor
    echo ===============================================
    echo.
    echo Lütfen bekle - 2-3 dakika...
    echo.
    
    set TEMP_DIR=%USERPROFILE%\AppData\Local\Temp\PixelBatch
    if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
    
    set NODE_URL=https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi
    set NODE_INSTALLER=%TEMP_DIR%\node-setup.msi
    
    echo İndiriliyor...
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('%NODE_URL%', '%NODE_INSTALLER%')" >nul 2>&1
    
    if not exist "%NODE_INSTALLER%" (
        echo ✗ HATA: İndirilemedi. İnternet kontrol et.
        pause
        exit /b 1
    )
    
    echo ✓ İndirme tamam. Kuruluyor...
    msiexec /i "%NODE_INSTALLER%" /quiet /norestart >nul 2>&1
    del "%NODE_INSTALLER%" /Q >nul 2>&1
    
    echo ✓ Node.js kuruldu!
    timeout /t 2 >nul
    
    echo.
    echo Şimdi PixelBatch açılıyor...
    echo.
    timeout /t 1 >nul
    
    REM Freshly spawn PowerShell (PATH güncellenir)
    powershell -NoProfile -Command "Start-Process cmd.exe -ArgumentList '/k cd /d \"%~dp0\" ^& node server.js' -NoNewWindow" >nul 2>&1
    exit /b 0
)

REM Node.js var - normal başla
color 0A
cls
echo.
echo ===============================================
echo   🎉 PixelBatch Hazır!
echo ===============================================
echo.

cd /d "%~dp0"

if not exist node_modules (
    echo Bağımlılıklar yükleniyor...
    call npm install --production >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo ✗ HATA: npm install başarısız
        pause
        exit /b 1
    )
    echo ✓ Kurulum tamam!
    echo.
)

echo Sunucu başlatılıyor...
echo Tarayıcı açılacak...
echo.

REM Server başlat ve tarayıcıyı aç
start "" node server.js
timeout /t 2 >nul
powershell -NoProfile -WindowStyle Hidden -Command "Start-Process 'http://localhost:3000'" >nul 2>&1

echo ✓ Tarayıcı açılıyor: http://localhost:3000
echo.
echo Durdur: Ctrl+C
echo.
pause
