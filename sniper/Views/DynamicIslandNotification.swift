//
//  DynamicIslandNotification.swift
//  sniper
//
//  Modern iPhone Dynamic Island-style notification for macOS
//

import SwiftUI
import AppKit
import Combine

class DynamicIslandNotificationManager {
    static let shared = DynamicIslandNotificationManager()
    
    private var notificationWindow: NSWindow?
    
    private init() {}
    
    func showNotification(message: String, duration: TimeInterval = 2.5) {
        DispatchQueue.main.async {
            self.displayNotification(message: message, duration: duration)
        }
    }
    
    private func displayNotification(message: String, duration: TimeInterval) {
        // Close any existing notification
        hideNotification()
        
        // Get the main screen
        guard let screen = NSScreen.main else { return }
        
        // Create the notification view
        let notificationView = DynamicIslandNotificationView(message: message)
        
        // Calculate position (bottom center of screen)
        let notificationSize = CGSize(width: 320, height: 60)
        let windowRect = CGRect(
            x: (screen.frame.width - notificationSize.width) / 2,
            y: 80, // 80 points from bottom for comfortable viewing
            width: notificationSize.width,
            height: notificationSize.height
        )
        
        // Create window
        let window = NSWindow(
            contentRect: windowRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        // Configure window for modern appearance
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        window.backgroundColor = NSColor.clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        
        // Set content
        window.contentView = NSHostingController(rootView: notificationView).view
        
        // Show window with animation
        window.orderFrontRegardless()
        
        // Store reference
        self.notificationWindow = window
        
        // Auto-hide after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.hideNotification()
        }
    }
    
    private func hideNotification() {
        notificationWindow?.orderOut(nil)
        notificationWindow = nil
    }
}

struct DynamicIslandNotificationView: View {
    let message: String
    @State private var isVisible = false
    @State private var checkmarkScale: CGFloat = 0.5
    @State private var backgroundScale: CGFloat = 0.8
    
    var body: some View {
        HStack(spacing: 16) {
            // Animated checkmark with modern styling
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.green.opacity(0.8),
                                Color.green
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                    .scaleEffect(checkmarkScale)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(checkmarkScale)
            }
            
            // Message text with modern typography
            Text(message)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            // Modern Dynamic Island-style background with blur
            ZStack {
                // Background blur
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.primary.opacity(0.05),
                                Color.primary.opacity(0.02)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.primary.opacity(0.2),
                                Color.primary.opacity(0.1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
            }
            .scaleEffect(backgroundScale)
        )
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            // Staggered animations for a more polished feel
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                isVisible = true
                backgroundScale = 1.0
            }
            
            // Delayed checkmark animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    checkmarkScale = 1.0
                }
            }
            
            // Exit animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isVisible = false
                }
            }
        }
    }
}

// Preview for SwiftUI Canvas
struct DynamicIslandNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicIslandNotificationView(message: "Text copied to clipboard")
            .padding()
            .background(Color.gray.opacity(0.3))
    }
}