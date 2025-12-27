#!/usr/bin/env swift

import Foundation
import AppKit

print("🔍 SnipeX App Locator & Tester")
print("==============================\n")

// Check if app is running
let runningApps = NSWorkspace.shared.runningApplications
if let sniperApp = runningApps.first(where: { $0.bundleIdentifier?.contains("sniper") == true }) {
    print("✅ SnipeX is running! (PID: \(sniperApp.processIdentifier))")
    
    // Activate the app
    sniperApp.activate(options: [])
    
    print("\n📍 WHERE TO FIND THE MENU BAR ICON:")
    print("1. Look at the TOP of your screen in the menu bar")
    print("2. Look for a camera/viewfinder icon (📷) on the RIGHT side")
    print("3. It should be near your WiFi, battery, and time icons")
    print("4. The icon might look like: 📷 or ⊙ or similar camera symbol")
    
    print("\n🖱️  HOW TO USE:")
    print("• CLICK the menu bar icon to open SnipeX")
    print("• OR press ⌘⇧2 (Command + Shift + 2) to capture")
    
    print("\n🧪 TEST THE KEYBOARD SHORTCUT:")
    print("Press ⌘⇧2 RIGHT NOW!")
    print("You should see a screen selection overlay appear")
    
    print("\n❓ IF YOU DON'T SEE THE ICON:")
    print("• Check if your menu bar is full - look for >> overflow")
    print("• Try switching between Light/Dark mode to make it visible")
    print("• The icon might be there but hard to see")
    
    print("\n🎯 WHAT SHOULD HAPPEN:")
    print("1. Click menu bar icon → SnipeX popover opens")
    print("2. Click 'New Capture' → Screen selection starts")
    print("3. Select area → OCR processes text")
    print("4. Text copied to clipboard automatically")
    
} else {
    print("❌ SnipeX is not running")
    print("Please launch the app first!")
}

print("\n💡 PRO TIP:")
print("If you see the menu bar icon, hover over it to see the tooltip:")
print("'SnipeX - Screen Intelligence'")

print("\n🚀 Ready to test? Try pressing ⌘⇧2 now!")