#!/usr/bin/swift

import Foundation
import AppKit

print("🎨 Properly fixing SnipeX app icon from AppIcons folder...")

// Source and destination paths
let sourceDir = "AppIcons/Assets.xcassets/AppIcon.appiconset"
let destDir = "sniper/Assets.xcassets/AppIcon.appiconset"

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

// First, let's copy all the PNG files from AppIcons
let iconFiles = ["16.png", "32.png", "64.png", "128.png", "256.png", "512.png", "1024.png"]

print("📋 Copying icon files...")
var successCount = 0

for iconFile in iconFiles {
    let sourcePath = "\(sourceDir)/\(iconFile)"
    let destPath = "\(destDir)/\(iconFile)"
    
    print("   \(iconFile)")
    
    guard fileManager.fileExists(atPath: sourcePath) else {
        print("   ⚠️  Source file not found: \(sourcePath)")
        continue
    }
    
    do {
        // Remove destination file if it exists
        if fileManager.fileExists(atPath: destPath) {
            try fileManager.removeItem(atPath: destPath)
        }
        
        // Copy the file
        try fileManager.copyItem(atPath: sourcePath, toPath: destPath)
        successCount += 1
        
    } catch {
        print("   ❌ Failed: \(error.localizedDescription)")
    }
}

print("   ✅ Copied \(successCount) icon files")
print()

// Now create a proper Contents.json that matches macOS requirements
let contentsJson = """
{
  "images" : [
    {
      "filename" : "16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "32.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "64.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "256.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "512.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "1024.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"""

// Write the new Contents.json
let contentsPath = "\(destDir)/Contents.json"
do {
    try contentsJson.write(toFile: contentsPath, atomically: true, encoding: .utf8)
    print("✅ Updated Contents.json with proper icon references")
} catch {
    print("❌ Failed to write Contents.json: \(error)")
    exit(1)
}

print()
print("🧹 Cleaning up old icon files...")

// Remove old icon files that don't match the new naming scheme
let oldIconFiles = [
    "icon_16x16.png", "icon_16x16@2x.png",
    "icon_32x32.png", "icon_32x32@2x.png", 
    "icon_128x128.png", "icon_128x128@2x.png",
    "icon_256x256.png", "icon_256x256@2x.png",
    "icon_512x512.png", "icon_512x512@2x.png"
]

for oldFile in oldIconFiles {
    let oldPath = "\(destDir)/\(oldFile)"
    if fileManager.fileExists(atPath: oldPath) {
        do {
            try fileManager.removeItem(atPath: oldPath)
            print("   🗑️  Removed \(oldFile)")
        } catch {
            print("   ⚠️  Could not remove \(oldFile): \(error)")
        }
    }
}

print()
print("🎉 App icon setup complete!")
print()
print("📋 Next steps:")
print("1. Clean and rebuild the app: ./build.sh")
print("2. The custom icons from AppIcons folder should now appear")
print("3. If icons still don't appear, try:")
print("   - Quit and restart the app")
print("   - Run: killall Dock && killall Finder")
print("   - Clear Xcode's derived data")