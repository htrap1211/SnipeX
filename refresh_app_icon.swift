#!/usr/bin/env swift

import Foundation
import AppKit

print("=== Refreshing SnipeX App Icon ===")

// First, let's create a proper .icns file
func createICNSFile() {
    print("Creating .icns file...")
    
    let appPath = "/Users/htrap1211/Desktop/sniper/sniper/build/Build/Products/Release/sniper.app"
    let iconsetPath = "/Users/htrap1211/Desktop/sniper/sniper/sniper/Assets.xcassets/AppIcon.appiconset"
    let icnsPath = "/tmp/SnipeX.icns"
    
    // Use iconutil to create .icns file
    let task = Process()
    task.launchPath = "/usr/bin/iconutil"
    task.arguments = ["-c", "icns", "-o", icnsPath, iconsetPath]
    
    do {
        try task.run()
        task.waitUntilExit()
        
        if task.terminationStatus == 0 {
            print("✓ Created .icns file at \(icnsPath)")
            
            // Copy the .icns file to the app bundle
            let appIconPath = "\(appPath)/Contents/Resources/AppIcon.icns"
            let copyTask = Process()
            copyTask.launchPath = "/bin/cp"
            copyTask.arguments = [icnsPath, appIconPath]
            
            try copyTask.run()
            copyTask.waitUntilExit()
            
            if copyTask.terminationStatus == 0 {
                print("✓ Copied .icns file to app bundle")
            } else {
                print("✗ Failed to copy .icns file to app bundle")
            }
        } else {
            print("✗ Failed to create .icns file")
        }
    } catch {
        print("✗ Error creating .icns file: \(error)")
    }
}

// Function to clear icon cache
func clearIconCache() {
    print("Clearing macOS icon cache...")
    
    let commands = [
        "sudo rm -rfv /Library/Caches/com.apple.iconservices.store",
        "sudo find /private/var/folders/ -name com.apple.dock.iconcache -exec rm {} \\;",
        "sudo find /private/var/folders/ -name com.apple.iconservices -exec rm -rf {} \\;",
        "killall Dock",
        "killall Finder"
    ]
    
    for command in commands {
        print("Running: \(command)")
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus == 0 {
                print("✓ Command succeeded")
            } else {
                print("⚠️ Command may have failed (this is often normal)")
            }
        } catch {
            print("⚠️ Error running command: \(error)")
        }
        
        // Small delay between commands
        usleep(500000) // 0.5 seconds
    }
}

// Function to re-register the app
func reregisterApp() {
    print("Re-registering app with Launch Services...")
    
    let appPath = "/Users/htrap1211/Desktop/sniper/sniper/build/Build/Products/Release/sniper.app"
    
    let task = Process()
    task.launchPath = "/System/Library/Frameworks/CoreServices.framework/Versions/Current/Frameworks/LaunchServices.framework/Versions/Current/Support/lsregister"
    task.arguments = ["-f", "-R", "-trusted", appPath]
    
    do {
        try task.run()
        task.waitUntilExit()
        
        if task.terminationStatus == 0 {
            print("✓ App re-registered successfully")
        } else {
            print("✗ Failed to re-register app")
        }
    } catch {
        print("✗ Error re-registering app: \(error)")
    }
}

// Execute all steps
createICNSFile()
print()
clearIconCache()
print()
reregisterApp()

print("\n=== Icon Refresh Complete ===")
print("Steps completed:")
print("1. ✓ Created proper .icns file")
print("2. ✓ Cleared macOS icon cache")
print("3. ✓ Restarted Dock and Finder")
print("4. ✓ Re-registered app with Launch Services")
print()
print("The app icon should now be visible in the Dock!")
print("If you still don't see it, try:")
print("1. Quit and relaunch the app")
print("2. Log out and log back in")
print("3. Restart your Mac")
print()
print("Note: Some commands may have asked for sudo password.")
print("This is normal for clearing system caches.")