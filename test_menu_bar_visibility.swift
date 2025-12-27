#!/usr/bin/env swift

import Foundation
import AppKit

print("Testing menu bar visibility...")

// Check if SnipeX is running
let runningApps = NSWorkspace.shared.runningApplications
let sniperApp = runningApps.first { $0.localizedName?.contains("sniper") == true }

if let app = sniperApp {
    print("✅ SnipeX is running: \(app.localizedName ?? "Unknown")")
    print("   Process ID: \(app.processIdentifier)")
    print("   Bundle ID: \(app.bundleIdentifier ?? "Unknown")")
    print("   Activation Policy: \(app.activationPolicy.rawValue)")
    
    // Try to activate the app
    app.activate(options: [.activateIgnoringOtherApps])
    print("   Attempted to activate app")
} else {
    print("❌ SnipeX is not running")
}

// Check menu bar items
print("\nChecking menu bar items...")
let statusBar = NSStatusBar.system
print("Status bar available length: \(statusBar.thickness)")

// Try to find our menu bar item by checking all status items
// Note: This is limited as we can't directly enumerate all status items
print("Menu bar setup complete - check visually for camera icon")

// Send a notification to test if the app is responsive
if let app = sniperApp {
    print("\nTesting app responsiveness...")
    
    // Try to bring the app to front
    app.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
    
    print("App activation attempted")
}

print("\nTest complete. Look for:")
print("1. Camera viewfinder icon in menu bar")
print("2. Try keyboard shortcut ⌘⇧2 or ⌘⇧3")
print("3. Click menu bar icon if visible")