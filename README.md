# TG WS Proxy iOS

MTProto-прокси для Telegram на iOS через CloudFlare WebSocket.

## Требования

- Go 1.19+ (для компиляции ядра)
- macOS с Xcode 15+ (для финальной сборки .ipa)
- iOS 16+

## Быстрый старт

### Вариант 1: GitHub Actions (рекомендуется, без Mac)

1. Создайте репозиторий на GitHub
2. Запушьте проект
3. Go → Actions → Build iOS App → Run workflow
4. Скачайте `.app` из Artifacts

### Вариант 2: Сборка на Windows (только проверка кода)

```cmd
cd tg-ws-proxy-ios
check_windows.bat
```

Проверяет Go-код. Для полной сборки нужен Mac.

### Вариант 3: Сборка на macOS (полная)

```bash
cd tg-ws-proxy-ios
chmod +x build_ios.sh
./build_ios.sh
```

### Открытие в Xcode

1. Откройте `TgWsProxy.xcodeproj` в Xcode
2. Перетащите `build/TgWsProxy.xcframework` в проект
3. Выберите схему `TgWsProxy` и запустите (Cmd+R)

### Использование

1. Откройте приложение
2. Нажмите на логотип для запуска прокси
3. Нажмите "Применить в Telegram"
4. Подтвердите подключение в Telegram

## Структура проекта

```
tg-ws-proxy-ios/
├── tg-ws-proxy.go          # Ядро прокси (Go)
├── include/                 # C-заголовок
├── Makefile                # Сборка Go → iOS
├── build_ios.sh            # Скрипт сборки (macOS)
├── build_windows.bat       # Скрипт сборки (Windows)
├── check_windows.bat       # Проверка кода (Windows)
├── .github/workflows/      # GitHub Actions (автосборка)
├── TgWsProxy/
│   ├── TgWsProxyApp.swift  # Entry point
│   ├── Bridge/             # Bridging header
│   ├── Core/               # ProxyManager, LogManager
│   ├── Views/              # SwiftUI views (4 tabs)
│   ├── Models/             # SettingsStore
│   └── Theme/              # Colors
└── TgWsProxy.xcodeproj/
```

## Функционал

- **Proxy** — запуск/остановка прокси, статус, статистика
- **Settings** — настройки порта, DC адресов, CloudFlare, WS Pool
- **Logs** — просмотр логов в реальном времени
- **Info** — справка, ссылки на проект

## Отличия от Android версии

| Функция | Android | iOS |
|---------|---------|-----|
| Ядро | Go (CGO + JNA) | Go (CGO static lib) |
| UI | Jetpack Compose | SwiftUI |
| Хранение | DataStore | UserDefaults |
| Фон | Foreground Service | BGTaskScheduler |
| Автозапуск | BootReceiver | Не поддерживается |

## Лицензия

GPLv3
