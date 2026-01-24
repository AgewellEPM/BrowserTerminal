import Foundation
import AppKit

// MARK: - ANSI Control Codes
enum ANSIControlCode {
    case text(String)
    case cursorUp(Int)
    case cursorDown(Int)
    case cursorForward(Int)
    case cursorBack(Int)
    case cursorPosition(row: Int, col: Int)
    case eraseDisplay(Int)
    case eraseLine(Int)
    case setGraphicsMode([Int])
    case saveCursor
    case restoreCursor
    case clearScreen
    case bell
    case backspace
    case tab
    case lineFeed
    case carriageReturn
}

// MARK: - ANSI Parser
class ANSIParser {
    private var state: ParserState = .normal
    private var escapeBuffer = ""
    private var currentAttributes = TextAttributes()

    struct TextAttributes {
        var foregroundColor: NSColor = ANSIColorPalette.defaultForeground
        var backgroundColor: NSColor = ANSIColorPalette.defaultBackground
        var bold: Bool = false
        var italic: Bool = false
        var underline: Bool = false
        var inverse: Bool = false
        var strikethrough: Bool = false
    }

    private enum ParserState {
        case normal
        case escape
        case csi
        case osc
    }

    func parse(_ data: Data) -> [ANSIControlCode] {
        guard let string = String(data: data, encoding: .utf8) else {
            return []
        }
        return parse(string)
    }

    func parse(_ string: String) -> [ANSIControlCode] {
        var results: [ANSIControlCode] = []
        var textBuffer = ""

        for char in string {
            switch state {
            case .normal:
                if let code = processNormalCharacter(char, textBuffer: &textBuffer) {
                    results.append(code)
                }

            case .escape:
                processEscapeCharacter(char, textBuffer: &textBuffer, results: &results)

            case .csi:
                processCSICharacter(char, results: &results)

            case .osc:
                processOSCCharacter(char)
            }
        }

        if !textBuffer.isEmpty {
            results.append(.text(textBuffer))
        }

        return results
    }

    private func processNormalCharacter(_ char: Character, textBuffer: inout String) -> ANSIControlCode? {
        switch char {
        case "\u{001B}":
            if !textBuffer.isEmpty {
                let text = textBuffer
                textBuffer = ""
                state = .escape
                escapeBuffer = ""
                return .text(text)
            }
            state = .escape
            escapeBuffer = ""

        case "\u{0007}":
            if !textBuffer.isEmpty {
                let text = textBuffer
                textBuffer = ""
                return .text(text)
            }
            return .bell

        case "\u{0008}":
            if !textBuffer.isEmpty {
                let text = textBuffer
                textBuffer = ""
                return .text(text)
            }
            return .backspace

        case "\u{0009}":
            if !textBuffer.isEmpty {
                let text = textBuffer
                textBuffer = ""
                return .text(text)
            }
            return .tab

        case "\n":
            if !textBuffer.isEmpty {
                let text = textBuffer
                textBuffer = ""
                return .text(text)
            }
            return .lineFeed

        case "\r":
            if !textBuffer.isEmpty {
                let text = textBuffer
                textBuffer = ""
                return .text(text)
            }
            return .carriageReturn

        default:
            textBuffer.append(char)
        }
        return nil
    }

    private func processEscapeCharacter(_ char: Character, textBuffer: inout String, results: inout [ANSIControlCode]) {
        switch char {
        case "[":
            state = .csi
            escapeBuffer = ""

        case "]":
            state = .osc
            escapeBuffer = ""

        case "7":
            results.append(.saveCursor)
            state = .normal

        case "8":
            results.append(.restoreCursor)
            state = .normal

        case "(", ")", "*", "+":
            // Character set designations - ignore
            state = .normal

        default:
            // Unknown escape sequence - just reset
            state = .normal
        }
    }

    private func processCSICharacter(_ char: Character, results: inout [ANSIControlCode]) {
        if char.isASCII && (char.isNumber || char == ";" || char == "?") {
            escapeBuffer.append(char)
        } else {
            if let code = parseCSI(escapeBuffer, command: char) {
                results.append(code)
            }
            state = .normal
            escapeBuffer = ""
        }
    }

    private func processOSCCharacter(_ char: Character) {
        if char == "\u{0007}" || (char == "\\" && escapeBuffer.hasSuffix("\u{001B}")) {
            state = .normal
            escapeBuffer = ""
        } else {
            escapeBuffer.append(char)
        }
    }

    private func parseCSI(_ params: String, command: Character) -> ANSIControlCode? {
        // Handle DEC private mode sequences (e.g., ?2004h for bracketed paste)
        if params.hasPrefix("?") {
            // These are mostly mode settings we can ignore for display purposes
            // Just consume them silently
            return nil
        }

        let values = params.split(separator: ";").compactMap { Int($0) }

        switch command {
        case "A": return .cursorUp(values.first ?? 1)
        case "B": return .cursorDown(values.first ?? 1)
        case "C": return .cursorForward(values.first ?? 1)
        case "D": return .cursorBack(values.first ?? 1)
        case "H", "f":
            let row = values.count > 0 ? values[0] : 1
            let col = values.count > 1 ? values[1] : 1
            return .cursorPosition(row: row, col: col)
        case "J": return .eraseDisplay(values.first ?? 0)
        case "K": return .eraseLine(values.first ?? 0)
        case "m": return .setGraphicsMode(values.isEmpty ? [0] : values)
        case "s": return .saveCursor
        case "u": return .restoreCursor
        case "h", "l": return nil  // Mode settings - ignore for now
        default: return nil
        }
    }

    func applyGraphicsMode(_ modes: [Int]) -> TextAttributes {
        for mode in modes {
            ANSIStyleProcessor.process(mode: mode, attributes: &currentAttributes)
        }
        return currentAttributes
    }
}