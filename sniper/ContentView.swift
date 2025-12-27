//
//  ContentView.swift
//  sniper
//
//  Main app interface with modern design
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var screenIntelligence = ScreenIntelligenceService.shared
    @StateObject private var shortcutManager = GlobalShortcutManager()
    @State private var selectedTab: Tab = .history
    @State private var captureButtonHovered = false
    
    enum Tab: String, CaseIterable {
        case history = "History"
        case batch = "Batch Processing"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .history: return "clock.arrow.circlepath"
            case .batch: return "photo.stack"
            case .settings: return "gear"
            }
        }
        
        var description: String {
            switch self {
            case .history: return "View and manage your captures"
            case .batch: return "Process multiple images at once"
            case .settings: return "Configure app preferences"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // Modern Sidebar
            modernSidebar
        } detail: {
            // Main Content with modern styling
            modernDetailView
        }
        .onAppear {
            setupGlobalShortcut()
        }
        .onDisappear {
            shortcutManager.unregisterGlobalShortcut()
        }
        .overlay(
            // Toast notifications overlay
            ToastContainer()
                .allowsHitTesting(false)
        )
    }
    
    private var modernSidebar: some View {
        VStack(spacing: 0) {
            // Modern App Header
            VStack(spacing: 16) {
                // App icon with gradient
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
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 12, x: 0, y: 6)
                    
                    Image(systemName: "viewfinder.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
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
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "command")
                            .font(.caption2)
                        Image(systemName: "shift")
                            .font(.caption2)
                        Text("2")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("to capture")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                }
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 20)
            
            // Modern Navigation
            VStack(spacing: 8) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    ModernSidebarItem(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: { selectedTab = tab }
                    )
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            // Modern Quick Capture Button
            VStack(spacing: 16) {
                if screenIntelligence.isCapturing {
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Processing...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                Button(action: startCapture) {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.viewfinder")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Quick Capture")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.accentColor,
                                Color.accentColor.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    .scaleEffect(captureButtonHovered ? 1.02 : 1.0)
                }
                .buttonStyle(.plain)
                .disabled(screenIntelligence.isCapturing)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        captureButtonHovered = hovering
                    }
                }
            }
            .padding(20)
        }
        .frame(minWidth: 280)
        .background(.regularMaterial)
    }
    
    private var modernDetailView: some View {
        VStack(spacing: 0) {
            // Modern header for detail view
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedTab.rawValue)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(selectedTab.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Tab-specific actions could go here
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .background(.regularMaterial)
            
            // Content area
            Group {
                switch selectedTab {
                case .history:
                    HistoryView(service: screenIntelligence)
                case .batch:
                    BatchProcessingView(screenIntelligence: screenIntelligence)
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private func startCapture() {
        ScreenSelectionWindowManager.shared.showSelectionWindow(
            onRegionSelected: { region in
                Task {
                    await screenIntelligence.processScreenRegion(region)
                }
            },
            onCancelled: {
                // Selection was cancelled
                print("Screen capture cancelled")
            }
        )
    }
    
    private func setupGlobalShortcut() {
        shortcutManager.onShortcutTriggered = {
            startCapture()
        }
        shortcutManager.registerGlobalShortcut()
    }
}

// MARK: - Modern UI Components

struct ModernSidebarItem: View {
    let tab: ContentView.Tab
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.accentColor : Color.accentColor.opacity(isHovered ? 0.15 : 0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .accentColor)
                }
                
                Text(tab.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 1000, height: 700)
}
