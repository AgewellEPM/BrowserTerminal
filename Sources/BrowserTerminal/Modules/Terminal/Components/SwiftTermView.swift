import SwiftUI
import SwiftTerm

struct SwiftTermView: NSViewRepresentable {
    func makeNSView(context: Context) -> LocalProcessTerminalView {
        let term = LocalProcessTerminalView(frame: .zero)
        term.processDelegate = context.coordinator

        // Start the shell process
        term.startProcess(executable: ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh", args: ["-l"])

        // Ensure the view can become first responder and accepts keyboard events
        DispatchQueue.main.async {
            if let window = term.window {
                // Make the terminal the first responder to receive keyboard input
                window.makeFirstResponder(term)

                // Ensure the window itself is key and main
                window.makeKeyAndOrderFront(nil)
                window.makeMain()
            }
        }

        return term
    }

    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
        // Ensure the terminal maintains focus when the view updates
        DispatchQueue.main.async {
            if let window = nsView.window {
                if window.firstResponder != nsView {
                    window.makeFirstResponder(nsView)
                }
            }
        }
    }

    func makeCoordinator() -> SwiftTermCoordinator {
        SwiftTermCoordinator()
    }
}

final class SwiftTermCoordinator: NSObject, LocalProcessTerminalViewDelegate {
    func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {
        // No-op: SwiftTerm handles PTY resize internally
    }

    func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
        // Optionally set window title
        NSApplication.shared.keyWindow?.title = title
    }

    func hostCurrentDirectoryUpdate(source: SwiftTerm.TerminalView, directory: String?) {
        // No-op
    }

    func processTerminated(source: SwiftTerm.TerminalView, exitCode: Int32?) {
        // No-op
    }
}
