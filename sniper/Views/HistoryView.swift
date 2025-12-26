//
//  HistoryView.swift
//  sniper
//
//  Capture history with search functionality
//

import SwiftUI
import AppKit

struct HistoryView: View {
    @ObservedObject var service: ScreenIntelligenceService
    @State private var searchText = ""
    @State private var selectedContentType: ContentType?
    
    private var filteredHistory: [CaptureHistoryItem] {
        service.captureHistory.filter { item in
            let matchesSearch = searchText.isEmpty || 
                item.extractedText.localizedCaseInsensitiveContains(searchText) ||
                (item.appName?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchesType = selectedContentType == nil || item.contentType == selectedContentType
            
            return matchesSearch && matchesType
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter Bar
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search captures...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                
                // Content Type Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All",
                            isSelected: selectedContentType == nil
                        ) {
                            selectedContentType = nil
                        }
                        
                        ForEach(ContentType.allCases, id: \.self) { type in
                            FilterChip(
                                title: type.displayName,
                                isSelected: selectedContentType == type
                            ) {
                                selectedContentType = selectedContentType == type ? nil : type
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // History List
            if filteredHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text(searchText.isEmpty ? "No captures yet" : "No matches found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if searchText.isEmpty {
                        Text("Use ⌘⇧2 to capture text from your screen")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredHistory) { item in
                    HistoryItemRow(item: item) {
                        copyToClipboard(item.extractedText)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // Show brief feedback
        // Could add a toast notification here
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                .foregroundColor(isSelected ? Color.white : Color.primary)
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct HistoryItemRow: View {
    let item: CaptureHistoryItem
    let onCopy: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Thumbnail
            if let thumbnailData = item.thumbnailData,
               let nsImage = NSImage(data: thumbnailData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: contentTypeIcon(item.contentType))
                            .foregroundColor(.secondary)
                    )
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.contentType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(contentTypeColor(item.contentType))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text(item.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(item.extractedText)
                    .font(.system(.body, design: .default))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                if let appName = item.appName {
                    HStack {
                        Image(systemName: "app")
                            .font(.caption2)
                        Text(appName)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Copy Button
            HStack(spacing: 8) {
                Button(action: onCopy) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .help("Copy to clipboard")
                
                Button(action: { exportItem() }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .help("Export to file")
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    private func contentTypeIcon(_ type: ContentType) -> String {
        switch type {
        case .plainText: return "doc.text"
        case .table: return "tablecells"
        case .code: return "curlybraces"
        case .math: return "function"
        }
    }
    
    private func contentTypeColor(_ type: ContentType) -> Color {
        switch type {
        case .plainText: return .blue
        case .table: return .green
        case .code: return .purple
        case .math: return .orange
        }
    }
    
    private func exportItem() {
        // Convert history item to StructuredOutput for export
        let structuredOutput = StructuredOutput(
            contentType: item.contentType,
            rawText: item.extractedText,
            formattedText: item.extractedText, // Could be enhanced with formatting
            confidence: 0.95 // Default confidence for history items
        )
        
        let suggestedName = "Capture_\(DateFormatter.filenameSafe.string(from: item.timestamp))"
        ExportManager.shared.showExportDialog(for: structuredOutput, suggestedName: suggestedName)
    }
}

#Preview {
    HistoryView(service: ScreenIntelligenceService())
        .frame(width: 400, height: 600)
}