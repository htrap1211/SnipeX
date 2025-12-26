//
//  NotificationManager.swift
//  sniper
//
//  Enhanced notification system with animations and feedback
//

import Foundation
import AppKit
import SwiftUI
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var currentToast: ToastMessage?
    
    private init() {
        requestNotificationPermission()
    }
    
    // MARK: - Toast Notifications (In-App)
    
    func showToast(_ message: String, type: ToastType = .info, duration: TimeInterval = 3.0) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentToast = ToastMessage(text: message, type: type, duration: duration)
        }
        
        // Auto-dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                if self.currentToast?.text == message {
                    self.currentToast = nil
                }
            }
        }
    }
    
    func showSuccess(_ message: String) {
        showToast(message, type: .success)
    }
    
    func showError(_ message: String) {
        showToast(message, type: .error, duration: 5.0)
    }
    
    func showInfo(_ message: String) {
        showToast(message, type: .info)
    }
    
    // MARK: - System Notifications
    
    func showSystemNotification(title: String, body: String, identifier: String = UUID().uuidString) {
        guard UserDefaults.standard.bool(forKey: "showNotifications") else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to show notification: \(error)")
            }
        }
    }
    
    // MARK: - Capture Feedback
    
    func showCaptureSuccess(contentType: ContentType, textLength: Int) {
        let message = "Captured \(contentType.displayName.lowercased()) (\(textLength) characters)"
        showSuccess(message)
        
        // System notification for background captures
        showSystemNotification(
            title: "SnipeX Capture Complete",
            body: message
        )
    }
    
    func showCaptureError(_ error: Error) {
        let message = "Capture failed: \(error.localizedDescription)"
        showError(message)
    }
    
    func showExportSuccess(filename: String) {
        showSuccess("Exported to \(filename)")
    }
    
    // MARK: - Permission Handling
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
}

// MARK: - Toast Message Model

struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let type: ToastType
    let duration: TimeInterval
    
    static func == (lhs: ToastMessage, rhs: ToastMessage) -> Bool {
        lhs.id == rhs.id
    }
}

enum ToastType {
    case success
    case error
    case info
    case warning
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        case .warning: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Toast View

struct ToastView: View {
    let message: ToastMessage
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: message.type.icon)
                .foregroundColor(message.type.color)
                .font(.title2)
            
            Text(message.text)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(message.type.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Toast Container View

struct ToastContainer: View {
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some View {
        VStack {
            Spacer()
            
            if let toast = notificationManager.currentToast {
                ToastView(message: toast)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: notificationManager.currentToast)
    }
}