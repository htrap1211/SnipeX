//
//  MenuBarContentView.swift
//  sniper
//
//  Menu bar popover content with modern UI/UX
//

import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var menuBarManager: MenuBarManager
    @ObservedObject private var screenIntelligence: ScreenIntelligenceService
    @State private var isHovered = false
    @State private var captureButtonScale: CGFloat = 1.0
    
    init(menuBarManager: MenuBarManager) {
        self.menuBarManager = menuBarManager
        self.screenIntelligence = menuBarManager.screenIntelligenceService
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Modern Header with gradient
            headerView
            
            // Quick Actions with modern cards
            quickActionsView
            
            // Recent Captures with sleek design
            recentCapturesView
            
            Spacer()
            
            // Modern Footer
            footerView
        }
        .frame(width: 360, height: 480)
        .background(
            // Modern gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(NSColor.controlBackgroundColor),
                    Color(NSColor.controlBackgroundColor).opacity(0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            // Subtle border
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                // Modern app icon with glow effect
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.accentColor.opacity(0.8),
                                    Color.accentColor
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "viewfinder.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("SnipeX")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.primary, Color.primary.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Screen Intelligence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Modern close button
                Button(action: menuBarManager.closePopover) {
                    ZStack {
                        Circle()
                            .fill(Color.secondary.opacity(isHovered ? 0.2 : 0.1))
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "xmark")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovered = hovering
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Modern status indicator with animation
            if screenIntelligence.isCapturing {
                HStack(spacing: 12) {
                    // Animated progress indicator
                    ZStack {
                        Circle()
                            .stroke(Color.accentColor.opacity(0.3), lineWidth: 2)
                            .frame(width: 20, height: 20)
                        
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(Color.accentColor, lineWidth: 2)
                            .frame(width: 20, height: 20)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: screenIntelligence.isCapturing)
                    }
                    
                    Text("Processing capture...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
    
    private var quickActionsView: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Quick Actions")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                // Main capture button with modern design
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        captureButtonScale = 0.95
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            captureButtonScale = 1.0
                        }
                    }
                    menuBarManager.triggerCapture()
                }) {
                    HStack(spacing: 16) {
                        // Gradient icon background
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.accentColor,
                                            Color.accentColor.opacity(0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 48, height: 48)
                                .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "camera.viewfinder")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("New Capture")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "command")
                                    .font(.caption2)
                                Image(systemName: "shift")
                                    .font(.caption2)
                                Text("2")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.regularMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .scaleEffect(captureButtonScale)
                }
                .buttonStyle(.plain)
                .disabled(screenIntelligence.isCapturing)
                
                // Secondary actions with modern card design
                HStack(spacing: 12) {
                    ModernActionCard(
                        icon: "clock.arrow.circlepath",
                        title: "History",
                        action: menuBarManager.showMainWindow
                    )
                    
                    ModernActionCard(
                        icon: "gear",
                        title: "Settings",
                        action: { /* TODO: Settings */ }
                    )
                    
                    ModernActionCard(
                        icon: "square.and.arrow.up",
                        title: "Export",
                        action: { /* TODO: Export */ }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    
    private var recentCapturesView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Captures")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !screenIntelligence.captureHistory.isEmpty {
                    Button("View All") {
                        menuBarManager.showMainWindow()
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            
            if screenIntelligence.captureHistory.isEmpty {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.1))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                    
                    VStack(spacing: 8) {
                        Text("No captures yet")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Press ⌘⇧2 to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 32)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(screenIntelligence.captureHistory.prefix(4))) { item in
                            ModernCaptureRow(item: item)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 200)
            }
        }
    }
    
    private var footerView: some View {
        HStack(spacing: 16) {
            Button("Open Main Window") {
                menuBarManager.showMainWindow()
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.accentColor)
            .buttonStyle(.plain)
            
            Spacer()
            
            Button("Quit SnipeX") {
                menuBarManager.quit()
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(Color.primary.opacity(0.05))
        )
    }
}

// MARK: - Modern UI Components

struct ModernActionCard: View {
    let icon: String
    let title: String
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor.opacity(isHovered ? 0.15 : 0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.accentColor)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(isHovered ? 0.2 : 0.1), lineWidth: 1)
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct ModernCaptureRow: View {
    let item: CaptureHistoryItem
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Modern content type icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: contentTypeIcon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.extractedText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(item.contentType.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundColor(.accentColor)
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Text(timeAgo)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Modern copy button
            Button(action: copyToClipboard) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(isHovered ? 0.2 : 0.1))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                }
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                )
        )
    }
    
    private var contentTypeIcon: String {
        switch item.contentType {
        case .plainText: return "doc.text"
        case .table: return "tablecells"
        case .code: return "curlybraces"
        case .math: return "function"
        }
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: item.timestamp, relativeTo: Date())
    }
    
    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.extractedText, forType: .string)
        
        // Show brief feedback
        NotificationManager.shared.showSuccess("Copied to clipboard")
    }
}

#Preview {
    MenuBarContentView(menuBarManager: MenuBarManager())
        .frame(width: 320, height: 400)
}