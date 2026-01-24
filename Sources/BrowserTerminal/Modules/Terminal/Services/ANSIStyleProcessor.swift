import AppKit

struct ANSIStyleProcessor {
    static func process(mode: Int, attributes: inout ANSIParser.TextAttributes) {
        switch mode {
        case 0: // Reset
            attributes = ANSIParser.TextAttributes()

        case 1: // Bold
            attributes.bold = true

        case 3: // Italic
            attributes.italic = true

        case 4: // Underline
            attributes.underline = true

        case 7: // Inverse
            attributes.inverse = true

        case 9: // Strikethrough
            attributes.strikethrough = true

        case 22: // Normal intensity
            attributes.bold = false

        case 23: // Not italic
            attributes.italic = false

        case 24: // Not underlined
            attributes.underline = false

        case 27: // Not inverse
            attributes.inverse = false

        case 29: // Not strikethrough
            attributes.strikethrough = false

        case 30...37: // Foreground color
            attributes.foregroundColor = ANSIColorPalette.colors[mode - 30]

        case 39: // Default foreground
            attributes.foregroundColor = ANSIColorPalette.defaultForeground

        case 40...47: // Background color
            attributes.backgroundColor = ANSIColorPalette.colors[mode - 40]

        case 49: // Default background
            attributes.backgroundColor = ANSIColorPalette.defaultBackground

        case 90...97: // Bright foreground color
            attributes.foregroundColor = ANSIColorPalette.brightColors[mode - 90]

        case 100...107: // Bright background color
            attributes.backgroundColor = ANSIColorPalette.brightColors[mode - 100]

        default:
            break
        }
    }
}