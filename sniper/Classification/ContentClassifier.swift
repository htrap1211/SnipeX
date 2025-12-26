//
//  ContentClassifier.swift
//  sniper
//
//  Intelligent content type detection
//

import Foundation
import CoreGraphics
import Vision

class ContentClassifier {
    
    func classifyContent(text: String, image: CGImage? = nil) -> ContentType {
        // Multi-stage classification with improved priority order
        
        // 1. Code detection first (before math) - code is more specific
        if let codeType = classifyByCodePatterns(text) {
            return codeType
        }
        
        // 2. Table detection - structural patterns
        if let tableType = classifyByTableStructure(text) {
            return tableType
        }
        
        // 3. Math detection last - most general
        if let mathType = classifyByMathPatterns(text) {
            return mathType
        }
        
        // Default to plain text
        return .plainText
    }
    
    // MARK: - Code Classification (Higher Priority)
    
    private func classifyByCodePatterns(_ text: String) -> ContentType? {
        // Strong code indicators that should override math detection
        let strongCodeKeywords = [
            "function", "class", "import", "export", "const", "let", "var", 
            "def", "return", "if", "else", "for", "while", "try", "catch",
            "public", "private", "protected", "static", "void", "int", "string",
            "bool", "float", "double", "char", "struct", "enum", "interface",
            "extends", "implements", "override", "abstract", "final"
        ]
        
        let strongCodeSymbols = [
            "=>", "->", "==", "!=", "&&", "||", "++", "--", "+=", "-=", "*=", "/=",
            "===", "!==", "<<", ">>", "::", "?:", "??", "?."
        ]
        
        let lowercasedText = text.lowercased()
        
        // Check for strong code keywords
        for keyword in strongCodeKeywords {
            if lowercasedText.contains(keyword) {
                return .code
            }
        }
        
        // Check for strong code symbols
        for symbol in strongCodeSymbols {
            if text.contains(symbol) {
                return .code
            }
        }
        
        // Check for code structure patterns
        if containsCodeStructure(text) {
            return .code
        }
        
        return nil
    }
    
    private func containsCodeStructure(_ text: String) -> Bool {
        let lines = text.components(separatedBy: .newlines)
        
        // Look for function/method definitions
        let functionPatterns = [
            #"func\s+\w+\s*\("#,  // Swift: func name(
            #"function\s+\w+\s*\("#,  // JavaScript: function name(
            #"def\s+\w+\s*\("#,  // Python: def name(
            #"\w+\s*\([^)]*\)\s*\{"#,  // General: name() {
            #"public\s+\w+\s+\w+\s*\("#,  // Java: public type name(
            #"private\s+\w+\s+\w+\s*\("#  // Java: private type name(
        ]
        
        for pattern in functionPatterns {
            if text.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        
        // Look for control structures
        let controlPatterns = [
            #"if\s*\([^)]+\)\s*\{"#,  // if (condition) {
            #"for\s*\([^)]+\)\s*\{"#,  // for (init; condition; increment) {
            #"while\s*\([^)]+\)\s*\{"#,  // while (condition) {
            #"try\s*\{"#,  // try {
            #"catch\s*\([^)]*\)\s*\{"#  // catch (exception) {
        ]
        
        for pattern in controlPatterns {
            if text.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        
        // Check for indentation patterns (common in code)
        let indentedLines = lines.filter { $0.hasPrefix("    ") || $0.hasPrefix("\t") }
        let bracesCount = text.filter { $0 == "{" || $0 == "}" }.count
        
        // If >30% of lines are indented AND there are braces, likely code
        if indentedLines.count > lines.count / 3 && bracesCount >= 2 {
            return true
        }
        
        return false
    }
    
    // MARK: - Table Classification
    
    private func classifyByTableStructure(_ text: String) -> ContentType? {
        let lines = text.components(separatedBy: .newlines)
        guard lines.count >= 2 else { return nil }
        
        // Look for consistent delimiters across lines
        let delimiters = ["|", "\t", ",", ";"]
        
        for delimiter in delimiters {
            let delimiterCounts = lines.map { $0.components(separatedBy: delimiter).count - 1 }
            let nonZeroCounts = delimiterCounts.filter { $0 > 0 }
            
            // If most lines have the same number of delimiters (and > 1), it's likely a table
            if nonZeroCounts.count >= lines.count / 2 {
                guard let mostCommonCount = mostFrequent(in: nonZeroCounts) else { continue }
                let consistentLines = nonZeroCounts.filter { $0 == mostCommonCount }
                
                if consistentLines.count >= lines.count / 2 && mostCommonCount > 1 {
                    return .table
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Math Classification (Lower Priority)
    
    private func classifyByMathPatterns(_ text: String) -> ContentType? {
        // Only classify as math if it has strong mathematical indicators
        // and doesn't look like code
        
        // Strong math symbols that are unlikely to be in code
        let strongMathSymbols = ["∑", "∫", "∞", "∂", "∆", "∇", "∈", "∉", "⊂", "⊃", "∪", "∩"]
        
        for symbol in strongMathSymbols {
            if text.contains(symbol) {
                return .math
            }
        }
        
        // Greek letters in mathematical context
        let greekLetters = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "λ", "μ", "ν", "ξ", "π", "ρ", "σ", "τ", "υ", "φ", "χ", "ψ", "ω"]
        let greekCount = greekLetters.reduce(0) { count, letter in
            count + text.components(separatedBy: letter).count - 1
        }
        
        // If multiple Greek letters, likely math
        if greekCount >= 2 {
            return .math
        }
        
        // Mathematical functions and operators
        let mathFunctions = ["sin", "cos", "tan", "log", "ln", "exp", "lim", "max", "min"]
        let mathOperators = ["≤", "≥", "≠", "±", "≈", "∝", "∴", "∵"]
        
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
        
        // Look for fraction patterns like "1/2", "x/y" but not file paths
        let fractionPattern = #"\b[a-zA-Z0-9]+/[a-zA-Z0-9]+\b"#
        if let fractionRange = text.range(of: fractionPattern, options: .regularExpression) {
            let fraction = String(text[fractionRange])
            // Exclude common file extensions and paths
            if !fraction.contains(".") && !fraction.lowercased().contains("http") {
                mathIndicators += 1
            }
        }
        
        // Only classify as math if we have multiple strong indicators
        if mathIndicators >= 2 {
            return .math
        }
        
        return nil
    }
    
    // MARK: - Utilities
    
    private func mostFrequent<T: Hashable>(in array: [T]) -> T? {
        guard !array.isEmpty else { return nil }
        let counts = Dictionary(grouping: array, by: { $0 }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key
    }
}