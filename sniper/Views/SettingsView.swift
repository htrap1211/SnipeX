//
//  SettingsView.swift
//  sniper
//
//  App settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultOutputFormat") private var defaultOutputFormat: String = StructuredOutput.OutputFormat.plainText.rawValue
    @AppStorage("ocrLanguage") private var ocrLanguage: String = "en-US"
    @AppStorage("showNotifications") private var showNotifications: Bool = true
    @AppStorage("autoClipboard") private var autoClipboard: Bool = true
    @AppStorage("appDisplayMode") private var appDisplayMode: String = AppDisplayMode.menuBarOnly.rawValue
    @AppStorage("aiEnhancementEnabled") private var aiEnhancementEnabled: Bool = false
    @AppStorage("globalShortcut") private var globalShortcut: KeyboardShortcut = KeyboardShortcut.default
    
    var body: some View {
        settingsContent
            .onAppear {
                // Ensure settings are properly initialized
                print("SettingsView: Loaded with language: \(ocrLanguage), format: \(defaultOutputFormat)")
            }
    }
    
    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Configure Screen Intelligence behavior")
                    .foregroundColor(.secondary)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Capture Settings
                    SettingsSection(title: "Capture", icon: "camera.viewfinder") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Keyboard Shortcut:")
                                    .frame(width: 140, alignment: .leading)
                                
                                ShortcutRecorderView(shortcut: $globalShortcut)
                                
                                Spacer()
                            }
                            
                            Toggle("Auto-copy to clipboard", isOn: $autoClipboard)
                            
                            HStack {
                                Toggle("Show notifications", isOn: $showNotifications)
                                
                                if showNotifications && !NotificationManager.shared.notificationPermissionGranted {
                                    Button("Enable in System Preferences") {
                                        openNotificationSettings()
                                    }
                                    .buttonStyle(.link)
                                    .font(.caption)
                                }
                            }
                        }
                    }
                    
                    // App Appearance Settings
                    SettingsSection(title: "App Appearance", icon: "app.badge") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Display Mode:")
                                    .frame(width: 140, alignment: .leading)
                                
                                Picker("Display Mode", selection: $appDisplayMode) {
                                    ForEach(AppDisplayMode.allCases, id: \.rawValue) { mode in
                                        Text(mode.displayName).tag(mode.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: 200)
                                
                                Spacer()
                            }
                            
                            // Show description for selected mode
                            if let selectedMode = AppDisplayMode(rawValue: appDisplayMode) {
                                Text(selectedMode.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 140)
                            }
                            
                            // Restart notice
                            if appDisplayMode != AppDisplayMode.menuBarOnly.rawValue {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.orange)
                                        Text("App restart required for display mode changes")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                    
                                    Button("Restart SnipeX Now") {
                                        restartApp()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                }
                                .padding(.leading, 140)
                            }
                        }
                    }
                    
                    // OCR Settings
                    SettingsSection(title: "Text Recognition", icon: "doc.text.magnifyingglass") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Language:")
                                    .frame(width: 140, alignment: .leading)
                                
                                Picker("Language", selection: $ocrLanguage) {
                                    ForEach(getSupportedLanguages(), id: \.self) { languageCode in
                                        Text(getLanguageDisplayName(for: languageCode))
                                            .tag(languageCode)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: 200)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Text("Default Format:")
                                    .frame(width: 140, alignment: .leading)
                                
                                Picker("Format", selection: $defaultOutputFormat) {
                                    ForEach(StructuredOutput.OutputFormat.allCases, id: \.rawValue) { format in
                                        Text(format.displayName).tag(format.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: 200)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // AI Enhancement (Future Feature)
                    SettingsSection(title: "AI Enhancement", icon: "brain.head.profile") {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Enable AI text cleanup", isOn: $aiEnhancementEnabled)
                                .disabled(true) // For MVP
                            
                            Text("AI features will be available in a future update")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Privacy
                    SettingsSection(title: "Privacy", icon: "hand.raised.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("All processing happens on your device", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            
                            Label("Screenshots are never saved to disk", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            
                            Label("No data is sent to external servers", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            
                            Button("View Privacy Policy") {
                                // TODO: Show privacy policy
                            }
                            .buttonStyle(.link)
                        }
                    }
                    
                    // About
                    SettingsSection(title: "About", icon: "info.circle") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Screen Intelligence v1.0")
                                .font(.headline)
                            
                            Text("Advanced OCR with intelligent content detection")
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Button("GitHub") {
                                    // TODO: Open GitHub
                                }
                                .buttonStyle(.link)
                                
                                Button("Support") {
                                    // TODO: Open support
                                }
                                .buttonStyle(.link)
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    // Helper methods to safely access OCREngineFactory
    private func getSupportedLanguages() -> [String] {
        return Array(OCREngineFactory.supportedLanguages.keys.sorted())
    }
    
    private func getLanguageDisplayName(for code: String) -> String {
        return OCREngineFactory.languageDisplayName(for: code)
    }
    
    private func restartApp() {
        // Show confirmation dialog
        let alert = NSAlert()
        alert.messageText = "Restart SnipeX"
        alert.informativeText = "SnipeX will restart to apply the new display mode. Any unsaved work will be lost."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Restart Now")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Get the app bundle path
            let bundlePath = Bundle.main.bundlePath
            
            // Use NSWorkspace to relaunch the app
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = [bundlePath]
            
            // Launch the new instance
            task.launch()
            
            // Quit the current instance
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSApp.terminate(nil)
            }
        }
    }
    
    private func openNotificationSettings() {
        // Open System Preferences to Notifications
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.headline)
            }
            
            content
                .padding(.leading, 24)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(12)
    }
}

#Preview {
    SettingsView()
        .frame(width: 500, height: 600)
}