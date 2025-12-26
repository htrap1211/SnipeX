//
//  StructuredOutputGenerator.swift
//  sniper
//
//  Generate structured output based on content type
//

import Foundation

class StructuredOutputGenerator {
    
    func generateOutput(from ocrResult: OCRResult, contentType: ContentType) -> StructuredOutput {
        let processedText: String
        let format: StructuredOutput.OutputFormat
        var metadata: [String: Any] = [:]
        
        switch contentType {
        case .plainText:
            processedText = cleanPlainText(ocrResult.rawText)
            format = .plainText
            
        case .table:
            processedText = convertToCSV(ocrResult.rawText)
            format = .csv
            metadata["delimiter"] = detectDelimiter(ocrResult.rawText)
            
        case .code:
            processedText = formatAsCode(ocrResult.rawText)
            format = .markdown
            metadata["language"] = detectProgrammingLanguage(ocrResult.rawText)
            
        case .math:
            processedText = convertToLaTeX(ocrResult.rawText)
            format = .latex
        }
        
        metadata["confidence"] = ocrResult.confidence
        metadata["boundingBoxCount"] = ocrResult.boundingBoxes.count
        
        return StructuredOutput(
            originalText: ocrResult.rawText,
            processedText: processedText,
            contentType: contentType,
            format: format,
            metadata: metadata
        )
    }
    
    // MARK: - Text Processing Methods
    
    private func cleanPlainText(_ text: String) -> String {
        return text
            .replacingOccurrences(of: #"\s*-\s*\n\s*"#, with: "", options: .regularExpression) // Remove hyphenation
            .replacingOccurrences(of: #"\n\s*\n"#, with: "\n\n", options: .regularExpression) // Normalize paragraphs
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func convertToCSV(_ text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        let delimiter = detectDelimiter(text)
        
        var csvLines: [String] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            guard !trimmedLine.isEmpty else { continue }
            
            let cells: [String]
            
            switch delimiter {
            case "|":
                cells = trimmedLine.components(separatedBy: "|")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
            case "\t":
                cells = trimmedLine.components(separatedBy: "\t")
            default:
                // Try to split by multiple spaces (common in OCR output)
                cells = trimmedLine.components(separatedBy: #"\s{2,}"#)
                    .compactMap { component in
                        let trimmed = component.trimmingCharacters(in: .whitespaces)
                        return trimmed.isEmpty ? nil : trimmed
                    }
            }
            
            // Escape CSV values that contain commas or quotes
            let escapedCells = cells.map { cell in
                if cell.contains(",") || cell.contains("\"") {
                    return "\"\(cell.replacingOccurrences(of: "\"", with: "\"\""))\""
                }
                return cell
            }
            
            csvLines.append(escapedCells.joined(separator: ","))
        }
        
        return csvLines.joined(separator: "\n")
    }
    
    private func formatAsCode(_ text: String) -> String {
        let language = detectProgrammingLanguage(text)
        return "```\(language)\n\(text)\n```"
    }
    
    private func convertToLaTeX(_ text: String) -> String {
        var latex = text
        
        // Basic math symbol conversions
        let conversions: [(String, String)] = [
            ("≤", "\\leq"),
            ("≥", "\\geq"),
            ("≠", "\\neq"),
            ("±", "\\pm"),
            ("∞", "\\infty"),
            ("∑", "\\sum"),
            ("∫", "\\int"),
            ("√", "\\sqrt"),
            ("∂", "\\partial"),
            ("∆", "\\Delta"),
            ("π", "\\pi"),
            ("θ", "\\theta"),
            ("α", "\\alpha"),
            ("β", "\\beta"),
            ("γ", "\\gamma"),
            ("λ", "\\lambda"),
            ("μ", "\\mu"),
            ("σ", "\\sigma")
        ]
        
        for (symbol, latexCode) in conversions {
            latex = latex.replacingOccurrences(of: symbol, with: latexCode)
        }
        
        // Wrap in math environment if it contains LaTeX commands
        if latex.contains("\\") {
            latex = "$\(latex)$"
        }
        
        return latex
    }
    
    // MARK: - Detection Helpers
    
    private func detectDelimiter(_ text: String) -> String {
        let delimiters = ["|", "\t", ",", ";"]
        var delimiterCounts: [String: Int] = [:]
        
        for delimiter in delimiters {
            delimiterCounts[delimiter] = text.components(separatedBy: delimiter).count - 1
        }
        
        return delimiterCounts.max(by: { $0.value < $1.value })?.key ?? " "
    }
    
    private func detectProgrammingLanguage(_ text: String) -> String {
        let lowercased = text.lowercased()
        
        // Simple language detection based on keywords
        if lowercased.contains("func ") || lowercased.contains("var ") || lowercased.contains("let ") {
            return "swift"
        } else if lowercased.contains("function ") || lowercased.contains("const ") || lowercased.contains("=>") {
            return "javascript"
        } else if lowercased.contains("def ") || lowercased.contains("import ") {
            return "python"
        } else if lowercased.contains("public class") || lowercased.contains("private ") {
            return "java"
        } else if lowercased.contains("#include") || lowercased.contains("int main") {
            return "c"
        }
        
        return "" // No specific language detected
    }
}