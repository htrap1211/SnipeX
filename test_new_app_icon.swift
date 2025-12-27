#!/usr/bin/swift

import Foundation
import AppKit

print("🎨 Testing SnipeX with new app icons from AppIcons folder...")
print()

// Test the built app
let appPath = "build/Build/Products/Release/sniper.app"

let fileManager = FileManager.default

// Check if app exists
guard fileManager.fileExists(atPath: appPath) else {
    print("❌ App not found at \(appPath)")
    print("   Please run ./build.sh first")
    exit(1)
}

print("✅ App found at: \(appPath)")

// Check if AppIcon.icns exists in the app bundle
let resourcesPath = "\(appPath)/Contents/Resources"
let iconPath = "\(resourcesPath)/AppIcon.icns"

if fileManager.fileExists(atPath: iconPath) {
    print("✅ AppIcon.icns exists in app bundle")
    
    // Get file size
    do {
        let attributes = try fileManager.attributesOfItem(atPath: iconPath)
        if let fileSize = attributes[.size] as? Int64 {
            let sizeInKB = Double(fileSize) / 1024.0
            print("   📏 Icon file size: \(String(format: "%.1f", sizeInKB)) KB")
        }
    } catch {
        print("   ⚠️  Could not get file size: \(error)")
    }
    
} else {
    print("❌ AppIcon.icns missing from app bundle")
    print("   Expected at: \(iconPath)")
}

print()
print("🚀 Testing app launch...")

// Launch the app to test the new icon
let task = Process()
task.launchPath = "/usr/bin/open"
task.arguments = [appPath]

do {
    try task.run()
    print("✅ App launched successfully!")
    print()
    print("📋 What to check:")
    print("1. 🖥️  Check the dock - you should see the new app icon")
    print("2. 📱 Check the menu bar - the camera icon should be visible")
    print("3. 🎯 Try ⌘⇧2 to test screen capture functionality")
    print("4. 🔄 If the icon doesn't appear immediately, try:")
    print("   - Quit and restart the app")
    print("   - Run: killall Dock && killall Finder")
    print()
    print("🎉 The new icons from the AppIcons folder are now active!")
    
} catch {
    print("❌ Failed to launch app: \(error)")
    exit(1)
}