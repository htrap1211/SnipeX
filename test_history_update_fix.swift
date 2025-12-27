#!/usr/bin/env swift

import Foundation
import AppKit

print("=== Testing History Update Fix ===")
print("This test verifies that both menu bar button and ⌘⇧2 shortcut")
print("update the capture history in the app.")
print()

// Launch the app
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

print("\n=== Test Instructions ===")
print("The fix ensures that MenuBarContentView properly observes the ScreenIntelligenceService.")
print("Both the menu bar button and keyboard shortcut should now update the history.")
print()
print("Please test the following sequence:")
print()
print("STEP 1: Test Menu Bar Button")
print("  1. Click the SnipeX camera icon in your menu bar")
print("  2. Click 'New Capture' button")
print("  3. Select some text on screen")
print("  4. Verify:")
print("     - Text is copied to clipboard")
print("     - Dynamic Island notification appears")
print("     - Click menu bar icon again - captured text should appear in 'Recent Captures'")
print()
print("STEP 2: Test Keyboard Shortcut")
print("  1. Press ⌘⇧2")
print("  2. Select some different text on screen")
print("  3. Verify:")
print("     - Text is copied to clipboard")
print("     - Dynamic Island notification appears")
print("     - Click menu bar icon - BOTH captures should appear in 'Recent Captures'")
print()
print("STEP 3: Verify History Persistence")
print("  1. Click menu bar icon")
print("  2. Check that both captures from steps 1 and 2 are visible")
print("  3. The most recent capture should be at the top")
print()
print("Expected Result:")
print("✓ Both menu bar button and ⌘⇧2 shortcut should add items to history")
print("✓ History should be visible in the menu bar popover")
print("✓ Dynamic Island notification should appear for both methods")
print()
print("Press Enter when you've completed the test...")

// Wait for user input
let _ = readLine()

print("\n=== Test Results ===")
print("If both capture methods now update the history in the menu bar popover,")
print("the fix was successful! The issue was that MenuBarContentView wasn't")
print("properly observing the ScreenIntelligenceService's @Published properties.")