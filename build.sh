#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="Bootable Installer Creator"
APP_BUNDLE="$SCRIPT_DIR/build/$APP_NAME.app"

echo "Building $APP_NAME..."

# Clean previous build
rm -rf "$SCRIPT_DIR/build"

# Create app bundle structure
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Generate icon if iconset doesn't exist
if [ ! -d "$SCRIPT_DIR/Resources/AppIcon.iconset" ]; then
    echo "Generating app icon..."
    swift "$SCRIPT_DIR/Scripts/GenerateIcon.swift"
fi

# Convert iconset to icns
if [ -d "$SCRIPT_DIR/Resources/AppIcon.iconset" ]; then
    echo "Creating icns from iconset..."
    iconutil -c icns "$SCRIPT_DIR/Resources/AppIcon.iconset" -o "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
fi

# Copy Info.plist
cp "$SCRIPT_DIR/Resources/Info.plist" "$APP_BUNDLE/Contents/"

# Compile Swift source
echo "Compiling Swift source..."
swiftc -o "$APP_BUNDLE/Contents/MacOS/BootableInstallerCreator" \
    -framework Cocoa \
    -target arm64-apple-macos12 \
    "$SCRIPT_DIR/Sources/BootableInstallerCreator.swift"

# Touch the app bundle
touch "$APP_BUNDLE"

echo ""
echo "Build complete: $APP_BUNDLE"
echo ""
echo "To run: open \"$APP_BUNDLE\""
