//
//  StructuredOutputTests.swift
//  sniperTests
//
//  Tests for structured output generation
//

import XCTest
@testable import sniper

final class StructuredOutputTests: XCTestCase {
    
    var generator: StructuredOutputGenerator!
    
    override func setUpWithError() throws {
        generator = StructuredOutputGenerator()
    }
    
    override func tearDownWithError() throws {
        generator = nil
    }
    
    // MARK: - Plain Text Output Tests
    
    func testPlainTextCleaning() throws {
        let messyText = """
        This is a para-
        graph with hyphen-
        ation breaks.
        
        
        And multiple blank lines.
        """
        
        let ocrResult = OCRResult(rawText: messyText, contentType: .plainText)
        let output = generator.generateOutput(from: ocrResult, contentType: .plainText)
        
        XCTAssertEqual(output.format, .plainText)
        XCTAssertFalse(output.processedText.contains("-\n"), "Hyphenation should be removed")
        XCTAssertFalse(output.processedText.contains("\n\n\n"), "Multiple blank lines should be normalized")
    }
    
    func testPlainTextPreservesStructure() throws {
        let structuredText = """
        Title
        
        First paragraph with some content.
        
        Second paragraph with more content.
        """
        
        let ocrResult = OCRResult(rawText: structuredText, contentType: .plainText)
        let output = generator.generateOutput(from: ocrResult, contentType: .plainText)
        
        XCTAssertTrue(output.processedText.contains("Title"), "Should preserve title")
        XCTAssertTrue(output.processedText.contains("First paragraph"), "Should preserve paragraphs")
        XCTAssertTrue(output.processedText.contains("Second paragraph"), "Should preserve paragraphs")
    }
    
    // MARK: - Table to CSV Tests
    
    func testPipeDelimitedTableToCSV() throws {
        let tableText = """
        Name | Age | City
        John | 25 | New York
        Jane | 30 | Boston
        """
        
        let ocrResult = OCRResult(rawText: tableText, contentType: .table)
        let output = generator.generateOutput(from: ocrResult, contentType: .table)
        
        XCTAssertEqual(output.format, .csv)
        
        let lines = output.processedText.components(separatedBy: .newlines)
        XCTAssertEqual(lines[0], "Name,Age,City", "Header should be converted to CSV")
        XCTAssertEqual(lines[1], "John,25,New York", "Data should be converted to CSV")
        XCTAssertEqual(lines[2], "Jane,30,Boston", "Data should be converted to CSV")
    }
    
    func testTabDelimitedTableToCSV() throws {
        let tableText = "Name\tAge\tCity\nJohn\t25\tNYC\nJane\t30\tLA"
        
        let ocrResult = OCRResult(rawText: tableText, contentType: .table)
        let output = generator.generateOutput(from: ocrResult, contentType: .table)
        
        XCTAssertEqual(output.format, .csv)
        XCTAssertTrue(output.processedText.contains("Name,Age,City"))
        XCTAssertTrue(output.processedText.contains("John,25,NYC"))
    }
    
    func testCSVWithCommasInData() throws {
        let tableText = """
        Name | Company | City
        John Smith | Acme, Inc | New York, NY
        Jane Doe | Tech Corp | Boston, MA
        """
        
        let ocrResult = OCRResult(rawText: tableText, contentType: .table)
        let output = generator.generateOutput(from: ocrResult, contentType: .table)
        
        // Should escape values containing commas
        XCTAssertTrue(output.processedText.contains("\"Acme, Inc\""), "Should escape comma-containing values")
        XCTAssertTrue(output.processedText.contains("\"New York, NY\""), "Should escape comma-containing values")
    }
    
    func testCSVWithQuotesInData() throws {
        let tableText = """
        Name | Quote
        John | He said "Hello"
        Jane | She said "World"
        """
        
        let ocrResult = OCRResult(rawText: tableText, contentType: .table)
        let output = generator.generateOutput(from: ocrResult, contentType: .table)
        
        // Should escape quotes by doubling them
        XCTAssertTrue(output.processedText.contains("\"He said \"\"Hello\"\"\""), "Should escape quotes properly")
    }
    
    func testSpaceDelimitedTableToCSV() throws {
        let tableText = """
        Name     Age  City
        John     25   NYC
        Jane     30   LA
        """
        
        let ocrResult = OCRResult(rawText: tableText, contentType: .table)
        let output = generator.generateOutput(from: ocrResult, contentType: .table)
        
        XCTAssertEqual(output.format, .csv)
        XCTAssertTrue(output.processedText.contains("Name,Age,City"))
        XCTAssertTrue(output.processedText.contains("John,25,NYC"))
    }
    
    // MARK: - Code to Markdown Tests
    
    func testSwiftCodeToMarkdown() throws {
        let codeText = """
        func hello() {
            print("world")
        }
        """
        
        let ocrResult = OCRResult(rawText: codeText, contentType: .code)
        let output = generator.generateOutput(from: ocrResult, contentType: .code)
        
        XCTAssertEqual(output.format, .markdown)
        XCTAssertTrue(output.processedText.hasPrefix("```swift"), "Should detect Swift language")
        XCTAssertTrue(output.processedText.hasSuffix("```"), "Should end with code block")
        XCTAssertTrue(output.processedText.contains(codeText), "Should contain original code")
    }
    
    func testJavaScriptCodeToMarkdown() throws {
        let codeText = """
        function hello() {
            console.log("world");
        }
        """
        
        let ocrResult = OCRResult(rawText: codeText, contentType: .code)
        let output = generator.generateOutput(from: ocrResult, contentType: .code)
        
        XCTAssertEqual(output.format, .markdown)
        XCTAssertTrue(output.processedText.hasPrefix("```javascript"), "Should detect JavaScript language")
        XCTAssertTrue(output.processedText.contains(codeText), "Should contain original code")
    }
    
    func testPythonCodeToMarkdown() throws {
        let codeText = """
        def hello():
            print("world")
        """
        
        let ocrResult = OCRResult(rawText: codeText, contentType: .code)
        let output = generator.generateOutput(from: ocrResult, contentType: .code)
        
        XCTAssertEqual(output.format, .markdown)
        XCTAssertTrue(output.processedText.hasPrefix("```python"), "Should detect Python language")
        XCTAssertTrue(output.processedText.contains(codeText), "Should contain original code")
    }
    
    func testUnknownLanguageCodeToMarkdown() throws {
        let codeText = """
        some_unknown_syntax {
            do_something();
        }
        """
        
        let ocrResult = OCRResult(rawText: codeText, contentType: .code)
        let output = generator.generateOutput(from: ocrResult, contentType: .code)
        
        XCTAssertEqual(output.format, .markdown)
        XCTAssertTrue(output.processedText.hasPrefix("```"), "Should use generic code block")
        XCTAssertTrue(output.processedText.contains(codeText), "Should contain original code")
    }
    
    // MARK: - Math to LaTeX Tests
    
    func testBasicMathSymbolsToLaTeX() throws {
        let mathText = "∫ x² dx = x³/3 + C"
        
        let ocrResult = OCRResult(rawText: mathText, contentType: .math)
        let output = generator.generateOutput(from: ocrResult, contentType: .math)
        
        XCTAssertEqual(output.format, .latex)
        XCTAssertTrue(output.processedText.contains("\\int"), "Should convert integral symbol")
        XCTAssertTrue(output.processedText.hasPrefix("$"), "Should wrap in math environment")
        XCTAssertTrue(output.processedText.hasSuffix("$"), "Should wrap in math environment")
    }
    
    func testGreekLettersToLaTeX() throws {
        let mathText = "α + β = γ"
        
        let ocrResult = OCRResult(rawText: mathText, contentType: .math)
        let output = generator.generateOutput(from: ocrResult, contentType: .math)
        
        XCTAssertEqual(output.format, .latex)
        XCTAssertTrue(output.processedText.contains("\\alpha"), "Should convert alpha")
        XCTAssertTrue(output.processedText.contains("\\beta"), "Should convert beta")
        XCTAssertTrue(output.processedText.contains("\\gamma"), "Should convert gamma")
    }
    
    func testMathInequalitiesToLaTeX() throws {
        let mathText = "x ≤ y ≥ z ≠ w"
        
        let ocrResult = OCRResult(rawText: mathText, contentType: .math)
        let output = generator.generateOutput(from: ocrResult, contentType: .math)
        
        XCTAssertEqual(output.format, .latex)
        XCTAssertTrue(output.processedText.contains("\\leq"), "Should convert ≤")
        XCTAssertTrue(output.processedText.contains("\\geq"), "Should convert ≥")
        XCTAssertTrue(output.processedText.contains("\\neq"), "Should convert ≠")
    }
    
    func testComplexMathToLaTeX() throws {
        let mathText = "∑ᵢ₌₁ⁿ √(xᵢ² + yᵢ²) ≈ ∫₀^∞ f(x)dx"
        
        let ocrResult = OCRResult(rawText: mathText, contentType: .math)
        let output = generator.generateOutput(from: ocrResult, contentType: .math)
        
        XCTAssertEqual(output.format, .latex)
        XCTAssertTrue(output.processedText.contains("\\sum"), "Should convert summation")
        XCTAssertTrue(output.processedText.contains("\\sqrt"), "Should convert square root")
        XCTAssertTrue(output.processedText.contains("\\int"), "Should convert integral")
        XCTAssertTrue(output.processedText.contains("\\infty"), "Should convert infinity")
    }
    
    func testPlainMathTextToLaTeX() throws {
        let mathText = "x + y = z"
        
        let ocrResult = OCRResult(rawText: mathText, contentType: .math)
        let output = generator.generateOutput(from: ocrResult, contentType: .math)
        
        XCTAssertEqual(output.format, .latex)
        // Should not wrap in math environment if no LaTeX commands
        XCTAssertEqual(output.processedText, mathText, "Plain math should remain unchanged")
    }
    
    // MARK: - Metadata Tests
    
    func testOutputMetadata() throws {
        let ocrResult = OCRResult(
            rawText: "test",
            boundingBoxes: [CGRect(x: 0, y: 0, width: 100, height: 20)],
            confidence: 0.95,
            contentType: .plainText
        )
        
        let output = generator.generateOutput(from: ocrResult, contentType: .plainText)
        
        XCTAssertEqual(output.metadata["confidence"] as? Float, 0.95, "Should preserve confidence")
        XCTAssertEqual(output.metadata["boundingBoxCount"] as? Int, 1, "Should count bounding boxes")
    }
    
    func testTableMetadata() throws {
        let tableText = "A|B|C\n1|2|3"
        let ocrResult = OCRResult(rawText: tableText, contentType: .table)
        let output = generator.generateOutput(from: ocrResult, contentType: .table)
        
        XCTAssertEqual(output.metadata["delimiter"] as? String, "|", "Should detect delimiter")
    }
    
    func testCodeMetadata() throws {
        let codeText = "function test() { return true; }"
        let ocrResult = OCRResult(rawText: codeText, contentType: .code)
        let output = generator.generateOutput(from: ocrResult, contentType: .code)
        
        XCTAssertEqual(output.metadata["language"] as? String, "javascript", "Should detect language")
    }
    
    // MARK: - Edge Cases
    
    func testEmptyInput() throws {
        let ocrResult = OCRResult(rawText: "", contentType: .plainText)
        let output = generator.generateOutput(from: ocrResult, contentType: .plainText)
        
        XCTAssertEqual(output.format, .plainText)
        XCTAssertTrue(output.processedText.isEmpty, "Empty input should produce empty output")
    }
    
    func testWhitespaceOnlyInput() throws {
        let ocrResult = OCRResult(rawText: "   \n\t  ", contentType: .plainText)
        let output = generator.generateOutput(from: ocrResult, contentType: .plainText)
        
        XCTAssertEqual(output.format, .plainText)
        XCTAssertTrue(output.processedText.isEmpty, "Whitespace-only input should be cleaned")
    }
    
    func testVeryLongInput() throws {
        let longText = String(repeating: "A|B|C\n1|2|3\n", count: 1000)
        let ocrResult = OCRResult(rawText: longText, contentType: .table)
        let output = generator.generateOutput(from: ocrResult, contentType: .table)
        
        XCTAssertEqual(output.format, .csv)
        XCTAssertFalse(output.processedText.isEmpty, "Should handle long input")
    }
    
    // MARK: - Performance Tests
    
    func testPlainTextPerformance() throws {
        let longText = String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 1000)
        let ocrResult = OCRResult(rawText: longText, contentType: .plainText)
        
        measure {
            _ = generator.generateOutput(from: ocrResult, contentType: .plainText)
        }
    }
    
    func testTableConversionPerformance() throws {
        let tableText = String(repeating: "Name|Age|City\nJohn|25|NYC\nJane|30|LA\n", count: 100)
        let ocrResult = OCRResult(rawText: tableText, contentType: .table)
        
        measure {
            _ = generator.generateOutput(from: ocrResult, contentType: .table)
        }
    }
    
    func testMathConversionPerformance() throws {
        let mathText = String(repeating: "∫ x² dx = x³/3 + C, α + β = γ, ∑ᵢ₌₁ⁿ xᵢ ", count: 100)
        let ocrResult = OCRResult(rawText: mathText, contentType: .math)
        
        measure {
            _ = generator.generateOutput(from: ocrResult, contentType: .math)
        }
    }
}