//
//  MenuBarManager.swift
//  sniper
//
//  Menu bar management for SnipeX
//

import SwiftUI
import AppKit
import Combine

class MenuBarManager: NSObject, ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    var screenIntelligenceService: ScreenIntelligenceService {
        return ScreenIntelligenceService.shared
    }
    
    @Published var isMenuOpen = false
    
    override init() {
        super.init()
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        print("MenuBarManager: Setting up menu bar")
        
        // Create status item in menu bar with fixed length for better visibility
        statusItem = NSStatusBar.system.statusItem(withLength: 28)
        
        guard let statusItem = statusItem else {
            print("MenuBarManager: Failed to create status item")
            return
        }
        
        guard let button = statusItem.button else {
            print("MenuBarManager: Status item has no button")
            return
        }
        
        print("MenuBarManager: Configuring status item button")
        
        // Use a more visible icon approach
        if let image = NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: "SnipeX") {
            // Make the icon more visible
            let resizedImage = NSImage(size: NSSize(width: 18, height: 18))
            resizedImage.lockFocus()
            image.draw(in: NSRect(x: 0, y: 0, width: 18, height: 18))
            resizedImage.unlockFocus()
            
            button.image = resizedImage
            button.image?.isTemplate = true
            print("MenuBarManager: Set camera.viewfinder icon with custom size")
        } else {
            // Fallback to a simple text icon that's always visible
            button.title = "📷"
            button.font = NSFont.systemFont(ofSize: 16)
            print("MenuBarManager: Set emoji fallback with larger font")
        }
        
        // Configure button properties for maximum visibility
        button.action = #selector(togglePopover)
        button.target = self
        button.toolTip = "SnipeX - Screen Intelligence\nClick to open • ⌘⇧2 to capture"
        button.appearsDisabled = false
        
        // Force the status item to be visible and autosave
        statusItem.isVisible = true
        statusItem.autosaveName = "SnipeXMenuBarItem"
        
        print("MenuBarManager: Menu bar setup complete with enhanced visibility")
        
        // Create popover for menu content
        setupPopover()
        
        // Force a refresh after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.forceMenuBarRefresh()
        }
    }
    
    private func forceMenuBarRefresh() {
        guard let button = statusItem?.button else { return }
        
        // Force the button to redraw
        button.needsDisplay = true
        
        // Toggle visibility to force refresh
        statusItem?.isVisible = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.statusItem?.isVisible = true
            print("MenuBarManager: Forced menu bar refresh complete")
        }
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 360, height: 480)
        popover?.behavior = .transient
        popover?.delegate = self
        
        // Set the popover content
        let menuView = MenuBarContentView(menuBarManager: self)
        popover?.contentViewController = NSHostingController(rootView: menuView)
    }
    
    @objc private func togglePopover() {
        guard let popover = popover,
              let button = statusItem?.button else { return }
        
        if popover.isShown {
            closePopover()
        } else {
            openPopover(relativeTo: button)
        }
    }
    
    func openPopover(relativeTo view: NSView) {
        guard let popover = popover else { return }
        
        popover.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
        isMenuOpen = true
        
        // Activate the app to ensure proper focus
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func closePopover() {
        popover?.performClose(nil)
        isMenuOpen = false
    }
    
    func setScreenIntelligenceService(_ service: ScreenIntelligenceService) {
        // No longer needed - MenuBarManager owns the service
        print("MenuBarManager: setScreenIntelligenceService called but service is now owned by MenuBarManager")
    }
    
    func triggerCapture() {
        closePopover()
        
        // Small delay to ensure popover is closed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ScreenSelectionWindowManager.shared.showSelectionWindow(
                onRegionSelected: { [weak self] region in
                    Task {
                        await self?.screenIntelligenceService.processScreenRegion(region)
                    }
                },
                onCancelled: {
                    print("Screen capture cancelled from menu bar")
                }
            )
        }
    }
    
    func showMainWindow() {
        closePopover()
        
        // Create and show main window
        let contentView = ContentView()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "SnipeX"
        window.contentView = NSHostingController(rootView: contentView).view
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        // Activate the app
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func quit() {
        NSApp.terminate(nil)
    }
    
    func hideMenuBarIcon() {
        print("MenuBarManager: Hiding menu bar icon")
        statusItem?.isVisible = false
    }
    
    func showMenuBarIcon() {
        print("MenuBarManager: Showing menu bar icon")
        statusItem?.isVisible = true
        
        // Force refresh the menu bar
        DispatchQueue.main.async {
            self.statusItem?.button?.needsDisplay = true
        }
    }
}

// MARK: - NSPopoverDelegate
extension MenuBarManager: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        isMenuOpen = false
    }
}