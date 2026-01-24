import AppKit

class TerminalTextViewCoordinator: NSObject, NSTextViewDelegate {
    weak var session: TerminalSession?
    weak var textView: CustomTerminalTextView?
    var lastOutput = ""
    var lastRows: Int = 0
    var lastCols: Int = 0
    var inputHandler: TerminalInputHandler?
    var ansiParser: ANSIParser

    override init() {
        self.ansiParser = ANSIParser()
        super.init()
        self.inputHandler = TerminalInputHandler(coordinator: self)
    }

    func updateTerminalOutput(_ output: String) {
        guard let textView = textView else { return }
        lastOutput = output

        // Normalize control chars so interactive prompts render on one line
        let normalized = normalizeForDisplay(output)

        // Simply display the already-cleaned output
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular),
            .foregroundColor: NSColor.white,
            .backgroundColor: NSColor.black
        ]

        let attributedString = NSMutableAttributedString(string: normalized, attributes: defaultAttributes)

        // Detect and mark URLs as clickable links
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let range = NSRange(location: 0, length: (output as NSString).length)
            detector.enumerateMatches(in: output, options: [], range: range) { match, _, _ in
                guard let match = match, let url = match.url else { return }
                attributedString.addAttribute(.link, value: url, range: match.range)
            }
        }

        // Update the text
        textView.textStorage?.setAttributedString(attributedString)

        // Move cursor to end for new input
        let endRange = NSRange(location: textView.textStorage?.length ?? 0, length: 0)
        textView.setSelectedRange(endRange)
        textView.scrollToEndOfDocument(nil)
    }

    private func normalizeForDisplay(_ input: String) -> String {
        var lines: [String] = []
        var current = ""

        for scalar in input.unicodeScalars {
            switch scalar {
            case "\n":
                lines.append(current)
                current.removeAll(keepingCapacity: true)
            case "\r":
                // Carriage return: reset to start of current line
                current.removeAll(keepingCapacity: true)
            case "\u{0008}":
                // Backspace
                if !current.isEmpty { current.removeLast() }
            default:
                current.unicodeScalars.append(scalar)
            }
        }

        lines.append(current)

        // Heuristic: collapse trailing run of 1‑char lines (local typing) into one line
        var i = lines.count - 1
        var buffer = ""
        while i >= 0 {
            let s = lines[i]
            if s.count == 1, let ch = s.unicodeScalars.first, ch.value >= 0x20, ch.value != 0x7F {
                buffer = String(s) + buffer
                i -= 1
            } else {
                break
            }
        }
        if !buffer.isEmpty {
            lines.removeLast(lines.count - 1 - i)
            if lines.isEmpty {
                lines = [buffer]
            } else {
                lines[lines.count - 1] += buffer
            }
        }

        return lines.joined(separator: "\n")
    }

    func sendInput(_ text: String) {
        session?.write(text)
    }

    // MARK: - NSTextViewDelegate
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        return inputHandler?.handleCommand(commandSelector) ?? false
    }

    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
        return inputHandler?.shouldChangeText(in: affectedCharRange, replacementString: replacementString) ?? false
    }

    func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool {
        if let url = link as? URL {
            NotificationCenter.default.post(name: .openURLFromTerminal, object: nil, userInfo: ["url": url.absoluteString])
            return true
        } else if let s = link as? String, let url = URL(string: s) {
            NotificationCenter.default.post(name: .openURLFromTerminal, object: nil, userInfo: ["url": url.absoluteString])
            return true
        }
        return false
    }
}

extension Notification.Name {
    static let openURLFromTerminal = Notification.Name("openURLFromTerminal")
}
