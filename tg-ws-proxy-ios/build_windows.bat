@echo off
REM TG WS Proxy iOS — Build Script (Windows)
REM Компилирует Go static library для iOS из Windows

setlocal

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo === TG WS Proxy iOS — Windows Build ===
echo.

REM Check Go
where go >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Go not found. Install from https://go.dev/dl/
    exit /b 1
)
go version
echo.

echo --- Step 1: Building static library for iOS device (arm64) ---
if not exist "build\ios" mkdir "build\ios"
set GOOS=ios
set GOARCH=arm64
set CGO_ENABLED=1
go build -buildmode=c-archive -o build\ios\libtgwsproxy.a .

echo --- Step 2: Building static library for iOS Simulator (arm64) ---
if not exist "build\sim" mkdir "build\sim"
set GOOS=ios
set GOARCH=arm64
set CGO_ENABLED=1
go build -buildmode=c-archive -o build\sim\libtgwsproxy.a .

echo.
echo === Build complete! ===
echo Static libraries:
echo   Device:  build\ios\libtgwsproxy.a
echo   Simulator: build\sim\libtgwsproxy.a
echo.
echo Next steps:
echo   1. Copy this project to a Mac
echo   2. Run: make xcframework
echo   3. Open TgWsProxy.xcodeproj in Xcode
echo   4. Drag build\TgWsProxy.xcframework into project
echo   5. Cmd+R to build and run

endlocal
