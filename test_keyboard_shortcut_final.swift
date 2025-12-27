#!/usr/bin/env swift

import Foundation
import AppKit
import SwiftUI

// Test script to verify keyboard shortcut ⌘⇧2 is working
print("=== Testing Keyboard Shortcut ⌘⇧2 ===")

// 1. Launch the app
print("1. Launching SnipeX app...")
let appPath = "/Users/htrap1211/Library/Developer/Xcode/DerivedData/sniper-eyrzkjxywxqvkmcztdohheqhmqff/Build/Products/Debug/sniper.app"

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

// 3. Check if app is running
let runningApps = NSWorkspace.shared.runningApplications
let sniperApp = runningApps.first { $0.bundleIdentifier?.contains("sniper") == true }

if let app = sniperApp {
    print("✓ SnipeX is running (Bundle ID: \(app.bundleIdentifier ?? "unknown"))")
    print("✓ Process ID: \(app.processIdentifier)")
} else {
    print("✗ SnipeX app not found in running applications")
    print("Running apps:")
    for app in runningApps.prefix(10) {
        print("  - \(app.localizedName ?? "Unknown") (\(app.bundleIdentifier ?? "no bundle ID"))")
    }
}

// 4. Instructions for manual testing
print("\n=== Manual Test Instructions ===")
print("The app should now be running in menu bar mode.")
print("Please test the following:")
print("1. Look for the SnipeX camera icon in your menu bar")
print("2. Click the menu bar icon - it should open a popover")
print("3. Try the keyboard shortcut ⌘⇧2 - it should trigger screen capture")
print("4. Select a text area and verify:")
print("   - Text is copied to clipboard")
print("   - Dynamic Island notification appears saying 'Text copied to clipboard'")
print("\nPress Enter when you've completed the test...")

// Wait for user input
let _ = readLine()

print("\n=== Test Results ===")
print("If both menu bar button and ⌘⇧2 shortcut work identically,")
print("and the Dynamic Island notification appears, the fix is successful!")
print("If the shortcut still doesn't work, we'll need to investigate further.")