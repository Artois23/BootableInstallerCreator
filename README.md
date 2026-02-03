# Bootable Installer Creator

A native macOS app for creating bootable macOS installers on USB drives.

## Features

- Native AppKit interface
- Browse and select macOS installer apps
- Browse and select target USB volume
- Real-time progress bar during creation
- Status updates for each stage of the process

## Requirements

- macOS 12.0 or later
- A macOS installer app (downloaded from App Store or Apple)
- A USB drive (8GB+ recommended)

## Building

```bash
chmod +x build.sh
./build.sh
```

The built app will be in `build/Bootable Installer Creator.app`

## Usage

1. Launch the app
2. Click "Browse..." to select a macOS installer (e.g., "Install macOS Sequoia.app")
3. Click "Browse..." to select your target USB volume
4. Click "Create Bootable Installer"
5. Enter your administrator password when prompted
6. Wait for the process to complete

**Warning:** The target USB volume will be completely erased!

## License

MIT License
