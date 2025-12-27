#!/usr/bin/env swift

import Foundation
import AppKit

print("🎯 SnipeX Improved Capture Test Guide")
print("=====================================\n")

// Check if app is running
let runningApps = NSWorkspace.shared.runningApplications
if let sniperApp = runningApps.first(where: { $0.bundleIdentifier?.contains("sniper") == true }) {
    print("✅ SnipeX is running! (PID: \(sniperApp.processIdentifier))")
    
    print("\n🔧 Improvements Made:")
    print("   ✅ Higher window level for better visibility")
    print("   ✅ Brighter, more visible selection overlay")
    print("   ✅ Clear area shows original image during selection")
    print("   ✅ Better error handling for permissions")
    print("   ✅ Enhanced visual feedback")
    
    print("\n📋 Testing Steps:")
    print("1. **Find the Menu Bar Icon**")
    print("   - Look for camera icon (📷) in your menu bar")
    print("   - Should be on the right side near system icons")
    
    print("\n2. **Test Screen Capture**")
    print("   - Press ⌘⇧2 or ⌘⇧3 (keyboard shortcut)")
    print("   - OR click menu bar icon → 'New Capture'")
    
    print("\n3. **What Should Happen**")
    print("   - Screen should darken with overlay")
    print("   - Blue instruction text at top: 'Click and drag to select an area • Press ESC to cancel'")
    print("   - You should be able to click and drag to select")
    
    print("\n4. **During Selection**")
    print("   - Selected area should show original image (clear)")
    print("   - Blue border around selection")
    print("   - White corner handles")
    print("   - Dimensions displayed in blue box")
    
    print("\n5. **Complete Selection**")
    print("   - Release mouse to complete selection")
    print("   - OCR should process the text")
    print("   - Text copied to clipboard")
    
    print("\n❓ **If Selection Overlay Doesn't Appear:**")
    print("   1. Check Screen Recording Permission:")
    print("      - System Preferences > Security & Privacy > Privacy")
    print("      - Select 'Screen Recording' from left sidebar")
    print("      - Make sure SnipeX is checked ✓")
    print("      - Restart SnipeX after granting permission")
    
    print("\n   2. Try Alternative Methods:")
    print("      - Click menu bar icon first, then 'New Capture'")
    print("      - Make sure no other apps are in fullscreen mode")
    print("      - Try on different display if you have multiple monitors")
    
    print("\n🎨 **Visual Improvements:**")
    print("   - Darker overlay (60% opacity) for better contrast")
    print("   - Bright blue instruction text")
    print("   - Clear selection area shows original content")
    print("   - Larger, more visible corner handles")
    print("   - Blue dimension display box")
    
    print("\n🔑 **Keyboard Controls:**")
    print("   - ESC: Cancel selection")
    print("   - ⌘⇧2: Primary capture shortcut")
    print("   - ⌘⇧3: Fallback capture shortcut")
    
    print("\n🚀 **Ready to Test!**")
    print("Try pressing ⌘⇧2 now and look for the improved selection overlay!")
    
} else {
    print("❌ SnipeX is not running")
    print("Please launch SnipeX first, then run this test")
}

print("\n💡 **Pro Tips:**")
print("• The overlay should be much more visible now")
print("• If you see the overlay but can't interact, check permissions")
print("• The selection area will be crystal clear showing original content")
print("• Look for bright blue instruction text at the top")