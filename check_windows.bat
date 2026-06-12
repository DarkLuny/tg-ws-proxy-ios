@echo off
REM TG WS Proxy iOS — Quick Check (Windows, без CGO)
REM Проверяет что Go-код компилируется (без C-экспорта)

setlocal

cd /d "%~dp0"

echo === TG WS Proxy — Quick Check (Windows) ===
echo.

REM Проверяем синтаксис Go
go vet ./...
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Go vet failed
    exit /b 1
)

echo.
echo === Go code OK ===
echo.
echo To build for iOS, you need:
echo   1. A Mac with Xcode, OR
echo   2. Push to GitHub (auto-builds via Actions)
echo.

endlocal
