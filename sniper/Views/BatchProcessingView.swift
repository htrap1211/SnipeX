//
//  BatchProcessingView.swift
//  sniper
//
//  Batch processing interface
//

import SwiftUI
import UniformTypeIdentifiers

struct BatchProcessingView: View {
    @StateObject private var batchProcessor: BatchProcessor
    @State private var showingFilePicker = false
    @State private var showingExportDialog = false
    @State private var selectedExportFormat: BatchExportFormat = .csv
    
    init(screenIntelligence: ScreenIntelligenceService) {
        _batchProcessor = StateObject(wrappedValue: BatchProcessor(screenIntelligence: screenIntelligence))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Batch Processing")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Process multiple images at once")
                    .foregroundColor(.secondary)
            }
            
            if batchProcessor.isProcessing {
                // Processing View
                processingView
            } else if batchProcessor.results.isEmpty {
                // Initial State
                initialView
            } else {
                // Results View
                resultsView
            }
            
            Spacer()
        }
        .padding(20)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                Task {
                    await batchProcessor.processFiles(urls)
                }
            case .failure(let error):
                NotificationManager.shared.showError("Failed to load files: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Views
    
    private var initialView: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.stack")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            VStack(spacing: 12) {
                Text("Select Images to Process")
                    .font(.headline)
                
                Text("Choose multiple images to extract text from all at once")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Choose Images") {
                showingFilePicker = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            // Drag and Drop Area
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentColor.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [8]))
                .frame(height: 120)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.down.doc")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Or drag images here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                )
                .onDrop(of: [.image], isTargeted: nil) { providers in
                    handleDrop(providers)
                }
        }
    }
    
    private var processingView: some View {
        VStack(spacing: 24) {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.accentColor.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: batchProcessor.progress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: batchProcessor.progress)
                
                VStack {
                    Text("\(Int(batchProcessor.progress * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(batchProcessor.currentItem)/\(batchProcessor.totalItems)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 8) {
                Text("Processing Images...")
                    .font(.headline)
                
                Text("Image \(batchProcessor.currentItem) of \(batchProcessor.totalItems)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Linear Progress Bar
            ProgressView(value: batchProcessor.progress)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(maxWidth: 300)
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 20) {
            // Summary
            HStack(spacing: 20) {
                StatCard(
                    title: "Total",
                    value: "\(batchProcessor.results.count)",
                    color: .blue
                )
                
                StatCard(
                    title: "Success",
                    value: "\(batchProcessor.results.filter { $0.success }.count)",
                    color: .green
                )
                
                StatCard(
                    title: "Failed",
                    value: "\(batchProcessor.results.filter { !$0.success }.count)",
                    color: .red
                )
            }
            
            // Actions
            HStack(spacing: 12) {
                Button("Process More") {
                    batchProcessor.results.removeAll()
                    showingFilePicker = true
                }
                .buttonStyle(.bordered)
                
                Button("Export Results") {
                    showingExportDialog = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(batchProcessor.results.isEmpty)
            }
            
            // Results List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(batchProcessor.results.enumerated()), id: \.offset) { index, result in
                        BatchResultRow(result: result)
                    }
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showingExportDialog) {
            exportDialog
        }
    }
    
    private var exportDialog: some View {
        VStack(spacing: 20) {
            Text("Export Results")
                .font(.headline)
            
            Picker("Format", selection: $selectedExportFormat) {
                ForEach(BatchExportFormat.allCases, id: \.self) { format in
                    Text(format.displayName).tag(format)
                }
            }
            .pickerStyle(.segmented)
            
            HStack {
                Button("Cancel") {
                    showingExportDialog = false
                }
                .buttonStyle(.bordered)
                
                Button("Export") {
                    exportResults()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 300)
    }
    
    // MARK: - Actions
    
    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        let urls = providers.compactMap { provider -> URL? in
            var url: URL?
            let semaphore = DispatchSemaphore(value: 0)
            
            _ = provider.loadObject(ofClass: URL.self) { loadedURL, _ in
                url = loadedURL
                semaphore.signal()
            }
            
            semaphore.wait()
            return url
        }
        
        guard !urls.isEmpty else { return false }
        
        Task {
            await batchProcessor.processFiles(urls)
        }
        
        return true
    }
    
    private func exportResults() {
        let savePanel = NSSavePanel()
        savePanel.title = "Export Batch Results"
        savePanel.nameFieldStringValue = "batch_results.\(selectedExportFormat.fileExtension)"
        savePanel.allowedContentTypes = [UTType(filenameExtension: selectedExportFormat.fileExtension)!]
        
        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else { return }
            
            do {
                try batchProcessor.exportResults(to: url, format: selectedExportFormat)
                showingExportDialog = false
            } catch {
                NotificationManager.shared.showError("Export failed: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 60)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct BatchResultRow: View {
    let result: BatchResult
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Status Icon
            Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(result.success ? .green : .red)
                .font(.title3)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Image \(result.index + 1)")
                        .font(.headline)
                    
                    Spacer()
                    
                    if let contentType = result.contentType {
                        Text(contentType.displayName)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(contentTypeColor(contentType))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                
                if let text = result.extractedText {
                    Text(text)
                        .font(.body)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                } else if let error = result.error {
                    Text("Error: \(error.localizedDescription)")
                        .font(.body)
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(8)
    }
    
    private func contentTypeColor(_ type: ContentType) -> Color {
        switch type {
        case .plainText: return .blue
        case .table: return .green
        case .code: return .purple
        case .math: return .orange
        }
    }
}

#Preview {
    BatchProcessingView(screenIntelligence: ScreenIntelligenceService())
        .frame(width: 600, height: 800)
}