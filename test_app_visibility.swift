#!/usr/bin/env swift

import Foundation
import AppKit

print("=== SnipeX App Visibility Test ===\n")

// Check if the app is running
let runningApps = NSWorkspace.shared.runningApplications
let sniperApp = runningApps.first { $0.bundleIdentifier?.contains("sniper") == true }

if let app = sniperApp {
    print("✅ SnipeX is running!")
    print("   Bundle ID: \(app.bundleIdentifier ?? "Unknown")")
    print("   Process ID: \(app.processIdentifier)")
    print("   Activation Policy: \(app.activationPolicy.rawValue)")
    print("   Is Active: \(app.isActive)")
    print("   Is Hidden: \(app.isHidden)")
} else {
    print("❌ SnipeX is not running")
}

// Check menu bar items
print("\n🔍 Checking Menu Bar...")
let statusBar = NSStatusBar.system
print("   Status bar exists: \(statusBar)")

// Instructions for user
print("\n=== What to Look For ===")
print("1. Look for a viewfinder icon (⊙) in your menu bar (top right of screen)")
print("2. The icon should be near the clock, WiFi, and other system icons")
print("3. Click the icon to open the SnipeX popover")
print("4. If you don't see it, try:")
print("   - Look for it in the menu bar overflow (>> icon)")
print("   - Check if it's hidden behind other menu bar items")
print("   - Try pressing ⌘⇧2 to trigger a capture")

print("\n=== Troubleshooting ===")
print("If the menu bar icon is not visible:")
print("1. Quit the app (⌘Q)")
print("2. Relaunch it")
print("3. Check System Preferences > Security & Privacy > Accessibility")
print("4. Make sure SnipeX has accessibility permissions")

print("\n=== Testing Shortcut ===")
print("Try pressing ⌘⇧2 (Command + Shift + 2)")
print("This should trigger the screen capture functionality")
print("If it works, the app is running correctly!")