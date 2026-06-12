# TG WS Proxy — iOS Build (Cross-compile from Windows/Mac)
# On Windows: make go-lib  (компилирует Go static library)
# On Mac: make xcframework (создаёт XCFramework из .a файлов)

APP_NAME := TgWsProxy
LIB_NAME := libtgwsproxy
BUILD_DIR := build

.PHONY: all go-lib xcframework clean

all: go-lib

# Кросс-компиляция Go → iOS static library (работает на Windows/Linux/Mac)
go-lib:
	@echo "==> Building $(LIB_NAME).a for iOS device (arm64)"
	@mkdir -p $(BUILD_DIR)/ios
	GOOS=ios GOARCH=arm64 CGO_ENABLED=1 \
		go build -buildmode=c-archive -o $(BUILD_DIR)/ios/$(LIB_NAME).a .

	@echo "==> Building $(LIB_NAME).a for iOS Simulator (arm64)"
	@mkdir -p $(BUILD_DIR)/sim
	GOOS=ios GOARCH=arm64 CGO_ENABLED=1 \
		GOFLAGS="-tags=iossimulator" \
		go build -buildmode=c-archive -o $(BUILD_DIR)/sim/$(LIB_NAME).a .

	@echo "==> Done: $(BUILD_DIR)/ios/ and $(BUILD_DIR)/sim/"

# Только для Mac — создаёт XCFramework из готовых .a файлов
xcframework: go-lib
	@echo "==> Creating XCFramework"
	xcodebuild -create-xcframework \
		-library $(BUILD_DIR)/ios/$(LIB_NAME).a -headers include \
		-library $(BUILD_DIR)/sim/$(LIB_NAME).a -headers include \
		-output $(BUILD_DIR)/$(APP_NAME).xcframework
	@echo "==> Done: $(BUILD_DIR)/$(APP_NAME).xcframework"

clean:
	@echo "==> Cleaning build artifacts"
	rm -rf $(BUILD_DIR)
