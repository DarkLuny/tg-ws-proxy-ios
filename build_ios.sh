#!/bin/bash
set -e

echo "=== TG WS Proxy iOS — Build Script ==="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BUILD_DIR="build"
APP_NAME="TgWsProxy"

if ! command -v go &> /dev/null; then
    echo "ERROR: Go not found. Install from https://go.dev/dl/"
    exit 1
fi

if ! command -v xcodebuild &> /dev/null; then
    echo "ERROR: Xcode Command Line Tools not found."
    exit 1
fi

echo "--- Step 1: Building XCFramework ---"
mkdir -p $BUILD_DIR/ios $BUILD_DIR/sim

CGO_ENABLED=1 GOOS=ios GOARCH=arm64 \
  CC=$(xcrun --sdk iphoneos -f clang) \
  CFLAGS="-isysroot $(xcrun --sdk iphoneos --show-sdk-path) -arch arm64 -mios-version-min=16.0" \
  go build -v -buildmode=c-archive -o $BUILD_DIR/ios/libtgwsproxy.a .

CGO_ENABLED=1 GOOS=ios GOARCH=arm64 \
  CC=$(xcrun --sdk iphonesimulator -f clang) \
  CFLAGS="-isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) -arch arm64 -mios-simulator-version-min=16.0" \
  go build -buildmode=c-archive -o $BUILD_DIR/sim/libtgwsproxy.a .

xcodebuild -create-xcframework \
  -library $BUILD_DIR/ios/libtgwsproxy.a -headers include \
  -library $BUILD_DIR/sim/libtgwsproxy.a -headers include \
  -output $BUILD_DIR/$APP_NAME.xcframework

echo ""
echo "--- Step 2: Building .app ---"
xcodebuild archive \
  -project TgWsProxy.xcodeproj \
  -scheme $APP_NAME \
  -configuration Release \
  -archivePath $BUILD_DIR/$APP_NAME.xcarchive \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  AD_HOC_CODE_SIGNING_ALLOWED=YES

echo ""
echo "--- Step 3: Creating .ipa ---"
mkdir -p $BUILD_DIR/ipa/Payload
cp -r $BUILD_DIR/$APP_NAME.xcarchive/Products/Applications/$APP_NAME.app $BUILD_DIR/ipa/Payload/
cd $BUILD_DIR/ipa
zip -r ../$APP_NAME.ipa Payload/
cd ../..

echo ""
echo "=== Done! ==="
echo "  IPA: $BUILD_DIR/$APP_NAME.ipa"
echo ""
echo "Установка на iPhone:"
echo "  1. AltStore: https://altstore.io"
echo "  2. Sideloadly: https://sideloadly.io"
echo "  3. iTunes/Finder: перетащите .ipa в Devices"
