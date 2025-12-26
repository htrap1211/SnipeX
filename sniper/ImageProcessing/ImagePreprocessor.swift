//
//  ImagePreprocessor.swift
//  sniper
//
//  High-performance image preprocessing for enhanced OCR accuracy
//

import Foundation
import CoreImage
import CoreGraphics
import AppKit
import Accelerate

class ImagePreprocessor {
    private let context: CIContext
    private let processingQueue = DispatchQueue(label: "image.processing", qos: .userInitiated)
    
    // Cache for frequently used filters
    private var filterCache: [String: CIFilter] = [:]
    
    init() {
        // Use GPU acceleration when available, fallback to CPU
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            context = CIContext(mtlDevice: metalDevice)
        } else {
            context = CIContext(options: [.useSoftwareRenderer: false])
        }
    }
    
    func preprocessForOCR(_ image: CGImage) -> CGImage? {
        // Quick size check - if image is too large, resize first for performance
        let maxDimension: CGFloat = 2048
        let resizedImage = resizeIfNeeded(image, maxDimension: maxDimension)
        
        let ciImage = CIImage(cgImage: resizedImage)
        
        // Apply optimized preprocessing pipeline
        let processed = ciImage
            |> convertToGrayscale
            |> enhanceContrast
            |> sharpenImage
            |> reduceNoise
        
        // Use smaller extent for memory efficiency
        let outputExtent = processed.extent
        return context.createCGImage(processed, from: outputExtent)
    }
    
    // MARK: - Performance Optimizations
    
    private func resizeIfNeeded(_ image: CGImage, maxDimension: CGFloat) -> CGImage {
        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        
        // Only resize if image is larger than max dimension
        guard max(width, height) > maxDimension else { return image }
        
        let scale = maxDimension / max(width, height)
        let newWidth = Int(width * scale)
        let newHeight = Int(height * scale)
        
        guard let context = CGContext(
            data: nil,
            width: newWidth,
            height: newHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return image }
        
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        return context.makeImage() ?? image
    }
    
    // MARK: - Processing Steps with Caching
    
    private func convertToGrayscale(_ image: CIImage) -> CIImage {
        let filter = getCachedFilter("CIColorControls", key: "grayscale") { filter in
            filter.setValue(0.0, forKey: kCIInputSaturationKey)
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        return filter.outputImage ?? image
    }
    
    private func enhanceContrast(_ image: CIImage) -> CIImage {
        let filter = getCachedFilter("CIColorControls", key: "contrast") { filter in
            filter.setValue(1.3, forKey: kCIInputContrastKey)
            filter.setValue(0.1, forKey: kCIInputBrightnessKey)
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        return filter.outputImage ?? image
    }
    
    private func sharpenImage(_ image: CIImage) -> CIImage {
        let filter = getCachedFilter("CISharpenLuminance", key: "sharpen") { filter in
            filter.setValue(0.4, forKey: kCIInputSharpnessKey)
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        return filter.outputImage ?? image
    }
    
    private func reduceNoise(_ image: CIImage) -> CIImage {
        // Use a simple blur for noise reduction to avoid parameter issues
        let filter = getCachedFilter("CIGaussianBlur", key: "noise") { filter in
            filter.setValue(0.5, forKey: kCIInputRadiusKey)
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        return filter.outputImage ?? image
    }
    
    // MARK: - Filter Caching
    
    private func getCachedFilter(_ filterName: String, key: String, configure: (CIFilter) -> Void) -> CIFilter {
        let cacheKey = "\(filterName)_\(key)"
        
        if let cachedFilter = filterCache[cacheKey] {
            return cachedFilter
        }
        
        guard let filter = CIFilter(name: filterName) else {
            // Return identity filter if creation fails
            return CIFilter()
        }
        
        configure(filter)
        filterCache[cacheKey] = filter
        return filter
    }
    
    // MARK: - Memory Management
    
    func clearCache() {
        filterCache.removeAll()
    }
    
    deinit {
        clearCache()
    }
}

// MARK: - Functional Pipeline Operator
infix operator |>: AdditionPrecedence

func |><T, U>(value: T, function: (T) -> U) -> U {
    return function(value)
}