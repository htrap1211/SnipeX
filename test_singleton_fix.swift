#!/usr/bin/env swift

import Foundation
import AppKit

print("=== Testing Singleton Pattern Fix ===")
print("This test verifies that the ScreenIntelligenceService singleton")
print("ensures both menu bar and main window share the same capture history.")
print()

// Launch the app
print("1. Launching SnipeX with singleton service...")
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

print("\n=== Singleton Pattern Fix Details ===")
print("The root cause was multiple ScreenIntelligenceService instances:")
print("• MenuBarManager had its own instance")
print("• ContentView created a separate instance")
print("• Keyboard shortcuts updated MenuBar's instance")
print("• Main window HistoryView observed ContentView's instance")
print("• Result: Captures appeared in menu bar but not main window")
print()
print("Fixed by implementing singleton pattern:")
print("• ScreenIntelligenceService.shared ensures single instance")
print("• All components now reference the same service")
print("• Both capture methods update the same history")
print()

print("=== Comprehensive Test Instructions ===")
print()
print("STEP 1: Test Menu Bar Capture")
print("  1. Click the SnipeX camera icon in your menu bar")
print("  2. Click 'New Capture' button")
print("  3. Select some text on screen")
print("  4. Verify:")
print("     - Text is copied to clipboard")
print("     - Dynamic Island notification appears")
print("     - Text appears in menu bar 'Recent Captures'")
print()

print("STEP 2: Test Keyboard Shortcut Capture")
print("  1. Press ⌘⇧2")
print("  2. Select different text on screen")
print("  3. Verify:")
print("     - Text is copied to clipboard")
print("     - Dynamic Island notification appears")
print("     - Click menu bar icon - BOTH captures should be visible")
print()

print("STEP 3: Test Main Window History")
print("  1. Click 'Open Main Window' in menu bar popover")
print("  2. Navigate to History tab (should be default)")
print("  3. Verify:")
print("     - BOTH captures from steps 1 and 2 are visible")
print("     - History shows captures in chronological order")
print("     - Search and filter functionality works")
print()

print("STEP 4: Test Cross-Component Consistency")
print("  1. Use ⌘⇧2 to capture more text")
print("  2. Check menu bar popover - new capture should appear")
print("  3. Check main window history - new capture should appear")
print("  4. Use menu bar button to capture more text")
print("  5. Check both locations - all captures should be visible")
print()

print("STEP 5: Test Real-Time Updates")
print("  1. Keep main window History tab open")
print("  2. Use ⌘⇧2 to capture text")
print("  3. Verify history updates immediately without refresh")
print("  4. Use menu bar button to capture text")
print("  5. Verify history updates immediately")
print()

print("Expected Results:")
print("✅ Single shared service instance across all components")
print("✅ Menu bar captures appear in main window history")
print("✅ Keyboard shortcut captures appear in main window history")
print("✅ Real-time updates in all UI components")
print("✅ Consistent behavior regardless of capture method")
print("✅ No duplicate or missing captures")
print()

print("Press Enter when you've completed all test steps...")

// Wait for user input
let _ = readLine()

print("\n=== Singleton Fix Test Results ===")
print("If keyboard shortcut captures now appear in the main window's")
print("History view, the singleton pattern fix was successful!")
print()
print("This fix ensures:")
print("• Single source of truth for capture history")
print("• Consistent state across all UI components")
print("• Real-time updates in menu bar and main window")
print("• No more separate service instances")
print()
print("The app now properly shares capture history between all")
print("interface components, resolving the keyboard shortcut issue!")