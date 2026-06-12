#!/bin/bash
set -e

echo "=== TG WS Proxy iOS — Build Script ==="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BUILD_DIR="build"
APP_NAME="TgWsProxy"

# Check Go
if ! command -v go &> /dev/null; then
    echo "ERROR: Go not found. Install from https://go.dev/dl/"
    exit 1
fi
echo "Go version: $(go version)"

# Check Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "ERROR: Xcode Command Line Tools not found."
    exit 1
fi
echo "Xcode found: $(xcode-select -p)"

# Check iOS SDK
if ! xcrun --sdk iphoneos --show-sdk-path &> /dev/null; then
    echo "ERROR: iOS SDK not found. Install Xcode from App Store."
    exit 1
fi
echo "iOS SDK: $(xcrun --sdk iphoneos --show-sdk-path)"

echo ""
echo "--- Step 1: Building static library for iOS device ---"
make ios

echo ""
echo "--- Step 2: Building static library for iOS Simulator ---"
make ios-sim

echo ""
echo "--- Step 3: Creating XCFramework ---"
make xcframework

echo ""
echo "=== Build complete! ==="
echo "XCFramework: $BUILD_DIR/$APP_NAME.xcframework"
echo ""
echo "To use in Xcode:"
echo "  1. Open your Xcode project"
echo "  2. Drag $BUILD_DIR/$APP_NAME.xcframework into your project"
echo "  3. Add bridging header: TgWsProxy-Bridging-Header.h"
