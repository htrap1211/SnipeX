#!/usr/bin/swift

import Foundation
import AppKit

print("🎨 Updating SnipeX app icon from AppIcons folder...")

// Source and destination paths
let sourceDir = "AppIcons/Assets.xcassets/AppIcon.appiconset"
let destDir = "sniper/Assets.xcassets/AppIcon.appiconset"

// Icon mapping: (source_filename, dest_filename)
let iconMappings: [(String, String)] = [
    ("16.png", "icon_16x16.png"),
    ("32.png", "icon_16x16@2x.png"),
    ("32.png", "icon_32x32.png"),
    ("64.png", "icon_32x32@2x.png"),
    ("128.png", "icon_128x128.png"),
    ("256.png", "icon_128x128@2x.png"),
    ("256.png", "icon_256x256.png"),
    ("512.png", "icon_256x256@2x.png"),
    ("512.png", "icon_512x512.png"),
    ("1024.png", "icon_512x512@2x.png")
]

let fileManager = FileManager.default

// Check if source directory exists
guard fileManager.fileExists(atPath: sourceDir) else {
    print("❌ Source directory not found: \(sourceDir)")
    exit(1)
}

// Check if destination directory exists
guard fileManager.fileExists(atPath: destDir) else {
    print("❌ Destination directory not found: \(destDir)")
    exit(1)
}

print("📁 Source: \(sourceDir)")
print("📁 Destination: \(destDir)")
print()

// Copy and rename icons
var successCount = 0
var failureCount = 0

for (sourceFile, destFile) in iconMappings {
    let sourcePath = "\(sourceDir)/\(sourceFile)"
    let destPath = "\(destDir)/\(destFile)"
    
    print("📋 Copying \(sourceFile) → \(destFile)")
    
    // Check if source file exists
    guard fileManager.fileExists(atPath: sourcePath) else {
        print("   ⚠️  Source file not found: \(sourcePath)")
        failureCount += 1
        continue
    }
    
    do {
        // Remove destination file if it exists
        if fileManager.fileExists(atPath: destPath) {
            try fileManager.removeItem(atPath: destPath)
        }
        
        // Copy the file
        try fileManager.copyItem(atPath: sourcePath, toPath: destPath)
        print("   ✅ Success")
        successCount += 1
        
    } catch {
        print("   ❌ Failed: \(error.localizedDescription)")
        failureCount += 1
    }
}

print()
print("📊 Results:")
print("   ✅ Successful: \(successCount)")
print("   ❌ Failed: \(failureCount)")

if failureCount == 0 {
    print()
    print("🎉 All icons updated successfully!")
    print()
    print("📋 Next steps:")
    print("1. Clean and rebuild the app: ./build.sh")
    print("2. The new icons should appear in the dock and menu bar")
    print("3. You may need to restart the app to see changes")
    print("4. If icons don't appear immediately, try:")
    print("   - Quit and restart the app")
    print("   - Run: killall Dock && killall Finder")
    
} else {
    print()
    print("⚠️  Some icons failed to copy. Please check the errors above.")
    exit(1)
}