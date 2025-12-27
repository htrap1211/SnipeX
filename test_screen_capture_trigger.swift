#!/usr/bin/env swift

import Foundation
import AppKit

print("Testing screen capture trigger...")

// Find the SnipeX app
let runningApps = NSWorkspace.shared.runningApplications
guard let sniperApp = runningApps.first(where: { $0.localizedName?.contains("sniper") == true }) else {
    print("❌ SnipeX is not running")
    exit(1)
}

print("✅ Found SnipeX app: \(sniperApp.localizedName ?? "Unknown")")
print("   Process ID: \(sniperApp.processIdentifier)")

// Activate the app first
sniperApp.activate()

// Wait a moment for activation
Thread.sleep(forTimeInterval: 0.5)

print("\nAttempting to trigger screen capture...")

// Try to send the keyboard shortcut to the app
// We'll use AppleScript to send the shortcut
let script = """
tell application "System Events"
    tell process "sniper"
        key code 19 using {command down, shift down}
    end tell
end tell
"""

let appleScript = NSAppleScript(source: script)
var error: NSDictionary?
let result = appleScript?.executeAndReturnError(&error)

if let error = error {
    print("❌ AppleScript error: \(error)")
    
    // Try alternative approach - direct key simulation
    print("Trying alternative approach...")
    
    // Create a CGEvent for the keyboard shortcut
    let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: 19, keyDown: true) // Key code 19 is '2'
    let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: 19, keyDown: false)
    
    // Set the command and shift modifiers
    keyDownEvent?.flags = [.maskCommand, .maskShift]
    keyUpEvent?.flags = [.maskCommand, .maskShift]
    
    // Post the events
    keyDownEvent?.post(tap: .cghidEventTap)
    keyUpEvent?.post(tap: .cghidEventTap)
    
    print("✅ Sent keyboard shortcut ⌘⇧2")
} else {
    print("✅ AppleScript executed successfully")
}

print("\nWaiting for screen capture overlay to appear...")
print("Look for:")
print("1. Dark overlay covering the screen")
print("2. Yellow selection rectangle when dragging")
print("3. Instructions at the top of the screen")
print("4. Press ESC to cancel if overlay appears")

// Wait for user input
print("\nPress Enter when done testing...")
_ = readLine()

print("Test complete.")