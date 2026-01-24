import AppKit

class TerminalInputHandler {
    weak var coordinator: TerminalTextViewCoordinator?
    var inputStartLocation = 0

    init(coordinator: TerminalTextViewCoordinator) {
        self.coordinator = coordinator
    }

    func handleCommand(_ commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(NSResponder.insertNewline(_:)):
            // Many TTY programs expect CR (\r); send CR
            sendInput("\r")
            return true

        case #selector(NSResponder.insertTab(_:)):
            sendInput("\t")
            return true

        case #selector(NSResponder.deleteBackward(_:)):
            // Send backspace character to the terminal
            sendInput("\u{007F}") // DEL character
            return true

        case #selector(NSResponder.moveUp(_:)):
            sendInput("\u{001B}[A")
            return true

        case #selector(NSResponder.moveDown(_:)):
            sendInput("\u{001B}[B")
            return true

        case #selector(NSResponder.moveLeft(_:)):
            sendInput("\u{001B}[D")
            return true

        case #selector(NSResponder.moveRight(_:)):
            sendInput("\u{001B}[C")
            return true

        default:
            return false
        }
    }

    func shouldChangeText(in affectedCharRange: NSRange, replacementString: String?) -> Bool {
        // Don't allow local text editing - just send input to PTY
        if let text = replacementString, !text.isEmpty {
            sendInput(text)
        }

        // Return false to prevent local text modification
        // The terminal display should only update from PTY output
        return false
    }

    func sendInput(_ text: String) {
        coordinator?.sendInput(text)
    }
}
