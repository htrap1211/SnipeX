#!/bin/bash

# Screen Intelligence Build Script
# This script builds the macOS app and handles basic setup

set -e

echo "🔨 Building Screen Intelligence..."

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode command line tools not found. Please install Xcode."
    exit 1
fi

# Build the project
echo "📦 Building project..."
xcodebuild -project sniper.xcodeproj -scheme sniper -configuration Release -derivedDataPath build

echo "✅ Build completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Open the built app from build/Build/Products/Release/sniper.app"
echo "2. Grant Screen Recording permission in System Settings"
echo "3. Grant Accessibility permission (optional, for app detection)"
echo "4. Press ⌘⇧2 to start capturing text!"
echo ""
echo "🎯 The app is now ready to use!"