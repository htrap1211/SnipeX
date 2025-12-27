//
//  GlobalShortcutManager.swift
//  sniper
//
//  Global keyboard shortcut handling with customization support
//

import Foundation
import AppKit
import Carbon
import Combine
import SwiftUI

class GlobalShortcutManager: ObservableObject {
    private var eventMonitor: Any?
    private var hotKeyRef: EventHotKeyRef?
    private let hotKeyID: EventHotKeyID = EventHotKeyID(signature: OSType(0x53495052), id: 1) // 'SIPR'
    private var eventHandlerRef: EventHandlerRef?
    
    @AppStorage("globalShortcut") private var storedShortcut: KeyboardShortcut = KeyboardShortcut.default
    
    var onShortcutTriggered: (() -> Void)?
    
    var currentShortcut: KeyboardShortcut {
        get { storedShortcut }
        set {
            storedShortcut = newValue
            // Re-register with new shortcut
            registerGlobalShortcut()
        }
    }
    
    func registerGlobalShortcut() {
        registerGlobalShortcut(with: currentShortcut)
    }
    
    func registerGlobalShortcut(with shortcut: KeyboardShortcut) {
        // Unregister any existing shortcut first
        unregisterGlobalShortcut()
        
        let keyCode = UInt32(shortcut.keyCode)
        let modifiers = shortcut.carbonModifiers
        
        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status == noErr {
            self.hotKeyRef = hotKeyRef
            installEventHandler()
            print("Successfully registered global shortcut: \(shortcut.displayString)")
        } else {
            print("Failed to register global shortcut: \(status)")
            handleShortcutRegistrationError(status, shortcut: shortcut)
        }
    }
    
    private func handleShortcutRegistrationError(_ status: OSStatus, shortcut: KeyboardShortcut) {
        let errorMessage: String
        
        switch status {
        case -9878: // eventAlreadyPostedErr or hotkey already registered
            errorMessage = "Shortcut \(shortcut.displayString) is already in use by another application"
        case -50: // paramErr
            errorMessage = "Invalid shortcut parameters"
        case -108: // memFullErr
            errorMessage = "Not enough memory to register shortcut"
        default:
            errorMessage = "Unknown error (\(status)) registering shortcut"
        }
        
        print("Shortcut registration error: \(errorMessage)")
        
        // Try to register a fallback shortcut
        if shortcut != KeyboardShortcut.fallback {
            print("Attempting to register fallback shortcut...")
            registerGlobalShortcut(with: KeyboardShortcut.fallback)
        } else {
            // Even fallback failed, show user notification
            DispatchQueue.main.async {
                NotificationManager.shared.showError("Could not register global shortcut. Please choose a different shortcut in Settings.")
            }
        }
    }
    
    func unregisterGlobalShortcut() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        
        if let eventHandlerRef = eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
        
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }
    
    private func installEventHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        
        let callback: EventHandlerProcPtr = { (nextHandler, theEvent, userData) -> OSStatus in
            guard let userData = userData else { return OSStatus(eventNotHandledErr) }
            
            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(
                theEvent,
                OSType(kEventParamDirectObject),
                OSType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )
            
            guard status == noErr else { return OSStatus(eventNotHandledErr) }
            
            // Get the manager instance from user data
            let manager = Unmanaged<GlobalShortcutManager>.fromOpaque(userData).takeUnretainedValue()
            
            DispatchQueue.main.async {
                manager.onShortcutTriggered?()
            }
            
            return OSStatus(noErr)
        }
        
        var eventHandlerRef: EventHandlerRef?
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )
        
        if status == noErr {
            self.eventHandlerRef = eventHandlerRef
        } else {
            print("Failed to install event handler: \(status)")
        }
    }
    
    deinit {
        unregisterGlobalShortcut()
    }
}