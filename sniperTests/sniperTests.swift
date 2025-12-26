//
//  sniperTests.swift
//  sniperTests
//
//  Automated tests for Screen Intelligence
//

import XCTest
import CoreGraphics
import AppKit
@testable import sniper

final class sniperTests: XCTestCase {
    
    var contentClassifier: ContentClassifier!
    var outputGenerator: StructuredOutputGenerator!
    var imagePreprocessor: ImagePreprocessor!
    var ocrEngine: VisionOCREngine!
    
    override func setUpWithError() throws {
        contentClassifier = ContentClassifier()
        outputGenerator = StructuredOutputGenerator()
        imagePreprocessor = ImagePreprocessor()
        ocrEngine = VisionOCREngine()
    }
    
    override func tearDownWithError() throws {
        contentClassifier = nil
        outputGenerator = nil
        imagePreprocessor = nil
        ocrEngine = nil
    }
    
    // MARK: - Content Classification Tests
    
    func testPlainTextClassification() throws {
        let plainText = "The quick brown fox jumps over the lazy dog. This is a simple paragraph of text."
        let result = contentClassifier.classifyContent(text: plainText)
        XCTAssertEqual(result, .plainText, "Plain text should be classified as plainText")
    }
    
    func testTableClassification() throws {
        let tableText = """
        Name        | Age | City
        ------------|-----|----------
        John Smith  | 25  | New York
        Jane Doe    | 30  | Boston
        Bob Johnson | 35  | Chicago
        """
        let result = contentClassifier.classifyContent(text: tableText)
        XCTAssertEqual(result, .table, "Table structure should be classified as table")
    }
    
    func testCSVTableClassification() throws {
        let csvText = """
        Name,Age,City
        John Smith,25,New York
        Jane Doe,30,Boston
        Bob Johnson,35,Chicago
        """
        let result = contentClassifier.classifyContent(text: csvText)
        XCTAssertEqual(result, .table, "CSV structure should be classified as table")
    }
    
    func testCodeClassification() throws {
        let codeText = """
        func processData() -> String {
            let result = "Hello World"
            return result
        }
        """
        let result = contentClassifier.classifyContent(text: codeText)
        XCTAssertEqual(result, .code, "Swift code should be classified as code")
    }
    
    func testJavaScriptCodeClassification() throws {
        let jsCode = """
        function processData() {
            const result = "Hello World";
            return result;
        }
        """
        let result = contentClassifier.classifyContent(text: jsCode)
        XCTAssertEqual(result, .code, "JavaScript code should be classified as code")
    }
    
    func testMathClassification() throws {
        let mathText = """
        ∫₀¹ x² dx = 1/3
        f(x) = ax² + bx + c
        lim(x→∞) 1/x = 0
        """
        let result = contentClassifier.classifyContent(text: mathText)
        XCTAssertEqual(result, .math, "Mathematical expressions should be classified as math")
    }
    
    func testMathSymbolsClassification() throws {
        let mathSymbols = "α + β = γ, ∑ᵢ₌₁ⁿ xᵢ, √(a² + b²)"
        let result = contentClassifier.classifyContent(text: mathSymbols)
        XCTAssertEqual(result, .math, "Math symbols should be classified as math")
    }
    
    // MARK: - Structured Output Generation Tests
    
    func testPlainTextOutput() throws {
        let ocrResult = OCRResult(rawText: "Hello\nWorld\nTest", contentType: .plainText)
        let output = outputGenerator.generateOutput(from: ocrResult, contentType: .plainText)
        
        XCTAssertEqual(output.format, .plainText)
        XCTAssertEqual(output.contentType, .plainText)
        XCTAssertFalse(output.processedText.isEmpty)
    }
    
    func testTableToCSVOutput() throws {
        let tableText = """
        Name | Age | City
        John | 25 | NYC
        Jane | 30 | LA
        """
        let ocrResult = OCRResult(rawText: tableText, contentType: .table)
        let output = outputGenerator.generateOutput(from: ocrResult, contentType: .table)
        
        XCTAssertEqual(output.format, .csv)
        XCTAssertEqual(output.contentType, .table)
        XCTAssertTrue(output.processedText.contains(","), "CSV should contain commas")
        XCTAssertTrue(output.processedText.contains("Name,Age,City"), "CSV should have proper headers")
    }
    
    func testCodeToMarkdownOutput() throws {
        let codeText = """
        function test() {
            return "hello";
        }
        """
        let ocrResult = OCRResult(rawText: codeText, contentType: .code)
        let output = outputGenerator.generateOutput(from: ocrResult, contentType: .code)
        
        XCTAssertEqual(output.format, .markdown)
        XCTAssertEqual(output.contentType, .code)
        XCTAssertTrue(output.processedText.contains("```"), "Code should be wrapped in markdown code blocks")
    }
    
    func testMathToLaTeXOutput() throws {
        let mathText = "∫ x² dx = x³/3 + C"
        let ocrResult = OCRResult(rawText: mathText, contentType: .math)
        let output = outputGenerator.generateOutput(from: ocrResult, contentType: .math)
        
        XCTAssertEqual(output.format, .latex)
        XCTAssertEqual(output.contentType, .math)
        XCTAssertTrue(output.processedText.contains("\\int"), "Integral symbol should be converted to LaTeX")
    }
    
    // MARK: - Image Processing Tests
    
    func testImagePreprocessing() throws {
        let testImage = createTestImage(width: 100, height: 50, text: "TEST")
        let processedImage = imagePreprocessor.preprocessForOCR(testImage)
        
        XCTAssertNotNil(processedImage, "Image preprocessing should return a valid image")
        XCTAssertEqual(processedImage?.width, testImage.width, "Processed image should maintain width")
        XCTAssertEqual(processedImage?.height, testImage.height, "Processed image should maintain height")
    }
    
    // MARK: - OCR Engine Tests
    
    func testOCRWithSimpleText() async throws {
        let testImage = createTestImage(width: 200, height: 50, text: "HELLO WORLD")
        let result = try await ocrEngine.recognize(image: testImage)
        
        XCTAssertFalse(result.rawText.isEmpty, "OCR should extract some text")
        XCTAssertGreaterThan(result.confidence, 0.0, "OCR should have some confidence")
    }
    
    func testOCRWithNumbers() async throws {
        let testImage = createTestImage(width: 200, height: 50, text: "1234567890")
        let result = try await ocrEngine.recognize(image: testImage)
        
        XCTAssertFalse(result.rawText.isEmpty, "OCR should extract numbers")
        // Note: OCR might not be 100% accurate with programmatically generated images
    }
    
    // MARK: - Integration Tests
    
    func testFullPipelineWithTable() async throws {
        let tableImage = createTableImage()
        
        // Test OCR
        let ocrResult = try await ocrEngine.recognize(image: tableImage)
        
        // Test Classification
        let contentType = contentClassifier.classifyContent(text: ocrResult.rawText)
        
        // Test Output Generation
        let output = outputGenerator.generateOutput(
            from: OCRResult(rawText: ocrResult.rawText, contentType: contentType),
            contentType: contentType
        )
        
        XCTAssertFalse(output.processedText.isEmpty, "Full pipeline should produce output")
    }
    
    func testFullPipelineWithCode() async throws {
        let codeImage = createCodeImage()
        
        let ocrResult = try await ocrEngine.recognize(image: codeImage)
        let contentType = contentClassifier.classifyContent(text: ocrResult.rawText)
        let output = outputGenerator.generateOutput(
            from: OCRResult(rawText: ocrResult.rawText, contentType: contentType),
            contentType: contentType
        )
        
        XCTAssertFalse(output.processedText.isEmpty, "Code pipeline should produce output")
    }
    
    // MARK: - Performance Tests
    
    func testOCRPerformance() async throws {
        let testImage = createTestImage(width: 800, height: 600, text: "Performance Test Text")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let _ = try await ocrEngine.recognize(image: testImage)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertLessThan(timeElapsed, 5.0, "OCR should complete within 5 seconds")
    }
    
    func testClassificationPerformance() throws {
        let longText = String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 100)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let _ = contentClassifier.classifyContent(text: longText)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertLessThan(timeElapsed, 0.1, "Classification should be very fast")
    }
    
    // MARK: - Edge Cases
    
    func testEmptyTextClassification() throws {
        let result = contentClassifier.classifyContent(text: "")
        XCTAssertEqual(result, .plainText, "Empty text should default to plainText")
    }
    
    func testVeryShortTextClassification() throws {
        let result = contentClassifier.classifyContent(text: "Hi")
        XCTAssertEqual(result, .plainText, "Very short text should be plainText")
    }
    
    func testMixedContentClassification() throws {
        let mixedText = """
        Here's some code:
        function test() { return 42; }
        And a table:
        A | B
        1 | 2
        """
        let result = contentClassifier.classifyContent(text: mixedText)
        // Should classify based on the most prominent content type
        XCTAssertTrue([.code, .table, .plainText].contains(result), "Mixed content should classify to one type")
    }
}

// MARK: - Test Helper Methods

extension sniperTests {
    
    func createTestImage(width: Int, height: Int, text: String) -> CGImage {
        let size = CGSize(width: width, height: height)
        let renderer = NSGraphicsContext.current
        
        let image = NSImage(size: size)
        image.lockFocus()
        
        // White background
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        // Black text
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 16),
            .foregroundColor: NSColor.black
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        attributedString.draw(in: textRect)
        image.unlockFocus()
        
        // Convert to CGImage
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            fatalError("Could not create test image")
        }
        
        return cgImage
    }
    
    func createTableImage() -> CGImage {
        let tableText = """
        Name     Age  City
        John     25   NYC
        Jane     30   LA
        Bob      35   SF
        """
        return createTestImage(width: 300, height: 120, text: tableText)
    }
    
    func createCodeImage() -> CGImage {
        let codeText = """
        func hello() {
            print("world")
        }
        """
        return createTestImage(width: 250, height: 80, text: codeText)
    }
}