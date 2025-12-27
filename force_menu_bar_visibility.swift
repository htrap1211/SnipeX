#!/usr/bin/env swift

import Foundation
import AppKit

print("=== Forcing SnipeX Menu Bar Visibility ===\n")

// Try to find and interact with the SnipeX app
let workspace = NSWorkspace.shared
let runningApps = workspace.runningApplications

if let sniperApp = runningApps.first(where: { $0.bundleIdentifier?.contains("sniper") == true }) {
    print("✅ Found SnipeX app (PID: \(sniperApp.processIdentifier))")
    
    // Try to activate the app
    let activated = sniperApp.activate(options: [.activateIgnoringOtherApps])
    print("   Activation attempt: \(activated ? "Success" : "Failed")")
    
    // Give it a moment
    Thread.sleep(forTimeInterval: 1.0)
    
    print("\n🔍 Menu Bar Icon Troubleshooting:")
    print("1. Look in the top-right corner of your screen")
    print("2. The icon should look like: ⊙ (viewfinder circle)")
    print("3. If you don't see it, check the menu bar overflow area (>> icon)")
    print("4. Try moving your mouse along the entire menu bar")
    
    print("\n⌨️  Keyboard Shortcut Test:")
    print("Press ⌘⇧2 (Command + Shift + 2) now!")
    print("This should trigger the screen capture overlay")
    
    print("\n🔧 If Still Not Visible:")
    print("1. The app might need accessibility permissions")
    print("2. Try quitting and relaunching the app")
    print("3. Check if other menu bar apps are hiding it")
    
} else {
    print("❌ SnipeX app not found in running applications")
    print("Please launch the app first")
}

print("\n=== Manual Steps ===")
print("1. Look for the viewfinder icon (⊙) in your menu bar")
print("2. Click it to open the SnipeX menu")
print("3. Try the 'New Capture' button")
print("4. Or use the keyboard shortcut ⌘⇧2")

// Check if we can access the status bar
let statusBar = NSStatusBar.system
print("\nStatus bar available: \(statusBar)")
print("Status bar thickness: \(statusBar.thickness)")

print("\n💡 Pro Tip: If the icon is there but hard to see,")
print("   try switching to Dark Mode or Light Mode to make it more visible!")