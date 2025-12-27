# App Display Mode Feature

## Overview
The App Display Mode feature allows users to choose where SnipeX appears on their Mac - in the menu bar, Dock, or both locations. This provides flexibility for different user preferences and workflows.

## Display Mode Options

### 1. Menu Bar Only (Default)
- **Description**: App appears only in the menu bar (recommended)
- **Behavior**: 
  - No Dock icon
  - Runs as an accessory app (`NSApplication.ActivationPolicy.accessory`)
  - Always accessible via menu bar icon
  - Minimal system footprint
- **Best For**: Users who prefer clean Dock and quick access

### 2. Dock Only
- **Description**: App appears only in the Dock like traditional apps
- **Behavior**:
  - Dock icon visible
  - No menu bar icon
  - Runs as regular app (`NSApplication.ActivationPolicy.regular`)
  - Access via Dock or Spotlight
- **Best For**: Users who prefer traditional app behavior

### 3. Both Menu Bar & Dock
- **Description**: App appears in both menu bar and Dock
- **Behavior**:
  - Both Dock and menu bar icons visible
  - Runs as regular app (`NSApplication.ActivationPolicy.regular`)
  - Maximum accessibility
- **Best For**: Power users who want multiple access points

## Technical Implementation

### Architecture
```
sniperApp.swift
    ↓
AppDisplayMode enum (CoreTypes.swift)
    ↓
Settings Integration (SettingsView.swift)
    ↓
MenuBarManager visibility control
    ↓
NSApplication.ActivationPolicy management
```

### Key Components

1. **AppDisplayMode Enum** (`CoreTypes.swift`)
   - Defines three display modes with properties
   - Maps to NSApplication.ActivationPolicy
   - Provides display names and descriptions

2. **Settings Integration** (`SettingsView.swift`)
   - New "App Appearance" section
   - Dropdown picker for mode selection
   - Restart notification and button
   - Real-time setting persistence

3. **App Lifecycle Management** (`sniperApp.swift`)
   - Reads display mode preference on startup
   - Configures activation policy accordingly
   - Manages menu bar icon visibility

4. **Menu Bar Control** (`MenuBarManager.swift`)
   - `hideMenuBarIcon()` and `showMenuBarIcon()` methods
   - Dynamic visibility control based on mode

### Settings Storage
- **Key**: `appDisplayMode` (String)
- **Values**: `"menuBarOnly"`, `"dockOnly"`, `"both"`
- **Default**: `"menuBarOnly"`
- **Persistence**: UserDefaults (automatic sync)

## User Experience

### Changing Display Mode
1. **Access Settings**: Menu bar → Settings or ⌘, (if in Dock mode)
2. **Navigate**: Settings → App Appearance → Display Mode
3. **Select Mode**: Choose from dropdown menu
4. **Apply Changes**: Click "Restart SnipeX Now" button
5. **Verification**: App appears in selected location(s)

### Restart Functionality
- **Automatic Restart**: Built-in restart mechanism
- **Confirmation Dialog**: Warns about unsaved work
- **Seamless Transition**: New instance launches before old one quits
- **Settings Preserved**: All preferences maintained across restart

## Code Examples

### Setting Display Mode Programmatically
```swift
// Set to Dock only
UserDefaults.standard.set(AppDisplayMode.dockOnly.rawValue, forKey: "appDisplayMode")

// Set to both locations
UserDefaults.standard.set(AppDisplayMode.both.rawValue, forKey: "appDisplayMode")
```

### Reading Current Mode
```swift
let currentMode = UserDefaults.standard.string(forKey: "appDisplayMode") ?? AppDisplayMode.menuBarOnly.rawValue
let displayMode = AppDisplayMode(rawValue: currentMode) ?? .menuBarOnly
```

### Activation Policy Mapping
```swift
switch displayMode {
case .menuBarOnly: 
    NSApp.setActivationPolicy(.accessory)  // No Dock icon
case .dockOnly, .both: 
    NSApp.setActivationPolicy(.regular)    // Show Dock icon
}
```

## Benefits

### For Users
1. **Flexibility**: Choose preferred app location
2. **Workflow Integration**: Fits different usage patterns
3. **System Cleanliness**: Option to minimize visual clutter
4. **Accessibility**: Multiple access points when needed

### For Developers
1. **User Satisfaction**: Accommodates different preferences
2. **Professional Polish**: Enterprise-grade customization
3. **System Integration**: Proper macOS app behavior
4. **Future Extensibility**: Foundation for more UI options

## Compatibility

### macOS Versions
- **Minimum**: macOS 15.7+ (current target)
- **Tested**: macOS Sequoia 15.1+
- **APIs Used**: Standard NSApplication APIs (fully compatible)

### Migration
- **Existing Users**: Automatically default to Menu Bar Only
- **New Users**: Start with recommended Menu Bar Only mode
- **Settings**: Preserved across app updates

## Testing

### Manual Testing Steps
1. **Default Behavior**: Verify Menu Bar Only on fresh install
2. **Mode Switching**: Test all three modes with restart
3. **Settings Persistence**: Verify mode survives app restart
4. **Icon Visibility**: Confirm correct icon placement
5. **Functionality**: Ensure all features work in each mode

### Automated Tests
- ✅ Settings storage and retrieval
- ✅ Display mode enumeration
- ✅ Default value handling
- ✅ Mode switching logic

## Future Enhancements

### Potential Additions
1. **Dynamic Switching**: Change modes without restart
2. **Custom Icons**: Different icons for different modes
3. **Contextual Modes**: Auto-switch based on usage patterns
4. **Workspace Integration**: Different modes per macOS Space

### User Feedback Integration
- Monitor usage patterns across modes
- Collect feedback on preferred behaviors
- Optimize default settings based on data

## Troubleshooting

### Common Issues
1. **Mode Not Applied**: Ensure app restart completed
2. **Missing Icons**: Check System Preferences permissions
3. **Settings Reset**: Verify UserDefaults persistence

### Debug Information
- Current mode: Check UserDefaults key `appDisplayMode`
- Activation policy: Verify via `NSApp.activationPolicy()`
- Menu bar state: Check `statusItem?.isVisible`

This feature significantly enhances SnipeX's flexibility and user experience by providing choice in how users interact with the application on their Mac.