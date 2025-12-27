#!/usr/bin/env swift

import Foundation
import AppKit

print("🔍 SnipeX Capture Debug Tool")
print("============================\n")

// Check if SnipeX is running
let runningApps = NSWorkspace.shared.runningApplications
if let sniperApp = runningApps.first(where: { $0.bundleIdentifier?.contains("sniper") == true }) {
    print("✅ SnipeX is running (PID: \(sniperApp.processIdentifier))")
    
    // Check screen recording permissions
    print("\n🔐 Checking Screen Recording Permissions...")
    
    // Try to get screen info
    let screens = NSScreen.screens
    print("   📺 Found \(screens.count) screen(s)")
    
    for (index, screen) in screens.enumerated() {
        print("   Screen \(index + 1): \(screen.frame.width)x\(screen.frame.height)")
    }
    
    // Check if we can access screen capture
    if #available(macOS 12.3, *) {
        print("   ✅ ScreenCaptureKit available (macOS 12.3+)")
    } else {
        print("   ⚠️  ScreenCaptureKit not available (macOS < 12.3)")
    }
    
    print("\n🎯 Possible Issues:")
    print("1. Screen Recording Permission:")
    print("   - Go to System Preferences > Security & Privacy > Privacy")
    print("   - Select 'Screen Recording' from the left sidebar")
    print("   - Make sure SnipeX is checked/enabled")
    print("   - You may need to restart SnipeX after granting permission")
    
    print("\n2. Window Level Issues:")
    print("   - The selection overlay might be appearing behind other windows")
    print("   - Try minimizing all other applications")
    
    print("\n3. Display Issues:")
    print("   - If using multiple monitors, try on the main display")
    print("   - Check if the overlay appears on a different screen")
    
    print("\n🧪 Debugging Steps:")
    print("1. Press ⌘⇧2 or ⌘⇧3 to trigger capture")
    print("2. Look for any windows that appear briefly")
    print("3. Try pressing ESC if you think the overlay is there but invisible")
    print("4. Check Console.app for any error messages from SnipeX")
    
    print("\n💡 Quick Fix Attempts:")
    print("• Restart SnipeX completely")
    print("• Grant screen recording permission if not already done")
    print("• Try on a different display if you have multiple monitors")
    
} else {
    print("❌ SnipeX is not running")
    print("Please launch SnipeX first")
}

print("\n🔧 System Information:")
print("macOS Version: \(ProcessInfo.processInfo.operatingSystemVersionString)")
print("Current User: \(NSUserName())")

// Check for any obvious permission issues
let workspace = NSWorkspace.shared
print("Workspace available: \(workspace)")

print("\n📋 Next Steps:")
print("1. Ensure SnipeX has Screen Recording permission")
print("2. Try the capture again")
print("3. If still not working, we'll need to modify the overlay code")