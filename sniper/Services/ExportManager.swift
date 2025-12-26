//
//  ExportManager.swift
//  sniper
//
//  File export functionality for captured content
//

import Foundation
import AppKit
import UniformTypeIdentifiers

class ExportManager {
    
    enum ExportFormat: String, CaseIterable {
        case txt = "txt"
        case pdf = "pdf"
        case rtf = "rtf"
        case html = "html"
        case csv = "csv"
        case json = "json"
        
        var displayName: String {
            switch self {
            case .txt: return "Plain Text (.txt)"
            case .pdf: return "PDF Document (.pdf)"
            case .rtf: return "Rich Text (.rtf)"
            case .html: return "HTML Document (.html)"
            case .csv: return "CSV Spreadsheet (.csv)"
            case .json: return "JSON Data (.json)"
            }
        }
        
        var fileExtension: String {
            return rawValue
        }
        
        var utType: UTType {
            switch self {
            case .txt: return .plainText
            case .pdf: return .pdf
            case .rtf: return .rtf
            case .html: return .html
            case .csv: return .commaSeparatedText
            case .json: return .json
            }
        }
    }
    
    static let shared = ExportManager()
    
    private init() {}
    
    // MARK: - Export Methods
    
    func exportContent(_ content: StructuredOutput, format: ExportFormat, to url: URL) throws {
        let data: Data
        
        switch format {
        case .txt:
            data = try exportAsPlainText(content)
        case .pdf:
            data = try exportAsPDF(content)
        case .rtf:
            data = try exportAsRTF(content)
        case .html:
            data = try exportAsHTML(content)
        case .csv:
            data = try exportAsCSV(content)
        case .json:
            data = try exportAsJSON(content)
        }
        
        try data.write(to: url)
    }
    
    func showExportDialog(for content: StructuredOutput, suggestedName: String = "Capture") {
        let savePanel = NSSavePanel()
        savePanel.title = "Export Capture"
        savePanel.nameFieldStringValue = suggestedName
        savePanel.canCreateDirectories = true
        savePanel.allowedContentTypes = ExportFormat.allCases.map { $0.utType }
        
        // Add format selection accessory view
        let formatSelector = NSPopUpButton()
        formatSelector.addItems(withTitles: ExportFormat.allCases.map { $0.displayName })
        
        let accessoryView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 30))
        let label = NSTextField(labelWithString: "Format:")
        label.frame = NSRect(x: 0, y: 5, width: 60, height: 20)
        formatSelector.frame = NSRect(x: 70, y: 0, width: 200, height: 30)
        
        accessoryView.addSubview(label)
        accessoryView.addSubview(formatSelector)
        savePanel.accessoryView = accessoryView
        
        // Update file extension when format changes
        formatSelector.target = savePanel
        formatSelector.action = #selector(NSSavePanel.validateVisibleColumns)
        
        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else { return }
            
            let selectedFormat = ExportFormat.allCases[formatSelector.indexOfSelectedItem]
            
            // Ensure correct file extension
            let finalURL = url.appendingPathExtension(selectedFormat.fileExtension)
            
            do {
                try self.exportContent(content, format: selectedFormat, to: finalURL)
                
                // Show success notification
                let notification = NSUserNotification()
                notification.title = "Export Successful"
                notification.informativeText = "Capture exported to \(finalURL.lastPathComponent)"
                NSUserNotificationCenter.default.deliver(notification)
                
                // Reveal in Finder
                NSWorkspace.shared.activateFileViewerSelecting([finalURL])
                
            } catch {
                // Show error alert
                let alert = NSAlert()
                alert.messageText = "Export Failed"
                alert.informativeText = error.localizedDescription
                alert.alertStyle = .warning
                alert.runModal()
            }
        }
    }
    
    // MARK: - Format-Specific Export Methods
    
    private func exportAsPlainText(_ content: StructuredOutput) throws -> Data {
        let text = content.processedText
        guard let data = text.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }
        return data
    }
    
    private func exportAsPDF(_ content: StructuredOutput) throws -> Data {
        let text = content.processedText
        
        // Create attributed string with proper formatting
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12),
            .foregroundColor: NSColor.textColor
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        
        // Create PDF data
        let pdfData = NSMutableData()
        let consumer = CGDataConsumer(data: pdfData)!
        
        var pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size
        let context = CGContext(consumer: consumer, mediaBox: &pageRect, nil)!
        
        context.beginPDFPage(nil)
        
        // Draw text
        let textRect = CGRect(x: 50, y: 50, width: 512, height: 692)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let path = CGPath(rect: textRect, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        
        CTFrameDraw(frame, context)
        
        context.endPDFPage()
        context.closePDF()
        
        return pdfData as Data
    }
    
    private func exportAsRTF(_ content: StructuredOutput) throws -> Data {
        let text = content.processedText
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12),
            .foregroundColor: NSColor.textColor
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        
        let range = NSRange(location: 0, length: attributedString.length)
        return try attributedString.data(from: range, documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtf])
    }
    
    private func exportAsHTML(_ content: StructuredOutput) throws -> Data {
        let text = content.processedText
        let escapedText = text.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\n", with: "<br>\n")
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>SnipeX Capture</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 40px; }
                pre { background: #f5f5f5; padding: 20px; border-radius: 8px; overflow-x: auto; }
            </style>
        </head>
        <body>
            <h1>SnipeX Capture</h1>
            <p><strong>Content Type:</strong> \(content.contentType.rawValue.capitalized)</p>
            <p><strong>Captured:</strong> \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))</p>
            <hr>
            <pre>\(escapedText)</pre>
        </body>
        </html>
        """
        
        guard let data = html.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }
        return data
    }
    
    private func exportAsCSV(_ content: StructuredOutput) throws -> Data {
        // For CSV, use the processed text if it's table data, otherwise create simple CSV
        let text = content.contentType == .table ? content.processedText : content.originalText
        
        guard let data = text.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }
        return data
    }
    
    private func exportAsJSON(_ content: StructuredOutput) throws -> Data {
        let exportData: [String: Any] = [
            "contentType": content.contentType.rawValue,
            "originalText": content.originalText,
            "processedText": content.processedText,
            "format": content.format.rawValue,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "metadata": [
                "exportedBy": "SnipeX",
                "version": "1.0"
            ]
        ]
        
        return try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
}

// MARK: - Export Errors

enum ExportError: LocalizedError {
    case encodingFailed
    case unsupportedFormat
    case fileWriteFailed
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode content for export"
        case .unsupportedFormat:
            return "Unsupported export format"
        case .fileWriteFailed:
            return "Failed to write file"
        }
    }
}