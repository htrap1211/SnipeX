//
//  CoreTypes.swift
//  sniper
//
//  Core data models for Screen Intelligence
//

import Foundation
import CoreGraphics
import AppKit

// MARK: - Content Classification
enum ContentType: String, CaseIterable {
    case plainText = "text"
    case table = "table"
    case code = "code"
    case math = "math"
    
    var displayName: String {
        switch self {
        case .plainText: return "Text"
        case .table: return "Table"
        case .code: return "Code"
        case .math: return "Math"
        }
    }
}

// MARK: - App Display Mode
enum AppDisplayMode: String, CaseIterable {
    case menuBarOnly = "menuBarOnly"
    case dockOnly = "dockOnly"
    case both = "both"
    
    var displayName: String {
        switch self {
        case .menuBarOnly: return "Menu Bar Only"
        case .dockOnly: return "Dock Only"
        case .both: return "Both Menu Bar & Dock"
        }
    }
    
    var description: String {
        switch self {
        case .menuBarOnly: return "App appears only in the menu bar (recommended)"
        case .dockOnly: return "App appears only in the Dock like traditional apps"
        case .both: return "App appears in both menu bar and Dock"
        }
    }
    
    var activationPolicy: NSApplication.ActivationPolicy {
        switch self {
        case .menuBarOnly: return .accessory
        case .dockOnly: return .regular
        case .both: return .regular
        }
    }
}

// MARK: - Capture Region
struct CaptureRegion {
    let rect: CGRect
    let screen: NSScreen
    let timestamp: Date
    
    init(rect: CGRect, screen: NSScreen) {
        self.rect = rect
        self.screen = screen
        self.timestamp = Date()
    }
}

// MARK: - OCR Result
struct OCRResult {
    let rawText: String
    let boundingBoxes: [CGRect]
    let confidence: Float
    let contentType: ContentType
    
    init(rawText: String, boundingBoxes: [CGRect] = [], confidence: Float = 0.0, contentType: ContentType = .plainText) {
        self.rawText = rawText
        self.boundingBoxes = boundingBoxes
        self.confidence = confidence
        self.contentType = contentType
    }
}

// MARK: - Structured Output
struct StructuredOutput {
    let originalText: String
    let processedText: String
    let contentType: ContentType
    let format: OutputFormat
    let metadata: [String: Any]
    
    enum OutputFormat: String, CaseIterable {
        case plainText = "txt"
        case markdown = "md"
        case csv = "csv"
        case json = "json"
        case latex = "tex"
        
        var displayName: String {
            switch self {
            case .plainText: return "Plain Text"
            case .markdown: return "Markdown"
            case .csv: return "CSV"
            case .json: return "JSON"
            case .latex: return "LaTeX"
            }
        }
    }
}

// MARK: - Capture History Item
struct CaptureHistoryItem: Identifiable {
    let id = UUID()
    let timestamp: Date
    let thumbnailData: Data?
    let extractedText: String
    let contentType: ContentType
    let appName: String?
    let region: CGRect
    
    init(extractedText: String, contentType: ContentType, thumbnailData: Data? = nil, appName: String? = nil, region: CGRect = .zero) {
        self.timestamp = Date()
        self.extractedText = extractedText
        self.contentType = contentType
        self.thumbnailData = thumbnailData
        self.appName = appName
        self.region = region
    }
}