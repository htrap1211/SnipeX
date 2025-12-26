//
//  ScreenSelectionOverlay.swift
//  sniper
//
//  TextSniper-style implementation using ScreenCaptureKit
//

import SwiftUI
import AppKit
import ScreenCaptureKit

// Custom window class that can become key window
class ScreenSelectionWindow: NSWindow {
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }
    override var acceptsFirstResponder: Bool { return true }
}

// TextSniper-style approach: capture entire screen, then let user select region
class ScreenSelectionWindowManager {
    static let shared = ScreenSelectionWindowManager()
    private var selectionWindow: NSWindow?
    private var capturedImage: NSImage?
    
    private init() {}
    
    func showSelectionWindow(onRegionSelected: @escaping (CaptureRegion) -> Void, onCancelled: @escaping () -> Void) {
        print("ScreenSelectionWindowManager: showSelectionWindow called")
        
        // Ensure we're on the main thread
        DispatchQueue.main.async {
            // Add a small delay to ensure the app is fully initialized
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                Task {
                    await self.captureScreenThenSelect(onRegionSelected: onRegionSelected, onCancelled: onCancelled)
                }
            }
        }
    }
    
    private func captureScreenThenSelect(onRegionSelected: @escaping (CaptureRegion) -> Void, onCancelled: @escaping () -> Void) async {
        guard let screen = NSScreen.main else {
            print("ScreenSelectionWindowManager: No main screen found")
            onCancelled()
            return
        }
        
        print("ScreenSelectionWindowManager: Starting capture process for screen: \(screen.frame)")
        
        do {
            // Step 1: Capture the entire screen using ScreenCaptureKit
            let screenImage: CGImage
            
            if #available(macOS 12.3, *) {
                screenImage = try await captureEntireScreen()
            } else {
                // Fallback for older macOS versions
                print("ScreenSelectionWindowManager: Using fallback capture for macOS < 12.3")
                throw CaptureError.unsupportedOS
            }
            
            let nsImage = NSImage(cgImage: screenImage, size: screen.frame.size)
            self.capturedImage = nsImage
            
            print("ScreenSelectionWindowManager: Screen captured successfully, showing selection overlay")
            
            // Step 2: Show selection overlay on top of the captured image
            DispatchQueue.main.async {
                self.showSelectionOverlay(
                    screenImage: nsImage,
                    screen: screen,
                    onRegionSelected: onRegionSelected,
                    onCancelled: onCancelled
                )
            }
        } catch {
            print("ScreenSelectionWindowManager: Failed to capture screen: \(error)")
            
            // Show a more user-friendly error
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Screen Capture Failed"
                
                if error is CaptureError {
                    alert.informativeText = (error as! CaptureError).localizedDescription
                } else {
                    alert.informativeText = "Unable to capture screen. Please check screen recording permissions in System Preferences > Security & Privacy > Privacy > Screen Recording."
                }
                
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.addButton(withTitle: "Open System Preferences")
                
                let response = alert.runModal()
                if response == .alertSecondButtonReturn {
                    // Open System Preferences to Screen Recording
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
            
            onCancelled()
        }
    }
    
    @available(macOS 12.3, *)
    private func captureEntireScreen() async throws -> CGImage {
        print("ScreenSelectionWindowManager: Starting entire screen capture")
        
        do {
            // Get available content
            print("ScreenSelectionWindowManager: Getting shareable content")
            let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            print("ScreenSelectionWindowManager: Found \(availableContent.displays.count) displays")
            
            // Get the main display
            guard let display = availableContent.displays.first else {
                print("ScreenSelectionWindowManager: No displays found")
                throw CaptureError.displayNotFound
            }
            
            print("ScreenSelectionWindowManager: Using display \(display.displayID), size: \(display.width)x\(display.height)")
            
            // Configure the capture for entire screen
            let filter = SCContentFilter(display: display, excludingWindows: [])
            
            let configuration = SCStreamConfiguration()
            configuration.width = Int(display.width)
            configuration.height = Int(display.height)
            configuration.showsCursor = false
            configuration.capturesAudio = false
            
            print("ScreenSelectionWindowManager: Configuration set, performing capture")
            
            // Perform the capture
            let image = try await SCScreenshotManager.captureImage(
                contentFilter: filter,
                configuration: configuration
            )
            
            print("ScreenSelectionWindowManager: Screen capture successful, image size: \(image.width)x\(image.height)")
            return image
            
        } catch {
            print("ScreenSelectionWindowManager: Screen capture failed: \(error)")
            
            // Log more details about the error
            if let scError = error as? SCStreamError {
                print("ScreenSelectionWindowManager: SCStreamError code: \(scError.code), description: \(scError.localizedDescription)")
            }
            
            throw error
        }
    }
    
    private func showSelectionOverlay(
        screenImage: NSImage,
        screen: NSScreen,
        onRegionSelected: @escaping (CaptureRegion) -> Void,
        onCancelled: @escaping () -> Void
    ) {
        print("ScreenSelectionWindowManager: Creating selection overlay window")
        
        // Close any existing window
        hideSelectionWindow()
        
        // Create a custom window that can become key
        let window = ScreenSelectionWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        // Configure window to properly receive input
        window.level = .screenSaver
        window.backgroundColor = NSColor.clear
        window.isOpaque = false
        window.ignoresMouseEvents = false
        window.acceptsMouseMovedEvents = true
        window.hasShadow = false
        window.canHide = false
        window.hidesOnDeactivate = false
        
        // Create the selection view
        let selectionView = TextSniperStyleSelectionView(
            backgroundImage: screenImage,
            screen: screen
        )
        
        selectionView.onRegionSelected = { [weak self] region in
            print("ScreenSelectionWindowManager: Region selected: \(region.rect)")
            self?.hideSelectionWindow()
            onRegionSelected(region)
        }
        
        selectionView.onCancelled = { [weak self] in
            print("ScreenSelectionWindowManager: Selection cancelled")
            self?.hideSelectionWindow()
            onCancelled()
        }
        
        window.contentView = selectionView
        
        // Show the window with proper ordering
        window.orderFrontRegardless()
        
        // Make sure the window can receive key events
        // Use a small delay to ensure proper window setup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            window.makeKeyAndOrderFront(nil)
            print("ScreenSelectionWindowManager: Selection window is now active")
        }
        
        self.selectionWindow = window
    }
    
    private func hideSelectionWindow() {
        selectionWindow?.orderOut(nil)
        selectionWindow = nil
        capturedImage = nil
    }
}

// TextSniper-style selection view
class TextSniperStyleSelectionView: NSView {
    var onRegionSelected: ((CaptureRegion) -> Void)?
    var onCancelled: (() -> Void)?
    
    private let backgroundImage: NSImage
    private let screen: NSScreen
    private var startPoint: CGPoint = .zero
    private var currentPoint: CGPoint = .zero
    private var isSelecting = false
    
    init(backgroundImage: NSImage, screen: NSScreen) {
        self.backgroundImage = backgroundImage
        self.screen = screen
        super.init(frame: screen.frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        wantsLayer = true
        
        // Add a simple timer to auto-cancel after 30 seconds (safety measure)
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { [weak self] _ in
            self?.onCancelled?()
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        startPoint = event.locationInWindow
        currentPoint = startPoint
        isSelecting = true
        needsDisplay = true
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard isSelecting else { return }
        currentPoint = event.locationInWindow
        needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        guard isSelecting else { return }
        isSelecting = false
        
        let selectionRect = CGRect(
            x: min(startPoint.x, currentPoint.x),
            y: min(startPoint.y, currentPoint.y),
            width: abs(currentPoint.x - startPoint.x),
            height: abs(currentPoint.y - startPoint.y)
        )
        
        // Check if selection is meaningful
        if selectionRect.width > 10 && selectionRect.height > 10 {
            // Convert coordinates (flip Y axis for screen coordinates)
            let screenRect = CGRect(
                x: selectionRect.origin.x,
                y: screen.frame.height - selectionRect.origin.y - selectionRect.height,
                width: selectionRect.width,
                height: selectionRect.height
            )
            
            let region = CaptureRegion(rect: screenRect, screen: screen)
            onRegionSelected?(region)
        } else {
            onCancelled?()
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape key
            onCancelled?()
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Draw the captured screen image as background
        backgroundImage.draw(in: bounds)
        
        // Draw dark overlay over everything
        NSColor.black.withAlphaComponent(0.4).setFill()
        bounds.fill()
        
        if isSelecting {
            let selectionRect = CGRect(
                x: min(startPoint.x, currentPoint.x),
                y: min(startPoint.y, currentPoint.y),
                width: abs(currentPoint.x - startPoint.x),
                height: abs(currentPoint.y - startPoint.y)
            )
            
            // Draw selection border (no clear area, just the border)
            NSColor.systemBlue.setStroke()
            let path = NSBezierPath(rect: selectionRect)
            path.lineWidth = 2.0
            path.stroke()
            
            // Draw corner handles for better visibility
            let handleSize: CGFloat = 8
            let handles = [
                CGPoint(x: selectionRect.minX, y: selectionRect.minY),
                CGPoint(x: selectionRect.maxX, y: selectionRect.minY),
                CGPoint(x: selectionRect.minX, y: selectionRect.maxY),
                CGPoint(x: selectionRect.maxX, y: selectionRect.maxY)
            ]
            
            NSColor.systemBlue.setFill()
            for handle in handles {
                let handleRect = CGRect(
                    x: handle.x - handleSize/2,
                    y: handle.y - handleSize/2,
                    width: handleSize,
                    height: handleSize
                )
                NSBezierPath(ovalIn: handleRect).fill()
            }
            
            // Draw dimensions
            let dimensionsText = String(format: "%.0f × %.0f", selectionRect.width, selectionRect.height)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .medium),
                .foregroundColor: NSColor.white
            ]
            
            let attributedString = NSAttributedString(string: dimensionsText, attributes: attributes)
            let textSize = attributedString.size()
            let textRect = CGRect(
                x: selectionRect.maxX - textSize.width - 10,
                y: selectionRect.minY - textSize.height - 10,
                width: textSize.width + 8,
                height: textSize.height + 4
            )
            
            // Background for dimensions
            NSColor.black.withAlphaComponent(0.8).setFill()
            NSBezierPath(roundedRect: textRect, xRadius: 4, yRadius: 4).fill()
            
            attributedString.draw(at: CGPoint(x: textRect.minX + 4, y: textRect.minY + 2))
        } else {
            // Show instructions
            let instructionText = "Click and drag to select an area • Press ESC to cancel"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: NSColor.white
            ]
            
            let attributedString = NSAttributedString(string: instructionText, attributes: attributes)
            let textSize = attributedString.size()
            let textRect = CGRect(
                x: (bounds.width - textSize.width) / 2,
                y: bounds.height - 60,
                width: textSize.width,
                height: textSize.height
            )
            
            // Background for instructions
            NSColor.black.withAlphaComponent(0.8).setFill()
            NSBezierPath(roundedRect: textRect.insetBy(dx: -10, dy: -5), xRadius: 8, yRadius: 8).fill()
            
            attributedString.draw(in: textRect)
        }
    }
    
    override var acceptsFirstResponder: Bool { true }
}

// Legacy compatibility structs
struct ScreenSelectionOverlayWindow: View {
    let onRegionSelected: (CaptureRegion) -> Void
    let onCancelled: () -> Void
    
    var body: some View {
        VStack {
            Text("Screen Selection")
                .font(.title)
                .padding()
            
            Button("Start Selection") {
                ScreenSelectionWindowManager.shared.showSelectionWindow(
                    onRegionSelected: onRegionSelected,
                    onCancelled: onCancelled
                )
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct ScreenSelectionOverlay: NSViewRepresentable {
    let onRegionSelected: (CaptureRegion) -> Void
    let onCancelled: () -> Void
    
    func makeNSView(context: Context) -> NSView {
        return NSView()
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // Not used
    }
}