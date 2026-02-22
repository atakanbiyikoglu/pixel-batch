@echo off
REM PixelBatch - HEIC'den JPEG'e Dönüştürücü
chcp 65001 >nul
setlocal enabledelayedexpansion

REM Self-elevating (admin otomatik)
net session >nul 2>&1
if %errorlevel% neq 0 (
    set "VBS_ELEVATE=%temp%\elevate_%random%.vbs"
    (
        echo Set objShell = CreateObject("Shell.Application"^)
        echo objShell.ShellExecute "cmd.exe", "/c cd /d ""%~dp0"" && ""%~0""", "", "runas", 1
    ) > "%VBS_ELEVATE%"
    cscript.exe "%VBS_ELEVATE%" //nologo >nul 2>&1
    del "%VBS_ELEVATE%" /Q >nul 2>&1
    exit /b 0
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
    
    REM İlk kurulumda masaüstü kısayolunu otomatik oluştur
    echo Masaüstü kısayolu oluşturuluyor...
    set "VBS_SHORTCUT=%temp%\mkshortcut_%random%.vbs"
    (
        echo Set oWS = WScript.CreateObject("WScript.Shell"^)
        echo For Each fold In oWS.SpecialFolders
        echo     If fold = 16 Then
        echo         sLinkFile = oWS.SpecialFolders(16^) ^& "\PixelBatch.lnk"
        echo         Set oLink = oWS.CreateShortcut(sLinkFile^)
        echo         oLink.TargetPath = "%~dp0PixelBatch.bat"
        echo         oLink.WorkingDirectory = "%~dp0"
        echo         oLink.Description = "PixelBatch - HEIC'den JPEG'e Dönüştürücü"
        echo         oLink.IconLocation = "%~dp0PixelBatch.bat"
        echo         oLink.Save
        echo     End If
        echo Next
    ) > "%VBS_SHORTCUT%"
    cscript.exe "%VBS_SHORTCUT%" //nologo >nul 2>&1
    del "%VBS_SHORTCUT%" /Q >nul 2>&1
    echo ✓ Masaüstü kısayolu oluşturuldu!
    echo.
)

echo Sunucu başlatılıyor...
echo Tarayıcı açılacak...
echo.

REM Server başlat ve tarayıcıyı aç
echo Sunucu başlıyor %TIME%...
node server.js %*
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ✗ HATA: Sunucu başlanamadı
    echo Kontrol et: port 3000 kullanımda mı?
    echo.
)
echo.
echo ✓ Tamamlandı
echo.
pause
