@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

REM Self-elevating without prompt
net session >nul 2>&1
if errorlevel 1 (
    powershell -Command "Start-Process cmd.exe -ArgumentList '/c cd /d ""%~dp0"" && ""%~0""' -Verb RunAs" >nul 2>&1
    exit /b 0
)

REM Check Node.js
where node >nul 2>nul
if errorlevel 1 (
    cls
    color 0E
    echo.
    echo Node.js Indiriliyor ve Kuruluyor...
    echo.
    
    set TEMP=%USERPROFILE%\AppData\Local\Temp\PixelBatch
    if not exist "%TEMP%" mkdir "%TEMP%"
    
    set URL=https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi
    set MSI=%TEMP%\node.msi
    
    echo Indirilyor...
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('%URL%', '%MSI%')" >nul 2>&1
    
    if not exist "%MSI%" (
        echo HATA: Indirilmedi.
        pause
        exit /b 1
    )
    
    echo Kurulyor...
    msiexec /i "%MSI%" /quiet /norestart >nul 2>&1
    del "%MSI%" /Q >nul 2>&1
    
    echo Kuruldu.
    echo.
    
    powershell -NoProfile -Command "Start-Process cmd.exe -ArgumentList '/k cd /d ""%~dp0"" ^& node server.js' -NoNewWindow" >nul 2>&1
    exit /b 0
)

color 0A
cls
echo.
echo PixelBatch Hazir
echo.

cd /d "%~dp0"

if not exist node_modules (
    echo Bagimliliklar kuruluyor...
    call npm install --production >nul 2>&1
    if errorlevel 1 (
        echo HATA: npm install
        pause
        exit /b 1
    )
    echo Tamam
    echo.
    
    set LNK=%USERPROFILE%\Desktop\PixelBatch.lnk
    if not exist "%LNK%" (
        echo Masaustu kisayolu yapiliyor...
        powershell -NoProfile -Command "$s = New-Object -ComObject WScript.Shell; $sc = $s.CreateShortcut('%LNK%'); $sc.TargetPath = '%~dp0PixelBatch.bat'; $sc.WorkingDirectory = '%~dp0'; $sc.Save()" >nul 2>&1
        echo Hazir
    )
    echo.
)

echo Sunucu baslatiliyor - Tarayici acilacak
echo.

node server.js %*
echo.
echo Tamamlandi
echo.
pause