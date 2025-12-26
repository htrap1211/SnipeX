//
//  TestConfiguration.swift
//  sniperTests
//
//  Test configuration and utilities
//

import Foundation
import CoreGraphics
import AppKit

struct TestConfiguration {
    
    // MARK: - Test Data
    
    static let sampleTexts = [
        "The quick brown fox jumps over the lazy dog.",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "1234567890 !@#$%^&*()_+-=[]{}|;':\",./<>?",
        "Hello World! This is a test of OCR accuracy.",
        "Testing various font sizes and styles."
    ]
    
    static let sampleTables = [
        """
        Name | Age | City
        John | 25 | NYC
        Jane | 30 | LA
        Bob | 35 | SF
        """,
        """
        Product,Price,Stock
        Apple,1.50,100
        Banana,0.75,200
        Orange,2.00,50
        """,
        """
        ID\tName\tScore
        1\tAlice\t95
        2\tBob\t87
        3\tCharlie\t92
        """
    ]
    
    static let sampleCode = [
        """
        func hello() {
            print("Hello, World!")
        }
        """,
        """
        function calculateSum(a, b) {
            return a + b;
        }
        """,
        """
        def process_data(items):
            return [item.upper() for item in items]
        """,
        """
        public class Calculator {
            public int add(int a, int b) {
                return a + b;
            }
        }
        """
    ]
    
    static let sampleMath = [
        "∫₀¹ x² dx = 1/3",
        "f(x) = ax² + bx + c",
        "lim(x→∞) 1/x = 0",
        "∑ᵢ₌₁ⁿ i = n(n+1)/2",
        "α + β = γ, where α, β ∈ ℝ",
        "√(a² + b²) = c",
        "∂f/∂x = 2x + y"
    ]
    
    // MARK: - Test Image Generation
    
    static func createTestImage(
        width: Int,
        height: Int,
        text: String,
        fontSize: CGFloat = 16,
        fontName: String = "Helvetica",
        backgroundColor: NSColor = .white,
        textColor: NSColor = .black
    ) -> CGImage {
        
        let size = CGSize(width: width, height: height)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Fill background
        backgroundColor.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        // Draw text
        let font = NSFont(name: fontName, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        
        // Center the text
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        attributedString.draw(in: textRect)
        image.unlockFocus()
        
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fatalError("Could not create test image")
        }
        
        return cgImage
    }
    
    static func createMultiLineTestImage(
        width: Int,
        height: Int,
        lines: [String],
        fontSize: CGFloat = 14,
        lineSpacing: CGFloat = 20
    ) -> CGImage {
        
        let size = CGSize(width: width, height: height)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // White background
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        // Draw each line
        let font = NSFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.black
        ]
        
        var yPosition = size.height - 30 // Start from top with margin
        
        for line in lines {
            let attributedString = NSAttributedString(string: line, attributes: attributes)
            let textRect = CGRect(
                x: 20, // Left margin
                y: yPosition,
                width: size.width - 40, // Account for margins
                height: lineSpacing
            )
            
            attributedString.draw(in: textRect)
            yPosition -= lineSpacing
            
            if yPosition < 20 { break } // Stop if we run out of space
        }
        
        image.unlockFocus()
        
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fatalError("Could not create multi-line test image")
        }
        
        return cgImage
    }
    
    // MARK: - Test Validation Helpers
    
    static func validateCSVFormat(_ csv: String) -> Bool {
        let lines = csv.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count > 1 else { return false }
        
        let headerColumns = lines[0].components(separatedBy: ",").count
        
        // Check that all rows have the same number of columns
        for line in lines.dropFirst() {
            let columns = line.components(separatedBy: ",").count
            if columns != headerColumns {
                return false
            }
        }
        
        return true
    }
    
    static func validateMarkdownCodeBlock(_ markdown: String) -> Bool {
        return markdown.hasPrefix("```") && markdown.hasSuffix("```") && markdown.components(separatedBy: "```").count >= 3
    }
    
    static func validateLaTeXMath(_ latex: String) -> Bool {
        // Check if it contains LaTeX commands or is wrapped in math environment
        return latex.contains("\\") || (latex.hasPrefix("$") && latex.hasSuffix("$"))
    }
    
    // MARK: - Performance Benchmarks
    
    static let performanceBenchmarks = [
        "smallText": (width: 200, height: 50, expectedTime: 1.0),
        "mediumText": (width: 800, height: 200, expectedTime: 2.0),
        "largeText": (width: 1600, height: 600, expectedTime: 5.0)
    ]
    
    // MARK: - Test Assertions
    
    static func assertSimilarText(_ actual: String, _ expected: String, accuracy: Double = 0.8, file: StaticString = #file, line: UInt = #line) {
        let similarity = calculateStringSimilarity(actual, expected)
        if similarity < accuracy {
            XCTFail("Text similarity \(similarity) is below threshold \(accuracy). Expected: '\(expected)', Actual: '\(actual)'", file: file, line: line)
        }
    }
    
    private static func calculateStringSimilarity(_ str1: String, _ str2: String) -> Double {
        let longer = str1.count > str2.count ? str1 : str2
        let shorter = str1.count > str2.count ? str2 : str1
        
        if longer.isEmpty { return 1.0 }
        
        let editDistance = levenshteinDistance(str1, str2)
        return (Double(longer.count) - Double(editDistance)) / Double(longer.count)
    }
    
    private static func levenshteinDistance(_ str1: String, _ str2: String) -> Int {
        let str1Array = Array(str1)
        let str2Array = Array(str2)
        let str1Count = str1Array.count
        let str2Count = str2Array.count
        
        var matrix = Array(repeating: Array(repeating: 0, count: str2Count + 1), count: str1Count + 1)
        
        for i in 0...str1Count {
            matrix[i][0] = i
        }
        
        for j in 0...str2Count {
            matrix[0][j] = j
        }
        
        for i in 1...str1Count {
            for j in 1...str2Count {
                let cost = str1Array[i-1] == str2Array[j-1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i-1][j] + 1,      // deletion
                    matrix[i][j-1] + 1,      // insertion
                    matrix[i-1][j-1] + cost  // substitution
                )
            }
        }
        
        return matrix[str1Count][str2Count]
    }
}

// MARK: - XCTest Extensions

import XCTest

extension XCTestCase {
    
    func measureAsync<T>(_ block: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        print("⏱️ Async operation completed in \(String(format: "%.3f", timeElapsed))s")
        return result
    }
    
    func assertProcessingTime<T>(_ maxTime: TimeInterval, _ block: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertLessThan(timeElapsed, maxTime, "Processing took \(timeElapsed)s, expected < \(maxTime)s")
        return result
    }
}