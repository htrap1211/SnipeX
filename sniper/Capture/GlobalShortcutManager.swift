//
//  GlobalShortcutManager.swift
//  sniper
//
//  Global keyboard shortcut handling
//

import Foundation
import AppKit
import Carbon
import Combine

class GlobalShortcutManager: ObservableObject {
    private var eventMonitor: Any?
    private var hotKeyRef: EventHotKeyRef?
    private let hotKeyID: EventHotKeyID = EventHotKeyID(signature: OSType(0x53495052), id: 1) // 'SIPR'
    private var eventHandlerRef: EventHandlerRef?
    
    var onShortcutTriggered: (() -> Void)?
    
    func registerGlobalShortcut() {
        // Unregister any existing shortcut first
        unregisterGlobalShortcut()
        
        // Register Cmd+Shift+2 (similar to screenshot shortcut)
        let keyCode: UInt32 = 19 // Key code for '2'
        let modifiers: UInt32 = UInt32(cmdKey | shiftKey)
        
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
        } else {
            print("Failed to register global shortcut: \(status)")
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