# BrowserTerminal

A native macOS application that combines a web browser and terminal emulator in a split-view interface with deep integration between both components.

## Features

- **Split View Interface**: Browser on the left, terminal on the right
- **Full Web Browser**: Based on WKWebView (Safari engine) with navigation controls
- **Terminal Emulator**: Full ANSI/VT100 support with PTY for true shell interaction
- **Multiple Sessions**: Support for multiple browser tabs and terminal sessions
- **Deep Integration**:
  - Execute terminal commands from browser JavaScript
  - Open URLs from terminal in the browser
  - Share data between browser and terminal contexts
  - Double-click on code blocks in web pages to execute in terminal

## System Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later (for building)
- Swift 5.9 or later

## Installation

### Build from Source

1. Clone or download the project
2. Navigate to the project directory:
   ```bash
   cd ~/BrowserTerminal
   ```

3. Build and run:
   ```bash
   swift build -c release
   ./.build/release/BrowserTerminal
   ```

### Quick Launch

Double-click `launch.command` in the project folder to build and run the application.

## Usage

### Browser Features

- **Navigation**: Use the toolbar buttons for back/forward/reload
- **URL Bar**: Enter URLs or search terms (automatically uses Google search for non-URLs)
- **Tabs**: Click the tab count button to switch between or create new browser tabs
- **Terminal Integration**: Press Cmd+Shift+T to send selected text to terminal

### Terminal Features

- **Multiple Sessions**: Click the + button to create new terminal sessions
- **Tab Switching**: Click on terminal tabs to switch between sessions
- **Commands**: Full shell access with your default shell (zsh/bash)
- **Keyboard Shortcuts**:
  - Cmd+C: Interrupt command (or copy if text is selected)
  - Cmd+V: Paste text
  - Cmd+T: New terminal tab
  - Cmd+Shift+T: New browser tab
  - Cmd+K: Clear terminal

### Browser-Terminal Integration

1. **From Browser to Terminal**:
   - Select text and press Cmd+Shift+T to execute in terminal
   - Double-click on code blocks (starting with $) to execute commands
   - Use JavaScript: `window.terminalBridge.execute("command")`

2. **From Terminal to Browser**:
   - URLs in terminal output can be Cmd+clicked to open in browser
   - Use the Terminal menu to send current page URL to terminal

## Architecture

The application is built with:
- **SwiftUI** for the user interface
- **WKWebView** for browser functionality
- **PTY (Pseudoterminal)** for terminal emulation
- **ANSI/VT100 parser** for terminal display
- **JavaScript bridge** for browser-terminal communication

## Project Structure

```
BrowserTerminal/
├── Sources/BrowserTerminal/
│   ├── App/                    # Application lifecycle
│   ├── Models/                 # Data models and state management
│   ├── Views/                  # UI components
│   │   ├── Browser/           # Browser-related views
│   │   └── Terminal/          # Terminal-related views
│   ├── Controllers/           # Business logic
│   └── Bridge/                # Browser-terminal integration
└── Package.swift              # Swift package configuration
```

## Development

To modify and rebuild:

1. Edit the Swift files in `Sources/BrowserTerminal/`
2. Build with: `swift build`
3. Test with: `swift test` (when tests are added)
4. Create release build: `swift build -c release`

## Known Limitations

- macOS only (not cross-platform)
- Basic ANSI/VT100 implementation (some advanced sequences may not work)
- Terminal colors are limited to standard 16-color palette
- No SSH key management (yet)

## Future Enhancements

- SSH support with key management
- Browser developer tools integration
- Terminal recording and playback
- Shared clipboard between browser and terminal
- Plugin system for custom commands
- More complete ANSI/VT100 implementation

## License

This project was created as a demonstration. Feel free to modify and use as needed.

## Troubleshooting

### Application won't start
- Ensure you're on macOS 14.0 or later
- Check that Swift is installed: `swift --version`
- Try building in debug mode first: `swift build`

### Terminal not working
- Check your default shell: `echo $SHELL`
- Ensure PTY permissions are correct
- Try resetting the terminal session (Cmd+Option+R)

### Browser issues
- Clear browser data through the app menu
- Check network connectivity
- Ensure JavaScript is enabled (it is by default)