//
//  BatchProcessor.swift
//  sniper
//
//  Batch processing for multiple screenshots
//

import Foundation
import CoreGraphics
import AppKit
import SwiftUI
import Combine

@MainActor
class BatchProcessor: ObservableObject {
    @Published var isProcessing = false
    @Published var progress: Double = 0.0
    @Published var currentItem = 0
    @Published var totalItems = 0
    @Published var results: [BatchResult] = []
    
    private let screenIntelligence: ScreenIntelligenceService
    
    init(screenIntelligence: ScreenIntelligenceService) {
        self.screenIntelligence = screenIntelligence
    }
    
    // MARK: - Batch Processing
    
    func processImages(_ images: [NSImage]) async {
        guard !images.isEmpty else { return }
        
        isProcessing = true
        progress = 0.0
        currentItem = 0
        totalItems = images.count
        results.removeAll()
        
        NotificationManager.shared.showInfo("Starting batch processing of \(images.count) images...")
        
        for (index, image) in images.enumerated() {
            currentItem = index + 1
            
            do {
                let result = try await processImage(image, index: index)
                results.append(result)
                
                progress = Double(index + 1) / Double(images.count)
                
            } catch {
                let errorResult = BatchResult(
                    index: index,
                    success: false,
                    error: error,
                    extractedText: nil,
                    contentType: nil
                )
                results.append(errorResult)
            }
        }
        
        isProcessing = false
        
        let successCount = results.filter { $0.success }.count
        let failureCount = results.count - successCount
        
        if failureCount == 0 {
            NotificationManager.shared.showSuccess("Batch processing complete! \(successCount) images processed successfully.")
        } else {
            NotificationManager.shared.showInfo("Batch processing complete! \(successCount) successful, \(failureCount) failed.")
        }
    }
    
    func processFiles(_ urls: [URL]) async {
        let images = urls.compactMap { url -> NSImage? in
            let validExtensions = ["png", "jpg", "jpeg", "tiff", "bmp", "gif"]
            guard validExtensions.contains(url.pathExtension.lowercased()) else { return nil }
            return NSImage(contentsOf: url)
        }
        
        guard !images.isEmpty else {
            NotificationManager.shared.showError("No valid image files found.")
            return
        }
        
        await processImages(images)
    }
    
    // MARK: - Individual Processing
    
    private func processImage(_ image: NSImage, index: Int) async throws -> BatchResult {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw BatchProcessingError.invalidImage
        }
        
        // Use the same processing pipeline as regular captures
        let preprocessedImage = screenIntelligence.batchImagePreprocessor.preprocessForOCR(cgImage) ?? cgImage
        let ocrResult = try await screenIntelligence.batchOCREngine.recognize(image: preprocessedImage)
        let contentType = screenIntelligence.batchContentClassifier.classifyContent(text: ocrResult.rawText, image: preprocessedImage)
        
        return BatchResult(
            index: index,
            success: true,
            error: nil,
            extractedText: ocrResult.rawText,
            contentType: contentType
        )
    }
    
    // MARK: - Export Results
    
    func exportResults(to url: URL, format: BatchExportFormat) throws {
        switch format {
        case .csv:
            try exportAsCSV(to: url)
        case .json:
            try exportAsJSON(to: url)
        case .txt:
            try exportAsText(to: url)
        }
        
        NotificationManager.shared.showExportSuccess(filename: url.lastPathComponent)
    }
    
    private func exportAsCSV(to url: URL) throws {
        var csvContent = "Index,Success,Content Type,Text Length,Text\n"
        
        for result in results {
            let success = result.success ? "Yes" : "No"
            let contentType = result.contentType?.displayName ?? "Unknown"
            let textLength = result.extractedText?.count ?? 0
            let text = result.extractedText?.replacingOccurrences(of: "\"", with: "\"\"") ?? ""
            
            csvContent += "\(result.index),\(success),\(contentType),\(textLength),\"\(text)\"\n"
        }
        
        try csvContent.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func exportAsJSON(to url: URL) throws {
        let exportData = results.map { result in
            [
                "index": result.index,
                "success": result.success,
                "contentType": result.contentType?.rawValue ?? "unknown",
                "extractedText": result.extractedText ?? "",
                "error": result.error?.localizedDescription ?? ""
            ]
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
        try jsonData.write(to: url)
    }
    
    private func exportAsText(to url: URL) throws {
        let textContent = results.enumerated().map { index, result in
            let header = "=== Image \(result.index + 1) ==="
            let status = result.success ? "SUCCESS" : "FAILED"
            let contentType = result.contentType?.displayName ?? "Unknown"
            let text = result.extractedText ?? "No text extracted"
            
            return "\(header)\nStatus: \(status)\nContent Type: \(contentType)\nText:\n\(text)\n"
        }.joined(separator: "\n")
        
        try textContent.write(to: url, atomically: true, encoding: .utf8)
    }
}

// MARK: - Models

struct BatchResult {
    let index: Int
    let success: Bool
    let error: Error?
    let extractedText: String?
    let contentType: ContentType?
}

enum BatchExportFormat: String, CaseIterable {
    case csv = "csv"
    case json = "json"
    case txt = "txt"
    
    var displayName: String {
        switch self {
        case .csv: return "CSV Spreadsheet"
        case .json: return "JSON Data"
        case .txt: return "Plain Text"
        }
    }
    
    var fileExtension: String {
        return rawValue
    }
}

enum BatchProcessingError: LocalizedError {
    case invalidImage
    case processingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid or corrupted image"
        case .processingFailed:
            return "Failed to process image"
        }
    }
}