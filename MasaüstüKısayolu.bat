@echo off
REM PixelBatch - Masaüstü Kısayolu Oluştur
chcp 65001 >nul
setlocal enabledelayedexpansion

color 0A
cls

echo.
echo ===============================================
echo.
echo   📌 Masaüstü Kısayolu Oluşturuluyor...
echo.
echo ===============================================
echo.

cd /d "%~dp0"

REM Tam yol al
set "BATCH_FILE=%~dp0PixelBatch.bat"

REM Masaüstü yolunu al
for /f "tokens=3" %%i in ('reg query "HKEY_CURRENT_USER\Shell Folders" /v Desktop ^| findstr Desktop') do set "DESKTOP=%%i"

REM VBScript oluştur (kısayol yaratmak için)
set "VBS_FILE=%TEMP%\CreateShortcut_%RANDOM%.vbs"

(
echo Set oWS = WScript.CreateObject("WScript.Shell"^)
echo sLinkFile = "%DESKTOP%\PixelBatch.lnk"
echo Set oLink = oWS.CreateShortcut(sLinkFile^)
echo oLink.TargetPath = "%BATCH_FILE%"
echo oLink.WorkingDirectory = "%~dp0"
echo oLink.Description = "PixelBatch - HEIC'den JPEG'e Dönüştürücü"
echo oLink.IconLocation = "%BATCH_FILE%"
echo oLink.Save
) > "%VBS_FILE%"

REM VBScript'i çalıştır
cscript.exe "%VBS_FILE%" //Nologo >nul 2>&1

REM Temizle
del "%VBS_FILE%" /Q >nul 2>&1

REM Kontrol et
if exist "%DESKTOP%\PixelBatch.lnk" (
    color 0B
    cls
    echo.
    echo ===============================================
    echo.
    echo   ✓ Masaüstü Kısayolu Oluşturuldu!
    echo.
    echo ===============================================
    echo.
    echo Masaüstüne "PixelBatch" simgesi eklendi.
    echo.
    echo Çift tıkla ve başla! 🚀
    echo.
) else (
    color 0E
    cls
    echo.
    echo ===============================================
    echo.
    echo   ⚠️  Kısayol Oluşturanamadı
    echo.
    echo ===============================================
    echo.
    echo Çözüm: Dosya Gezgini'nde
    echo PixelBatch.bat'ı masaüstüne
    echo sürükle-bırak yap. O da harika çalışır!
    echo.
)

pause
