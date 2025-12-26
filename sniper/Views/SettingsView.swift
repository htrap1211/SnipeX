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
    @AppStorage("aiEnhancementEnabled") private var aiEnhancementEnabled: Bool = false
    @AppStorage("globalShortcut") private var globalShortcut: KeyboardShortcut = KeyboardShortcut.default
    
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading Settings...")
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                settingsContent
            }
        }
        .onAppear {
            // Small delay to ensure everything is initialized
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isLoading = false
            }
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
                            Toggle("Show notifications", isOn: $showNotifications)
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