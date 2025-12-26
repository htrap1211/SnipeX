#!/usr/bin/env swift

//
//  test_classification.swift
//  Test the improved content classification
//

import Foundation

// Simulate the improved classifier
class TestContentClassifier {
    func classifyContent(text: String) -> String {
        // Code detection first (higher priority)
        if classifyByCodePatterns(text) {
            return "code"
        }
        
        // Table detection
        if classifyByTableStructure(text) {
            return "table"
        }
        
        // Math detection last (lower priority)
        if classifyByMathPatterns(text) {
            return "math"
        }
        
        return "plainText"
    }
    
    private func classifyByCodePatterns(_ text: String) -> Bool {
        let strongCodeKeywords = [
            "function", "class", "import", "export", "const", "let", "var", 
            "def", "return", "if", "else", "for", "while", "try", "catch",
            "public", "private", "protected", "static", "void", "int", "string"
        ]
        
        let strongCodeSymbols = [
            "=>", "->", "==", "!=", "&&", "||", "++", "--", "+=", "-=",
            "===", "!==", "<<", ">>", "::", "?:", "??", "?."
        ]
        
        let lowercasedText = text.lowercased()
        
        // Check for strong code keywords
        for keyword in strongCodeKeywords {
            if lowercasedText.contains(keyword) {
                return true
            }
        }
        
        // Check for strong code symbols
        for symbol in strongCodeSymbols {
            if text.contains(symbol) {
                return true
            }
        }
        
        // Check for function patterns
        let functionPatterns = [
            "func ", "function ", "def ", "() {", "() =>", "public ", "private "
        ]
        
        for pattern in functionPatterns {
            if lowercasedText.contains(pattern) {
                return true
            }
        }
        
        return false
    }
    
    private func classifyByTableStructure(_ text: String) -> Bool {
        let lines = text.components(separatedBy: .newlines)
        guard lines.count >= 2 else { return false }
        
        let delimiters = ["|", "\t", ","]
        
        for delimiter in delimiters {
            let delimiterCounts = lines.map { $0.components(separatedBy: delimiter).count - 1 }
            let nonZeroCounts = delimiterCounts.filter { $0 > 0 }
            
            if nonZeroCounts.count >= lines.count / 2 && nonZeroCounts.count >= 2 {
                return true
            }
        }
        
        return false
    }
    
    private func classifyByMathPatterns(_ text: String) -> Bool {
        // Strong math symbols
        let strongMathSymbols = ["∑", "∫", "∞", "∂", "∆", "∇"]
        
        for symbol in strongMathSymbols {
            if text.contains(symbol) {
                return true
            }
        }
        
        // Greek letters (multiple required)
        let greekLetters = ["α", "β", "γ", "δ", "π", "θ", "λ", "μ", "σ"]
        let greekCount = greekLetters.reduce(0) { count, letter in
            count + (text.contains(letter) ? 1 : 0)
        }
        
        if greekCount >= 2 {
            return true
        }
        
        // Math functions with operators
        let mathFunctions = ["sin", "cos", "tan", "log", "ln", "lim"]
        let mathOperators = ["≤", "≥", "≠", "±", "≈"]
        
        var mathIndicators = 0
        
        for function in mathFunctions {
            if text.lowercased().contains(function) {
                mathIndicators += 1
            }
        }
        
        for mathOp in mathOperators {
            if text.contains(mathOp) {
                mathIndicators += 1
            }
        }
        
        return mathIndicators >= 2
    }
}

print("🧪 Testing Improved Content Classification")
print("=========================================")
print("")

let classifier = TestContentClassifier()

// Test cases that were problematic
let testCases = [
    // Code that might be misclassified as math
    ("JavaScript with operators", "code", """
     function calculate(x, y) {
         return x + y / 2;
     }
     """),
    
    ("Swift with operators", "code", """
     func process(data: [Int]) -> Int {
         return data.reduce(0, +)
     }
     """),
    
    ("Python with math operations", "code", """
     def calculate_average(numbers):
         return sum(numbers) / len(numbers)
     """),
    
    ("Code with comparison", "code", """
     if (x >= 0 && y <= 100) {
         return x + y;
     }
     """),
    
    // Actual math expressions
    ("Pure math formula", "math", """
     ∫₀¹ x² dx = x³/3 |₀¹ = 1/3
     """),
    
    ("Greek letters math", "math", """
     α + β = γ
     where α, β ∈ ℝ
     """),
    
    ("Math functions", "math", """
     lim(x→∞) sin(x)/x = 0
     cos(π/2) = 0
     """),
    
    // Tables
    ("Simple table", "table", """
     Name | Age | City
     John | 25 | NYC
     Jane | 30 | LA
     """),
    
    // Plain text
    ("Regular text", "plainText", """
     This is just regular text with some numbers like 1/2 
     but it's not mathematical notation.
     """),
]

var passed = 0
var failed = 0

for (name, expected, text) in testCases {
    let result = classifier.classifyContent(text: text)
    if result == expected {
        print("✅ \(name): \(result)")
        passed += 1
    } else {
        print("❌ \(name): \(result) (expected \(expected))")
        failed += 1
    }
}

print("")
print("📊 Results:")
print("Passed: \(passed)")
print("Failed: \(failed)")
print("Success Rate: \(String(format: "%.1f", Double(passed) / Double(testCases.count) * 100))%")

if failed == 0 {
    print("")
    print("🎉 All tests passed! Code classification is now prioritized correctly.")
} else {
    print("")
    print("⚠️  Some tests failed. The classification logic may need further refinement.")
}