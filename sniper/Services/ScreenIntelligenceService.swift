//
//  ScreenIntelligenceService.swift
//  sniper
//
//  Main service orchestrating the OCR pipeline
//

import Foundation
import CoreGraphics
import AppKit
import Combine

@MainActor
class ScreenIntelligenceService: ObservableObject {
    @Published var isCapturing = false
    @Published var lastResult: StructuredOutput?
    @Published var captureHistory: [CaptureHistoryItem] = []
    
    private var ocrEngine: OCREngine
    private let imagePreprocessor: ImagePreprocessor
    private let contentClassifier: ContentClassifier
    private let outputGenerator: StructuredOutputGenerator
    private let screenshotCapture: ScreenshotCapture
    
    // Public access for batch processing
    var batchOCREngine: OCREngine { ocrEngine }
    var batchImagePreprocessor: ImagePreprocessor { imagePreprocessor }
    var batchContentClassifier: ContentClassifier { contentClassifier }
    
    // Language setting observer
    private var languageObserver: AnyCancellable?
    
    init() {
        self.ocrEngine = OCREngineFactory.createDefault()
        self.imagePreprocessor = ImagePreprocessor()
        self.contentClassifier = ContentClassifier()
        self.outputGenerator = StructuredOutputGenerator()
        self.screenshotCapture = ScreenshotCapture()
        
        // Observe language changes
        setupLanguageObserver()
    }
    
    private func setupLanguageObserver() {
        languageObserver = UserDefaults.standard.publisher(for: \.ocrLanguage)
            .sink { [weak self] newLanguage in
                self?.updateOCRLanguage(newLanguage)
            }
    }
    
    private func updateOCRLanguage(_ languageCode: String) {
        if let languages = OCREngineFactory.supportedLanguages[languageCode] {
            ocrEngine = OCREngineFactory.create(with: languages)
        }
    }
    
    func processScreenRegion(_ region: CaptureRegion) async {
        isCapturing = true
        
        do {
            // 1. Capture screenshot
            let screenshot = try await captureScreenshot(region)
            
            // 2. Preprocess image for better OCR
            let preprocessedImage = imagePreprocessor.preprocessForOCR(screenshot) ?? screenshot
            
            // 3. Perform OCR
            var ocrResult = try await ocrEngine.recognize(image: preprocessedImage)
            
            // 4. Classify content type
            let contentType = contentClassifier.classifyContent(text: ocrResult.rawText, image: preprocessedImage)
            ocrResult = OCRResult(
                rawText: ocrResult.rawText,
                boundingBoxes: ocrResult.boundingBoxes,
                confidence: ocrResult.confidence,
                contentType: contentType
            )
            
            // 5. Generate structured output
            let structuredOutput = outputGenerator.generateOutput(from: ocrResult, contentType: contentType)
            
            // 6. Copy to clipboard
            copyToClipboard(structuredOutput.processedText)
            
            // 7. Create thumbnail and add to history
            let thumbnailData = createThumbnail(from: screenshot)
            let historyItem = CaptureHistoryItem(
                extractedText: structuredOutput.processedText,
                contentType: contentType,
                thumbnailData: thumbnailData,
                appName: getFrontmostAppName(),
                region: region.rect
            )
            
            captureHistory.insert(historyItem, at: 0)
            lastResult = structuredOutput
            
            // 8. Show success notification
            NotificationManager.shared.showCaptureSuccess(
                contentType: contentType,
                textLength: structuredOutput.processedText.count
            )
            
        } catch {
            print("Error processing screen region: \(error)")
            NotificationManager.shared.showCaptureError(error)
        }
        
        isCapturing = false
    }
    
    // MARK: - Private Methods
    
    private func captureScreenshot(_ region: CaptureRegion) async throws -> CGImage {
        return try await screenshotCapture.captureRegion(region)
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    private func createThumbnail(from image: CGImage) -> Data? {
        let maxSize: CGFloat = 200
        let originalSize = CGSize(width: image.width, height: image.height)
        
        let scale = min(maxSize / originalSize.width, maxSize / originalSize.height)
        let thumbnailSize = CGSize(
            width: originalSize.width * scale,
            height: originalSize.height * scale
        )
        
        guard let context = CGContext(
            data: nil,
            width: Int(thumbnailSize.width),
            height: Int(thumbnailSize.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        context.draw(image, in: CGRect(origin: .zero, size: thumbnailSize))
        
        guard let thumbnailImage = context.makeImage() else { return nil }
        
        let nsImage = NSImage(cgImage: thumbnailImage, size: thumbnailSize)
        return nsImage.tiffRepresentation
    }
    
    private func getFrontmostAppName() -> String? {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else { return nil }
        return frontmostApp.localizedName
    }
    
    private func showNotification(for output: StructuredOutput) {
        let notification = NSUserNotification()
        notification.title = "Text Extracted"
        notification.informativeText = "Captured \(output.contentType.displayName.lowercased()) • \(output.processedText.prefix(50))..."
        notification.soundName = nil // Silent notification
        
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private func showErrorNotification(_ error: Error) {
        let notification = NSUserNotification()
        notification.title = "Capture Failed"
        notification.informativeText = error.localizedDescription
        notification.soundName = NSUserNotificationDefaultSoundName
        
        NSUserNotificationCenter.default.deliver(notification)
    }
}