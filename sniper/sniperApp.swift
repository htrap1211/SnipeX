//
//  sniperApp.swift
//  sniper
//
//  Screen Intelligence App - Menu Bar & Dock Version
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Never terminate when last window closes for menu bar apps
        return false
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set activation policy to show in dock by default
        NSApp.setActivationPolicy(.regular)
    }
}

@main
struct sniperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var menuBarManager = MenuBarManager()
    @StateObject private var globalShortcutManager = GlobalShortcutManager()
    @AppStorage("appDisplayMode") private var appDisplayMode: String = AppDisplayMode.both.rawValue
    
    init() {
        // Setup for menu bar and dock app
    }
    
    var body: some Scene {
        // Main window - only show for dock mode or both mode
        WindowGroup {
            ContentView()
                .environmentObject(ScreenIntelligenceService.shared)
                .onAppear {
                    setupAppDisplayMode()
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 800, height: 600)
        .handlesExternalEvents(matching: Set(arrayLiteral: "main"))
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Capture") {
                    if currentDisplayMode == .dockOnly {
                        // For dock-only mode, trigger capture directly
                        triggerCaptureForDockMode()
                    } else {
                        menuBarManager.triggerCapture()
                    }
                }
                .keyboardShortcut("2", modifiers: [.command, .shift])
            }
            
            CommandGroup(after: .newItem) {
                Button("Show SnipeX") {
                    menuBarManager.showMainWindow()
                }
                .keyboardShortcut("1", modifiers: [.command, .shift])
            }
        }
        
        Settings {
            SettingsView()
        }
    }
    
    private var currentDisplayMode: AppDisplayMode {
        return AppDisplayMode(rawValue: appDisplayMode) ?? .menuBarOnly
    }
    
    private func setupAppDisplayMode() {
        let displayMode = currentDisplayMode
        
        print("sniperApp: Setting up display mode: \(displayMode.rawValue)")
        
        DispatchQueue.main.async {
            // Set activation policy based on user preference
            NSApp.setActivationPolicy(displayMode.activationPolicy)
            print("sniperApp: Set activation policy to \(displayMode.activationPolicy.rawValue)")
            
            // For menu bar only mode, prevent automatic termination
            if displayMode == .menuBarOnly {
                // Close any open windows for menu bar mode
                for window in NSApp.windows {
                    if window.title == "SnipeX" || window.contentViewController is NSHostingController<ContentView> {
                        window.close()
                    }
                }
            }
            
            // Configure menu bar visibility
            self.configureMenuBarVisibility(for: displayMode)
            
            self.setupGlobalShortcuts()
            
            // Force menu bar refresh after setup
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.menuBarManager.showMenuBarIcon()
                print("sniperApp: Display mode setup complete")
            }
        }
    }
    
    private func configureMenuBarVisibility(for displayMode: AppDisplayMode) {
        switch displayMode {
        case .menuBarOnly:
            // Menu bar only - this is handled by the MenuBarManager
            menuBarManager.showMenuBarIcon()
        case .dockOnly:
            // Dock only - hide menu bar icon
            menuBarManager.hideMenuBarIcon()
        case .both:
            // Both - menu bar icon is shown by default, dock icon is shown via .regular policy
            menuBarManager.showMenuBarIcon()
        }
    }
    
    private func triggerCaptureForDockMode() {
        // For dock-only mode, we need to trigger capture without menu bar manager
        ScreenSelectionWindowManager.shared.showSelectionWindow(
            onRegionSelected: { region in
                // You would need to access the ScreenIntelligenceService here
                // For now, we'll use the menu bar manager's service
                Task {
                    // This is a simplified approach - in a full implementation,
                    // you might want to create a shared service instance
                    print("Dock mode capture triggered for region: \(region.rect)")
                }
            },
            onCancelled: {
                print("Dock mode capture cancelled")
            }
        )
    }
    
    private func setupGlobalShortcuts() {
        // The MenuBarManager now owns the ScreenIntelligenceService
        globalShortcutManager.onShortcutTriggered = {
            print("Global shortcut triggered - calling menuBarManager.triggerCapture()")
            menuBarManager.triggerCapture()
        }
        globalShortcutManager.registerGlobalShortcut()
    }
}
