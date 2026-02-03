# Technical Specification

## Overview

Bootable Installer Creator is a native macOS application built with AppKit that provides a graphical interface for Apple's `createinstallmedia` command-line tool.

## Architecture

### Technology Stack

- **Language:** Swift
- **Framework:** AppKit (Cocoa)
- **Minimum macOS Version:** 12.0 (Monterey)
- **Architecture:** ARM64 (Apple Silicon)

### Application Structure

```
┌─────────────────────────────────────┐
│           NSApplication             │
├─────────────────────────────────────┤
│           AppDelegate               │
│  - Creates main window              │
│  - Manages app lifecycle            │
├─────────────────────────────────────┤
│        MainViewController           │
│  - UI layout and controls           │
│  - File selection handling          │
│  - Process execution                │
│  - Progress parsing                 │
└─────────────────────────────────────┘
```

### Key Components

#### AppDelegate
- Initializes the main application window
- Sets window properties (size, style, title)
- Handles application lifecycle events

#### MainViewController
- **UI Elements:**
  - Installer path field and browse button
  - Volume path field and browse button
  - Warning box with caution message
  - Progress bar (determinate, 0-100%)
  - Status label for current operation
  - Create button to initiate process

- **Core Methods:**
  - `browseInstaller()` - Opens NSOpenPanel for .app selection
  - `browseVolume()` - Opens NSOpenPanel for volume selection
  - `createInstaller()` - Validates inputs and starts creation
  - `promptForPassword()` - Displays secure password dialog
  - `runCreateInstallMedia()` - Executes the command with sudo
  - `parseOutput()` - Parses progress from command output

## Process Flow

```
1. User selects macOS installer app
   └── Validates createinstallmedia exists in bundle

2. User selects target USB volume
   └── Path stored for createinstallmedia --volume argument

3. User clicks "Create Bootable Installer"
   └── Confirmation dialog displayed

4. User enters administrator password
   └── Secure text field, not stored

5. createinstallmedia executes
   ├── Password piped via stdin to sudo -S
   ├── stdout/stderr monitored for progress
   └── UI updated in real-time

6. Process completes
   └── Success/failure dialog displayed
```

## Progress Tracking

The app parses `createinstallmedia` output to track progress:

| Stage | Output Pattern | Progress Range |
|-------|---------------|----------------|
| Erasing | `Erasing disk: X%` | 0-10% |
| Essential files | `Copying essential files` | 12% |
| Recovery OS | `Copying the macOS RecoveryOS` | 15% |
| Making bootable | `Making disk bootable` | 18% |
| Copying installer | `Copying to disk: X%` | 20-100% |

## Security Considerations

- Password is collected via NSSecureTextField (masked input)
- Password is immediately passed to sudo via stdin pipe
- Password is not stored or logged
- Uses `sudo -S` to read password from stdin
- Process runs with elevated privileges only for createinstallmedia

## Build System

### Build Script (`build.sh`)

1. Cleans previous build directory
2. Creates app bundle structure
3. Generates icon (if needed) via GenerateIcon.swift
4. Converts iconset to icns via `iconutil`
5. Copies Info.plist to bundle
6. Compiles Swift source with `swiftc`

### Compilation Flags

```bash
swiftc -o <output> \
    -framework Cocoa \
    -target arm64-apple-macos12 \
    <source.swift>
```

## Dependencies

- **External:** None (pure AppKit)
- **System Tools:**
  - `sudo` - Privilege elevation
  - `createinstallmedia` - Bundled in macOS installers
  - `swiftc` - Swift compiler (Xcode Command Line Tools)
  - `iconutil` - Icon conversion tool

## Limitations

- ARM64 only (modify build.sh for Intel support)
- Requires macOS installer app from App Store
- USB drive must be mounted and accessible
- No code signing (will show Gatekeeper warning)
