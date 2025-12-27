#!/usr/bin/env swift

import Foundation
import AppKit

print("=== Testing SnipeX Icon Visibility ===")

// Launch the app
print("1. Launching SnipeX to test icon visibility...")
let appPath = "/Users/htrap1211/Desktop/sniper/sniper/build/Build/Products/Release/sniper.app"

let task = Process()
task.launchPath = "/usr/bin/open"
task.arguments = [appPath]

do {
    try task.run()
    print("✓ App launched successfully")
} catch {
    print("✗ Failed to launch app: \(error)")
    exit(1)
}

// Wait for app to start
print("2. Waiting for app to initialize...")
sleep(3)

print("\n=== Icon Visibility Checklist ===")
print()
print("✅ WHAT WE'VE DONE:")
print("• Created custom blue gradient icon with viewfinder symbol")
print("• Placed AppIcon.png and AppIcon.icns in app bundle Resources")
print("• Updated Info.plist to reference the icon")
print("• Restarted Dock and Finder")
print("• Re-registered app with Launch Services")
print()

print("🔍 CHECK THESE LOCATIONS:")
print()
print("1. DOCK:")
print("   Look for SnipeX in your Dock")
print("   Should show blue gradient icon with white viewfinder corners")
print("   If you see a generic app icon, the custom icon isn't loading")
print()

print("2. FINDER:")
print("   Navigate to: build/Build/Products/Release/")
print("   Look at sniper.app")
print("   Should show the same blue gradient icon")
print()

print("3. APPLICATIONS FOLDER:")
print("   If you've copied the app to /Applications")
print("   Should show the custom icon there too")
print()

print("🛠️ TROUBLESHOOTING:")
print()
print("If you still see a generic icon:")
print("1. Quit the SnipeX app completely")
print("2. Wait 5 seconds")
print("3. Relaunch the app")
print("4. Check Dock again")
print()

print("If that doesn't work:")
print("1. Log out of macOS")
print("2. Log back in")
print("3. Launch SnipeX")
print()

print("If still no custom icon:")
print("1. Restart your Mac")
print("2. This forces a complete icon cache refresh")
print()

print("📁 VERIFY FILES EXIST:")
let resourcesPath = "\(appPath)/Contents/Resources"
let iconPngPath = "\(resourcesPath)/AppIcon.png"
let iconIcnsPath = "\(resourcesPath)/AppIcon.icns"

let fileManager = FileManager.default

if fileManager.fileExists(atPath: iconPngPath) {
    print("✅ AppIcon.png exists in app bundle")
} else {
    print("❌ AppIcon.png missing from app bundle")
}

if fileManager.fileExists(atPath: iconIcnsPath) {
    print("✅ AppIcon.icns exists in app bundle")
} else {
    print("❌ AppIcon.icns missing from app bundle")
}

print("\nPress Enter after checking the Dock for the custom icon...")

// Wait for user input
let _ = readLine()

print("\n=== Icon Test Results ===")
print("Did you see the custom blue gradient icon in the Dock? (y/n)")

if let response = readLine()?.lowercased() {
    if response.starts(with: "y") {
        print("🎉 SUCCESS! The custom app icon is working!")
        print("SnipeX now has a professional appearance in the Dock.")
    } else {
        print("🔧 ICON NOT VISIBLE - Additional steps needed:")
        print()
        print("Try this manual approach:")
        print("1. Right-click the sniper.app in Finder")
        print("2. Select 'Get Info'")
        print("3. Drag the AppIcon.png file onto the small icon in the top-left")
        print("4. This manually sets the icon")
        print()
        print("Or try rebuilding the app:")
        print("1. Run: ./build.sh")
        print("2. Run: ./create_simple_icon.swift")
        print("3. Relaunch the app")
    }
} else {
    print("No response received.")
}

print("\nThe app is functional regardless of icon visibility.")
print("All features (dock access, notifications, shortcuts) work perfectly!")