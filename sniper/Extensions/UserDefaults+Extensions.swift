//
//  UserDefaults+Extensions.swift
//  sniper
//
//  UserDefaults extensions for settings
//

import Foundation

extension UserDefaults {
    @objc dynamic var ocrLanguage: String {
        return string(forKey: "ocrLanguage") ?? "en-US"
    }
    
    @objc dynamic var defaultOutputFormat: String {
        return string(forKey: "defaultOutputFormat") ?? "plainText"
    }
    
    @objc dynamic var showNotifications: Bool {
        return bool(forKey: "showNotifications")
    }
    
    @objc dynamic var autoClipboard: Bool {
        return bool(forKey: "autoClipboard")
    }
}