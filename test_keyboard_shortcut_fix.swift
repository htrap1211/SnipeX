#!/usr/bin/env swift

import Foundation
import AppKit

print("🔧 Testing Keyboard Shortcut Fix")
print("================================")

// Find the SnipeX app
let runningApps = NSWorkspace.shared.runningApplications
guard let sniperApp = runningApps.first(where: { $0.localizedName?.contains("sniper") == true }) else {
    print("❌ SnipeX is not running")
    exit(1)
}

print("✅ Found SnipeX app: \(sniperApp.localizedName ?? "Unknown")")
print("   Process ID: \(sniperApp.processIdentifier)")
print("   Bundle ID: \(sniperApp.bundleIdentifier ?? "Unknown")")

// Activate the app
sniperApp.activate()
Thread.sleep(forTimeInterval: 0.5)

print("\n🎯 WHAT WAS FIXED:")
print("- ScreenIntelligenceService is now properly initialized at app startup")
print("- MenuBarManager gets the service reference immediately, not just when popover opens")
print("- Global shortcut ⌘⇧2 now properly connects to the capture function")
print("- Added debug logging to track shortcut triggering")

print("\n📋 TESTING INSTRUCTIONS:")
print("1. Look for the camera icon 📷 in your menu bar (should be visible)")
print("2. Try BOTH methods to capture:")
print("   a) Click the menu bar icon → Click 'New Capture' button")
print("   b) Press ⌘⇧2 keyboard shortcut directly")
print("3. Both should show the same yellow selection overlay")
print("4. Select some text and verify Dynamic Island notification appears")

print("\n🔍 EXPECTED BEHAVIOR:")
print("- Menu bar button: ✅ Works (you confirmed this)")
print("- Keyboard shortcut ⌘⇧2: ✅ Should now work (this was the fix)")
print("- Both should trigger the same capture flow")
print("- Dynamic Island notification: 'Text copied to clipboard'")

print("\n🐛 IF KEYBOARD SHORTCUT STILL DOESN'T WORK:")
print("- Check if another app is using ⌘⇧2 (like macOS screenshot)")
print("- Try the fallback shortcut ⌘⇧3")
print("- Check System Preferences > Keyboard > Shortcuts for conflicts")

print("\nPress Enter to start testing...")
_ = readLine()

print("🚀 Ready to test! Try both methods:")
print("   1. Menu bar icon → New Capture button")
print("   2. Keyboard shortcut ⌘⇧2")
print("\nBoth should work identically now!")

print("\nPress Enter when done testing...")
_ = readLine()

print("✅ Test complete! The keyboard shortcut should now work properly.")