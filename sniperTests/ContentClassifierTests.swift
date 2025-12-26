//
//  ContentClassifierTests.swift
//  sniperTests
//
//  Focused tests for content classification
//

import XCTest
@testable import sniper

final class ContentClassifierTests: XCTestCase {
    
    var classifier: ContentClassifier!
    
    override func setUpWithError() throws {
        classifier = ContentClassifier()
    }
    
    override func tearDownWithError() throws {
        classifier = nil
    }
    
    // MARK: - Table Detection Tests
    
    func testPipeDelimitedTable() throws {
        let text = """
        Name | Age | City
        John | 25 | NYC
        Jane | 30 | LA
        """
        XCTAssertEqual(classifier.classifyContent(text: text), .table)
    }
    
    func testTabDelimitedTable() throws {
        let text = "Name\tAge\tCity\nJohn\t25\tNYC\nJane\t30\tLA"
        XCTAssertEqual(classifier.classifyContent(text: text), .table)
    }
    
    func testCommaDelimitedTable() throws {
        let text = """
        Name,Age,City
        John,25,NYC
        Jane,30,LA
        """
        XCTAssertEqual(classifier.classifyContent(text: text), .table)
    }
    
    func testSpaceDelimitedTable() throws {
        let text = """
        Name     Age  City
        John     25   NYC
        Jane     30   LA
        Bob      35   SF
        """
        XCTAssertEqual(classifier.classifyContent(text: text), .table)
    }
    
    func testInconsistentTableNotDetected() throws {
        let text = """
        Name | Age
        John | 25 | NYC | Extra
        Jane
        """
        // Should not be detected as table due to inconsistency
        let result = classifier.classifyContent(text: text)
        XCTAssertNotEqual(result, .table)
    }
    
    // MARK: - Code Detection Tests
    
    func testSwiftCode() throws {
        let text = """
        func calculateSum(a: Int, b: Int) -> Int {
            return a + b
        }
        """
        XCTAssertEqual(classifier.classifyContent(text: text), .code)
    }
    
    func testJavaScriptCode() throws {
        let text = """
        const calculateSum = (a, b) => {
            return a + b;
        }
        """
        XCTAssertEqual(classifier.classifyContent(text: text), .code)
    }
    
    func testPythonCode() throws {
        let text = """
        def calculate_sum(a, b):
            return a + b
        """
        XCTAssertEqual(classifier.classifyContent(text: text), .code)
    }
    
    func testJavaCode() throws {
        let text = """
        public class Calculator {
            private int result;
            
            public int add(int a, int b) {
                return a + b;
            }
        }
        """
        XCTAssertEqual(classifier.classifyContent(text: text), .code)
    }
    
    func testCCode() throws {
        let text = """
        #include <stdio.h>
        
        int main() {
            printf("Hello World");
            return 0;
        }
        """
        XCTAssertEqual(classifier.classifyContent(text: text), .code)
    }
    
    func testCodeWithBraces() throws {
        let text = "if (condition) { doSomething(); }"
        XCTAssertEqual(classifier.classifyContent(text: text), .code)
    }
    
    func testCodeWithArrows() throws {
        let text = "const func = () => { return true; }"
        XCTAssertEqual(classifier.classifyContent(text: text), .code)
    }
    
    func testIndentedCode() throws {
        let text = """
        if condition:
            print("hello")
            if nested:
                print("world")
        """
        XCTAssertEqual(classifier.classifyContent(text: text), .code)
    }
    
    // MARK: - Math Detection Tests
    
    func testBasicMathSymbols() throws {
        let text = "∫₀¹ x² dx = 1/3"
        XCTAssertEqual(classifier.classifyContent(text: text), .math)
    }
    
    func testGreekLetters() throws {
        let text = "α + β = γ, where α and β are constants"
        XCTAssertEqual(classifier.classifyContent(text: text), .math)
    }
    
    func testMathFunctions() throws {
        let text = "sin(x) + cos(x) = √2 * sin(x + π/4)"
        XCTAssertEqual(classifier.classifyContent(text: text), .math)
    }
    
    func testLimits() throws {
        let text = "lim(x→∞) 1/x = 0"
        XCTAssertEqual(classifier.classifyContent(text: text), .math)
    }
    
    func testSummation() throws {
        let text = "∑ᵢ₌₁ⁿ i = n(n+1)/2"
        XCTAssertEqual(classifier.classifyContent(text: text), .math)
    }
    
    func testInequalities() throws {
        let text = "x ≤ y and y ≥ z, therefore x ≠ z"
        XCTAssertEqual(classifier.classifyContent(text: text), .math)
    }
    
    func testFractions() throws {
        let text = "The ratio is x/y where x > 0 and y > 0"
        XCTAssertEqual(classifier.classifyContent(text: text), .math)
    }
    
    func testComplexMath() throws {
        let text = """
        ∂f/∂x = 2x + y
        ∇f = (∂f/∂x, ∂f/∂y)
        ∫∫ f(x,y) dA = ∫₀¹ ∫₀¹ f(x,y) dx dy
        """
        XCTAssertEqual(classifier.classifyContent(text: text), .math)
    }
    
    // MARK: - Plain Text Tests
    
    func testSimplePlainText() throws {
        let text = "This is just a simple sentence with no special formatting."
        XCTAssertEqual(classifier.classifyContent(text: text), .plainText)
    }
    
    func testParagraphText() throws {
        let text = """
        This is a longer paragraph of text that contains multiple sentences. 
        It should be classified as plain text because it doesn't contain 
        any special formatting, code syntax, mathematical symbols, or 
        tabular data structure.
        """
        XCTAssertEqual(classifier.classifyContent(text: text), .plainText)
    }
    
    func testTextWithNumbers() throws {
        let text = "The year 2023 was significant, with 365 days and 12 months."
        XCTAssertEqual(classifier.classifyContent(text: text), .plainText)
    }
    
    func testTextWithPunctuation() throws {
        let text = "Hello! How are you? I'm fine, thanks. What about you?"
        XCTAssertEqual(classifier.classifyContent(text: text), .plainText)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyString() throws {
        XCTAssertEqual(classifier.classifyContent(text: ""), .plainText)
    }
    
    func testWhitespaceOnly() throws {
        XCTAssertEqual(classifier.classifyContent(text: "   \n\t  "), .plainText)
    }
    
    func testSingleWord() throws {
        XCTAssertEqual(classifier.classifyContent(text: "Hello"), .plainText)
    }
    
    func testSingleCharacter() throws {
        XCTAssertEqual(classifier.classifyContent(text: "A"), .plainText)
    }
    
    func testMixedContent() throws {
        let text = """
        Here's some explanation text.
        
        function example() {
            return "code";
        }
        
        And here's a table:
        Name | Value
        A    | 1
        B    | 2
        """
        // Should classify based on most prominent content
        let result = classifier.classifyContent(text: text)
        XCTAssertTrue([.code, .table, .plainText].contains(result))
    }
    
    // MARK: - Boundary Cases
    
    func testAlmostTable() throws {
        let text = """
        This looks like it might be a table
        But it's not consistent enough
        To be classified as one
        """
        XCTAssertEqual(classifier.classifyContent(text: text), .plainText)
    }
    
    func testAlmostCode() throws {
        let text = "I mentioned the function keyword in this sentence."
        XCTAssertEqual(classifier.classifyContent(text: text), .plainText)
    }
    
    func testAlmostMath() throws {
        let text = "The limit of my patience is approaching zero."
        XCTAssertEqual(classifier.classifyContent(text: text), .plainText)
    }
    
    // MARK: - Performance Tests
    
    func testClassificationPerformance() throws {
        let longText = String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 1000)
        
        measure {
            _ = classifier.classifyContent(text: longText)
        }
    }
    
    func testComplexClassificationPerformance() throws {
        let complexText = """
        \(String(repeating: "function test() { return true; } ", count: 100))
        \(String(repeating: "Name | Age | City\nJohn | 25 | NYC\n", count: 100))
        \(String(repeating: "∫ x² dx = x³/3 + C ", count: 100))
        """
        
        measure {
            _ = classifier.classifyContent(text: complexText)
        }
    }
}