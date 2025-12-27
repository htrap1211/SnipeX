# SnipeX v1.0 - Initial Release

## 🎉 Welcome to SnipeX!

SnipeX is a powerful screen intelligence application for macOS that extracts text from any part of your screen using advanced OCR technology.

## ✨ Key Features

### 🖱️ **Easy Screen Capture**
- Press `⌘⇧2` anywhere to start capturing
- Draw a selection rectangle around text
- Automatic text extraction and clipboard copy

### 🎯 **Smart Text Recognition**
- Advanced OCR engine with high accuracy
- Multiple language support
- Intelligent content classification
- Handles various text formats and layouts

### 🎨 **Modern User Interface**
- Clean, contemporary design
- Dynamic Island-style notifications
- Both menu bar and dock integration
- Customizable display modes

### 📱 **Dynamic Island Notifications**
- iPhone-style pill notifications
- Bottom-center positioning
- Smooth animations with green checkmark
- "Text copied to clipboard" confirmation

### 📚 **Comprehensive History**
- All captures saved with thumbnails
- Search and filter functionality
- Export to multiple formats (TXT, MD, CSV, JSON, LaTeX)
- Batch processing capabilities

### ⚙️ **Flexible Configuration**
- Menu bar only, dock only, or both modes
- Multiple OCR languages
- Customizable keyboard shortcuts
- Export format preferences

## 🚀 Installation

1. **Download**: Get `SnipeX-v1.0.dmg` from this release
2. **Install**: Open the DMG and drag SnipeX.app to Applications
3. **Launch**: Open SnipeX from Applications or Launchpad
4. **Permissions**: Grant Screen Recording permission when prompted
5. **Start Using**: Press `⌘⇧2` to capture text from anywhere!

## 🎯 How to Use

### Quick Start
1. Press `⌘⇧2` (or click the menu bar camera icon)
2. Draw a rectangle around the text you want to capture
3. Text is automatically copied to your clipboard
4. See the Dynamic Island notification confirming success

### Menu Bar Access
- Click the camera icon in your menu bar
- Access recent captures, settings, and quick capture
- Modern popover interface with gradient design

### Main Window
- Click the dock icon to open the full application
- Browse capture history with thumbnails
- Search, filter, and organize your captures
- Export individual items or batch process

## 🔧 System Requirements

- **macOS**: 15.7 or later (macOS Sequoia)
- **Architecture**: Apple Silicon (M1/M2/M3) or Intel
- **Permissions**: Screen Recording access required
- **Storage**: ~10MB for application

## 🆕 What's New in v1.0

- ✅ Complete OCR pipeline with advanced text recognition
- ✅ Dynamic Island-style notifications at bottom center
- ✅ Modern UI with gradient designs and smooth animations
- ✅ Both menu bar and dock integration
- ✅ Custom blue gradient app icon with viewfinder symbol
- ✅ Comprehensive export system (6 formats)
- ✅ Smart content classification
- ✅ Keyboard shortcut integration (`⌘⇧2`)
- ✅ Capture history with search and thumbnails
- ✅ Batch processing capabilities
- ✅ Multiple display modes (menu bar, dock, both)

## 🐛 Known Issues

- First launch may require manual permission granting in System Settings
- Icon cache refresh may be needed after installation (restart Dock if needed)

## 🔄 Troubleshooting

### Screen Recording Permission
If captures don't work:
1. Go to System Settings → Privacy & Security → Screen Recording
2. Enable SnipeX in the list
3. Restart the application

### Icon Not Showing
If the app icon appears generic:
1. Quit SnipeX completely
2. Run: `killall Dock && killall Finder`
3. Restart SnipeX

### Keyboard Shortcut Not Working
1. Check System Settings → Keyboard → Keyboard Shortcuts
2. Ensure no conflicts with `⌘⇧2`
3. Try clicking the menu bar icon instead

## 📞 Support

- **Issues**: Report bugs on GitHub Issues
- **Documentation**: Check README.md in the repository
- **Source Code**: Available on GitHub for transparency

## 🙏 Acknowledgments

Built with modern macOS technologies:
- SwiftUI for the user interface
- Vision framework for OCR
- ScreenCaptureKit for screen capture
- AppKit for system integration

---

**Enjoy using SnipeX for all your screen text extraction needs!** 🎯