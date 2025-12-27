#!/bin/bash

# Simple SnipeX DMG Creation Script
# Creates a basic distributable DMG file for macOS

set -e

APP_NAME="SnipeX"
APP_PATH="build/Build/Products/Release/sniper.app"
DMG_NAME="SnipeX-v1.0"
FINAL_DMG="${DMG_NAME}.dmg"
VOLUME_NAME="SnipeX Installer"

echo "🔨 Creating DMG for ${APP_NAME}..."

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ App not found at $APP_PATH. Please build the app first."
    exit 1
fi

# Clean up any existing DMG files
rm -f "$FINAL_DMG"

# Create a temporary directory for DMG contents
TEMP_DIR=$(mktemp -d)
echo "📁 Using temporary directory: $TEMP_DIR"

# Copy the app to temp directory
echo "📦 Copying app to DMG staging area..."
cp -R "$APP_PATH" "$TEMP_DIR/"

# Rename the app to SnipeX for better user experience
mv "$TEMP_DIR/sniper.app" "$TEMP_DIR/SnipeX.app"

# Create Applications symlink for easy installation
echo "🔗 Creating Applications symlink..."
ln -s /Applications "$TEMP_DIR/Applications"

# Create a README file for users
cat > "$TEMP_DIR/README.txt" << EOF
SnipeX - Screen Intelligence for macOS
=====================================

Installation Instructions:
1. Drag SnipeX.app to the Applications folder
2. Open SnipeX from Applications or Launchpad
3. Grant Screen Recording permission when prompted
4. Use ⌘⇧2 to capture text from anywhere on screen

Features:
• Intelligent text extraction from screenshots
• Multiple language OCR support
• Modern Dynamic Island-style notifications
• Menu bar and dock integration
• Export to various formats (TXT, MD, CSV, JSON, LaTeX)
• Smart content classification
• Capture history with search

For support and updates:
https://github.com/htrap1211/SnipeX

Enjoy using SnipeX!
EOF

echo "💾 Creating compressed DMG..."

# Create the DMG directly in compressed format
hdiutil create -srcfolder "$TEMP_DIR" -volname "$VOLUME_NAME" -fs HFS+ -format UDZO -imagekey zlib-level=9 "$FINAL_DMG"

# Clean up temporary files
rm -rf "$TEMP_DIR"

# Get final DMG size
DMG_SIZE_FINAL=$(du -h "$FINAL_DMG" | cut -f1)

echo "✅ DMG created successfully!"
echo ""
echo "📦 DMG Details:"
echo "   File: $FINAL_DMG"
echo "   Size: $DMG_SIZE_FINAL"
echo "   Location: $(pwd)/$FINAL_DMG"
echo ""
echo "🚀 Ready for distribution!"
echo "   Users can download and install by dragging SnipeX.app to Applications"
echo ""
echo "📋 Next steps:"
echo "1. Test the DMG by mounting it and installing the app"
echo "2. Upload $FINAL_DMG to GitHub releases"
echo "3. Share the download link with users"