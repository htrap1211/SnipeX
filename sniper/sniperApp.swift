//
//  sniperApp.swift
//  sniper
//
//  Screen Intelligence App
//

import SwiftUI

@main
struct sniperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Capture") {
                    // Trigger capture from menu
                }
                .keyboardShortcut("2", modifiers: [.command, .shift])
            }
        }
        
        Settings {
            SettingsView()
        }
    }
}
