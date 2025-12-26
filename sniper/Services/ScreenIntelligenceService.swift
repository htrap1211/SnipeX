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
        print("ScreenIntelligenceService: Starting processing for region: \(region.rect)")
        isCapturing = true
        
        do {
            print("ScreenIntelligenceService: Starting screen capture for region: \(region.rect)")
            
            // 1. Capture screenshot
            let screenshot = try await captureScreenshot(region)
            print("ScreenIntelligenceService: Screenshot captured successfully, size: \(screenshot.width)x\(screenshot.height)")
            
            // 2. Preprocess image for better OCR
            let preprocessedImage = imagePreprocessor.preprocessForOCR(screenshot) ?? screenshot
            print("ScreenIntelligenceService: Image preprocessing completed")
            
            // 3. Perform OCR
            var ocrResult = try await ocrEngine.recognize(image: preprocessedImage)
            print("ScreenIntelligenceService: OCR completed with text: \(ocrResult.rawText.prefix(50))...")
            
            // 4. Classify content type
            let contentType = contentClassifier.classifyContent(text: ocrResult.rawText, image: preprocessedImage)
            ocrResult = OCRResult(
                rawText: ocrResult.rawText,
                boundingBoxes: ocrResult.boundingBoxes,
                confidence: ocrResult.confidence,
                contentType: contentType
            )
            print("ScreenIntelligenceService: Content classified as: \(contentType)")
            
            // 5. Generate structured output
            let structuredOutput = outputGenerator.generateOutput(from: ocrResult, contentType: contentType)
            print("ScreenIntelligenceService: Structured output generated")
            
            // 6. Copy to clipboard
            copyToClipboard(structuredOutput.processedText)
            print("ScreenIntelligenceService: Text copied to clipboard")
            
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
            print("ScreenIntelligenceService: Added to history")
            
            // 8. Show success notification
            NotificationManager.shared.showCaptureSuccess(
                contentType: contentType,
                textLength: structuredOutput.processedText.count
            )
            print("ScreenIntelligenceService: Capture completed successfully")
            
        } catch {
            print("ScreenIntelligenceService: Error processing screen region: \(error)")
            
            // Show more specific error messages
            let errorMessage: String
            if let captureError = error as? CaptureError {
                errorMessage = captureError.localizedDescription
                print("ScreenIntelligenceService: CaptureError: \(captureError)")
            } else {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                print("ScreenIntelligenceService: Unexpected error: \(error)")
            }
            
            // Show error notification
            NotificationManager.shared.showCaptureError(error)
            
            // Also show an alert for critical errors
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Screen Capture Failed"
                alert.informativeText = errorMessage
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                
                if errorMessage.contains("permission") {
                    alert.addButton(withTitle: "Open System Preferences")
                }
                
                let response = alert.runModal()
                if response == .alertSecondButtonReturn {
                    // Open System Preferences to Screen Recording
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
        
        isCapturing = false
        print("ScreenIntelligenceService: Processing completed, isCapturing set to false")
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
}