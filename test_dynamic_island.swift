#!/usr/bin/env swift

import Foundation
import AppKit

print("Testing Dynamic Island notification...")

// Find the SnipeX app
let runningApps = NSWorkspace.shared.runningApplications
guard let sniperApp = runningApps.first(where: { $0.localizedName?.contains("sniper") == true }) else {
    print("❌ SnipeX is not running")
    exit(1)
}

print("✅ Found SnipeX app: \(sniperApp.localizedName ?? "Unknown")")
print("   Process ID: \(sniperApp.processIdentifier)")

// Activate the app
sniperApp.activate()
Thread.sleep(forTimeInterval: 0.5)

print("\n🎯 Testing the updated SnipeX with Dynamic Island notifications")
print("\nWhat to expect:")
print("1. Quick Preview feature has been REMOVED")
print("2. When you capture text, it will be copied directly to clipboard")
print("3. You should see a Dynamic Island-style notification saying 'Text copied to clipboard'")
print("4. The notification appears at the top center of your screen")
print("5. It has a pill shape with rounded corners and a green checkmark")

print("\n📋 How to test:")
print("1. Look for the camera icon in your menu bar")
print("2. Use keyboard shortcut ⌘⇧2 or ⌘⇧3 to start screen capture")
print("3. Select any text on your screen")
print("4. Watch for the Dynamic Island notification at the top of your screen")
print("5. Check your clipboard - the text should be there immediately")

print("\n🔍 If you don't see the menu bar icon:")
print("   - Check the right side of your menu bar")
print("   - Look for a camera viewfinder icon 📷")
print("   - The icon should be more visible now with enhanced setup")

print("\nPress Enter when you're ready to test...")
_ = readLine()

print("✅ Test ready! Try capturing some text now.")
print("   The Dynamic Island notification should appear when text is copied.")

print("\nPress Enter when done testing...")
_ = readLine()

print("Test complete!")