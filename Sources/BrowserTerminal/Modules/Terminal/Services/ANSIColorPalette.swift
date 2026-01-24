import AppKit

struct ANSIColorPalette {
    static let defaultForeground = NSColor.textColor
    static let defaultBackground = NSColor.textBackgroundColor

    static let colors: [NSColor] = [
        NSColor.black,               // 0 - Black
        NSColor.systemRed,           // 1 - Red
        NSColor.systemGreen,         // 2 - Green
        NSColor.systemYellow,        // 3 - Yellow
        NSColor.systemBlue,          // 4 - Blue
        NSColor.systemPurple,        // 5 - Magenta
        NSColor.systemCyan,          // 6 - Cyan
        NSColor.white,               // 7 - White
    ]

    static let brightColors: [NSColor] = [
        NSColor.darkGray,            // 8 - Bright Black
        brighten(NSColor.systemRed),    // 9 - Bright Red
        brighten(NSColor.systemGreen),  // 10 - Bright Green
        brighten(NSColor.systemYellow), // 11 - Bright Yellow
        brighten(NSColor.systemBlue),   // 12 - Bright Blue
        brighten(NSColor.systemPurple), // 13 - Bright Magenta
        brighten(NSColor.systemCyan),   // 14 - Bright Cyan
        brighten(NSColor.white),        // 15 - Bright White
    ]

    private static func brighten(_ color: NSColor) -> NSColor {
        return color.blended(withFraction: 0.3, of: .white) ?? color
    }
}