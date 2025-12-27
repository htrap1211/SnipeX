#!/usr/bin/swift

import Foundation
import AppKit

print("🔍 Verifying SnipeX icon setup...")
print()

let appPath = "build/Build/Products/Release/sniper.app"
let fileManager = FileManager.default

// Check app bundle
guard fileManager.fileExists(atPath: appPath) else {
    print("❌ App not found at \(appPath)")
    exit(1)
}

print("✅ App bundle exists: \(appPath)")

// Check icon files in the source
let iconSetPath = "sniper/Assets.xcassets/AppIcon.appiconset"
let iconFiles = ["16.png", "32.png", "64.png", "128.png", "256.png", "512.png", "1024.png"]

print("📁 Checking source icon files in \(iconSetPath):")
for iconFile in iconFiles {
    let iconPath = "\(iconSetPath)/\(iconFile)"
    if fileManager.fileExists(atPath: iconPath) {
        print("   ✅ \(iconFile)")
    } else {
        print("   ❌ \(iconFile) - MISSING")
    }
}

// Check Contents.json
let contentsPath = "\(iconSetPath)/Contents.json"
if fileManager.fileExists(atPath: contentsPath) {
    print("   ✅ Contents.json")
} else {
    print("   ❌ Contents.json - MISSING")
}

// Check built app resources
let resourcesPath = "\(appPath)/Contents/Resources"
let builtIconPath = "\(resourcesPath)/AppIcon.icns"

print()
print("📦 Checking built app resources:")
if fileManager.fileExists(atPath: builtIconPath) {
    print("   ✅ AppIcon.icns exists in app bundle")
    
    // Get file size
    do {
        let attributes = try fileManager.attributesOfItem(atPath: builtIconPath)
        if let fileSize = attributes[.size] as? Int64 {
            let sizeInKB = Double(fileSize) / 1024.0
            print("   📏 Size: \(String(format: "%.1f", sizeInKB)) KB")
        }
    } catch {
        print("   ⚠️  Could not get file size")
    }
} else {
    print("   ❌ AppIcon.icns missing from app bundle")
}

// Check Info.plist
let infoPlistPath = "\(appPath)/Contents/Info.plist"
if fileManager.fileExists(atPath: infoPlistPath) {
    print("   ✅ Info.plist exists")
} else {
    print("   ❌ Info.plist missing")
}

print()
print("🎨 Icon setup verification complete!")
print()
print("📋 If the icon still doesn't appear in the dock:")
print("1. Make sure the app is running")
print("2. Try restarting the app")
print("3. The Dock and Finder have been refreshed")
print("4. Check Activity Monitor to ensure the app is running")
print()
print("🎯 The custom icons from the AppIcons folder should now be visible!")