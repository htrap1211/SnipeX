//
//  ContentView.swift
//  sniper
//
//  Main app interface
//

import SwiftUI

struct ContentView: View {
    @StateObject private var screenIntelligence = ScreenIntelligenceService()
    @StateObject private var shortcutManager = GlobalShortcutManager()
    @State private var selectedTab: Tab = .history
    
    enum Tab: String, CaseIterable {
        case history = "History"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .history: return "clock.arrow.circlepath"
            case .settings: return "gear"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(spacing: 0) {
                // App Header
                VStack(spacing: 8) {
                    Image(systemName: "viewfinder.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.accentColor)
                    
                    Text("Screen Intelligence")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("⌘⇧2 to capture")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
                
                Divider()
                
                // Navigation
                List(Tab.allCases, id: \.self, selection: $selectedTab) { tab in
                    Label(tab.rawValue, systemImage: tab.icon)
                        .tag(tab)
                }
                .listStyle(.sidebar)
                
                Spacer()
                
                // Quick Capture Button
                Button(action: startCapture) {
                    HStack {
                        Image(systemName: "camera.viewfinder")
                        Text("Quick Capture")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .disabled(screenIntelligence.isCapturing)
            }
            .frame(minWidth: 200)
        } detail: {
            // Main Content
            Group {
                switch selectedTab {
                case .history:
                    HistoryView(service: screenIntelligence)
                case .settings:
                    SettingsView()
                }
            }
            .frame(minWidth: 400, minHeight: 300)
        }
        .onAppear {
            setupGlobalShortcut()
        }
        .onDisappear {
            shortcutManager.unregisterGlobalShortcut()
        }
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

#Preview {
    ContentView()
        .frame(width: 800, height: 600)
}
