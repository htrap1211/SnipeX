//
//  OCREngine.swift
//  sniper
//
//  OCR Engine abstraction layer
//

import Foundation
import CoreGraphics
import Vision
import AppKit

// MARK: - OCR Engine Protocol
protocol OCREngine {
    func recognize(image: CGImage) async throws -> OCRResult
}

// MARK: - Apple Vision OCR Engine
class VisionOCREngine: OCREngine {
    private let supportedLanguages: [String]
    
    init(languages: [String] = ["en-US"]) {
        self.supportedLanguages = languages
    }
    
    func recognize(image: CGImage) async throws -> OCRResult {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: OCRResult(rawText: ""))
                    return
                }
                
                var fullText = ""
                var boundingBoxes: [CGRect] = []
                var totalConfidence: Float = 0.0
                
                for observation in observations {
                    guard let topCandidate = observation.topCandidates(1).first else { continue }
                    
                    fullText += topCandidate.string + "\n"
                    boundingBoxes.append(observation.boundingBox)
                    totalConfidence += topCandidate.confidence
                }
                
                let averageConfidence = observations.isEmpty ? 0.0 : totalConfidence / Float(observations.count)
                let result = OCRResult(
                    rawText: fullText.trimmingCharacters(in: .whitespacesAndNewlines),
                    boundingBoxes: boundingBoxes,
                    confidence: averageConfidence
                )
                
                continuation.resume(returning: result)
            }
            
            // Configure for accuracy and multi-language support
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = supportedLanguages
            
            // Enable automatic language detection if multiple languages are supported
            if supportedLanguages.count > 1 {
                request.automaticallyDetectsLanguage = true
            }
            
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - OCR Engine Factory
class OCREngineFactory {
    static func createDefault() -> OCREngine {
        return VisionOCREngine()
    }
    
    static func create(with languages: [String]) -> OCREngine {
        return VisionOCREngine(languages: languages)
    }
    
    // Supported language configurations
    static let supportedLanguages: [String: [String]] = [
        "en-US": ["en-US"],
        "en-GB": ["en-GB"],
        "es": ["es-ES"],
        "fr": ["fr-FR"],
        "de": ["de-DE"],
        "zh-Hans": ["zh-Hans"],
        "zh-Hant": ["zh-Hant"],
        "ja": ["ja-JP"],
        "ko": ["ko-KR"],
        "it": ["it-IT"],
        "pt": ["pt-BR"],
        "ru": ["ru-RU"],
        "ar": ["ar-SA"],
        "hi": ["hi-IN"],
        "auto": ["en-US", "es-ES", "fr-FR", "de-DE", "zh-Hans", "ja-JP"] // Auto-detect common languages
    ]
    
    static func languageDisplayName(for code: String) -> String {
        switch code {
        case "en-US": return "English (US)"
        case "en-GB": return "English (UK)"
        case "es": return "Spanish"
        case "fr": return "French"
        case "de": return "German"
        case "zh-Hans": return "Chinese (Simplified)"
        case "zh-Hant": return "Chinese (Traditional)"
        case "ja": return "Japanese"
        case "ko": return "Korean"
        case "it": return "Italian"
        case "pt": return "Portuguese"
        case "ru": return "Russian"
        case "ar": return "Arabic"
        case "hi": return "Hindi"
        case "auto": return "Auto-detect"
        default: return code
        }
    }
}