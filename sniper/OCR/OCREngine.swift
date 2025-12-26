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
            
            // Configure for accuracy
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US"] // Can be made configurable
            
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
}