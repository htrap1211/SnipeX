#!/usr/bin/env swift

import Foundation
import CoreGraphics
import AppKit

print("=== Generating SnipeX App Icon ===")

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

// Generate icons for all required sizes
let iconSizes: [(String, CGSize)] = [
    ("icon_16x16.png", CGSize(width: 16, height: 16)),
    ("icon_16x16@2x.png", CGSize(width: 32, height: 32)),
    ("icon_32x32.png", CGSize(width: 32, height: 32)),
    ("icon_32x32@2x.png", CGSize(width: 64, height: 64)),
    ("icon_128x128.png", CGSize(width: 128, height: 128)),
    ("icon_128x128@2x.png", CGSize(width: 256, height: 256)),
    ("icon_256x256.png", CGSize(width: 256, height: 256)),
    ("icon_256x256@2x.png", CGSize(width: 512, height: 512)),
    ("icon_512x512.png", CGSize(width: 512, height: 512)),
    ("icon_512x512@2x.png", CGSize(width: 1024, height: 1024))
]

let outputDir = "sniper/Assets.xcassets/AppIcon.appiconset/"

for (filename, size) in iconSizes {
    print("Generating \(filename) (\(Int(size.width))x\(Int(size.height)))...")
    
    guard let icon = createAppIcon(size: size) else {
        print("Failed to create icon for size \(size)")
        continue
    }
    
    // Convert to PNG data
    guard let tiffData = icon.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
        print("Failed to convert icon to PNG for size \(size)")
        continue
    }
    
    // Write to file
    let filePath = outputDir + filename
    let url = URL(fileURLWithPath: filePath)
    
    do {
        try pngData.write(to: url)
        print("✓ Created \(filename)")
    } catch {
        print("✗ Failed to write \(filename): \(error)")
    }
}

print("\n=== Updating Contents.json ===")

// Update Contents.json with filenames
let updatedContents = """
{
  "images" : [
    {
      "filename" : "icon_16x16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_16x16@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_32x32@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128x128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_128x128@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_256x256@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_512x512@2x.png",
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

let contentsPath = outputDir + "Contents.json"
do {
    try updatedContents.write(toFile: contentsPath, atomically: true, encoding: .utf8)
    print("✓ Updated Contents.json")
} catch {
    print("✗ Failed to update Contents.json: \(error)")
}

print("\n✅ App icon generation complete!")
print("The SnipeX app now has a modern blue gradient icon with a viewfinder symbol.")
print("Build the app to see the new icon in the Dock and Finder.")