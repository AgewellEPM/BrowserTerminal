import AppKit

class TerminalKeyboardHandler {
    func handleKeyEvent(_ event: NSEvent, delegate: NSTextViewDelegate?) -> Bool {
        // Handle Cmd+C for interrupt
        if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "c" {
            if let textView = delegate as? NSTextView, textView.selectedRange().length == 0 {
                if let coordinator = delegate as? TerminalTextViewCoordinator {
                    coordinator.sendInput("\u{0003}") // Ctrl+C
                    return true
                }
            }
        }

        // Handle Cmd+V for paste
        if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
            if let string = NSPasteboard.general.string(forType: .string) {
                if let coordinator = delegate as? TerminalTextViewCoordinator {
                    coordinator.sendInput(string)
                    return true
                }
            }
        }

        return false
    }

    func handleControlKey(_ event: NSEvent, delegate: NSTextViewDelegate?) -> Bool {
        guard event.modifierFlags.contains(.control),
              let char = event.charactersIgnoringModifiers?.first,
              let coordinator = delegate as? TerminalTextViewCoordinator else {
            return false
        }

        let ctrlChar = ControlCharacterMapper.map(char)
        if let ctrlChar = ctrlChar {
            coordinator.sendInput(ctrlChar)
            return true
        }

        return false
    }
}