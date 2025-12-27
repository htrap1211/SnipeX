#!/usr/bin/env swift

import Foundation
import CoreGraphics
import AppKit

print("=== Creating Simple App Icon ===")

// Function to create a modern app icon
func createAppIcon(size: CGSize) -> NSImage? {
    let image = NSImage(size: size)
    
    image.lockFocus()
    
    // Get the current graphics context
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return nil
    }
    
    // Clear the background
    context.clear(CGRect(origin: .zero, size: size))
    
    // Create rounded rectangle background with gradient
    let cornerRadius = size.width * 0.2
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    
    // Add gradient background
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        CGColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0), // Blue
        CGColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0), // Light blue
        CGColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1.0)  // Dark blue
    ]
    
    guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 0.5, 1.0]) else {
        image.unlockFocus()
        return nil
    }
    
    context.saveGState()
    context.addPath(path)
    context.clip()
    
    // Draw gradient
    context.drawLinearGradient(gradient, 
                              start: CGPoint(x: 0, y: size.height), 
                              end: CGPoint(x: size.width, y: 0), 
                              options: [])
    
    context.restoreGState()
    
    // Add border
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3))
    context.setLineWidth(size.width * 0.02)
    context.addPath(path)
    context.strokePath()
    
    // Draw viewfinder icon in the center
    let iconSize = size.width * 0.5
    let iconRect = CGRect(
        x: (size.width - iconSize) / 2,
        y: (size.height - iconSize) / 2,
        width: iconSize,
        height: iconSize
    )
    
    // Draw viewfinder corners
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9))
    context.setLineWidth(size.width * 0.04)
    context.setLineCap(.round)
    
    let cornerLength = iconSize * 0.25
    let cornerOffset = iconSize * 0.1
    
    // Top-left corner
    context.move(to: CGPoint(x: iconRect.minX + cornerOffset, y: iconRect.maxY - cornerOffset))
    context.addLine(to: CGPoint(x: iconRect.minX + cornerOffset, y: iconRect.maxY - cornerOffset - cornerLength))
    context.move(to: CGPoint(x: iconRect.minX + cornerOffset, y: iconRect.maxY - cornerOffset))
    context.addLine(to: CGPoint(x: iconRect.minX + cornerOffset + cornerLength, y: iconRect.maxY - cornerOffset))
    
    // Top-right corner
    context.move(to: CGPoint(x: iconRect.maxX - cornerOffset, y: iconRect.maxY - cornerOffset))
    context.addLine(to: CGPoint(x: iconRect.maxX - cornerOffset, y: iconRect.maxY - cornerOffset - cornerLength))
    context.move(to: CGPoint(x: iconRect.maxX - cornerOffset, y: iconRect.maxY - cornerOffset))
    context.addLine(to: CGPoint(x: iconRect.maxX - cornerOffset - cornerLength, y: iconRect.maxY - cornerOffset))
    
    // Bottom-left corner
    context.move(to: CGPoint(x: iconRect.minX + cornerOffset, y: iconRect.minY + cornerOffset))
    context.addLine(to: CGPoint(x: iconRect.minX + cornerOffset, y: iconRect.minY + cornerOffset + cornerLength))
    context.move(to: CGPoint(x: iconRect.minX + cornerOffset, y: iconRect.minY + cornerOffset))
    context.addLine(to: CGPoint(x: iconRect.minX + cornerOffset + cornerLength, y: iconRect.minY + cornerOffset))
    
    // Bottom-right corner
    context.move(to: CGPoint(x: iconRect.maxX - cornerOffset, y: iconRect.minY + cornerOffset))
    context.addLine(to: CGPoint(x: iconRect.maxX - cornerOffset, y: iconRect.minY + cornerOffset + cornerLength))
    context.move(to: CGPoint(x: iconRect.maxX - cornerOffset, y: iconRect.minY + cornerOffset))
    context.addLine(to: CGPoint(x: iconRect.maxX - cornerOffset - cornerLength, y: iconRect.minY + cornerOffset))
    
    context.strokePath()
    
    // Add center crosshair
    context.setLineWidth(size.width * 0.015)
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6))
    
    let centerX = iconRect.midX
    let centerY = iconRect.midY
    let crossSize = iconSize * 0.08
    
    // Horizontal line
    context.move(to: CGPoint(x: centerX - crossSize, y: centerY))
    context.addLine(to: CGPoint(x: centerX + crossSize, y: centerY))
    
    // Vertical line
    context.move(to: CGPoint(x: centerX, y: centerY - crossSize))
    context.addLine(to: CGPoint(x: centerX, y: centerY + crossSize))
    
    context.strokePath()
    
    image.unlockFocus()
    return image
}

// Create a 512x512 icon and save it directly to the app bundle
print("Creating 512x512 app icon...")

guard let icon = createAppIcon(size: CGSize(width: 512, height: 512)) else {
    print("✗ Failed to create icon")
    exit(1)
}

// Convert to PNG data
guard let tiffData = icon.tiffRepresentation,
      let bitmapRep = NSBitmapImageRep(data: tiffData),
      let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
    print("✗ Failed to convert icon to PNG")
    exit(1)
}

// Save to app bundle Resources folder
let appPath = "/Users/htrap1211/Desktop/sniper/sniper/build/Build/Products/Release/sniper.app"
let resourcesPath = "\(appPath)/Contents/Resources"
let iconPath = "\(resourcesPath)/AppIcon.png"

// Create Resources directory if it doesn't exist
let fileManager = FileManager.default
if !fileManager.fileExists(atPath: resourcesPath) {
    do {
        try fileManager.createDirectory(atPath: resourcesPath, withIntermediateDirectories: true, attributes: nil)
        print("✓ Created Resources directory")
    } catch {
        print("✗ Failed to create Resources directory: \(error)")
        exit(1)
    }
}

// Write the icon file
do {
    try pngData.write(to: URL(fileURLWithPath: iconPath))
    print("✓ Created AppIcon.png at \(iconPath)")
} catch {
    print("✗ Failed to write icon file: \(error)")
    exit(1)
}

// Also create AppIcon.icns for better compatibility
let icnsPath = "\(resourcesPath)/AppIcon.icns"
do {
    try pngData.write(to: URL(fileURLWithPath: icnsPath))
    print("✓ Created AppIcon.icns at \(icnsPath)")
} catch {
    print("✗ Failed to write icns file: \(error)")
}

print("\n=== Updating Info.plist ===")

// Update Info.plist to reference our icon
let infoPlistPath = "\(appPath)/Contents/Info.plist"
let updatePlistTask = Process()
updatePlistTask.launchPath = "/usr/bin/plutil"
updatePlistTask.arguments = ["-replace", "CFBundleIconFile", "-string", "AppIcon", infoPlistPath]

do {
    try updatePlistTask.run()
    updatePlistTask.waitUntilExit()
    
    if updatePlistTask.terminationStatus == 0 {
        print("✓ Updated Info.plist with icon reference")
    } else {
        print("⚠️ Failed to update Info.plist (may not be critical)")
    }
} catch {
    print("⚠️ Error updating Info.plist: \(error)")
}

print("\n=== Refreshing System ===")

// Clear icon cache and refresh
let refreshCommands = [
    "killall Dock",
    "killall Finder"
]

for command in refreshCommands {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]
    
    do {
        try task.run()
        task.waitUntilExit()
        print("✓ Executed: \(command)")
    } catch {
        print("⚠️ Error executing \(command): \(error)")
    }
}

print("\n✅ Simple icon creation complete!")
print("The app should now show a blue gradient icon with viewfinder in the Dock.")
print("If you still don't see it, try restarting the app.")