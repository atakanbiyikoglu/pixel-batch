@echo off
REM PixelBatch - Masaüstü Kısayolu Oluştur
REM Bunu çalıştırarak masaüstüne PixelBatch kısayolu oluştur

setlocal enabledelayedexpansion

cd /d "%~dp0"

REM Tam yol al
set "BATCH_FILE=%~dp0PixelBatch.bat"

REM Masaüstü yolunu al
for /f "tokens=3" %%i in ('reg query "HKEY_CURRENT_USER\Shell Folders" /v Desktop ^| findstr Desktop') do set "DESKTOP=%%i"

REM VBScript oluştur (kısayol yaratmak için)
set "VBS_FILE=%TEMP%\CreateShortcut.vbs"

(
echo Set oWS = WScript.CreateObject("WScript.Shell"^)
echo sLinkFile = "%DESKTOP%\PixelBatch.lnk"
echo Set oLink = oWS.CreateShortcut(sLinkFile^)
echo oLink.TargetPath = "%BATCH_FILE%"
echo oLink.WorkingDirectory = "%~dp0"
echo oLink.Description = "PixelBatch - HEIC'den JPEG'e Dönüştürücü"
echo oLink.IconLocation = "%BATCH_FILE%"
echo oLink.Save
echo WScript.Echo "Kısayol oluşturuldu: " ^& sLinkFile
) > "%VBS_FILE%"

REM VBScript'i çalıştır
cscript.exe "%VBS_FILE%"

REM Temizle
del "%VBS_FILE%"

echo.
echo Masaüstüne kısayol oluşturuldu!
echo Şimdi PixelBatch'i masaüstüdeki kısayoldan çalıştırabilirsin.
echo.
pause
