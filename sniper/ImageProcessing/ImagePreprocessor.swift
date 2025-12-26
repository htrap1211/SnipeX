//
//  ImagePreprocessor.swift
//  sniper
//
//  Image preprocessing for enhanced OCR accuracy
//

import Foundation
import CoreImage
import CoreGraphics
import AppKit

class ImagePreprocessor {
    private let context = CIContext()
    
    func preprocessForOCR(_ image: CGImage) -> CGImage? {
        let ciImage = CIImage(cgImage: image)
        
        // Apply preprocessing pipeline - simplified to avoid parameter issues
        let processed = ciImage
            |> convertToGrayscale
            |> enhanceContrast
            |> sharpenImage
        
        return context.createCGImage(processed, from: processed.extent)
    }
    
    // MARK: - Processing Steps
    
    private func convertToGrayscale(_ image: CIImage) -> CIImage {
        guard let filter = CIFilter(name: "CIColorControls") else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey) // Remove color
        return filter.outputImage ?? image
    }
    
    private func enhanceContrast(_ image: CIImage) -> CIImage {
        guard let filter = CIFilter(name: "CIColorControls") else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(1.3, forKey: kCIInputContrastKey) // Increase contrast
        filter.setValue(0.1, forKey: kCIInputBrightnessKey) // Slight brightness boost
        return filter.outputImage ?? image
    }
    
    private func sharpenImage(_ image: CIImage) -> CIImage {
        guard let filter = CIFilter(name: "CISharpenLuminance") else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(0.4, forKey: kCIInputSharpnessKey)
        return filter.outputImage ?? image
    }
    
    // Removed the problematic noise reduction filter for now
    // Can be re-added later with correct parameters if needed
}

// MARK: - Functional Pipeline Operator
infix operator |>: AdditionPrecedence

func |><T, U>(value: T, function: (T) -> U) -> U {
    return function(value)
}