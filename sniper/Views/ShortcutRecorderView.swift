//
//  ShortcutRecorderView.swift
//  sniper
//
//  Custom keyboard shortcut recorder
//

import SwiftUI
import AppKit
import Carbon

struct ShortcutRecorderView: View {
    @Binding var shortcut: KeyboardShortcut
    @State private var isRecording = false
    @State private var recordedShortcut: KeyboardShortcut?
    @State private var eventMonitor: Any?
    
    var body: some View {
        HStack {
            Button(action: toggleRecording) {
                HStack {
                    if isRecording {
                        Text("Press keys...")
                            .foregroundColor(.secondary)
                    } else {
                        Text(shortcut.displayString)
                            .font(.system(.body, design: .monospaced))
                    }
                }
                .frame(minWidth: 120)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isRecording ? Color.accentColor.opacity(0.2) : Color(NSColor.controlBackgroundColor))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isRecording ? Color.accentColor : Color.clear, lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
            
            if shortcut != KeyboardShortcut.default {
                Button("Reset") {
                    shortcut = KeyboardShortcut.default
                }
                .buttonStyle(.link)
            }
        }
        .onAppear {
            // Don't set up monitoring on appear to avoid conflicts
        }
        .onDisappear {
            cleanupEventMonitor()
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            // Stop recording
            isRecording = false
            cleanupEventMonitor()
            if let recorded = recordedShortcut {
                shortcut = recorded
                recordedShortcut = nil
            }
        } else {
            // Start recording
            isRecording = true
            setupKeyEventMonitor()
        }
    }
    
    private func setupKeyEventMonitor() {
        // Clean up any existing monitor first
        cleanupEventMonitor()
        
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            guard self.isRecording else { return event }
            
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            let keyCode = event.keyCode
            
            // Require at least one modifier key
            guard !modifiers.isEmpty else { return nil }
            
            // Create shortcut from event
            if let shortcut = KeyboardShortcut.from(keyCode: keyCode, modifiers: modifiers) {
                DispatchQueue.main.async {
                    self.recordedShortcut = shortcut
                    self.isRecording = false
                    self.cleanupEventMonitor()
                }
            }
            
            return nil // Consume the event
        }
    }
    
    private func cleanupEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

// MARK: - Keyboard Shortcut Model

struct KeyboardShortcut: Codable, Equatable {
    let keyCode: UInt16
    let modifiers: NSEvent.ModifierFlags
    
    static let `default` = KeyboardShortcut(keyCode: 19, modifiers: [.command, .shift]) // ⌘⇧2
    
    var displayString: String {
        var result = ""
        
        if modifiers.contains(.control) { result += "⌃" }
        if modifiers.contains(.option) { result += "⌥" }
        if modifiers.contains(.shift) { result += "⇧" }
        if modifiers.contains(.command) { result += "⌘" }
        
        result += keyCodeToString(keyCode)
        
        return result
    }
    
    var carbonModifiers: UInt32 {
        var carbonMods: UInt32 = 0
        
        if modifiers.contains(.command) { carbonMods |= UInt32(cmdKey) }
        if modifiers.contains(.shift) { carbonMods |= UInt32(shiftKey) }
        if modifiers.contains(.option) { carbonMods |= UInt32(optionKey) }
        if modifiers.contains(.control) { carbonMods |= UInt32(controlKey) }
        
        return carbonMods
    }
    
    static func from(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) -> KeyboardShortcut? {
        // Filter to only relevant modifier flags
        let relevantModifiers = modifiers.intersection([.command, .shift, .option, .control])
        
        // Require at least command or control
        guard relevantModifiers.contains(.command) || relevantModifiers.contains(.control) else {
            return nil
        }
        
        return KeyboardShortcut(keyCode: keyCode, modifiers: relevantModifiers)
    }
    
    private func keyCodeToString(_ keyCode: UInt16) -> String {
        // Common key codes to readable strings
        switch keyCode {
        case 0: return "A"
        case 1: return "S"
        case 2: return "D"
        case 3: return "F"
        case 4: return "H"
        case 5: return "G"
        case 6: return "Z"
        case 7: return "X"
        case 8: return "C"
        case 9: return "V"
        case 11: return "B"
        case 12: return "Q"
        case 13: return "W"
        case 14: return "E"
        case 15: return "R"
        case 16: return "Y"
        case 17: return "T"
        case 18: return "1"
        case 19: return "2"
        case 20: return "3"
        case 21: return "4"
        case 22: return "6"
        case 23: return "5"
        case 24: return "="
        case 25: return "9"
        case 26: return "7"
        case 27: return "-"
        case 28: return "8"
        case 29: return "0"
        case 30: return "]"
        case 31: return "O"
        case 32: return "U"
        case 33: return "["
        case 34: return "I"
        case 35: return "P"
        case 37: return "L"
        case 38: return "J"
        case 39: return "'"
        case 40: return "K"
        case 41: return ";"
        case 42: return "\\"
        case 43: return ","
        case 44: return "/"
        case 45: return "N"
        case 46: return "M"
        case 47: return "."
        case 49: return "Space"
        case 50: return "`"
        case 51: return "⌫"
        case 53: return "⎋"
        case 36: return "⏎"
        case 48: return "⇥"
        case 123: return "←"
        case 124: return "→"
        case 125: return "↓"
        case 126: return "↑"
        case 122: return "F1"
        case 120: return "F2"
        case 99: return "F3"
        case 118: return "F4"
        case 96: return "F5"
        case 97: return "F6"
        case 98: return "F7"
        case 100: return "F8"
        case 101: return "F9"
        case 109: return "F10"
        case 103: return "F11"
        case 111: return "F12"
        default: return "Key\(keyCode)"
        }
    }
}

// MARK: - AppStorage Extension

extension KeyboardShortcut: RawRepresentable {
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8) else {
            // Return a safe default if encoding fails
            return "default"
        }
        return string
    }
    
    public init?(rawValue: String) {
        // Handle the default case
        if rawValue == "default" {
            self = KeyboardShortcut.default
            return
        }
        
        guard let data = rawValue.data(using: .utf8),
              let shortcut = try? JSONDecoder().decode(KeyboardShortcut.self, from: data) else {
            return nil
        }
        self = shortcut
    }
}

#Preview {
    @Previewable @State var shortcut = KeyboardShortcut.default
    return ShortcutRecorderView(shortcut: $shortcut)
        .padding()
}