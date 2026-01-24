import AppKit

class CustomTerminalTextView: NSTextView {
    weak var inputHandler: TerminalInputHandler?

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func becomeFirstResponder() -> Bool {
        return true
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        // Ensure the terminal view receives keyboard focus when shown
        if let window = self.window {
            window.makeFirstResponder(self)
        }
    }

    override func keyDown(with event: NSEvent) {
        // Send all keyboard input to the terminal
        if let inputHandler = inputHandler ?? (delegate as? TerminalTextViewCoordinator)?.inputHandler {
            // Check for control keys
            if event.modifierFlags.contains(.control) {
                if let char = event.charactersIgnoringModifiers?.first {
                    let controlChar = Character(UnicodeScalar(Int(char.asciiValue ?? 0) & 0x1F)!)
                    inputHandler.sendInput(String(controlChar))
                }
                return
            }

            // Handle special keys by keyCode
            switch event.keyCode {
            case 51: // Delete/Backspace
                inputHandler.sendInput("\u{007F}")
            case 123: // Left arrow
                inputHandler.sendInput("\u{001B}[D")
            case 124: // Right arrow
                inputHandler.sendInput("\u{001B}[C")
            case 125: // Down arrow
                inputHandler.sendInput("\u{001B}[B")
            case 126: // Up arrow
                inputHandler.sendInput("\u{001B}[A")
            case 36: // Return
                // Send CR (\r) which line-disciplines commonly map to NL
                inputHandler.sendInput("\r")
            case 48: // Tab
                inputHandler.sendInput("\t")
            case 53: // Escape
                inputHandler.sendInput("\u{001B}")
            default:
                // For normal characters, use the actual characters typed
                if let characters = event.characters, !characters.isEmpty {
                    inputHandler.sendInput(characters)
                }
            }
        }
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        // Allow command shortcuts to work
        if event.modifierFlags.contains(.command) {
            return super.performKeyEquivalent(with: event)
        }
        return false
    }

    override func paste(_ sender: Any?) {
        // Send pasted text to the PTY instead of inserting locally
        if let string = NSPasteboard.general.string(forType: .string) {
            if let handler = inputHandler ?? (delegate as? TerminalTextViewCoordinator)?.inputHandler {
                handler.sendInput(string)
            }
        }
    }

    // Override text input methods to prevent local editing
    override func insertText(_ insertString: Any, replacementRange: NSRange) {
        // Don't insert text locally
    }

    override func deleteBackward(_ sender: Any?) {
        // Don't delete locally
    }
}
