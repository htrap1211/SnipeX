//
//  ScreenshotCapture.swift
//  sniper
//
//  Screenshot capture using ScreenCaptureKit
//

import Foundation
import ScreenCaptureKit
import CoreGraphics
import AppKit

class ScreenshotCapture {
    
    func captureRegion(_ region: CaptureRegion) async throws -> CGImage {
        return try await captureWithScreenCaptureKit(region)
    }
    
    @available(macOS 12.3, *)
    private func captureWithScreenCaptureKit(_ region: CaptureRegion) async throws -> CGImage {
        // Get available content
        let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        
        // Find the display that contains our region
        guard let display = availableContent.displays.first(where: { display in
            let displayFrame = CGRect(
                x: display.frame.origin.x,
                y: display.frame.origin.y,
                width: display.frame.width,
                height: display.frame.height
            )
            return displayFrame.intersects(region.rect)
        }) else {
            throw CaptureError.displayNotFound
        }
        
        // Configure the capture for the specific region
        let filter = SCContentFilter(display: display, excludingWindows: [])
        
        let configuration = SCStreamConfiguration()
        configuration.sourceRect = region.rect
        configuration.width = Int(region.rect.width * region.screen.backingScaleFactor)
        configuration.height = Int(region.rect.height * region.screen.backingScaleFactor)
        configuration.showsCursor = false
        configuration.capturesAudio = false
        
        // Perform the capture
        let image = try await SCScreenshotManager.captureImage(
            contentFilter: filter,
            configuration: configuration
        )
        
        return image
    }
}

enum CaptureError: Error {
    case displayNotFound
    case captureFailure
    case permissionDenied
    case unsupportedOS
    
    var localizedDescription: String {
        switch self {
        case .displayNotFound:
            return "Could not find the target display"
        case .captureFailure:
            return "Failed to capture screenshot"
        case .permissionDenied:
            return "Screen recording permission is required"
        case .unsupportedOS:
            return "This feature requires macOS 12.3 or later"
        }
    }
}