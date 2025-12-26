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
        print("ScreenshotCapture: Starting capture for region: \(region.rect)")
        
        // Check for screen recording permissions first
        guard await checkScreenRecordingPermission() else {
            print("ScreenshotCapture: Permission denied")
            throw CaptureError.permissionDenied
        }
        
        print("ScreenshotCapture: Permission granted, proceeding with capture")
        return try await captureWithScreenCaptureKit(region)
    }
    
    private func checkScreenRecordingPermission() async -> Bool {
        print("ScreenshotCapture: Checking screen recording permission")
        
        if #available(macOS 12.3, *) {
            do {
                // Try to get shareable content to check permissions
                print("ScreenshotCapture: Attempting to get shareable content")
                let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                print("ScreenshotCapture: Successfully got shareable content with \(content.displays.count) displays")
                return true
            } catch {
                print("ScreenshotCapture: Screen recording permission check failed: \(error)")
                
                // Check if this is a specific permission error
                if let scError = error as? SCStreamError {
                    print("ScreenshotCapture: SCStreamError code: \(scError.code)")
                }
                
                return false
            }
        } else {
            print("ScreenshotCapture: macOS version < 12.3, assuming permission granted")
            return true
        }
    }
    
    @available(macOS 12.3, *)
    private func captureWithScreenCaptureKit(_ region: CaptureRegion) async throws -> CGImage {
        print("ScreenshotCapture: Starting ScreenCaptureKit capture")
        
        do {
            // Get available content with error handling
            print("ScreenshotCapture: Getting available content")
            let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            print("ScreenshotCapture: Found \(availableContent.displays.count) displays")
            
            // Find the display that contains our region
            guard let display = availableContent.displays.first(where: { display in
                let displayFrame = CGRect(
                    x: display.frame.origin.x,
                    y: display.frame.origin.y,
                    width: display.frame.width,
                    height: display.frame.height
                )
                let intersects = displayFrame.intersects(region.rect)
                print("ScreenshotCapture: Display \(display.displayID) frame: \(displayFrame), region: \(region.rect), intersects: \(intersects)")
                return intersects
            }) else {
                print("ScreenshotCapture: No display found that intersects with region \(region.rect)")
                throw CaptureError.displayNotFound
            }
            
            print("ScreenshotCapture: Using display \(display.displayID)")
            
            // Configure the capture for the specific region
            let filter = SCContentFilter(display: display, excludingWindows: [])
            
            let configuration = SCStreamConfiguration()
            configuration.sourceRect = region.rect
            configuration.width = Int(region.rect.width * region.screen.backingScaleFactor)
            configuration.height = Int(region.rect.height * region.screen.backingScaleFactor)
            configuration.showsCursor = false
            configuration.capturesAudio = false
            
            print("ScreenshotCapture: Configuration - sourceRect: \(region.rect), size: \(configuration.width)x\(configuration.height)")
            
            // Add some validation for the configuration
            if configuration.width <= 0 || configuration.height <= 0 {
                print("ScreenshotCapture: Invalid configuration dimensions")
                throw CaptureError.captureFailure
            }
            
            // Perform the capture with error handling
            print("ScreenshotCapture: Performing capture")
            let image = try await SCScreenshotManager.captureImage(
                contentFilter: filter,
                configuration: configuration
            )
            
            print("ScreenshotCapture: Capture successful, image size: \(image.width)x\(image.height)")
            return image
            
        } catch let error as CaptureError {
            print("ScreenshotCapture: CaptureError: \(error)")
            throw error
        } catch {
            print("ScreenshotCapture: ScreenCaptureKit error: \(error)")
            
            // Log more details about the error
            if let scError = error as? SCStreamError {
                print("ScreenshotCapture: SCStreamError code: \(scError.code), description: \(scError.localizedDescription)")
            }
            
            throw CaptureError.captureFailure
        }
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