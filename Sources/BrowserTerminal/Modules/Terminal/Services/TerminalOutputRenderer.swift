import AppKit

class TerminalOutputRenderer {
    private let ansiParser: ANSIParser

    init(ansiParser: ANSIParser) {
        self.ansiParser = ansiParser
    }

    func render(_ output: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
        let codes = ansiParser.parse(output)

        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular),
            .foregroundColor: NSColor.white,
            .backgroundColor: NSColor.black
        ]

        for code in codes {
            switch code {
            case .text(let text):
                let attrText = NSAttributedString(string: text, attributes: defaultAttributes)
                attributedString.append(attrText)

            case .clearScreen:
                attributedString.mutableString.setString("")

            case .carriageReturn:
                attributedString.append(NSAttributedString(string: "\r", attributes: defaultAttributes))

            case .lineFeed:
                attributedString.append(NSAttributedString(string: "\n", attributes: defaultAttributes))

            case .tab:
                attributedString.append(NSAttributedString(string: "\t", attributes: defaultAttributes))

            default:
                // Handle other ANSI codes as needed
                break
            }
        }

        return attributedString
    }
}