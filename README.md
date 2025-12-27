# SnipeX

<div align="center">

![SnipeX Logo](https://img.shields.io/badge/SnipeX-v1.0.0-blue?style=for-the-badge&logo=apple)

**Intelligent Screen Text Extraction for macOS**

*Precision OCR with smart content detection and structured output*

[![macOS](https://img.shields.io/badge/macOS-12.3+-blue?style=flat-square&logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange?style=flat-square&logo=swift)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen?style=flat-square)](https://github.com/htrap1211/SnipeX)

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Architecture](#-architecture) • [Contributing](#-contributing)

</div>

---

## 🎯 **What is SnipeX?**

SnipeX is a powerful macOS application that revolutionizes screen text extraction. Unlike basic OCR tools, SnipeX intelligently detects content types and provides structured output formats, making it perfect for developers, researchers, and professionals who work with diverse screen content.

### **Why SnipeX?**

- 🧠 **Smart Content Detection** - Automatically identifies text, tables, code, and mathematical expressions
- ⚡ **Lightning Fast** - Press `⌘⇧2` and instantly capture any screen region
- 🔄 **Structured Output** - Converts content to appropriate formats (CSV, Markdown, LaTeX)
- 🔒 **Privacy First** - All processing happens on-device, no data leaves your Mac
- 📚 **Searchable History** - Never lose a capture with full-text search
- 🎨 **Clean Interface** - Intuitive design that stays out of your way

---

## ✨ **Features**

### **🎯 Core Capabilities**
- **Global Shortcut**: Press `⌘⇧2` to capture text from anywhere
- **Region Selection**: Precise area selection with visual feedback
- **Advanced OCR**: Apple Vision framework with image preprocessing
- **Content Classification**: Automatically detects text, tables, code, and math
- **Smart Output**: Converts content to optimal formats automatically

### **🚀 Quick Preview Window (NEW!)**
- **Review Before Copy**: Preview OCR results in a floating window before copying
- **Text Editing**: Edit extracted text directly in the preview
- **Format Selection**: Choose from multiple output formats (Plain Text, Markdown, CSV, JSON, LaTeX)
- **Export Options**: Save results to files in various formats
- **Visual Feedback**: See thumbnails and text statistics
- **Keyboard Shortcuts**: `⌘+Return` to copy, `Escape` to cancel
- **Toggle Setting**: Can be enabled/disabled in Settings (enabled by default)

### **🎛️ Flexible App Display (NEW!)**
- **Menu Bar Only**: Clean, minimal presence (default and recommended)
- **Dock Only**: Traditional app behavior for users who prefer it
- **Both Locations**: Maximum accessibility with icons in both menu bar and Dock
- **Easy Switching**: Change modes in Settings → App Appearance
- **Instant Restart**: Built-in restart functionality to apply changes
- **Smart Defaults**: Automatically chooses the best mode for new users

### **📊 Content Types & Output Formats**

| Content Type | Detection | Output Format | Example |
|--------------|-----------|---------------|---------|
| **Plain Text** | Paragraphs, sentences | Clean text | Meeting notes, articles |
| **Tables** | Delimited data | CSV format | Spreadsheet data, lists |
| **Code** | Programming syntax | Markdown blocks | Swift, Python, JavaScript |
| **Math** | Mathematical notation | LaTeX format | Equations, formulas |

### **🔧 Advanced Features**
- **Image Preprocessing**: Enhances OCR accuracy with contrast and sharpening
- **Searchable History**: Full-text search across all captures
- **Content Filtering**: Filter history by content type
- **Clipboard Integration**: Automatic clipboard copying with notifications
- **Privacy Controls**: Complete offline operation, no external connections

---

## 🚀 **Installation**

### **Requirements**
- macOS 12.3 or later
- Xcode 15.0+ (for building from source)
- Screen Recording permission
- Accessibility permission (optional, for app detection)

### **Build from Source**

1. **Clone the repository**
   ```bash
   git clone https://github.com/htrap1211/SnipeX.git
   cd SnipeX
   ```

2. **Open in Xcode**
   ```bash
   open sniper.xcodeproj
   ```

3. **Configure signing**
   - Select your development team in project settings
   - Update bundle identifier if needed

4. **Build and run**
   - Press `⌘R` to build and run
   - Grant required permissions when prompted

### **Quick Build Script**
```bash
chmod +x build.sh
./build.sh
```

---

## 📖 **Usage**

### **Getting Started**

1. **Launch SnipeX** and grant required permissions
2. **Press `⌘⇧2`** anywhere on your Mac to start capture
3. **Select region** by clicking and dragging
4. **Text is automatically** extracted, classified, and copied to clipboard
5. **View history** in the app to search and manage past captures

### **Keyboard Shortcuts**
- `⌘⇧2` - Start screen capture
- `ESC` - Cancel selection
- `⌘F` - Search history (in app)

### **Content Examples**

#### **📝 Plain Text**
```
Meeting Notes - Project Alpha
Attendees: John, Jane, Bob
Action Items:
- Complete user testing by Friday
- Review design mockups
```

#### **📊 Table → CSV**
```
Name,Age,City
John Smith,25,New York
Jane Doe,30,Boston
Bob Johnson,35,Chicago
```

#### **💻 Code → Markdown**
```swift
func processData() -> String {
    let result = "Hello World"
    return result
}
```

#### **🔢 Math → LaTeX**
```latex
$\int_0^1 x^2 dx = \frac{x^3}{3} + C$
```

---

## 🏗️ **Architecture**

### **Pipeline Overview**
```
User Shortcut → Screen Selection → Screenshot → Preprocessing → 
Content Classification → OCR → Structured Output → Clipboard + History
```

### **Key Components**

#### **🎯 Core Services**
- **`ScreenIntelligenceService`** - Main orchestration service
- **`GlobalShortcutManager`** - System-wide keyboard shortcuts
- **`ScreenSelectionWindowManager`** - Region selection interface

#### **🔍 Processing Pipeline**
- **`ImagePreprocessor`** - CoreImage-based enhancement
- **`VisionOCREngine`** - Apple Vision framework integration
- **`ContentClassifier`** - Heuristic content type detection
- **`StructuredOutputGenerator`** - Format conversion

#### **💾 Data Management**
- **`CaptureHistoryItem`** - History data model
- **`StructuredOutput`** - Processed content structure
- **`CaptureRegion`** - Screen region representation

### **Project Structure**
```
SnipeX/
├── Models/           # Data models and types
├── OCR/             # OCR engine abstraction
├── ImageProcessing/ # Image enhancement
├── Classification/  # Content type detection
├── Capture/         # Screen capture and selection
├── Output/          # Format conversion
├── Services/        # Main business logic
├── Views/           # SwiftUI interface
└── Tests/           # Automated test suite
```

---

## 🧪 **Testing**

SnipeX includes comprehensive automated tests covering all major functionality:

### **Run Tests**
```bash
# Run all automated tests
./run_tests.sh

# Run specific test suites
swift test_classification.swift
swift integration_test.swift
swift validate_app.swift
```

### **Test Coverage**
- ✅ Content classification (50+ test cases)
- ✅ Structured output generation (30+ test cases)
- ✅ OCR pipeline integration (20+ test cases)
- ✅ Performance benchmarks (10+ test cases)
- ✅ Edge cases and error handling

---

## 🔒 **Privacy & Security**

### **Privacy Guarantees**
- 🔐 **On-Device Processing** - All OCR and analysis happens locally
- 🚫 **No Network Requests** - App works completely offline
- 🗑️ **No Persistent Storage** - Screenshots processed in memory only
- 🛡️ **App Sandbox** - Runs in macOS security sandbox

### **Permissions Required**
- **Screen Recording** - Required to capture screenshots
- **Accessibility** - Optional, for detecting frontmost app

---

## 🛣️ **Roadmap**

### **v1.1 - Enhanced Intelligence**
- [ ] AI-powered text cleanup and enhancement
- [ ] Custom keyboard shortcut configuration
- [ ] Multi-language OCR improvements
- [ ] Advanced math OCR with specialized engines

### **v1.2 - Productivity Features**
- [ ] Export to files (PDF, DOCX, etc.)
- [ ] Batch processing capabilities
- [ ] Workflow automation
- [ ] Plugin system for extensibility

### **v2.0 - Advanced Features**
- [ ] Cloud sync (optional)
- [ ] Team collaboration features
- [ ] Advanced analytics and insights
- [ ] Custom content type training

---

## 🤝 **Contributing**

We welcome contributions! Here's how you can help:

### **Development Setup**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`./run_tests.sh`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### **Areas for Contribution**
- 🐛 Bug fixes and improvements
- ✨ New content type detection
- 🎨 UI/UX enhancements
- 📚 Documentation improvements
- 🧪 Additional test coverage
- 🌍 Localization support

---

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 **Acknowledgments**

- **Apple Vision Framework** - For powerful OCR capabilities
- **ScreenCaptureKit** - For modern screen capture APIs
- **SwiftUI** - For beautiful, native macOS interface
- **Open Source Community** - For inspiration and best practices

---

## 📞 **Support**

- 🐛 **Bug Reports**: [Create an issue](https://github.com/htrap1211/SnipeX/issues)
- 💡 **Feature Requests**: [Start a discussion](https://github.com/htrap1211/SnipeX/discussions)
- 📧 **Contact**: htrap1211@gmail.com

---

<div align="center">

**Made with ❤️ for the macOS community**

⭐ **Star this repo if SnipeX helps you!** ⭐

</div>